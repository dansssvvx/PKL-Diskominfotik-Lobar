# 🗄️ Entity Relationship Diagram (ERD) - LoVista

## Database Overview

LoVista menggunakan MySQL 8.0 dengan total **30+ tables** yang terorganisir dalam 6 kategori utama:

1. **User Management** (2 tables)
2. **Tourism Content** (11 tables)
3. **Travel Services** (10 tables)
4. **Booking & Transactions** (3 tables)
5. **AI & Contributions** (2 tables)
6. **System & Logging** (3 tables)

---

## 📊 Entity Relationship Diagram

### High-Level Architecture

```
┌──────────────────┐
│  USER MANAGEMENT │
│                  │
│  • roles         │
│  • users         │
└────────┬─────────┘
         │
         │ 1:N
         ▼
┌──────────────────┐       ┌──────────────────┐       ┌──────────────────┐
│ TOURISM CONTENT  │       │ TRAVEL SERVICES  │       │    BOOKINGS      │
│                  │       │                  │       │                  │
│  • destinations  │       │  • agencies      │       │  • bookings      │
│  • categories    │◄──────┤  • packages      ├──────►│  • homestay_     │
│  • images        │       │  • vehicles      │       │    bookings      │
│  • facilities    │       │  • homestays     │       │  • vehicle_      │
│  • culinaries    │       │  • rooms         │       │    rentals       │
│  • cultures      │       │                  │       │                  │
│  • reviews       │       │                  │       │                  │
│  • wishlists     │       │                  │       │                  │
└──────────────────┘       └──────────────────┘       └──────────────────┘
         │                          │                          │
         │                          │                          │
         ▼                          ▼                          ▼
┌──────────────────┐       ┌──────────────────┐       ┌──────────────────┐
│  AI & CONTRIB    │       │  SYSTEM & LOGS   │       │   GENERATED      │
│                  │       │                  │       │   COLUMNS        │
│  • ai_recommend  │       │  • activity_logs │       │                  │
│  • contributions │       │  • settings      │       │  Auto-calculated │
└──────────────────┘       │  • notifications │       │  values using    │
                           └──────────────────┘       │  MySQL triggers  │
                                                      └──────────────────┘
```

---

## 📋 Detailed Table Relationships

### 1. USER MANAGEMENT

#### roles
```sql
┌─────────────────┐
│     roles       │
├─────────────────┤
│ id (PK)         │
│ name (UQ)       │
│ display_name    │
│ permissions JSON│
│ created_at      │
└─────────────────┘
        │
        │ 1:N
        ▼
```

#### users
```sql
┌─────────────────┐
│     users       │
├─────────────────┤
│ id (PK)         │
│ email (UQ)      │
│ password_hash   │
│ fullname        │
│ phone           │
│ role_id (FK)    │───► roles.id
│ profile_photo   │
│ is_verified     │
│ is_active       │
│ created_at      │
└─────────────────┘
```

**Relationships:**
- `users.role_id` → `roles.id` (Many-to-One)
- `users` → `contributions` (One-to-Many)
- `users` → `reviews` (One-to-Many)
- `users` → `bookings` (One-to-Many)
- `users` → `wishlists` (One-to-Many)

---

### 2. TOURISM CONTENT

#### destination_categories
```sql
┌──────────────────────┐
│ destination_         │
│ categories           │
├──────────────────────┤
│ id (PK)              │
│ name                 │
│ slug (UQ)            │
│ icon                 │
│ description          │
│ display_order        │
└──────────────────────┘
        │
        │ 1:N
        ▼
```

#### tourism_destinations (CORE TABLE)
```sql
┌────────────────────────────┐
│   tourism_destinations     │
├────────────────────────────┤
│ id (PK)                    │
│ name                       │
│ slug (UQ)                  │
│ category_id (FK)           │───► destination_categories.id
│ description                │
│ address                    │
│ village                    │
│ district                   │
│ latitude                   │
│ longitude                  │
│ opening_hours              │
│ ticket_price               │
│ parking_fee                │
│ contact_phone              │
│ contact_email              │
│ website                    │
│ main_image                 │
│ status ENUM                │
│ contributor_id (FK)        │───► users.id
│ operator_id (FK)           │───► users.id
│ views_count                │
│ created_at                 │
│ updated_at                 │
└────────────────────────────┘
        │                │            │
        │ 1:N            │ 1:N        │ 1:N
        ▼                ▼            ▼
┌─────────────┐  ┌──────────────┐  ┌──────────────┐
│destination_ │  │ destination_ │  │  culinaries  │
│  images     │  │ facilities   │  │              │
└─────────────┘  └──────────────┘  └──────────────┘
```

