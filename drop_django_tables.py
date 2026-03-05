import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'lovista_backend.settings')
django.setup()

from django.db import connection

def drop_django_tables():
    with connection.cursor() as cursor:
        cursor.execute("SHOW TABLES")
        tables = [row[0] for row in cursor.fetchall()]
        
        # Django internal tables
        django_tables = [t for t in tables if t.startswith('django_') or t.startswith('auth_')]
        
        if django_tables:
            print(f"Dropping tables: {', '.join(django_tables)}")
            cursor.execute("SET FOREIGN_KEY_CHECKS = 0")
            for table in django_tables:
                cursor.execute(f"DROP TABLE IF EXISTS {table}")
            cursor.execute("SET FOREIGN_KEY_CHECKS = 1")
            print("Django internal tables dropped.")
        else:
            print("No Django internal tables found.")

if __name__ == "__main__":
    drop_django_tables()
