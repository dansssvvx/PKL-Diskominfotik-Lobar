from django.db import models
from django.contrib.auth.models import AbstractBaseUser, BaseUserManager, PermissionsMixin
from django.utils import timezone
import datetime

class Role(models.Model):
    name = models.CharField(max_length=50, unique=True)
    display_name = models.CharField(max_length=100)
    permissions = models.JSONField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'roles'

    def __str__(self):
        return self.display_name

class UserManager(BaseUserManager):
    def create_user(self, email, password=None, **extra_fields):
        if not email:
            raise ValueError('The Email field must be set')
        email = self.normalize_email(email)
        user = self.model(email=email, **extra_fields)
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_superuser(self, email, password=None, **extra_fields):
        extra_fields.setdefault('is_staff', True)
        extra_fields.setdefault('is_superuser', True)
        role, _ = Role.objects.get_or_create(name='admin', defaults={'display_name': 'Administrator'})
        extra_fields.setdefault('role', role)
        return self.create_user(email, password, **extra_fields)

class User(AbstractBaseUser, PermissionsMixin):
    email = models.EmailField(max_length=255, unique=True)
    password = models.CharField(max_length=255, db_column='password_hash')
    fullname = models.CharField(max_length=255)
    phone = models.CharField(max_length=20, null=True, blank=True)
    role = models.ForeignKey(Role, on_delete=models.CASCADE, related_name='users', db_column='role_id')
    profile_photo = models.ImageField(upload_to='profiles/', null=True, blank=True)
    is_verified = models.BooleanField(default=False)
    is_active = models.BooleanField(default=True)
    is_staff = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)

    objects = UserManager()

    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = ['fullname']

    class Meta:
        db_table = 'users'

    def __str__(self):
        return self.email

class DestinationCategory(models.Model):
    name = models.CharField(max_length=100)
    slug = models.SlugField(max_length=120, unique=True)
    icon = models.CharField(max_length=255, null=True, blank=True)
    description = models.TextField(null=True, blank=True)
    display_order = models.IntegerField(default=0)

    class Meta:
        db_table = 'destination_categories'
        verbose_name_plural = "Destination Categories"

    def __str__(self):
        return self.name

class TourismDestination(models.Model):
    STATUS_CHOICES = [
        ('draft', 'Draft'),
        ('pending', 'Pending'),
        ('published', 'Published'),
        ('archived', 'Archived'),
    ]
    name = models.CharField(max_length=255)
    slug = models.SlugField(max_length=255, unique=True)
    category = models.ForeignKey(DestinationCategory, on_delete=models.CASCADE, related_name='destinations', db_column='category_id')
    description = models.TextField(null=True, blank=True)
    address = models.CharField(max_length=255, null=True, blank=True)
    village = models.CharField(max_length=100, null=True, blank=True)
    district = models.CharField(max_length=100, null=True, blank=True)
    latitude = models.DecimalField(max_digits=10, decimal_places=8, null=True, blank=True)
    longitude = models.DecimalField(max_digits=11, decimal_places=8, null=True, blank=True)
    opening_hours = models.CharField(max_length=255, null=True, blank=True)
    ticket_price = models.DecimalField(max_digits=10, decimal_places=2, default=0.00)
    parking_fee = models.DecimalField(max_digits=10, decimal_places=2, default=0.00)
    contact_phone = models.CharField(max_length=20, null=True, blank=True)
    contact_email = models.EmailField(max_length=255, null=True, blank=True)
    website = models.URLField(max_length=255, null=True, blank=True)
    main_image = models.CharField(max_length=255, null=True, blank=True)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='draft')
    contributor = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, blank=True, related_name='contributed_destinations', db_column='contributor_id')
    operator = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, blank=True, related_name='operated_destinations', db_column='operator_id')
    views_count = models.IntegerField(default=0)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'tourism_destinations'

    def __str__(self):
        return self.name

class DestinationImage(models.Model):
    destination = models.ForeignKey(TourismDestination, on_delete=models.CASCADE, related_name='images', db_column='destination_id')
    image_url = models.CharField(max_length=255)
    caption = models.CharField(max_length=255, null=True, blank=True)
    display_order = models.IntegerField(default=0)
    uploaded_by = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, blank=True, db_column='uploaded_by')
    is_featured = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'destination_images'

