import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'lovista_backend.settings')
django.setup()

from django.db import connection

def add_profile_photo_column():
    with connection.cursor() as cursor:
        cursor.execute("SHOW COLUMNS FROM users")
        columns = [row[0] for row in cursor.fetchall()]
        
        if 'profile_photo' in columns:
            print("Changing 'profile_photo' column type to handle file paths...")
            # MySQL usually needs VARCHAR for ImageField paths
            cursor.execute("ALTER TABLE users MODIFY COLUMN profile_photo VARCHAR(255) NULL")
        else:
            print("Adding 'profile_photo' column...")
            cursor.execute("ALTER TABLE users ADD COLUMN profile_photo VARCHAR(255) NULL")
            
        print("Database updated successfully.")

if __name__ == "__main__":
    add_profile_photo_column()
