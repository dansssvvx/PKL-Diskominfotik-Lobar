from django.db.models import F
from django.utils import timezone
from rest_framework import viewsets, permissions, status, parsers
from rest_framework.response import Response
from rest_framework.decorators import action
from rest_framework_simplejwt.views import TokenObtainPairView
from .models import (
    Role, User, DestinationCategory, TourismDestination, DestinationImage,
    Facility, DestinationFacility, Culinary, Culture, Review, Wishlist,
    TravelAgency, TourPackage, Vehicle, Homestay, HomestayRoom, Booking,
    HomestayBooking, VehicleRental, AIRecommendation, Contribution,
    Notification, ActivityLog, Setting
)
from .serializers import (
    RoleSerializer, UserSerializer, DestinationCategorySerializer,
    TourismDestinationSerializer, DestinationImageSerializer, FacilitySerializer,
    CulinarySerializer, CultureSerializer, ReviewSerializer, TourPackageSerializer,
    BookingSerializer, TravelAgencySerializer, VehicleSerializer, HomestaySerializer,
    HomestayRoomSerializer, NotificationSerializer, HomestayBookingSerializer,
    VehicleRentalSerializer, AIRecommendationSerializer, ContributionSerializer,
    ActivityLogSerializer, SettingSerializer, WishlistSerializer
)
from .utils import log_activity
# ... (existing ViewSets)

class HomestayBookingViewSet(viewsets.ModelViewSet):
    queryset = HomestayBooking.objects.all()
    serializer_class = HomestayBookingSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return self.queryset.filter(user=self.request.user)

class VehicleRentalViewSet(viewsets.ModelViewSet):
    queryset = VehicleRental.objects.all()
    serializer_class = VehicleRentalSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return self.queryset.filter(user=self.request.user)
        
    def perform_create(self, serializer):
        import uuid
        vehicle = serializer.validated_data['vehicle']
        start_date = serializer.validated_data['start_date']
        end_date = serializer.validated_data['end_date']
        driver_included = serializer.validated_data.get('driver_included', False)
        
        diff = end_date - start_date
        total_days = diff.days + 1
        if total_days < 1:
            total_days = 1
            
        daily_rate = vehicle.daily_rate
        driver_rate = vehicle.driver_rate if driver_included else 0
        total_price = (daily_rate + driver_rate) * total_days
        
        rental_number = f"RNT-{uuid.uuid4().hex[:8].upper()}"
        
        serializer.save(
            user=self.request.user,
            rental_number=rental_number,
            daily_rate=daily_rate,
            driver_rate=driver_rate,
            total_price=total_price
        )

class AIRecommendationViewSet(viewsets.ModelViewSet):
    queryset = AIRecommendation.objects.all()
    serializer_class = AIRecommendationSerializer
    
    def perform_create(self, serializer):
        from .models import TourismDestination
        import json
        
        data = self.request.data
        interests = data.get('interests', [])
        travel_style = data.get('travel_style', '')
        
        # Simple heuristic: find destinations matching the requested categories/interests
        qs = TourismDestination.objects.filter(is_active=True)
        
        matches = []
        for dest in qs:
            score = 0
            if travel_style.lower() in dest.description.lower() or travel_style.lower() in dest.name.lower():
                score += 2
            for interest in interests:
                if interest.lower() in dest.category.name.lower() or interest.lower() in dest.description.lower():
                    score += 1
            if score > 0:
                matches.append((score, dest))
                
        # Sort by score descending and take top 3
        matches.sort(key=lambda x: x[0], reverse=True)
        top_destinations = matches[:3]
        
        # Format for JSON
        recommendations = []
        for _, dest in top_destinations:
            recommendations.append({
                'slug': dest.slug,
                'name': dest.name,
                'category': dest.category.name,
                'description': dest.description[:100] + '...',
                'image': dest.main_image.url if dest.main_image else None
            })
            
        # Fallback if no exact matches: just return 3 featured
        if not recommendations:
            featured = TourismDestination.objects.filter(is_active=True, is_featured=True)[:3]
            for dest in featured:
                recommendations.append({
                    'slug': dest.slug,
                    'name': dest.name,
                    'category': dest.category.name,
                    'description': dest.description[:100] + '...',
                    'image': dest.main_image.url if dest.main_image else None
                })

        user = self.request.user if self.request.user.is_authenticated else None
        serializer.save(user=user, recommendations=recommendations)

