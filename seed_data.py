import os
import django
import datetime
from django.utils import timezone
from django.utils.text import slugify

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'lovista_backend.settings')
django.setup()

from api.models import (
    Role, User, DestinationCategory, TourismDestination, 
    Facility, Culinary, Culture, TravelAgency, 
    TourPackage, Homestay, Vehicle
)

def seed_data():
    print("Updating seeder with beautiful tourism images...")

    # 1. Roles
    admin_role, _ = Role.objects.get_or_create(name='admin', defaults={'display_name': 'Administrator'})
    operator_role, _ = Role.objects.get_or_create(name='operator', defaults={'display_name': 'Operator Wisata'})
    user_role, _ = Role.objects.get_or_create(name='user', defaults={'display_name': 'Wisatawan'})

    # 2. Users
    admin_user = User.objects.filter(email='admin@lovista.com').first()
    if not admin_user:
        admin_user = User.objects.create_superuser(email='admin@lovista.com', password='password123', fullname='Admin LoVista', role=admin_role)

    op_user = User.objects.filter(email='operator@lovista.com').first()
    if not op_user:
        op_user = User.objects.create_user(email='operator@lovista.com', password='password123', fullname='Budi Operator', role=operator_role)
    
    agency, _ = TravelAgency.objects.get_or_create(user=op_user, defaults={'business_name': 'Lombok Travelindo', 'is_verified': True})

    # 3. Categories
    cat_pantai, _ = DestinationCategory.objects.get_or_create(name='Pantai', defaults={'slug': 'pantai'})
    cat_gunung, _ = DestinationCategory.objects.get_or_create(name='Alam', defaults={'slug': 'alam'})
    cat_budaya, _ = DestinationCategory.objects.get_or_create(name='Budaya', defaults={'slug': 'budaya'})

    # 4. Destinations (Populer) dengan foto asli
    destinations = [
        ('Pantai Senggigi', 'pantai-senggigi', cat_pantai, 'https://images.unsplash.com/photo-1588668214407-6ea9a6d8c272?q=80&w=2071', 1500),
        ('Gili Kedis', 'gili-kedis', cat_pantai, 'https://images.unsplash.com/photo-1590523741831-ab7e8b8f9c7f?q=80&w=2070', 850),
        ('Bukit Merese', 'bukit-merese', cat_gunung, 'https://images.unsplash.com/photo-1516690561799-46d8f74f9abf?q=80&w=2070', 1200),
        ('Air Terjun Benang Kelambu', 'air-terjun-benang-kelambu', cat_gunung, 'https://images.unsplash.com/photo-1511497584788-876760111969?q=80&w=2070', 950),
        ('Pura Lingsar', 'pura-lingsar', cat_budaya, 'https://images.unsplash.com/photo-1596422846543-75c6fc18a5cf?q=80&w=2070', 700),
    ]

    for name, slug, cat, img, views in destinations:
        dest, created = TourismDestination.objects.get_or_create(slug=slug, defaults={'name': name, 'category': cat, 'main_image': img, 'views_count': views, 'status': 'published'})
        if not created:
            dest.main_image = img
            dest.save()

    # 5. Tour Packages (Featured) dengan foto asli
    packages = [
        ('Explore Sekotong Islands', 'explore-sekotong', 'https://images.unsplash.com/photo-1544918877-460635b6d13e?q=80&w=2070', 350000),
        ('Senggigi Sunset Dinner', 'senggigi-sunset', 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?q=80&w=2073', 250000),
        ('Lombok Cultural Tour', 'lombok-culture', 'https://images.unsplash.com/photo-1537996194471-e657df975ab4?q=80&w=2070', 450000),
    ]

    for name, slug, img, price in packages:
        pkg, created = TourPackage.objects.get_or_create(slug=slug, defaults={'agency': agency, 'name': name, 'main_image': img, 'price_per_person': price, 'is_featured': True, 'is_active': True})
        if not created:
            pkg.main_image = img
            pkg.save()

    # 6. Local Culinaries dengan foto asli
    culinaries = [
        ('Ayam Taliwang', 'https://images.unsplash.com/photo-1598515214211-89d3c73ae83b?q=80&w=2070'),
        ('Plecing Kangkung', 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?q=80&w=2080'),
        ('Sate Rembiga', 'https://images.unsplash.com/photo-1529692236671-f1f6cf9683ba?q=80&w=2070'),
    ]

    for name, img in culinaries:
        cul, created = Culinary.objects.get_or_create(name=name, defaults={'image': img, 'is_verified': True})
        if not created:
            cul.image = img
            cul.save()

    # 7. Vehicle Rental dengan foto asli
    vehicles = [
        ('Toyota', 'Avanza', 'car', 'https://images.unsplash.com/photo-1549317661-bd32c8ce0db2?q=80&w=2070'),
        ('Honda', 'Vario 125', 'motorcycle', 'https://images.unsplash.com/photo-1558981806-ec527fa84c39?q=80&w=2070'),
    ]

    for brand, model, vtype, img in vehicles:
        veh = Vehicle.objects.filter(brand=brand, model=model).first()
        if veh:
            veh.image = img
            veh.save()

    print("Seeding completed successfully with real images!")

if __name__ == "__main__":
    seed_data()