class Facility(models.Model):
    name = models.CharField(max_length=100, unique=True)
    icon = models.CharField(max_length=255, null=True, blank=True)
    description = models.TextField(null=True, blank=True)

    class Meta:
        db_table = 'facilities'
        verbose_name_plural = "Facilities"

    def __str__(self):
        return self.name

class DestinationFacility(models.Model):
    destination = models.ForeignKey(TourismDestination, on_delete=models.CASCADE, related_name='facilities', db_column='destination_id')
    facility = models.ForeignKey(Facility, on_delete=models.CASCADE, db_column='facility_id')
    notes = models.TextField(null=True, blank=True)
    is_available = models.BooleanField(default=True)

    class Meta:
        db_table = 'destination_facilities'
        unique_together = ('destination', 'facility')

class Culinary(models.Model):
    destination = models.ForeignKey(TourismDestination, on_delete=models.SET_NULL, null=True, blank=True, related_name='culinaries', db_column='destination_id')
    name = models.CharField(max_length=255)
    description = models.TextField(null=True, blank=True)
    price_range = models.CharField(max_length=50, null=True, blank=True)
    contact = models.CharField(max_length=255, null=True, blank=True)
    image = models.CharField(max_length=255, null=True, blank=True)
    latitude = models.DecimalField(max_digits=10, decimal_places=8, null=True, blank=True)
    longitude = models.DecimalField(max_digits=11, decimal_places=8, null=True, blank=True)
    is_standalone = models.BooleanField(default=False)
    is_verified = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'culinaries'
        verbose_name_plural = "Culinaries"

class Culture(models.Model):
    STATUS_CHOICES = [
        ('draft', 'Draft'),
        ('pending', 'Pending'),
        ('published', 'Published'),
        ('archived', 'Archived'),
    ]
    name = models.CharField(max_length=255)
    description = models.TextField(null=True, blank=True)
    location = models.CharField(max_length=255, null=True, blank=True)
    event_date = models.DateField(null=True, blank=True)
    event_frequency = models.CharField(max_length=100, null=True, blank=True)
    images = models.JSONField(null=True, blank=True)
    contributor = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, blank=True, db_column='contributor_id')
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='draft')
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'cultures'

class Review(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, db_column='user_id')
    destination = models.ForeignKey(TourismDestination, on_delete=models.CASCADE, related_name='reviews', db_column='destination_id')
    rating = models.PositiveSmallIntegerField()
    comment = models.TextField(null=True, blank=True)
    images = models.JSONField(null=True, blank=True)
    helpful_count = models.IntegerField(default=0)
    is_verified_visit = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'reviews'
        unique_together = ('user', 'destination')

class Wishlist(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, db_column='user_id')
    destination = models.ForeignKey(TourismDestination, on_delete=models.CASCADE, db_column='destination_id')
    notes = models.TextField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'wishlists'
        unique_together = ('user', 'destination')

class TravelAgency(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE, db_column='user_id')
    business_name = models.CharField(max_length=255)
    license_number = models.CharField(max_length=100, null=True, blank=True)
    address = models.CharField(max_length=255, null=True, blank=True)
    phone = models.CharField(max_length=20, null=True, blank=True)
    email = models.EmailField(max_length=255, null=True, blank=True)
    logo = models.CharField(max_length=255, null=True, blank=True)
    description = models.TextField(null=True, blank=True)
    bank_account = models.JSONField(null=True, blank=True)
    is_verified = models.BooleanField(default=False)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'travel_agencies'
        verbose_name_plural = "Travel Agencies"

class TourPackage(models.Model):
    agency = models.ForeignKey(TravelAgency, on_delete=models.CASCADE, related_name='packages', db_column='agency_id')
    name = models.CharField(max_length=255)
    slug = models.SlugField(max_length=255, unique=True)
    description = models.TextField(null=True, blank=True)
    duration_days = models.IntegerField(default=1)
    min_person = models.IntegerField(default=1)
    max_person = models.IntegerField(null=True, blank=True)
    price_per_person = models.DecimalField(max_digits=10, decimal_places=2)
    discount_percentage = models.DecimalField(max_digits=5, decimal_places=2, default=0.00)
    main_image = models.CharField(max_length=255, null=True, blank=True)
    inclusions = models.TextField(null=True, blank=True)
    exclusions = models.TextField(null=True, blank=True)
    terms_conditions = models.TextField(null=True, blank=True)
    is_active = models.BooleanField(default=True)
    is_featured = models.BooleanField(default=False)
    views_count = models.IntegerField(default=0)
    booking_count = models.IntegerField(default=0)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'tour_packages'

