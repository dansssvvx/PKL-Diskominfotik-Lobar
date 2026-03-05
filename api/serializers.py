from rest_framework import serializers
from .models import (
    Role, User, DestinationCategory, TourismDestination, DestinationImage,
    Facility, DestinationFacility, Culinary, Culture, Review, Wishlist,
    TravelAgency, TourPackage, PackageDestination, PackageItinerary,
    PackageInclusion, Vehicle, Homestay, HomestayRoom, Booking,
    HomestayBooking, VehicleRental, AIRecommendation, Contribution,
    ActivityLog, Setting, Notification
)

class RoleSerializer(serializers.ModelSerializer):
    class Meta:
        model = Role
        fields = '__all__'

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ('id', 'email', 'password', 'fullname', 'phone', 'role', 'profile_photo', 'is_verified', 'is_active', 'created_at')
        extra_kwargs = {
            'password': {'write_only': True},
            'role': {'required': False, 'allow_null': True},
            'profile_photo': {'read_only': True}
        }

class DestinationCategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = DestinationCategory
        fields = '__all__'

class DestinationImageSerializer(serializers.ModelSerializer):
    class Meta:
        model = DestinationImage
        fields = '__all__'

class TourismDestinationSerializer(serializers.ModelSerializer):
    category_name = serializers.ReadOnlyField(source='category.name')
    images = DestinationImageSerializer(many=True, read_only=True)
    
    class Meta:
        model = TourismDestination
        fields = '__all__'

class FacilitySerializer(serializers.ModelSerializer):
    class Meta:
        model = Facility
        fields = '__all__'

class CulinarySerializer(serializers.ModelSerializer):
    class Meta:
        model = Culinary
        fields = '__all__'

class CultureSerializer(serializers.ModelSerializer):
    class Meta:
        model = Culture
        fields = '__all__'

class ReviewSerializer(serializers.ModelSerializer):
    user_name = serializers.ReadOnlyField(source='user.fullname')
    class Meta:
        model = Review
        fields = '__all__'

class TourPackageSerializer(serializers.ModelSerializer):
    agency_name = serializers.ReadOnlyField(source='agency.business_name')
    class Meta:
        model = TourPackage
        fields = '__all__'

class BookingSerializer(serializers.ModelSerializer):
    package_name = serializers.ReadOnlyField(source='package.name')
    user_name = serializers.ReadOnlyField(source='user.fullname')
    class Meta:
        model = Booking
        fields = '__all__'

class TravelAgencySerializer(serializers.ModelSerializer):
    class Meta:
        model = TravelAgency
        fields = '__all__'

class VehicleSerializer(serializers.ModelSerializer):
    class Meta:
        model = Vehicle
        fields = '__all__'

class HomestaySerializer(serializers.ModelSerializer):
    class Meta:
        model = Homestay
        fields = '__all__'

class HomestayRoomSerializer(serializers.ModelSerializer):
    class Meta:
        model = HomestayRoom
        fields = '__all__'

class NotificationSerializer(serializers.ModelSerializer):
    class Meta:
        model = Notification
        fields = '__all__'