#### destination_images
```sql
┌────────────────────────────┐
│   destination_images       │
├────────────────────────────┤
│ id (PK)                    │
│ destination_id (FK)        │───► tourism_destinations.id
│ image_url                  │
│ caption                    │
│ display_order              │
│ uploaded_by (FK)           │───► users.id
│ is_featured                │
│ created_at                 │
└────────────────────────────┘
```

#### facilities & destination_facilities (MANY-TO-MANY)
```sql
┌──────────────┐              ┌──────────────────────┐              ┌──────────────────────┐
│ facilities   │              │ destination_         │              │ tourism_             │
│              │              │ facilities           │              │ destinations         │
├──────────────┤              ├──────────────────────┤              └──────────────────────┘
│ id (PK)      │◄─────────────┤ id (PK)              │                       ▲
│ name         │              │ destination_id (FK)  │───────────────────────┘
│ icon         │              │ facility_id (FK)     │
│ description  │              │ notes                │
└──────────────┘              │ is_available         │
                              └──────────────────────┘
```

#### culinaries
```sql
┌────────────────────────────┐
│      culinaries            │
├────────────────────────────┤
│ id (PK)                    │
│ destination_id (FK) NULL   │───► tourism_destinations.id
│ name                       │
│ description                │
│ price_range                │
│ contact                    │
│ image                      │
│ latitude                   │
│ longitude                  │
│ is_standalone BOOL         │
│ is_verified                │
│ created_at                 │
└────────────────────────────┘
```

#### cultures
```sql
┌────────────────────────────┐
│       cultures             │
├────────────────────────────┤
│ id (PK)                    │
│ name                       │
│ description                │
│ location                   │
│ event_date                 │
│ event_frequency            │
│ images JSON                │
│ contributor_id (FK)        │───► users.id
│ status ENUM                │
│ created_at                 │
└────────────────────────────┘
```

#### reviews
```sql
┌────────────────────────────┐
│        reviews             │
├────────────────────────────┤
│ id (PK)                    │
│ user_id (FK)               │───► users.id
│ destination_id (FK)        │───► tourism_destinations.id
│ rating (1-5)               │
│ comment                    │
│ images JSON                │
│ helpful_count              │
│ is_verified_visit          │
│ created_at                 │
│ updated_at                 │
└────────────────────────────┘
```

#### wishlists
```sql
┌────────────────────────────┐
│       wishlists            │
├────────────────────────────┤
│ id (PK)                    │
│ user_id (FK)               │───► users.id
│ destination_id (FK)        │───► tourism_destinations.id
│ notes                      │
│ created_at                 │
└────────────────────────────┘
UNIQUE (user_id, destination_id)
```

---

### 3. TRAVEL SERVICES

#### travel_agencies
```sql
┌────────────────────────────┐
│    travel_agencies         │
├────────────────────────────┤
│ id (PK)                    │
│ user_id (FK) UNIQUE        │───► users.id
│ business_name              │
│ license_number             │
│ address                    │
│ phone                      │
│ email                      │
│ logo                       │
│ description                │
│ bank_account JSON          │
│ is_verified                │
│ is_active                  │
│ created_at                 │
└────────────────────────────┘
        │
        │ 1:N
        ├─────────────┬─────────────┬─────────────┐
        ▼             ▼             ▼             ▼
┌──────────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐
│tour_packages │ │ vehicles │ │ homestays│ │(future)  │
└──────────────┘ └──────────┘ └──────────┘ └──────────┘
```

