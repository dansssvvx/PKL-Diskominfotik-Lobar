from django.db.models import Avg, Count
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

class TravelAgencySerializer(serializers.ModelSerializer):
    package_count = serializers.IntegerField(source='packages.count', read_only=True)
    vehicle_count = serializers.IntegerField(source='vehicles.count', read_only=True)
    class Meta:
        model = TravelAgency
        fields = '__all__'

class UserSerializer(serializers.ModelSerializer):
    role_name = serializers.ReadOnlyField(source='role.name')
    agency_profile = TravelAgencySerializer(source='travelagency', read_only=True)
    class Meta:
        model = User
        fields = ('id', 'email', 'password', 'fullname', 'phone', 'role', 'role_name', 'profile_photo', 'is_verified', 'is_active', 'created_at', 'agency_profile')
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

class FacilitySerializer(serializers.ModelSerializer):
    class Meta:
        model = Facility
        fields = '__all__'

class CulinarySerializer(serializers.ModelSerializer):
    class Meta:
        model = Culinary
        fields = '__all__'

class ReviewSerializer(serializers.ModelSerializer):
    user_details = UserSerializer(source='user', read_only=True)
    class Meta:
        model = Review
        fields = '__all__'
        extra_kwargs = {
            'user': {'read_only': True},
            'destination': {'read_only': True}
        }

class TourismDestinationSerializer(serializers.ModelSerializer):
    category_name = serializers.ReadOnlyField(source='category.name')
    images = DestinationImageSerializer(many=True, read_only=True)
    reviews = ReviewSerializer(many=True, read_only=True)
    culinaries = CulinarySerializer(many=True, read_only=True)
    avg_rating = serializers.SerializerMethodField()
    review_count = serializers.SerializerMethodField()
    
    class Meta:
        model = TourismDestination
        fields = '__all__'

    def get_avg_rating(self, obj):
        result = obj.reviews.aggregate(Avg('rating'))['rating__avg']
        return round(result, 1) if result is not None else 0

    def get_review_count(self, obj):
        return obj.reviews.count()

class CultureSerializer(serializers.ModelSerializer):
    class Meta:
        model = Culture
        fields = '__all__'

class PackageDestinationSerializer(serializers.ModelSerializer):
    destination_name = serializers.ReadOnlyField(source='destination.name')
    destination_slug = serializers.ReadOnlyField(source='destination.slug')
    main_image = serializers.ReadOnlyField(source='destination.main_image')
    class Meta:
        model = PackageDestination
        fields = '__all__'

class PackageItinerarySerializer(serializers.ModelSerializer):
    class Meta:
        model = PackageItinerary
        fields = '__all__'

class PackageInclusionSerializer(serializers.ModelSerializer):
    class Meta:
        model = PackageInclusion
        fields = '__all__'

class TourPackageSerializer(serializers.ModelSerializer):
    agency_name = serializers.ReadOnlyField(source='agency.business_name')
    destinations = PackageDestinationSerializer(source='package_destinations', many=True, read_only=True)
    itineraries = PackageItinerarySerializer(many=True, read_only=True)
    inclusions = PackageInclusionSerializer(source='package_inclusions', many=True, read_only=True)
    
    class Meta:
        model = TourPackage
        fields = '__all__'
        extra_kwargs = {
            'agency': {'required': False, 'allow_null': True},
            'main_image': {'required': False, 'allow_null': True},
        }

class BookingSerializer(serializers.ModelSerializer):
    package_name = serializers.ReadOnlyField(source='package.name')
    user_name = serializers.ReadOnlyField(source='user.fullname')
    user_email = serializers.ReadOnlyField(source='user.email')
    agency_name = serializers.ReadOnlyField(source='package.agency.business_name')
    booking_number = serializers.CharField(read_only=True)
    end_date = serializers.DateField(read_only=True)
    total_price = serializers.DecimalField(max_digits=10, decimal_places=2, read_only=True)
    class Meta:
        model = Booking
        fields = '__all__'
        read_only_fields = ['user', 'status', 'payment_status', 'payment_proof']

class VehicleSerializer(serializers.ModelSerializer):
    agency_name = serializers.ReadOnlyField(source='agency.business_name')
    class Meta:
        model = Vehicle
        fields = '__all__'
        extra_kwargs = {
            'agency': {'required': False, 'allow_null': True, 'read_only': False},
            'image': {'required': False, 'allow_null': True},
        }

class HomestaySerializer(serializers.ModelSerializer):
    owner_name = serializers.ReadOnlyField(source='owner.fullname')
    starting_price = serializers.SerializerMethodField()
    rooms = serializers.SerializerMethodField()
    price_per_night = serializers.DecimalField(max_digits=10, decimal_places=2, write_only=True, required=False)

    class Meta:
        model = Homestay
        fields = '__all__'
        extra_kwargs = {
            'owner': {'required': False, 'allow_null': True},
            'main_image': {'required': False, 'allow_null': True},
        }

    def get_starting_price(self, obj):
        from django.db.models import Min
        min_price = obj.rooms.aggregate(Min('price_per_night'))['price_per_night__min']
        return min_price or 0

    def get_rooms(self, obj):
        return HomestayRoomSerializer(obj.rooms.all(), many=True).data

class HomestayRoomSerializer(serializers.ModelSerializer):
    homestay_name = serializers.ReadOnlyField(source='homestay.name')
    class Meta:
        model = HomestayRoom
        fields = '__all__'

class NotificationSerializer(serializers.ModelSerializer):
    class Meta:
        model = Notification
        fields = '__all__'

class ActivityLogSerializer(serializers.ModelSerializer):
    user_fullname = serializers.ReadOnlyField(source='user.fullname')
    class Meta:
        model = ActivityLog
        fields = '__all__'

class HomestayBookingSerializer(serializers.ModelSerializer):
    room_name = serializers.ReadOnlyField(source='room.room_type')
    homestay_name = serializers.ReadOnlyField(source='room.homestay.name')
    user_name = serializers.ReadOnlyField(source='user.fullname')
    class Meta:
        model = HomestayBooking
        fields = '__all__'
        read_only_fields = ('booking_number', 'user', 'total_price', 'status', 'payment_status', 'payment_proof', 'notes')

class VehicleRentalSerializer(serializers.ModelSerializer):
    vehicle_name = serializers.ReadOnlyField(source='vehicle.model')
    vehicle_brand = serializers.ReadOnlyField(source='vehicle.brand')
    agency_name = serializers.ReadOnlyField(source='vehicle.agency.business_name')
    user_name = serializers.ReadOnlyField(source='user.fullname')
    user_email = serializers.ReadOnlyField(source='user.email')
    class Meta:
        model = VehicleRental
        fields = '__all__'
        read_only_fields = ['rental_number', 'user', 'daily_rate', 'driver_rate', 'total_price', 'status', 'payment_status', 'payment_proof', 'created_at', 'updated_at']

class AIRecommendationSerializer(serializers.ModelSerializer):
    class Meta:
        model = AIRecommendation
        fields = '__all__'

class ContributionSerializer(serializers.ModelSerializer):
    class Meta:
        model = Contribution
        fields = '__all__'

class SettingSerializer(serializers.ModelSerializer):
    class Meta:
        model = Setting
        fields = '__all__'

class WishlistSerializer(serializers.ModelSerializer):
    destination = TourismDestinationSerializer(read_only=True)
    class Meta:
        model = Wishlist
        fields = '__all__'
