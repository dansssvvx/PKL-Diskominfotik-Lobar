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
    print("Seeding comprehensive data...")

    # 1. Roles
    admin_role, _ = Role.objects.get_or_create(name='admin', defaults={'display_name': 'Administrator'})
    operator_role, _ = Role.objects.get_or_create(name='operator', defaults={'display_name': 'Operator Wisata'})
    user_role, _ = Role.objects.get_or_create(name='user', defaults={'display_name': 'Wisatawan'})

    # 2. Users
    admin_user = User.objects.filter(email='admin@lovista.com').first()
    if not admin_user:
        admin_user = User.objects.create_superuser(
            email='admin@lovista.com',
            password='password123',
            fullname='Admin LoVista',
            role=admin_role
        )

    op_user = User.objects.filter(email='operator@lovista.com').first()
    if not op_user:
        op_user = User.objects.create_user(
            email='operator@lovista.com',
            password='password123',
            fullname='Budi Operator',
            role=operator_role
        )
    
    # 3. Travel Agency
    agency, _ = TravelAgency.objects.get_or_create(
        user=op_user,
        defaults={
            'business_name': 'Lombok Travelindo',
            'license_number': 'TRV-12345',
            'address': 'Jl. Raya Senggigi No. 10, Lombok Barat',
            'phone': '08123456789',
            'is_verified': True
        }
    )

    # 4. Categories
    cat_pantai, _ = DestinationCategory.objects.get_or_create(name='Pantai', defaults={'slug': 'pantai'})
    cat_gunung, _ = DestinationCategory.objects.get_or_create(name='Alam', defaults={'slug': 'alam'})
    cat_budaya, _ = DestinationCategory.objects.get_or_create(name='Budaya', defaults={'slug': 'budaya'})

    # 5. Destinations (Populer)
    destinations = [
        ('Pantai Senggigi', 'pantai-senggigi', cat_pantai, 'Pantai paling populer di Lombok Barat.', 5000, 1500),
        ('Gili Kedis', 'gili-kedis', cat_pantai, 'Pulau mungil berbentuk hati.', 10000, 850),
        ('Bukit Merese', 'bukit-merese', cat_gunung, 'Bukit dengan pemandangan laut yang luas.', 5000, 1200),
        ('Air Terjun Benang Kelambu', 'air-terjun-benang-kelambu', cat_gunung, 'Air terjun unik yang menyerupai tirai kelambu.', 15000, 950),
        ('Pura Lingsar', 'pura-lingsar', cat_budaya, 'Simbol kerukunan umat beragama.', 10000, 700),
    ]

    for name, slug, cat, desc, price, views in destinations:
        TourismDestination.objects.get_or_create(
            slug=slug,
            defaults={
                'name': name,
                'category': cat,
                'description': desc,
                'ticket_price': price,
                'views_count': views,
                'status': 'published'
            }
        )

    # 6. Tour Packages (Featured)
    packages = [
        ('Explore Sekotong Islands', 'explore-sekotong', 'Full day boat tour to Gili Nanggu, Sudak, and Kedis.', 350000),
        ('Senggigi Sunset Dinner', 'senggigi-sunset', 'Romantic dinner and beach walk in Senggigi area.', 250000),
        ('Lombok Cultural Tour', 'lombok-culture', 'Visit traditional villages and historical temples.', 450000),
    ]

    for name, slug, desc, price in packages:
        TourPackage.objects.get_or_create(
            slug=slug,
            defaults={
                'agency': agency,
                'name': name,
                'description': desc,
                'price_per_person': price,
                'is_featured': True,
                'is_active': True
            }
        )

    # 7. Local Culinaries
    culinaries = [
        ('Ayam Taliwang', 'Ayam bakar pedas khas Lombok.', 'Rp 35rb - 70rb'),
        ('Plecing Kangkung', 'Sayur kangkung dengan sambal tomat pedas.', 'Rp 10rb - 20rb'),
        ('Sate Rembiga', 'Sate daging sapi dengan bumbu pedas manis.', 'Rp 25rb - 50rb'),
    ]

    for name, desc, price in culinaries:
        Culinary.objects.get_or_create(name=name, defaults={'description': desc, 'price_range': price, 'is_verified': True})

    # 8. Culture Heritage
    cultures = [
        ('Perang Topat', 'Ritual tahunan simbol kerukunan di Pura Lingsar.', 'Pura Lingsar'),
        ('Gendang Beleq', 'Musik tradisional Lombok dengan drum besar.', 'Seluruh Lombok'),
        ('Tenun Sasak', 'Seni menun kain tradisional suku Sasak.', 'Desa Sukarara'),
    ]

    for name, desc, loc in cultures:
        Culture.objects.get_or_create(name=name, defaults={'description': desc, 'location': loc, 'status': 'published'})

    # 9. Vehicle Rental
    vehicles = [
        ('Toyota', 'Avanza', 'car', 350000),
        ('Honda', 'Vario 125', 'motorcycle', 75000),
        ('Isuzu', 'Elf', 'van', 850000),
    ]

    for brand, model, vtype, rate in vehicles:
        Vehicle.objects.get_or_create(
            plate_number=f"DR {brand[0]}{model[0]} {rate%1000}",
            defaults={
                'agency': agency,
                'type': vtype,
                'brand': brand,
                'model': model,
                'daily_rate': rate,
                'is_available': True
            }
        )

    print("Seeding completed successfully!")

if __name__ == "__main__":
    seed_data()
