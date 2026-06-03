# LoVista — Sistem Informasi Pariwisata Lombok Barat

LoVista adalah platform sistem informasi pariwisata untuk Kabupaten Lombok Barat, yang mencakup informasi destinasi, kuliner, budaya, akomodasi, dan paket wisata.

## Struktur Proyek

- `lovista_backend/`: Konfigurasi utama Django.
- `api/`: Aplikasi Django yang menangani REST API.
- `lovista-frontend/`: Aplikasi frontend menggunakan Vue.js + Vite + TypeScript.
- `media/`: Folder penyimpanan file media (foto profil, dll).

---

## Prasyarat

Sebelum memulai, pastikan Anda telah menginstal:
- [Python 3.10+](https://www.python.org/)
- [Node.js 18+](https://nodejs.org/)
- [MySQL](https://dev.mysql.com/downloads/installer/) (XAMPP/Laragon/Native)

---

## Instalasi & Menjalankan Proyek

### 1. Persiapan Database
1. Buat database baru di MySQL dengan nama `lovista`.
2. Pastikan server MySQL Anda berjalan (biasanya di port 3306).

### 2. Setup Backend (Django)
Buka terminal baru di root folder proyek:

```bash
# Membuat virtual environment (Opsional tapi disarankan)
python -m venv venv

# Mengaktifkan virtual environment
# Windows:
venv\Scripts\activate
# Linux/Mac:
source venv/bin/activate

# Install dependensi
pip install -r requirements.txt

# Melakukan migrasi database
python manage.py migrate

# Menjalankan seeder (untuk data awal & akun admin)
python seed_data.py

# Menjalankan server backend
python manage.py runserver
```

Server backend akan berjalan di `http://127.0.0.1:8000/`.

**Akun Default (dari seeder):**
- **Admin:** `admin@lovista.com` / `password123`
- **Operator:** `operator@lovista.com` / `password123`

### 3. Setup Frontend (Vue.js)
Buka terminal baru dan masuk ke folder frontend:

```bash
cd lovista-frontend

# Install dependensi
npm install

# Menjalankan server development
npm run dev
```

Aplikasi frontend akan berjalan di `http://localhost:5173/` (atau port lain sesuai output terminal).

### 4. Perintah Administratif (Opsional)
Jika Anda ingin membuat superuser baru secara manual atau melakukan tugas administratif lainnya:

```bash
# Membuat superuser baru
python manage.py createsuperuser

# Mengumpulkan file statis (untuk production)
python manage.py collectstatic

# Masuk ke shell Django
python manage.py shell
```

---

## Catatan Tambahan
- Jika ingin menggunakan **SQLite** alih-alih MySQL, ubah bagian `DATABASES` di `lovista_backend/settings.py`.
- Pastikan backend berjalan saat mengakses frontend agar API dapat terhubung.