#### tour_packages
```sql
┌────────────────────────────┐
│     tour_packages          │
├────────────────────────────┤
│ id (PK)                    │
│ agency_id (FK)             │───► travel_agencies.id
│ name                       │
│ slug (UQ)                  │
│ description                │
│ duration_days              │
│ min_person                 │
│ max_person                 │
│ price_per_person           │
│ discount_percentage        │
│ main_image                 │
│ inclusions TEXT            │
│ exclusions TEXT            │
│ terms_conditions           │
│ is_active                  │
│ is_featured                │
│ views_count                │
│ booking_count              │
│ created_at                 │
└────────────────────────────┘
        │
        │ 1:N
        ├─────────────┬─────────────┬─────────────┐
        ▼             ▼             ▼             ▼
┌──────────────┐ ┌──────────────┐ ┌──────────────┐ ┌──────────────┐
│package_      │ │package_      │ │package_      │ │  bookings    │
│destinations  │ │itineraries   │ │inclusions    │ │              │
└──────────────┘ └──────────────┘ └──────────────┘ └──────────────┘
```

#### package_destinations (MANY-TO-MANY)
```sql
┌────────────────────────────┐
│   package_destinations     │
├────────────────────────────┤
│ id (PK)                    │
│ package_id (FK)            │───► tour_packages.id
│ destination_id (FK)        │───► tourism_destinations.id
│ day_number                 │
│ visit_order                │
│ duration_hours             │
│ notes                      │
└────────────────────────────┘
```

#### package_itineraries
```sql
┌────────────────────────────┐
│   package_itineraries      │
├────────────────────────────┤
│ id (PK)                    │
│ package_id (FK)            │───► tour_packages.id
│ day_number                 │
│ time                       │
│ activity                   │
│ location                   │
│ description                │
│ image                      │
│ display_order              │
└────────────────────────────┘
```

#### package_inclusions
```sql
┌────────────────────────────┐
│   package_inclusions       │
├────────────────────────────┤
│ id (PK)                    │
│ package_id (FK)            │───► tour_packages.id
│ item                       │
│ is_included BOOL           │
│ category ENUM              │
└────────────────────────────┘
```

#### vehicles
```sql
┌────────────────────────────┐
│        vehicles            │
├────────────────────────────┤
│ id (PK)                    │
│ agency_id (FK)             │───► travel_agencies.id
│ type ENUM                  │
│ brand                      │
│ model                      │
│ year                       │
│ capacity                   │
│ plate_number (UQ)          │
│ daily_rate                 │
│ driver_rate                │
│ image                      │
│ features JSON              │
│ is_available               │
│ is_active                  │
│ created_at                 │
└────────────────────────────┘
        │
        │ 1:N
        ▼
┌────────────────────────────┐
│     vehicle_rentals        │
└────────────────────────────┘
```

#### homestays
```sql
┌────────────────────────────┐
│       homestays            │
├────────────────────────────┤
│ id (PK)                    │
│ owner_id (FK)              │───► users.id
│ name                       │
│ address                    │
│ village                    │
│ district                   │
│ latitude                   │
│ longitude                  │
│ total_rooms                │
│ description                │
│ phone                      │
│ amenities JSON             │
│ main_image                 │
│ check_in_time              │
│ check_out_time             │
│ policies                   │
│ is_verified                │
│ is_active                  │
│ created_at                 │
└────────────────────────────┘
        │
        │ 1:N
        ▼
┌────────────────────────────┐
│     homestay_rooms         │
├────────────────────────────┤
│ id (PK)                    │
│ homestay_id (FK)           │───► homestays.id
│ room_number                │
│ room_type                  │
│ capacity                   │
│ price_per_night            │
│ facilities JSON            │
│ image                      │
│ is_available               │
│ created_at                 │
└────────────────────────────┘
        │
        │ 1:N
        ▼
┌────────────────────────────┐
│   homestay_bookings        │
└────────────────────────────┘
```

---

### 4. BOOKING & TRANSACTIONS

