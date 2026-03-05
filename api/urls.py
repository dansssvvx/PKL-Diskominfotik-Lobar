from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import (
    RoleViewSet, UserViewSet, DestinationCategoryViewSet,
    TourismDestinationViewSet, CulinaryViewSet, CultureViewSet,
    ReviewViewSet, TourPackageViewSet, BookingViewSet,
    TravelAgencyViewSet, VehicleViewSet, HomestayViewSet,
    HomestayRoomViewSet, NotificationViewSet
)

router = DefaultRouter()
router.register(r'roles', RoleViewSet)
router.register(r'users', UserViewSet)
router.register(r'categories', DestinationCategoryViewSet)
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

urlpatterns = [
    path('', include(router.urls)),
]
