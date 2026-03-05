import os
import django
from django.contrib.auth import authenticate

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'lovista_backend.settings')
django.setup()

from api.models import User

def debug_auth():
    email = 'user1@gmail.com'
    password = 'password123'
    
    user = User.objects.filter(email=email).first()
    if not user:
        print(f"DEBUG: User {email} TIDAK ADA di database.")
        return

    print(f"DEBUG: User ditemukan -> ID: {user.id}, Fullname: {user.fullname}")
    print(f"DEBUG: is_active: {user.is_active}")
    print(f"DEBUG: Password Hash: {user.password[:20]}...")
    
    # Coba autentikasi manual menggunakan backend Django
    authenticated_user = authenticate(username=email, password=password)
    
    if authenticated_user:
        print("DEBUG: Autentikasi BERHASIL di sisi server.")
    else:
        print("DEBUG: Autentikasi GAGAL di sisi server.")
        # Cek apakah password match secara manual
        if user.check_password(password):
            print("DEBUG: Manual check_password() BERHASIL. Masalah ada di Authentication Backend.")
        else:
            print("DEBUG: Manual check_password() GAGAL. Password di DB tidak cocok dengan 'password123'.")

if __name__ == "__main__":
    debug_auth()
