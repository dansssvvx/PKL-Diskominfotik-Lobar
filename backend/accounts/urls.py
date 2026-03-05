from django.urls import path
from .views import (
    RegisterView, 
    ProfileView,
    RoleListView
)

urlpatterns = [
    path('register/', RegisterView.as_view(), name='register'),
    path('profile/', ProfileView.as_view(), name='profile'),
    path('roles/', RoleListView.as_view(), name='roles'),
]
