import os
import sys
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'lovista_backend.settings')
django.setup()

from django.db import connection

def clear_migrations():
    with connection.cursor() as cursor:
        try:
            print("Cleaning up migration history...")
            cursor.execute("DELETE FROM django_migrations")
            print("Migration history cleared.")
        except Exception as e:
            print(f"Notice: {e}")

if __name__ == "__main__":
    clear_migrations()
