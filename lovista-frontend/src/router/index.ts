import { createRouter, createWebHistory, type RouteRecordRaw } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const routes: RouteRecordRaw[] = [
  // ─── PUBLIC ────────────────────────────────────────────────────────────────
  {
    path: '/',
    component: () => import('@/views/HomeView.vue'),
    name: 'home',
    meta: { title: 'LoVista — Explore West Lombok' }
  },
  {
    path: '/destinations',
    component: () => import('@/views/DestinationsView.vue'),
    name: 'destinations',
    meta: { title: 'Destinations — LoVista' }
  },
  {
    path: '/destinations/:slug',
    component: () => import('@/views/DestinationDetailView.vue'),
    name: 'destination-detail',
    meta: { title: 'Destination Detail — LoVista' }
  },
  {
    path: '/packages',
    component: () => import('@/views/PackagesView.vue'),
    name: 'packages',
    meta: { title: 'Tour Packages — LoVista' }
  },
  {
    path: '/packages/:slug',
    component: () => import('@/views/PackageDetailView.vue'),
    name: 'package-detail',
    meta: { title: 'Package Detail — LoVista' }
  },
  {
    path: '/culture',
    component: () => import('@/views/CultureView.vue'),
    name: 'culture',
    meta: { title: 'Culture & Heritage — LoVista' }
  },
  {
    path: '/culinaries',
    component: () => import('@/views/CulinaryView.vue'),
    name: 'culinaries',
    meta: { title: 'Local Culinaries — LoVista' }
  },
  {
    path: '/rent',
    component: () => import('@/views/RentView.vue'),
    name: 'rent',
    meta: { title: 'Vehicle Rental — LoVista' }
  },
  {
    path: '/homestays',
    component: () => import('@/views/HomestayView.vue'),
    name: 'homestays',
    meta: { title: 'Homestay — LoVista' }
  },
  {
    path: '/ai-recommendation',
    component: () => import('@/views/AIRecommendationView.vue'),
    name: 'ai-recommendation',
    meta: { title: 'AI Recommendation — LoVista' }
  },
  {
    path: '/map',
    component: () => import('@/views/MapView.vue'),
    name: 'map',
    meta: { title: 'Interactive Map — LoVista' }
  },
  // ─── AUTH ──────────────────────────────────────────────────────────────────
  {
    path: '/login',
    component: () => import('@/views/LoginView.vue'),
    name: 'login',
    meta: { title: 'Login — LoVista', guestOnly: true }
  },
  {
    path: '/register',
    component: () => import('@/views/RegisterView.vue'),
    name: 'register',
    meta: { title: 'Register — LoVista', guestOnly: true }
  },
  // ─── USER (auth required) ──────────────────────────────────────────────────
  {
    path: '/profile',
    component: () => import('@/views/ProfileView.vue'),
    name: 'profile',
    meta: { requiresAuth: true, title: 'My Profile — LoVista' }
  },
  {
    path: '/my-bookings',
    component: () => import('@/views/MyBookingsView.vue'),
    name: 'my-bookings',
    meta: { requiresAuth: true, title: 'My Bookings — LoVista' }
  },
  {
    path: '/wishlist',
    component: () => import('@/views/WishlistView.vue'),
    name: 'wishlist',
    meta: { requiresAuth: true, title: 'My Wishlist — LoVista' }
  },
  // ─── OPERATOR DASHBOARD ───────────────────────────────────────────────────
  {
    path: '/operator',
    component: () => import('@/views/operator/OperatorLayout.vue'),
    meta: { requiresAuth: true, role: 'operator' },
    children: [
      {
        path: '',
        component: () => import('@/views/operator/OperatorDashboard.vue'),
        name: 'operator-dashboard',
        meta: { title: 'Operator Dashboard — LoVista' }
      },
      {
        path: 'packages',
        component: () => import('@/views/operator/OperatorPackages.vue'),
        name: 'operator-packages',
        meta: { title: 'Manage Packages — LoVista' }
      },
      {
        path: 'vehicles',
        component: () => import('@/views/operator/OperatorVehicles.vue'),
        name: 'operator-vehicles',
        meta: { title: 'Manage Vehicles — LoVista' }
      },
      {
        path: 'homestays',
        component: () => import('@/views/operator/OperatorHomestays.vue'),
        name: 'operator-homestays',
        meta: { title: 'Manage Homestays — LoVista' }
      },
      {
        path: 'bookings',
        component: () => import('@/views/operator/OperatorBookings.vue'),
        name: 'operator-bookings',
        meta: { title: 'Manage Bookings — LoVista' }
      },
      {
        path: 'contributions',
        component: () => import('@/views/operator/OperatorContributions.vue'),
        name: 'operator-contributions',
        meta: { title: 'Contributions — LoVista' }
      },
      {
        path: 'profile',
        component: () => import('@/views/operator/OperatorProfile.vue'),
        name: 'operator-profile',
        meta: { title: 'Agency Profile — LoVista' }
      },
    ]
  },
  // ─── ADMIN DASHBOARD ──────────────────────────────────────────────────────
  {
    path: '/admin',
    component: () => import('@/views/admin/AdminLayout.vue'),
    meta: { requiresAuth: true, role: 'admin' },
    children: [
      {
        path: '',
        component: () => import('@/views/admin/AdminDashboard.vue'),
        name: 'admin-dashboard',
        meta: { title: 'Admin Dashboard — LoVista' }
      },
      {
        path: 'destinations',
        component: () => import('@/views/admin/AdminDestinations.vue'),
        name: 'admin-destinations',
        meta: { title: 'Manage Destinations — LoVista' }
      },
      {
        path: 'users',
        component: () => import('@/views/admin/AdminUsers.vue'),
        name: 'admin-users',
        meta: { title: 'Manage Users — LoVista' }
      },
      {
        path: 'operators',
        component: () => import('@/views/admin/AdminOperators.vue'),
        name: 'admin-operators',
        meta: { title: 'Manage Operators — LoVista' }
      },
      {
        path: 'contributions',
        component: () => import('@/views/admin/AdminContributions.vue'),
        name: 'admin-contributions',
        meta: { title: 'Review Contributions — LoVista' }
      },
      {
        path: 'bookings',
        component: () => import('@/views/admin/AdminBookings.vue'),
        name: 'admin-bookings',
        meta: { title: 'All Bookings — LoVista' }
      },
      {
        path: 'activity-logs',
        component: () => import('@/views/admin/AdminActivityLogs.vue'),
        name: 'admin-logs',
        meta: { title: 'Activity Logs — LoVista' }
      },
      {
        path: 'settings',
        component: () => import('@/views/admin/AdminSettings.vue'),
        name: 'admin-settings',
        meta: { title: 'Settings — LoVista' }
      },
    ]
  },
  // ─── 404 ───────────────────────────────────────────────────────────────────
  {
    path: '/:pathMatch(.*)*',
    component: () => import('@/views/NotFoundView.vue'),
    name: '404'
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes,
  scrollBehavior(to, _from, savedPosition) {
    if (savedPosition) return savedPosition
    if (to.hash) return { el: to.hash, behavior: 'smooth' }
    return { top: 0, behavior: 'smooth' }
  }
})

// Navigation guards
router.beforeEach(async (to) => {
  // Set page title
  document.title = (to.meta.title as string) || 'LoVista'

  const auth = useAuthStore()
  if (auth.token && !auth.user) await auth.fetchMe()

  if (to.meta.requiresAuth && !auth.isLoggedIn) {
    return { name: 'login', query: { redirect: to.fullPath } }
  }

  if (to.meta.guestOnly && auth.isLoggedIn) {
    return { name: 'home' }
  }

  if (to.meta.role === 'admin' && !auth.isAdmin) {
    return { name: 'home' }
  }

  if (to.meta.role === 'operator' && !auth.isOperator && !auth.isAdmin) {
    return { name: 'home' }
  }
})

export default router