#### bookings (Tour Package Bookings)
```sql
┌────────────────────────────┐
│        bookings            │
├────────────────────────────┤
│ id (PK)                    │
│ booking_number (UQ)        │ ← Auto-generated
│ user_id (FK)               │───► users.id
│ package_id (FK)            │───► tour_packages.id
│ start_date                 │
│ end_date (GENERATED)       │ ← Computed from start_date + duration
│ total_person               │
│ total_price                │
│ discount_amount            │
│ final_price (GENERATED)    │ ← Computed: total_price - discount
│ special_request            │
│ status ENUM                │
│ payment_status ENUM        │
│ payment_method             │
│ payment_proof              │
│ notes                      │
│ cancelled_at               │
│ cancelled_reason           │
│ created_at                 │
└────────────────────────────┘
```

#### homestay_bookings
```sql
┌────────────────────────────┐
│   homestay_bookings        │
├────────────────────────────┤
│ id (PK)                    │
│ booking_number (UQ)        │ ← Auto-generated
│ user_id (FK)               │───► users.id
│ room_id (FK)               │───► homestay_rooms.id
│ check_in                   │
│ check_out                  │
│ total_nights (GENERATED)   │ ← Computed: DATEDIFF(check_out, check_in)
│ total_price                │
│ guest_name                 │
│ guest_phone                │
│ guest_email                │
│ guest_count                │
│ special_request            │
│ status ENUM                │
│ payment_status ENUM        │
│ payment_method             │
│ payment_proof              │
│ notes                      │
│ created_at                 │
└────────────────────────────┘
```

#### vehicle_rentals
```sql
┌────────────────────────────┐
│     vehicle_rentals        │
├────────────────────────────┤
│ id (PK)                    │
│ rental_number (UQ)         │ ← Auto-generated
│ user_id (FK)               │───► users.id
│ vehicle_id (FK)            │───► vehicles.id
│ start_date                 │
│ end_date                   │
│ total_days (GENERATED)     │ ← Computed: DATEDIFF(end_date, start_date) + 1
│ daily_rate                 │
│ driver_included            │
│ driver_rate                │
│ total_price                │
│ pickup_location            │
│ dropoff_location           │
│ renter_name                │
│ renter_phone               │
│ renter_id_number           │
│ renter_id_photo            │
│ status ENUM                │
│ payment_status ENUM        │
│ payment_method             │
│ notes                      │
│ created_at                 │
└────────────────────────────┘
```

---

### 5. AI & CONTRIBUTIONS

#### ai_recommendations
```sql
┌────────────────────────────┐
│   ai_recommendations       │
├────────────────────────────┤
│ id (PK)                    │
│ user_id (FK) NULL          │───► users.id
│ session_id                 │
│ preferences JSON           │
│ budget                     │
│ duration                   │
│ travel_style               │
│ interests JSON             │
│ recommendations JSON       │
│ feedback_rating            │
│ created_at                 │
└────────────────────────────┘
```

#### contributions
```sql
┌────────────────────────────┐
│      contributions         │
├────────────────────────────┤
│ id (PK)                    │
│ contributor_id (FK)        │───► users.id
│ type ENUM                  │
│ entity_id                  │
│ data JSON                  │
│ status ENUM                │
│ rejection_reason           │
│ revision_notes             │
│ reviewed_by (FK)           │───► users.id
│ submitted_at               │
│ reviewed_at                │
└────────────────────────────┘
```

---

### 6. SYSTEM & LOGGING

#### activity_logs
```sql
┌────────────────────────────┐
│      activity_logs         │
├────────────────────────────┤
│ id (PK)                    │
│ user_id (FK)               │───► users.id
│ action                     │
│ entity_type                │
│ entity_id                  │
│ old_value JSON             │
│ new_value JSON             │
│ ip_address                 │
│ user_agent                 │
│ created_at                 │
└────────────────────────────┘
```

#### settings
```sql
┌────────────────────────────┐
│        settings            │
├────────────────────────────┤
│ id (PK)                    │
│ key_name (UQ)              │
│ value                      │
│ type                       │
│ description                │
│ is_public                  │
│ updated_at                 │
│ updated_by (FK)            │───► users.id
└────────────────────────────┘
```

