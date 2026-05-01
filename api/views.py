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
    Notification
)
from .serializers import (
    RoleSerializer, UserSerializer, DestinationCategorySerializer,
    TourismDestinationSerializer, DestinationImageSerializer, FacilitySerializer,
    CulinarySerializer, CultureSerializer, ReviewSerializer, TourPackageSerializer,
    BookingSerializer, TravelAgencySerializer, VehicleSerializer, HomestaySerializer,
    HomestayRoomSerializer, NotificationSerializer, HomestayBookingSerializer,
    VehicleRentalSerializer, AIRecommendationSerializer, ContributionSerializer
)

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

class AIRecommendationViewSet(viewsets.ModelViewSet):
    queryset = AIRecommendation.objects.all()
    serializer_class = AIRecommendationSerializer
    
    def perform_create(self, serializer):
        if self.request.user.is_authenticated:
            serializer.save(user=self.request.user)
        else:
            serializer.save()

class ContributionViewSet(viewsets.ModelViewSet):
    queryset = Contribution.objects.all()
    serializer_class = ContributionSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        if self.request.user.is_staff:
            return self.queryset.all()
        return self.queryset.filter(contributor=self.request.user)

    def perform_create(self, serializer):
        serializer.save(contributor=self.request.user)

    @action(detail=True, methods=['post'])
    def approve(self, request, pk=None):
        contribution = self.get_object()
        contribution.status = 'approved'
        contribution.reviewed_by = request.user
        contribution.reviewed_at = timezone.now()
        contribution.save()
        return Response({'status': 'approved'})

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

    @action(detail=False, methods=['get'])
    def featured(self, request):
        items = self.queryset.filter(is_verified=True)[:4]
        serializer = self.get_serializer(items, many=True)
        return Response(serializer.data)

class CultureViewSet(viewsets.ModelViewSet):
    queryset = Culture.objects.all()
    serializer_class = CultureSerializer

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
        try:
            agency = TravelAgency.objects.get(user=request.user)
        except TravelAgency.DoesNotExist:
            return Response({'detail': 'Agency profile not found'}, status=status.HTTP_404_NOT_FOUND)
            
        # Dummy stats for now
        data = {
            'total_bookings': Booking.objects.filter(package__agency=agency).count(),
            'pending_bookings': Booking.objects.filter(package__agency=agency, status='pending').count(),
            'total_revenue': 0, # Should calculate from paid bookings
            'active_packages': TourPackage.objects.filter(agency=agency, is_active=True).count(),
            'active_vehicles': Vehicle.objects.filter(agency=agency, is_active=True).count(),
            'active_homestays': 0 # Homestays are linked to owners (User), not Agency in current model?
        }
        return Response(data)

class VehicleViewSet(viewsets.ModelViewSet):
    queryset = Vehicle.objects.all()
    serializer_class = VehicleSerializer

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

class AdminViewSet(viewsets.ViewSet):
    permission_classes = [permissions.IsAuthenticated, permissions.IsAdminUser]

    @action(detail=False, methods=['get'])
    def stats(self, request):
        data = {
            'total_destinations': TourismDestination.objects.count(),
            'total_users': User.objects.count(),
            'total_bookings': Booking.objects.count(),
            'total_revenue': 0, # Placeholder
            'pending_contributions': Contribution.objects.filter(status='pending').count(),
            'active_operators': User.objects.filter(role__name='operator').count()
        }
        return Response(data)

    @action(detail=False, methods=['get'])
    def users(self, request):
        users = User.objects.all()
        serializer = UserSerializer(users, many=True)
        return Response(serializer.data)

    @action(detail=False, methods=['get'], url_path='activity-logs')
    def activity_logs(self, request):
        # ActivityLog model exists but no data or serializer needed for now
        return Response([])