class PackageDestination(models.Model):
    package = models.ForeignKey(TourPackage, on_delete=models.CASCADE, related_name='package_destinations', db_column='package_id')
    destination = models.ForeignKey(TourismDestination, on_delete=models.CASCADE, db_column='destination_id')
    day_number = models.IntegerField()
    visit_order = models.IntegerField()
    duration_hours = models.DecimalField(max_digits=5, decimal_places=2, null=True, blank=True)
    notes = models.TextField(null=True, blank=True)

    class Meta:
        db_table = 'package_destinations'
        unique_together = ('package', 'destination', 'day_number', 'visit_order')

class PackageItinerary(models.Model):
    package = models.ForeignKey(TourPackage, on_delete=models.CASCADE, related_name='itineraries', db_column='package_id')
    day_number = models.IntegerField()
    time = models.TimeField(null=True, blank=True)
    activity = models.CharField(max_length=255)
    location = models.CharField(max_length=255, null=True, blank=True)
    description = models.TextField(null=True, blank=True)
    image = models.CharField(max_length=255, null=True, blank=True)
    display_order = models.IntegerField(default=0)

    class Meta:
        db_table = 'package_itineraries'
        verbose_name_plural = "Package Itineraries"

class PackageInclusion(models.Model):
    CATEGORY_CHOICES = [
        ('accommodation', 'Accommodation'),
        ('transportation', 'Transportation'),
        ('meals', 'Meals'),
        ('activities', 'Activities'),
        ('other', 'Other'),
    ]
    package = models.ForeignKey(TourPackage, on_delete=models.CASCADE, related_name='package_inclusions', db_column='package_id')
    item = models.CharField(max_length=255)
    is_included = models.BooleanField(default=True)
    category = models.CharField(max_length=20, choices=CATEGORY_CHOICES, default='other')

    class Meta:
        db_table = 'package_inclusions'

class Vehicle(models.Model):
    TYPE_CHOICES = [
        ('car', 'Car'),
        ('motorcycle', 'Motorcycle'),
        ('bus', 'Bus'),
        ('van', 'Van'),
        ('other', 'Other'),
    ]
    agency = models.ForeignKey(TravelAgency, on_delete=models.CASCADE, related_name='vehicles', db_column='agency_id')
    type = models.CharField(max_length=20, choices=TYPE_CHOICES)
    brand = models.CharField(max_length=100)
    model = models.CharField(max_length=100)
    year = models.IntegerField(null=True, blank=True)
    capacity = models.IntegerField(null=True, blank=True)
    plate_number = models.CharField(max_length=20, unique=True)
    daily_rate = models.DecimalField(max_digits=10, decimal_places=2)
    driver_rate = models.DecimalField(max_digits=10, decimal_places=2, default=0.00)
    image = models.CharField(max_length=255, null=True, blank=True)
    features = models.JSONField(null=True, blank=True)
    is_available = models.BooleanField(default=True)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'vehicles'

class Homestay(models.Model):
    owner = models.ForeignKey(User, on_delete=models.CASCADE, db_column='owner_id')
    name = models.CharField(max_length=255)
    address = models.CharField(max_length=255, null=True, blank=True)
    village = models.CharField(max_length=100, null=True, blank=True)
    district = models.CharField(max_length=100, null=True, blank=True)
    latitude = models.DecimalField(max_digits=10, decimal_places=8, null=True, blank=True)
    longitude = models.DecimalField(max_digits=11, decimal_places=8, null=True, blank=True)
    total_rooms = models.IntegerField(default=1)
    description = models.TextField(null=True, blank=True)
    phone = models.CharField(max_length=20, null=True, blank=True)
    amenities = models.JSONField(null=True, blank=True)
    main_image = models.CharField(max_length=255, null=True, blank=True)
    check_in_time = models.TimeField(default='14:00:00')
    check_out_time = models.TimeField(default='12:00:00')
    policies = models.TextField(null=True, blank=True)
    is_verified = models.BooleanField(default=False)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'homestays'

