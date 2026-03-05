from django.db import models
from django.contrib.auth.models import AbstractUser, BaseUserManager
from django.utils.translation import gettext_lazy as _

class Role(models.Model):
    name = models.CharField(max_length=50, unique=True)
    display_name = models.CharField(max_length=100)
    permissions = models.JSONField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.display_name

class UserManager(BaseUserManager):
    def create_user(self, email, password=None, **extra_fields):
        if not email:
            raise ValueError(_('Email is required'))
        email = self.normalize_email(email)
        user = self.model(email=email, **extra_fields)
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_superuser(self, email, password=None, **extra_fields):
        extra_fields.setdefault('is_staff', True)
        extra_fields.setdefault('is_superuser', True)
        
        # Ensure we have an admin role
        admin_role, _ = Role.objects.get_or_create(
            name='admin', 
            defaults={'display_name': 'Administrator'}
        )
        extra_fields.setdefault('role', admin_role)
        
        return self.create_user(email, password, **extra_fields)

class User(AbstractUser):
    username = None  # Remove username, use email instead
    email = models.EmailField(_('email address'), unique=True)
    fullname = models.CharField(max_length=255)
    phone = models.CharField(max_length=20, null=True, blank=True)
    role = models.ForeignKey(Role, on_delete=models.CASCADE, related_name='users', null=True)
    profile_photo = models.ImageField(upload_to='profiles/', null=True, blank=True)
    is_verified = models.BooleanField(default=False)
    # is_active is inherited from AbstractUser
    
    objects = UserManager()

    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = ['fullname']

    def __str__(self):
        return f"{self.fullname} ({self.email})"

    @property
    def is_operator(self):
        return self.role and self.role.name == 'operator'

    @property
    def is_admin(self):
        return self.role and self.role.name == 'admin' or self.is_superuser
