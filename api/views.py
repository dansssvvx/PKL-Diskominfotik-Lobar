from rest_framework import viewsets, permissions, status, parsers
from rest_framework.response import Response
from rest_framework.decorators import action
from rest_framework_simplejwt.views import TokenObtainPairView
from .models import (
    Role, User, DestinationCategory, TourismDestination, DestinationImage,
    Facility, DestinationFacility, Culinary, Culture, Review, Wishlist,
    TravelAgency, TourPackage, Vehicle, Homestay, HomestayRoom, Booking,
    Notification
)
from .serializers import (
    RoleSerializer, UserSerializer, DestinationCategorySerializer,
    TourismDestinationSerializer, DestinationImageSerializer, FacilitySerializer,
    CulinarySerializer, CultureSerializer, ReviewSerializer, TourPackageSerializer,
    BookingSerializer, TravelAgencySerializer, VehicleSerializer, HomestaySerializer,
    HomestayRoomSerializer, NotificationSerializer
)

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

    @action(detail=False, methods=['get'])
    def popular(self, request):
        # Ambil top 5 berdasarkan views_count
        popular_items = self.queryset.filter(status='published').order_by('-views_count')[:5]
        serializer = self.get_serializer(popular_items, many=True)
        return Response(serializer.data)

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

class TravelAgencyViewSet(viewsets.ModelViewSet):
    queryset = TravelAgency.objects.all()
    serializer_class = TravelAgencySerializer

class VehicleViewSet(viewsets.ModelViewSet):
    queryset = Vehicle.objects.all()
    serializer_class = VehicleSerializer

class HomestayViewSet(viewsets.ModelViewSet):
    queryset = Homestay.objects.all()
    serializer_class = HomestaySerializer

class HomestayRoomViewSet(viewsets.ModelViewSet):
    queryset = HomestayRoom.objects.all()
    serializer_class = HomestayRoomSerializer

class NotificationViewSet(viewsets.ModelViewSet):
    queryset = Notification.objects.all()
    serializer_class = NotificationSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return self.queryset.filter(user=self.request.user).order_by('-created_at')

    @action(detail=False, methods=['get'])
    def unread_count(self, request):
        count = self.get_queryset().filter(is_read=False).count()
        return Response({'count': count})

    @action(detail=False, methods=['post'])
    def mark_all_read(self, request):
        self.get_queryset().filter(is_read=False).update(is_read=True)
        return Response({'detail': 'All notifications marked as read'})
