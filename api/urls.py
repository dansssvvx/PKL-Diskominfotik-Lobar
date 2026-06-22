from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import (
    RoleViewSet, UserViewSet, DestinationCategoryViewSet,
    TourismDestinationViewSet, CulinaryViewSet, CultureViewSet,
    ReviewViewSet, TourPackageViewSet, BookingViewSet,
    TravelAgencyViewSet, VehicleViewSet, HomestayViewSet,
    HomestayRoomViewSet, NotificationViewSet, AdminViewSet,
    HomestayBookingViewSet, VehicleRentalViewSet, AIRecommendationViewSet,
    ContributionViewSet, SettingViewSet, WishlistViewSet
)

router = DefaultRouter()
router.register(r'roles', RoleViewSet)
router.register(r'users', UserViewSet)
router.register(r'destination-categories', DestinationCategoryViewSet)
router.register(r'destinations', TourismDestinationViewSet)
router.register(r'culinaries', CulinaryViewSet)
router.register(r'cultures', CultureViewSet)
router.register(r'reviews', ReviewViewSet)
router.register(r'packages', TourPackageViewSet)
router.register(r'bookings', BookingViewSet)
router.register(r'agencies', TravelAgencyViewSet)
router.register(r'vehicles', VehicleViewSet)
router.register(r'homestays', HomestayViewSet)
router.register(r'rooms', HomestayRoomViewSet)
router.register(r'notifications', NotificationViewSet)
router.register(r'admin', AdminViewSet, basename='admin')
router.register(r'homestay-bookings', HomestayBookingViewSet)
router.register(r'vehicle-rentals', VehicleRentalViewSet)
router.register(r'ai-recommendations', AIRecommendationViewSet)
router.register(r'contributions', ContributionViewSet)
router.register(r'settings', SettingViewSet)
router.register(r'wishlist', WishlistViewSet)

urlpatterns = [
    path('', include(router.urls)),
]