class HomestayRoom(models.Model):
    homestay = models.ForeignKey(Homestay, on_delete=models.CASCADE, related_name='rooms', db_column='homestay_id')
    room_number = models.CharField(max_length=50, null=True, blank=True)
    room_type = models.CharField(max_length=100, null=True, blank=True)
    capacity = models.IntegerField(default=1)
    price_per_night = models.DecimalField(max_digits=10, decimal_places=2)
    facilities = models.JSONField(null=True, blank=True)
    image = models.CharField(max_length=255, null=True, blank=True)
    is_available = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'homestay_rooms'

class Booking(models.Model):
    STATUS_CHOICES = [
        ('pending', 'Pending'),
        ('confirmed', 'Confirmed'),
        ('cancelled', 'Cancelled'),
        ('completed', 'Completed'),
    ]
    PAYMENT_STATUS_CHOICES = [
        ('pending', 'Pending'),
        ('paid', 'Paid'),
        ('refunded', 'Refunded'),
        ('failed', 'Failed'),
    ]
    booking_number = models.CharField(max_length=50, unique=True)
    user = models.ForeignKey(User, on_delete=models.CASCADE, db_column='user_id')
    package = models.ForeignKey(TourPackage, on_delete=models.CASCADE, db_column='package_id')
    start_date = models.DateField()
    end_date = models.DateField()
    total_person = models.IntegerField()
    total_price = models.DecimalField(max_digits=10, decimal_places=2)
    discount_amount = models.DecimalField(max_digits=10, decimal_places=2, default=0.00)
    special_request = models.TextField(null=True, blank=True)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending')
    payment_status = models.CharField(max_length=20, choices=PAYMENT_STATUS_CHOICES, default='pending')
    payment_method = models.CharField(max_length=100, null=True, blank=True)
    payment_proof = models.CharField(max_length=255, null=True, blank=True)
    notes = models.TextField(null=True, blank=True)
    cancelled_at = models.DateTimeField(null=True, blank=True)
    cancelled_reason = models.TextField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'bookings'

    @property
    def final_price(self):
        return self.total_price - self.discount_amount

class HomestayBooking(models.Model):
    STATUS_CHOICES = [
        ('pending', 'Pending'),
        ('confirmed', 'Confirmed'),
        ('cancelled', 'Cancelled'),
        ('completed', 'Completed'),
    ]
    PAYMENT_STATUS_CHOICES = [
        ('pending', 'Pending'),
        ('paid', 'Paid'),
        ('refunded', 'Refunded'),
        ('failed', 'Failed'),
    ]
    booking_number = models.CharField(max_length=50, unique=True)
    user = models.ForeignKey(User, on_delete=models.CASCADE, db_column='user_id')
    room = models.ForeignKey(HomestayRoom, on_delete=models.CASCADE, db_column='room_id')
    check_in = models.DateField()
    check_out = models.DateField()
    total_price = models.DecimalField(max_digits=10, decimal_places=2)
    guest_name = models.CharField(max_length=255)
    guest_phone = models.CharField(max_length=20, null=True, blank=True)
    guest_email = models.EmailField(max_length=255, null=True, blank=True)
    guest_count = models.IntegerField(default=1)
    special_request = models.TextField(null=True, blank=True)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending')
    payment_status = models.CharField(max_length=20, choices=PAYMENT_STATUS_CHOICES, default='pending')
    payment_method = models.CharField(max_length=100, null=True, blank=True)
    payment_proof = models.CharField(max_length=255, null=True, blank=True)
    notes = models.TextField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'homestay_bookings'

    @property
    def total_nights(self):
        return (self.check_out - self.check_in).days