class WishlistViewSet(viewsets.ModelViewSet):
    queryset = Wishlist.objects.all()
    serializer_class = WishlistSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return self.queryset.filter(user=self.request.user).select_related('destination').order_by('-created_at')

class ContributionViewSet(viewsets.ModelViewSet):
    queryset = Contribution.objects.all()
    serializer_class = ContributionSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        status_filter = self.request.query_params.get('status')
        qs = self.queryset
        
        if not self.request.user.is_staff:
            qs = qs.filter(contributor=self.request.user)
            
        if status_filter:
            qs = qs.filter(status=status_filter)
            
        return qs.order_by('-submitted_at')

    def perform_create(self, serializer):
        serializer.save(contributor=self.request.user)

    @action(detail=True, methods=['post'])
    def approve(self, request, pk=None):
        contribution = self.get_object()
        contribution.status = 'approved'
        contribution.reviewed_by = request.user
        contribution.reviewed_at = timezone.now()
        contribution.save()
        
        log_activity(
            request, 
            action=f"Approved {contribution.type} contribution",
            entity_type="Contribution",
            entity_id=contribution.id
        )
        
        return Response({'status': 'approved'})

    @action(detail=True, methods=['post'])
    def reject(self, request, pk=None):
        contribution = self.get_object()
        contribution.status = 'rejected'
        contribution.rejection_reason = request.data.get('notes', '')
        contribution.reviewed_by = request.user
        contribution.reviewed_at = timezone.now()
        contribution.save()
        
        log_activity(
            request, 
            action=f"Rejected {contribution.type} contribution",
            entity_type="Contribution",
            entity_id=contribution.id
        )
        
        return Response({'status': 'rejected'})

class SettingViewSet(viewsets.ModelViewSet):
    queryset = Setting.objects.all()
    serializer_class = SettingSerializer

    def get_permissions(self):
        if self.action in ['list', 'retrieve']:
            return [permissions.AllowAny()]
        return [permissions.IsAdminUser()]

    def get_queryset(self):
        if self.request.user.is_staff:
            return self.queryset.all()
        return self.queryset.filter(is_public=True)

    def perform_update(self, serializer):
        serializer.save(updated_by=self.request.user)

class RoleViewSet(viewsets.ModelViewSet):
    queryset = Role.objects.all()
    serializer_class = RoleSerializer

