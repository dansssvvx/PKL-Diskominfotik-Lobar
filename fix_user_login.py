import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'lovista_backend.settings')
django.setup()

from api.models import User, Role

def fix_user():
    email = 'user1@gmail.com'
    password = 'password123' # Saya set password default
    
    user = User.objects.filter(email=email).first()
    
    if not user:
        print(f"User {email} tidak ditemukan. Membuat user baru...")
        role, _ = Role.objects.get_or_create(name='user', defaults={'display_name': 'Traveler'})
        user = User.objects.create_user(
            email=email,
            password=password,
            fullname='User Satu',
            role=role
        )
        print(f"User {email} berhasil dibuat dengan password: {password}")
    else:
        print(f"User {email} ditemukan. Mengupdate password agar ter-hash...")
        user.set_password(password)
        user.save()
        print(f"Password {email} berhasil diperbarui menjadi: {password}")

if __name__ == "__main__":
    fix_user()
