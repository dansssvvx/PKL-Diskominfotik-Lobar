import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'lovista_backend.settings')
django.setup()

from django.db import connection

def fix_user_table():
    with connection.cursor() as cursor:
        print("Checking for missing columns in 'users' table...")
        cursor.execute("SHOW COLUMNS FROM users")
        columns = [row[0] for row in cursor.fetchall()]
        
        # Kolom yang dibutuhkan Django Auth
        missing_columns = {
            'last_login': "DATETIME NULL",
            'is_superuser': "BOOLEAN DEFAULT FALSE",
            'is_staff': "BOOLEAN DEFAULT FALSE"
        }
        
        for col, definition in missing_columns.items():
            if col not in columns:
                print(f"Adding '{col}' column...")
                cursor.execute(f"ALTER TABLE users ADD COLUMN {col} {definition}")
            
        print("Database columns updated successfully.")

if __name__ == "__main__":
    fix_user_table()