class UserViewSet(viewsets.ModelViewSet):
    queryset = User.objects.all()
    serializer_class = UserSerializer

    def get_permissions(self):
        if self.action == 'create':
            return [permissions.AllowAny()]
        return super().get_permissions()

    def create(self, request, *args, **kwargs):
        # Ambil data dan keluarkan 'role' agar tidak divalidasi sebagai ID oleh serializer
        data = request.data.copy()
        role_name = data.pop('role', 'user')
        if isinstance(role_name, list): role_name = role_name[0]

        serializer = self.get_serializer(data=data)
        if not serializer.is_valid():
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        
        # Cari atau buat role berdasarkan nama (user/operator)
        user_role, _ = Role.objects.get_or_create(
            name=role_name, 
            defaults={'display_name': role_name.capitalize()}
        )
        
        try:
            user = User.objects.create_user(
                email=serializer.validated_data['email'],
                password=request.data.get('password'),
                fullname=serializer.validated_data['fullname'],
                phone=request.data.get('phone'),
                role=user_role
            )
            
            # Automatically create a TravelAgency profile for operators
            if role_name == 'operator':
                TravelAgency.objects.create(
                    user=user,
                    business_name=user.fullname,
                    phone=user.phone,
                    email=user.email
                )
                
            return Response(UserSerializer(user).data, status=status.HTTP_201_CREATED)
        except Exception as e:
            return Response({'detail': str(e)}, status=status.HTTP_400_BAD_REQUEST)

    @action(detail=False, methods=['get'], permission_classes=[permissions.IsAuthenticated])
    def me(self, request):
        serializer = self.get_serializer(request.user)
        return Response(serializer.data)

    @action(detail=False, methods=['post'], permission_classes=[permissions.IsAuthenticated], 
            parser_classes=[parsers.MultiPartParser, parsers.FormParser])
    def upload_photo(self, request):
        user = request.user
        if 'profile_photo' not in request.FILES:
            return Response({'detail': 'No file was submitted.'}, status=status.HTTP_400_BAD_REQUEST)
            
        try:
            photo = request.FILES['profile_photo']
            user.profile_photo = photo
            user.save()
            
            # Ambil URL relatif
            photo_url = user.profile_photo.url
            # Pastikan URL absolut untuk Frontend
            full_url = request.build_absolute_uri(photo_url)
            
            return Response({
                'detail': 'Photo updated successfully',
                'profile_photo': full_url
            }, status=status.HTTP_200_OK)
        except Exception as e:
            return Response({'detail': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

class DestinationCategoryViewSet(viewsets.ModelViewSet):
    queryset = DestinationCategory.objects.all()
    serializer_class = DestinationCategorySerializer

class TourismDestinationViewSet(viewsets.ModelViewSet):
    queryset = TourismDestination.objects.all()
    serializer_class = TourismDestinationSerializer
    lookup_field = 'slug'

    def get_queryset(self):
        qs = self.queryset
        status_filter = self.request.query_params.get('status')
        category_filter = self.request.query_params.get('category')
        search_query = self.request.query_params.get('search')

        if not self.request.user.is_staff:
            # Regular users can only see published destinations
            qs = qs.filter(status='published')
        elif status_filter:
            qs = qs.filter(status=status_filter)
            
        if category_filter:
            qs = qs.filter(category_id=category_filter)
            
        if search_query:
            qs = qs.filter(name__icontains=search_query)

        return qs.order_by('-created_at')

    def perform_create(self, serializer):
        instance = serializer.save()
        log_activity(
            self.request, 
            action="Created destination",
            entity_type="TourismDestination",
            entity_id=instance.id
        )

    def perform_update(self, serializer):
        instance = serializer.save()
        log_activity(
            self.request, 
            action="Updated destination",
            entity_type="TourismDestination",
            entity_id=instance.id
        )

    def perform_destroy(self, instance):
        dest_id = instance.id
        instance.delete()
        log_activity(
            self.request, 
            action="Deleted destination",
            entity_type="TourismDestination",
            entity_id=dest_id
        )

    def retrieve(self, request, *args, **kwargs):
        # Ambil instance berdasarkan slug
        instance = self.get_object()
        
        # Increment views_count menggunakan F() agar atomik
        TourismDestination.objects.filter(pk=instance.pk).update(views_count=F('views_count') + 1)
        
        # Refresh instance agar data terbaru (termasuk views_count yang baru di-update) terkirim ke front-end
        instance.refresh_from_db()
        
        serializer = self.get_serializer(instance)
        return Response(serializer.data)

    @action(detail=False, methods=['get'])
    def popular(self, request):
        # Ambil top 5 berdasarkan views_count
        popular_items = self.queryset.filter(status='published').order_by('-views_count')[:5]
        serializer = self.get_serializer(popular_items, many=True)
        return Response(serializer.data)

    @action(detail=False, methods=['get'])
    def featured(self, request):
        # Ambil yang statusnya published dan mungkin ada flag featured (tapi di model tidak ada, jadi ambil random atau terbaru)
        items = self.queryset.filter(status='published').order_by('-created_at')[:4]
        serializer = self.get_serializer(items, many=True)
        return Response(serializer.data)

    @action(detail=False, methods=['get'])
    def nearby(self, request):
        # Sederhana: ambil 5 random saja dulu karena perhitungan jarak butuh query spasial atau rumus Haversine
        items = self.queryset.filter(status='published')[:5]
        serializer = self.get_serializer(items, many=True)
        return Response(serializer.data)

    @action(detail=True, methods=['get', 'post'], permission_classes=[permissions.IsAuthenticatedOrReadOnly])
    def reviews(self, request, slug=None):
        destination = self.get_object()
        if request.method == 'GET':
            reviews = Review.objects.filter(destination=destination).order_by('-created_at')
            serializer = ReviewSerializer(reviews, many=True)
            return Response(serializer.data)
        
        # Cek apakah user sudah pernah mereview destinasi ini
        if Review.objects.filter(user=request.user, destination=destination).exists():
            return Response({'detail': 'You have already reviewed this destination.'}, status=status.HTTP_400_BAD_REQUEST)
            
        # Untuk POST
        serializer = ReviewSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save(user=request.user, destination=destination)
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    @action(detail=True, methods=['post'], permission_classes=[permissions.IsAuthenticated])
    def wishlist(self, request, slug=None):
        destination = self.get_object()
        wishlist_item, created = Wishlist.objects.get_or_create(
            user=request.user,
            destination=destination
        )
        
        if not created:
            wishlist_item.delete()
            return Response({'wishlisted': False}, status=status.HTTP_200_OK)
            
        return Response({'wishlisted': True}, status=status.HTTP_201_CREATED)

class CulinaryViewSet(viewsets.ModelViewSet):
    queryset = Culinary.objects.all()
    serializer_class = CulinarySerializer

    def perform_create(self, serializer):
        instance = serializer.save()
        log_activity(
            self.request,
            action="Created culinary",
            entity_type="Culinary",
            entity_id=instance.id,
            new_value={"name": instance.name}
        )

    def perform_update(self, serializer):
        instance = serializer.save()
        log_activity(
            self.request,
            action="Updated culinary",
            entity_type="Culinary",
            entity_id=instance.id,
            new_value={"name": instance.name}
        )

    def perform_destroy(self, instance):
        item_id = instance.id
        item_name = instance.name
        instance.delete()
        log_activity(
            self.request,
            action="Deleted culinary",
            entity_type="Culinary",
            entity_id=item_id,
            old_value={"name": item_name}
        )

    def get_queryset(self):
        qs = self.queryset
        search = self.request.query_params.get('search')
        if search:
            qs = qs.filter(name__icontains=search)
        return qs.order_by('-created_at')

    @action(detail=False, methods=['get'])
    def featured(self, request):
        items = self.queryset.filter(is_verified=True)[:4]
        serializer = self.get_serializer(items, many=True)
        return Response(serializer.data)

class CultureViewSet(viewsets.ModelViewSet):
    queryset = Culture.objects.all()
    serializer_class = CultureSerializer

    def get_queryset(self):
        qs = self.queryset
        status_filter = self.request.query_params.get('status')
        search = self.request.query_params.get('search')
        
        if not self.request.user.is_staff:
            qs = qs.filter(status='published')
        elif status_filter:
            qs = qs.filter(status=status_filter)
            
        if search:
            qs = qs.filter(name__icontains=search)
            
        return qs.order_by('-created_at')

    @action(detail=False, methods=['get'])
    def featured(self, request):
        items = self.queryset.filter(status='published')[:4]
        serializer = self.get_serializer(items, many=True)
        return Response(serializer.data)

class ReviewViewSet(viewsets.ModelViewSet):
    queryset = Review.objects.all()
    serializer_class = ReviewSerializer

class TourPackageViewSet(viewsets.ModelViewSet):
    queryset = TourPackage.objects.all()
    serializer_class = TourPackageSerializer
    lookup_field = 'slug'

    def perform_create(self, serializer):
        """Auto-assign agency from the authenticated operator."""
        user = self.request.user
        if user.is_authenticated and not user.is_staff:
            try:
                agency = TravelAgency.objects.get(user=user)
                serializer.save(agency=agency)
                return
            except TravelAgency.DoesNotExist:
                pass
        serializer.save()

    def get_queryset(self):
        qs = self.queryset
        user = self.request.user
        search = self.request.query_params.get('search')
        is_active = self.request.query_params.get('is_active')

        # If authenticated operator (non-admin): scope to their agency only
        if user.is_authenticated and not user.is_staff:
            try:
                agency = TravelAgency.objects.get(user=user)
                qs = qs.filter(agency=agency)
            except TravelAgency.DoesNotExist:
                qs = qs.none()
        else:
            # Admin can filter by explicit agency param
            agency_id = self.request.query_params.get('agency')
            if agency_id:
                qs = qs.filter(agency_id=agency_id)

        if search:
            qs = qs.filter(name__icontains=search)
        if is_active is not None:
            qs = qs.filter(is_active=(is_active.lower() == 'true'))

        return qs.order_by('-created_at')

    @action(detail=False, methods=['get'])
    def featured(self, request):
        featured_items = self.queryset.filter(is_active=True, is_featured=True)[:4]
        serializer = self.get_serializer(featured_items, many=True)
        return Response(serializer.data)

class BookingViewSet(viewsets.ModelViewSet):
    queryset = Booking.objects.all()
    serializer_class = BookingSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return self.queryset.filter(user=self.request.user)

    def perform_create(self, serializer):
        import uuid
        from datetime import timedelta
        package = serializer.validated_data['package']
        start_date = serializer.validated_data['start_date']
        total_person = serializer.validated_data['total_person']
        
        end_date = start_date + timedelta(days=package.duration_days)
        
        from decimal import Decimal
        price = package.price_per_person
        if package.discount_percentage and package.discount_percentage > 0:
            price = price - (price * (package.discount_percentage / Decimal('100.0')))
            
        total_price = price * total_person
        booking_number = f"BKG-{uuid.uuid4().hex[:8].upper()}"
        
        serializer.save(
            user=self.request.user,
            booking_number=booking_number,
            end_date=end_date,
            total_price=total_price
        )

    @action(detail=True, methods=['post'])
    def cancel(self, request, pk=None):
        booking = self.get_object()
        reason = request.data.get('reason', '')
        booking.status = 'cancelled'
        booking.cancelled_reason = reason
        booking.cancelled_at = timezone.now()
        booking.save()
        return Response({'detail': 'Booking cancelled successfully'})

    @action(detail=True, methods=['post'], parser_classes=[parsers.MultiPartParser, parsers.FormParser])
    def upload_proof(self, request, pk=None):
        booking = self.get_object()
        if 'payment_proof' not in request.FILES:
            return Response({'detail': 'No file submitted'}, status=status.HTTP_400_BAD_REQUEST)
        
        booking.payment_proof = request.FILES['payment_proof']
        booking.payment_status = 'pending' # Wait for admin to verify
        booking.save()
        return Response({'detail': 'Payment proof uploaded successfully'})

class TravelAgencyViewSet(viewsets.ModelViewSet):
    queryset = TravelAgency.objects.all()
    serializer_class = TravelAgencySerializer

    @action(detail=False, methods=['get', 'patch'], permission_classes=[permissions.IsAuthenticated])
    def me(self, request):
        try:
            agency = TravelAgency.objects.get(user=request.user)
        except TravelAgency.DoesNotExist:
            return Response({'detail': 'Agency profile not found'}, status=status.HTTP_404_NOT_FOUND)
            
        if request.method == 'PATCH':
            serializer = self.get_serializer(agency, data=request.data, partial=True)
            if serializer.is_valid():
                serializer.save()
                return Response(serializer.data)
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
            
        serializer = self.get_serializer(agency)
        return Response(serializer.data)

    @action(detail=False, methods=['get'], url_path='me/dashboard', permission_classes=[permissions.IsAuthenticated])
    def dashboard(self, request):
        from django.db.models import Sum
        try:
            agency = TravelAgency.objects.get(user=request.user)
        except TravelAgency.DoesNotExist:
            return Response({'detail': 'Agency profile not found'}, status=status.HTTP_404_NOT_FOUND)

        pkg_bookings = Booking.objects.filter(package__agency=agency)
        pkg_revenue = pkg_bookings.filter(payment_status='paid').aggregate(
            total=Sum('total_price')
        )['total'] or 0

        # Homestay bookings for homestays owned by this agency's user
        hs_bookings = HomestayBooking.objects.filter(room__homestay__user=request.user)
        hs_revenue = hs_bookings.filter(payment_status='paid').aggregate(
            total=Sum('total_price')
        )['total'] or 0

        veh_bookings = VehicleRental.objects.filter(vehicle__agency=agency)
        veh_revenue = veh_bookings.filter(payment_status='paid').aggregate(
            total=Sum('total_price')
        )['total'] or 0

        total_bookings = pkg_bookings.count() + hs_bookings.count() + veh_bookings.count()
        pending_bookings = (
            pkg_bookings.filter(status='pending').count() +
            hs_bookings.filter(status='pending').count() +
            veh_bookings.filter(status='pending').count()
        )

        data = {
            'total_bookings': total_bookings,
            'pending_bookings': pending_bookings,
            'total_revenue': float(pkg_revenue) + float(hs_revenue) + float(veh_revenue),
            'active_packages': TourPackage.objects.filter(agency=agency, is_active=True).count(),
            'active_vehicles': Vehicle.objects.filter(agency=agency, is_active=True).count(),
            'active_homestays': Homestay.objects.filter(user=request.user, is_active=True).count(),
        }
        return Response(data)

    @action(detail=False, methods=['get'], url_path='me/bookings', permission_classes=[permissions.IsAuthenticated])
    def me_bookings(self, request):
        """Tour package bookings for this operator's agency."""
        try:
            agency = TravelAgency.objects.get(user=request.user)
        except TravelAgency.DoesNotExist:
            return Response({'detail': 'Agency profile not found'}, status=status.HTTP_404_NOT_FOUND)

        qs = Booking.objects.filter(package__agency=agency).order_by('-created_at')
        status_filter = request.query_params.get('status')
        if status_filter:
            qs = qs.filter(status=status_filter)

        page = self.paginate_queryset(qs)
        if page is not None:
            serializer = BookingSerializer(page, many=True)
            return self.get_paginated_response(serializer.data)

        serializer = BookingSerializer(qs, many=True)
        return Response(serializer.data)

    @action(detail=False, methods=['get'], url_path='me/homestay-bookings', permission_classes=[permissions.IsAuthenticated])
    def me_homestay_bookings(self, request):
        """Homestay bookings for homestays belonging to this operator."""
        qs = HomestayBooking.objects.filter(
            room__homestay__user=request.user
        ).order_by('-created_at')
        status_filter = request.query_params.get('status')
        if status_filter:
            qs = qs.filter(status=status_filter)

        page = self.paginate_queryset(qs)
        if page is not None:
            serializer = HomestayBookingSerializer(page, many=True)
            return self.get_paginated_response(serializer.data)

        serializer = HomestayBookingSerializer(qs, many=True)
        return Response(serializer.data)

    @action(detail=False, methods=['get'], url_path='me/rentals', permission_classes=[permissions.IsAuthenticated])
    def me_rentals(self, request):
        """Vehicle rentals for vehicles belonging to this operator's agency."""
        try:
            agency = TravelAgency.objects.get(user=request.user)
        except TravelAgency.DoesNotExist:
            return Response({'detail': 'Agency profile not found'}, status=status.HTTP_404_NOT_FOUND)

        qs = VehicleRental.objects.filter(vehicle__agency=agency).order_by('-created_at')
        status_filter = request.query_params.get('status')
        if status_filter:
            qs = qs.filter(status=status_filter)

        page = self.paginate_queryset(qs)
        if page is not None:
            serializer = VehicleRentalSerializer(page, many=True)
            return self.get_paginated_response(serializer.data)

        serializer = VehicleRentalSerializer(qs, many=True)
        return Response(serializer.data)

class VehicleViewSet(viewsets.ModelViewSet):
    queryset = Vehicle.objects.all()
    serializer_class = VehicleSerializer

    def perform_create(self, serializer):
        """Auto-assign agency from the authenticated operator."""
        user = self.request.user
        agency = None
        if user.is_authenticated and not user.is_staff:
            try:
                agency = TravelAgency.objects.get(user=user)
            except TravelAgency.DoesNotExist:
                pass
        instance = serializer.save(agency=agency) if agency else serializer.save()
        log_activity(
            self.request,
            action="Created vehicle",
            entity_type="Vehicle",
            entity_id=instance.id,
            new_value={"plate_number": instance.plate_number, "model": instance.model}
        )

    def perform_update(self, serializer):
        instance = serializer.save()
        log_activity(
            self.request,
            action="Updated vehicle",
            entity_type="Vehicle",
            entity_id=instance.id,
            new_value={"plate_number": instance.plate_number, "model": instance.model}
        )

    def perform_destroy(self, instance):
        item_id = instance.id
        item_model = instance.model
        item_plate = instance.plate_number
        instance.delete()
        log_activity(
            self.request,
            action="Deleted vehicle",
            entity_type="Vehicle",
            entity_id=item_id,
            old_value={"plate_number": item_plate, "model": item_model}
        )

    def get_queryset(self):
        qs = self.queryset
        user = self.request.user
        search = self.request.query_params.get('search')
        vehicle_type = self.request.query_params.get('type')
        available = self.request.query_params.get('available')

        # If authenticated operator (non-admin): scope to their agency only
        if user.is_authenticated and not user.is_staff:
            try:
                agency = TravelAgency.objects.get(user=user)
                qs = qs.filter(agency=agency)
            except TravelAgency.DoesNotExist:
                qs = qs.none()
        else:
            agency_id = self.request.query_params.get('agency')
            if agency_id:
                qs = qs.filter(agency_id=agency_id)

        if search:
            qs = qs.filter(models.Q(model__icontains=search) | models.Q(brand__icontains=search))
        if vehicle_type:
            qs = qs.filter(type=vehicle_type)
        if available is not None:
            qs = qs.filter(is_available=(available.lower() == 'true'))
            
        return qs.order_by('-created_at')

class HomestayViewSet(viewsets.ModelViewSet):
    queryset = Homestay.objects.all()
    serializer_class = HomestaySerializer

class HomestayRoomViewSet(viewsets.ModelViewSet):
    queryset = HomestayRoom.objects.all()
    serializer_class = HomestayRoomSerializer

    @action(detail=True, methods=['get'])
    def availability(self, request, pk=None):
        # Sederhana: cek apakah ada booking yang tumpang tindih
        # Implementasi nyata butuh query ke HomestayBooking
        return Response({'available': True})

class NotificationViewSet(viewsets.ModelViewSet):
    queryset = Notification.objects.all()
    serializer_class = NotificationSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return self.queryset.filter(user=self.request.user).order_by('-created_at')

    @action(detail=False, methods=['get'], url_path='unread-count')
    def unread_count(self, request):
        count = self.get_queryset().filter(is_read=False).count()
        return Response({'count': count})

    @action(detail=False, methods=['post'])
    def mark_all_read(self, request):
        self.get_queryset().filter(is_read=False).update(is_read=True)
        return Response({'detail': 'All notifications marked as read'})

class AdminViewSet(viewsets.GenericViewSet):
    queryset = ActivityLog.objects.all()
    permission_classes = [permissions.IsAuthenticated, permissions.IsAdminUser]

    @action(detail=False, methods=['get'])
    def stats(self, request):
        from django.db.models import Sum
        
        # Calculate revenue based on the SQL schema
        # Booking has a virtual column 'final_price' in SQL, in Django we use the total_price - discount_amount
        package_revenue = Booking.objects.filter(payment_status='paid').aggregate(
            total=Sum(F('total_price') - F('discount_amount'))
        )['total'] or 0
        
        # HomestayBooking and VehicleRental use 'total_price'
        homestay_revenue = HomestayBooking.objects.filter(payment_status='paid').aggregate(
            total=Sum('total_price')
        )['total'] or 0
        
        vehicle_revenue = VehicleRental.objects.filter(payment_status='paid').aggregate(
            total=Sum('total_price')
        )['total'] or 0
        
        total_revenue = float(package_revenue) + float(homestay_revenue) + float(vehicle_revenue)

        data = {
            'total_destinations': TourismDestination.objects.count(),
            'total_users': User.objects.count(),
            'total_bookings': Booking.objects.count() + HomestayBooking.objects.count() + VehicleRental.objects.count(),
            'total_revenue': total_revenue,
            'total_vehicles': Vehicle.objects.count(),
            'pending_contributions': Contribution.objects.filter(status='pending').count(),
            'active_operators': User.objects.filter(role_id=2, is_active=True).count()
        }
        return Response(data)

    @action(detail=False, methods=['get'])
    def users(self, request):
        users = User.objects.all().order_by('-created_at')
        role = request.query_params.get('role')
        if role:
            users = users.filter(role__name=role)

        page = self.paginate_queryset(users)
        if page is not None:
            serializer = UserSerializer(page, many=True)
            return self.get_paginated_response(serializer.data)

        serializer = UserSerializer(users, many=True)
        return Response(serializer.data)

    @action(detail=True, methods=['post'], url_path='verify')
    def verify_operator(self, request, pk=None):
        try:
            user = User.objects.get(pk=pk)
            user.is_verified = True
            user.save()
            
            log_activity(
                request, 
                action="Verified operator",
                entity_type="User",
                entity_id=user.id
            )
            
            return Response({'detail': 'User operator verified successfully'})
        except User.DoesNotExist:
            return Response({'detail': 'User not found'}, status=status.HTTP_404_NOT_FOUND)

    @action(detail=True, methods=['post'], url_path='toggle-status')
    def toggle_status(self, request, pk=None):
        try:
            user = User.objects.get(pk=pk)
            user.is_active = not user.is_active
            user.save()
            
            status_str = "activated" if user.is_active else "deactivated"
            log_activity(
                request, 
                action=f"{status_str.capitalize()} user",
                entity_type="User",
                entity_id=user.id
            )
            
            return Response({
                'detail': f'User {status_str} successfully',
                'is_active': user.is_active
            })
        except User.DoesNotExist:
            return Response({'detail': 'User not found'}, status=status.HTTP_404_NOT_FOUND)

    @action(detail=False, methods=['get'])
    def bookings(self, request):
        booking_type = request.query_params.get('type', 'package')
        status_filter = request.query_params.get('status')
        
        if booking_type == 'homestay':
            queryset = HomestayBooking.objects.all().order_by('-created_at')
            serializer_class = HomestayBookingSerializer
        elif booking_type == 'vehicle':
            queryset = VehicleRental.objects.all().order_by('-created_at')
            serializer_class = VehicleRentalSerializer
        else:
            queryset = Booking.objects.all().order_by('-created_at')
            serializer_class = BookingSerializer
            
        if status_filter:
            queryset = queryset.filter(status=status_filter)
            
        page = self.paginate_queryset(queryset)
        if page is not None:
            serializer = serializer_class(page, many=True)
            return self.get_paginated_response(serializer.data)
            
        serializer = serializer_class(queryset, many=True)
        return Response(serializer.data)

    @action(detail=False, methods=['post'], url_path='bookings/update-status')
    def update_booking_status(self, request):
        booking_id = request.data.get('id')
        booking_type = request.data.get('type', 'package')
        new_status = request.data.get('status')
        new_payment_status = request.data.get('payment_status')
        
        try:
            if booking_type == 'homestay':
                booking = HomestayBooking.objects.get(pk=booking_id)
            elif booking_type == 'vehicle':
                booking = VehicleRental.objects.get(pk=booking_id)
            else:
                booking = Booking.objects.get(pk=booking_id)
                
            if new_status:
                booking.status = new_status
            if new_payment_status:
                booking.payment_status = new_payment_status
                
            booking.save()
            
            log_activity(
                request, 
                action=f"Updated {booking_type} booking status",
                entity_type=booking.__class__.__name__,
                entity_id=booking.id
            )
            
            return Response({'detail': 'Booking status updated successfully'})
        except Exception as e:
            return Response({'detail': str(e)}, status=status.HTTP_400_BAD_REQUEST)

    @action(detail=False, methods=['get'], url_path='activity-logs')
    def activity_logs(self, request):
        from rest_framework.pagination import PageNumberPagination

        logs = ActivityLog.objects.all().order_by('-created_at')
        
        date_from = request.query_params.get('date_from')
        date_to = request.query_params.get('date_to')
        
        if date_from:
            logs = logs.filter(created_at__gte=date_from)
        if date_to:
            # Append time to include the whole end day
            logs = logs.filter(created_at__lte=f"{date_to} 23:59:59")

        paginator = PageNumberPagination()
        paginator.page_size_query_param = 'page_size'
        paginator.page_size = 10 # Default page size

        page = paginator.paginate_queryset(logs, request)
        if page is not None:
            serializer = ActivityLogSerializer(page, many=True)
            return paginator.get_paginated_response(serializer.data)
        
        serializer = ActivityLogSerializer(logs, many=True)
        return Response(serializer.data)
