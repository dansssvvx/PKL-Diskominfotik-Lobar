from django.contrib import admin
from .models import (
    Role, User, DestinationCategory, TourismDestination, DestinationImage,
    Facility, DestinationFacility, Culinary, Culture, Review, Wishlist,
    TravelAgency, TourPackage, PackageDestination, PackageItinerary,
    PackageInclusion, Vehicle, Homestay, HomestayRoom, Booking,
    HomestayBooking, VehicleRental, AIRecommendation, Contribution,
    ActivityLog, Setting, Notification
)

@admin.register(Role)
class RoleAdmin(admin.ModelAdmin):
    list_display = ('name', 'display_name', 'created_at')

@admin.register(User)
class UserAdmin(admin.ModelAdmin):
    list_display = ('email', 'fullname', 'role', 'is_verified', 'is_active', 'is_staff')
    list_filter = ('role', 'is_verified', 'is_active', 'is_staff')
    search_fields = ('email', 'fullname')

@admin.register(DestinationCategory)
class DestinationCategoryAdmin(admin.ModelAdmin):
    list_display = ('name', 'slug', 'display_order')
    prepopulated_fields = {'slug': ('name',)}

@admin.register(TourismDestination)
class TourismDestinationAdmin(admin.ModelAdmin):
    list_display = ('name', 'category', 'district', 'status', 'created_at')
    list_filter = ('category', 'status', 'district')
    prepopulated_fields = {'slug': ('name',)}
    search_fields = ('name', 'description', 'address')

admin.site.register(DestinationImage)
admin.site.register(Facility)
admin.site.register(DestinationFacility)
admin.site.register(Culinary)
admin.site.register(Culture)
admin.site.register(Review)
admin.site.register(Wishlist)
admin.site.register(TravelAgency)
admin.site.register(TourPackage)
admin.site.register(PackageDestination)
admin.site.register(PackageItinerary)
admin.site.register(PackageInclusion)
admin.site.register(Vehicle)
admin.site.register(Homestay)
admin.site.register(HomestayRoom)
admin.site.register(Booking)
admin.site.register(HomestayBooking)
admin.site.register(VehicleRental)
admin.site.register(AIRecommendation)
admin.site.register(Contribution)
admin.site.register(ActivityLog)
admin.site.register(Setting)
admin.site.register(Notification)