class VehicleRental(models.Model):
    STATUS_CHOICES = [
        ('pending', 'Pending'),
        ('confirmed', 'Confirmed'),
        ('cancelled', 'Cancelled'),
        ('completed', 'Completed'),
    ]
    PAYMENT_STATUS_CHOICES = [
        ('pending', 'Pending'),
        ('paid', 'Paid'),
        ('refunded', 'Refunded'),
        ('failed', 'Failed'),
    ]
    rental_number = models.CharField(max_length=50, unique=True)
    user = models.ForeignKey(User, on_delete=models.CASCADE, db_column='user_id')
    vehicle = models.ForeignKey(Vehicle, on_delete=models.CASCADE, db_column='vehicle_id')
    start_date = models.DateField()
    end_date = models.DateField()
    daily_rate = models.DecimalField(max_digits=10, decimal_places=2)
    driver_included = models.BooleanField(default=False)
    driver_rate = models.DecimalField(max_digits=10, decimal_places=2, default=0.00)
    total_price = models.DecimalField(max_digits=10, decimal_places=2)
    pickup_location = models.CharField(max_length=255, null=True, blank=True)
    dropoff_location = models.CharField(max_length=255, null=True, blank=True)
    renter_name = models.CharField(max_length=255)
    renter_phone = models.CharField(max_length=20)
    renter_id_number = models.CharField(max_length=50, null=True, blank=True)
    renter_id_photo = models.CharField(max_length=255, null=True, blank=True)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending')
    payment_status = models.CharField(max_length=20, choices=PAYMENT_STATUS_CHOICES, default='pending')
    payment_method = models.CharField(max_length=100, null=True, blank=True)
    notes = models.TextField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'vehicle_rentals'

    @property
    def total_days(self):
        return (self.end_date - self.start_date).days + 1

class AIRecommendation(models.Model):
    user = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, blank=True, db_column='user_id')
    session_id = models.CharField(max_length=255, null=True, blank=True)
    preferences = models.JSONField(null=True, blank=True)
    budget = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    duration = models.CharField(max_length=100, null=True, blank=True)
    travel_style = models.CharField(max_length=100, null=True, blank=True)
    interests = models.JSONField(null=True, blank=True)
    recommendations = models.JSONField(null=True, blank=True)
    feedback_rating = models.PositiveSmallIntegerField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'ai_recommendations'

class Contribution(models.Model):
    TYPE_CHOICES = [
        ('destination', 'Destination'),
        ('culinary', 'Culinary'),
        ('culture', 'Culture'),
        ('other', 'Other'),
    ]
    STATUS_CHOICES = [
        ('pending', 'Pending'),
        ('approved', 'Approved'),
        ('rejected', 'Rejected'),
        ('revision_requested', 'Revision Requested'),
    ]
    contributor = models.ForeignKey(User, on_delete=models.CASCADE, related_name='contributions', db_column='contributor_id')
    type = models.CharField(max_length=20, choices=TYPE_CHOICES)
    entity_id = models.IntegerField(null=True, blank=True)
    data = models.JSONField()
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending')
    rejection_reason = models.TextField(null=True, blank=True)
    revision_notes = models.TextField(null=True, blank=True)
    reviewed_by = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, blank=True, related_name='reviewed_contributions', db_column='reviewed_by')
    submitted_at = models.DateTimeField(auto_now_add=True)
    reviewed_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        db_table = 'contributions'

class ActivityLog(models.Model):
    user = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, blank=True, db_column='user_id')
    action = models.CharField(max_length=255)
    entity_type = models.CharField(max_length=100, null=True, blank=True)
    entity_id = models.IntegerField(null=True, blank=True)
    old_value = models.JSONField(null=True, blank=True)
    new_value = models.JSONField(null=True, blank=True)
    ip_address = models.GenericIPAddressField(null=True, blank=True)
    user_agent = models.TextField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'activity_logs'

class Setting(models.Model):
    key_name = models.CharField(max_length=255, unique=True)
    value = models.TextField(null=True, blank=True)
    type = models.CharField(max_length=50, null=True, blank=True)
    description = models.TextField(null=True, blank=True)
    is_public = models.BooleanField(default=False)
    updated_at = models.DateTimeField(auto_now=True)
    updated_by = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, blank=True, db_column='updated_by')

    class Meta:
        db_table = 'settings'

class Notification(models.Model):
    TYPE_CHOICES = [
        ('info', 'Info'),
        ('warning', 'Warning'),
        ('alert', 'Alert'),
        ('success', 'Success'),
    ]
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='notifications', db_column='user_id')
    title = models.CharField(max_length=255)
    message = models.TextField()
    type = models.CharField(max_length=20, choices=TYPE_CHOICES, default='info')
    related_entity_type = models.CharField(max_length=100, null=True, blank=True)
    related_entity_id = models.IntegerField(null=True, blank=True)
    is_read = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    read_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        db_table = 'notifications'
