# LoVista Frontend — Vue 3 + TypeScript

Platform Informasi Pariwisata Digital Kabupaten Lombok Barat

## Stack
- **Vue 3** + Composition API
- **TypeScript** — fully typed, matching MySQL database schema
- **Vite** — fast dev server + build
- **Pinia** — state management (auth, destinations)
- **Vue Router 4** — client-side routing with guards
- **Axios** — HTTP client with JWT interceptors
- **Leaflet.js** — interactive map (integration point ready)

---

## Project Structure

```
src/
├── api/           # Axios API client — all endpoints matching Django REST API
├── assets/
│   └── styles/
│       └── main.css    # Global CSS variables, utilities, components
├── components/
│   ├── common/         # Reusable UI components
│   └── layout/
│       ├── TheNavbar.vue
│       └── TheFooter.vue
├── composables/        # Reusable Vue composables
├── router/
│   └── index.ts        # All routes + navigation guards (auth, role-based)
├── stores/
│   ├── auth.ts         # JWT auth store (login, register, fetchMe)
│   └── destination.ts  # Destinations + wishlist store
├── types/
│   └── index.ts        # 40+ TypeScript interfaces matching MySQL schema
├── utils/
├── views/
│   ├── HomeView.vue              # Landing page — hero, destinations, packages, culture, culinary, rental, AI banner
│   ├── DestinationDetailView.vue # Full detail — gallery, map, reviews, booking sidebar
│   ├── admin/
│   │   ├── AdminLayout.vue       # Sidebar layout with nav groups
│   │   ├── AdminDashboard.vue    # Stats, pending contributions, activity logs
│   │   ├── AdminDestinations.vue
│   │   ├── AdminUsers.vue
│   │   ├── AdminOperators.vue
│   │   ├── AdminContributions.vue
│   │   ├── AdminBookings.vue
│   │   ├── AdminActivityLogs.vue
│   │   └── AdminSettings.vue
│   └── operator/
│       ├── OperatorLayout.vue    # Sidebar layout with agency info
│       ├── OperatorDashboard.vue # Stats, recent bookings
│       ├── OperatorPackages.vue
│       ├── OperatorVehicles.vue
│       ├── OperatorHomestays.vue
│       ├── OperatorBookings.vue
│       ├── OperatorContributions.vue
│       └── OperatorProfile.vue
└── main.ts
```

---

## Setup & Run

```bash
# Install dependencies
npm install

# Start dev server (requires Django backend on :8000)
npm run dev

# Type check
npm run type-check

# Build for production
npm run build
```

---

## API Proxy

Dev server proxies `/api/*` → `http://localhost:8000` (configured in `vite.config.ts`).

Make sure Django backend is running on port 8000.

---

## Routing & Role Guards

| Route | Access |
|-------|--------|
| `/` `/destinations` `/packages` etc | Public |
| `/my-bookings` `/wishlist` `/profile` | Auth required |
| `/operator/*` | Operator + Admin only |
| `/admin/*` | Admin only |

Guards are in `src/router/index.ts` — redirect to `/login` if unauthenticated.

---

## TypeScript Types (`src/types/index.ts`)

All types match the MySQL database schema exactly:

| DB Table | TypeScript Interface |
|----------|---------------------|
| `users` | `User`, `AuthUser` |
| `roles` | `Role`, `UserRole` |
| `tourism_destinations` | `TourismDestination` |
| `destination_categories` | `DestinationCategory` |
| `tour_packages` | `TourPackage` |
| `travel_agencies` | `TravelAgency` |
| `homestays` + `homestay_rooms` | `Homestay`, `HomestayRoom` |
| `vehicles` | `Vehicle` |
| `bookings` | `Booking` |
| `homestay_bookings` | `HomestayBooking` |
| `vehicle_rentals` | `VehicleRental` |
| `reviews` | `Review` |
| `wishlists` | `Wishlist` |
| `cultures` | `Culture` |
| `culinaries` | `Culinary` |
| `ai_recommendations` | `AIRecommendation` |
| `contributions` | `Contribution` |
| `notifications` | `Notification` |
| `activity_logs` | `ActivityLog` |

---

## Next Steps: Django Backend

Expected Django API endpoints (Django REST Framework):

```
POST   /api/auth/login/
POST   /api/auth/register/
GET    /api/auth/me/
GET    /api/destinations/
GET    /api/destinations/:slug/
GET    /api/destinations/popular/
GET    /api/destination-categories/
GET    /api/packages/
GET    /api/packages/:slug/
GET    /api/packages/featured/
GET    /api/homestays/
GET    /api/vehicles/
GET    /api/cultures/
GET    /api/culinaries/
POST   /api/bookings/
POST   /api/homestay-bookings/
POST   /api/vehicle-rentals/
POST   /api/ai-recommendations/
GET    /api/notifications/
GET    /api/admin/stats/
GET    /api/admin/users/
GET    /api/agencies/me/
GET    /api/agencies/me/dashboard/
...
```

---

*Built for PKL Diskominfotik Lombok Barat — Django + Vue 3 + TypeScript + MySQL*