#### notifications
```sql
┌────────────────────────────┐
│      notifications         │
├────────────────────────────┤
│ id (PK)                    │
│ user_id (FK)               │───► users.id
│ title                      │
│ message                    │
│ type ENUM                  │
│ related_entity_type        │
│ related_entity_id          │
│ is_read                    │
│ created_at                 │
│ read_at                    │
└────────────────────────────┘
```

---

## 🔗 Key Relationships Summary

### One-to-Many Relationships

1. `roles` ─(1:N)─► `users`
2. `users` ─(1:N)─► `contributions`
3. `users` ─(1:N)─► `reviews`
4. `users` ─(1:N)─► `bookings`
5. `users` ─(1:N)─► `wishlists`
6. `destination_categories` ─(1:N)─► `tourism_destinations`
7. `tourism_destinations` ─(1:N)─► `destination_images`
8. `tourism_destinations` ─(1:N)─► `culinaries`
9. `tourism_destinations` ─(1:N)─► `reviews`
10. `travel_agencies` ─(1:N)─► `tour_packages`
11. `travel_agencies` ─(1:N)─► `vehicles`
12. `tour_packages` ─(1:N)─► `package_itineraries`
13. `tour_packages` ─(1:N)─► `package_inclusions`
14. `tour_packages` ─(1:N)─► `bookings`
15. `homestays` ─(1:N)─► `homestay_rooms`
16. `homestay_rooms` ─(1:N)─► `homestay_bookings`
17. `vehicles` ─(1:N)─► `vehicle_rentals`

### Many-to-Many Relationships

1. `tourism_destinations` ◄─►  `facilities`  
   *via* `destination_facilities`

2. `tour_packages` ◄─► `tourism_destinations`  
   *via* `package_destinations`

### Generated Columns (Computed)

1. `bookings.end_date` = `start_date + package.duration_days`
2. `bookings.final_price` = `total_price - discount_amount`
3. `homestay_bookings.total_nights` = `DATEDIFF(check_out, check_in)`
4. `vehicle_rentals.total_days` = `DATEDIFF(end_date, start_date) + 1`

---

## 📐 Database Constraints

### Primary Keys
All tables have `id INT AUTO_INCREMENT PRIMARY KEY`

### Unique Constraints
- `roles.name`
- `users.email`
- `destination_categories.slug`
- `tourism_destinations.slug`
- `facilities.name`
- `tour_packages.slug`
- `vehicles.plate_number`
- `bookings.booking_number`
- `homestay_bookings.booking_number`
- `vehicle_rentals.rental_number`
- `wishlists (user_id, destination_id)`

### Foreign Key Constraints
All foreign keys use `ON DELETE CASCADE` or `ON DELETE SET NULL`

### Check Constraints
- `reviews.rating` BETWEEN 1 AND 5
- All ENUM fields have defined values

---

## 🔍 Indexes

### Single Column Indexes
- All primary keys (auto-indexed)
- All foreign keys
- `users.email`
- `tourism_destinations.status`
- `tourism_destinations.district`
- `bookings.status`
- `bookings.payment_status`

### Composite Indexes
- `(category_id, status)` on `tourism_destinations`
- `(district, status)` on `tourism_destinations`
- `(package_id, day_number)` on `package_itineraries`
- `(user_id, is_read)` on `notifications`

### Fulltext Indexes
- `(name, description, address)` on `tourism_destinations`
- `(name, description, location)` on `cultures`
- `(name, description)` on `culinaries`

---

## 🎯 Design Principles

1. **Normalization**: Database normalized to 3NF
2. **Generated Columns**: Used for computed values
3. **JSON Fields**: For flexible, non-queried data
4. **Soft Deletes**: Status flags instead of hard deletes
5. **Audit Trail**: `created_at`, `updated_at` on all tables
6. **Triggers**: Auto-generate booking numbers, update counts

---

## 📊 Database Statistics

- **Total Tables**: 30+
- **Total Views**: 3
- **Total Triggers**: 3
- **Total Foreign Keys**: 40+
- **Total Indexes**: 50+
- **Estimated Size**: ~500MB with sample data
- **Max Connections**: 150 (default MySQL)
- **Character Set**: UTF8MB4 (full Unicode)
- **Collation**: utf8mb4_unicode_ci

---

**Last Updated:** February 4, 2026
