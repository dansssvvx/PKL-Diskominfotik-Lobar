<template>
  <div class="op-dash">
    <!-- Header -->
    <div class="op-dash__header-row">
      <div>
        <h1 class="admin-title">Operator Dashboard</h1>
        <p class="admin-subtitle">Selamat datang, {{ auth.user?.fullname }} — berikut ringkasan bisnis Anda hari ini.</p>
      </div>
      <div class="live-indicator">
        <span class="pulse-dot"></span>
        Live Updates Active
      </div>
    </div>

    <!-- Stats Grid -->
    <div class="stats-grid" v-if="dashData">
      <div class="stat-card" v-for="s in statCards" :key="s.label">
        <div class="stat-card__icon">{{ s.icon }}</div>
        <div class="stat-card__value">{{ s.value }}</div>
        <div class="stat-card__label">{{ s.label }}</div>
        <RouterLink :to="s.link" class="stat-card__link">View →</RouterLink>
      </div>
    </div>
    <div class="page-loader" v-else-if="loading">
      <div class="spinner"></div>
    </div>
    <div class="stats-grid" v-else>
      <div class="stat-card skeleton-card" v-for="i in 6" :key="i">
        <div class="skeleton-icon"></div>
        <div class="skeleton-value"></div>
        <div class="skeleton-label"></div>
      </div>
    </div>

    <!-- Quick Actions -->
    <div class="dash-section">
      <div class="dash-section__header">
        <h2 class="dash-section__title">Quick Actions</h2>
      </div>
      <div class="quick-actions">
        <RouterLink to="/operator/packages" class="quick-action-btn">
          <span class="qa-icon">🗺️</span>
          <span>Add Tour Package</span>
        </RouterLink>
        <RouterLink to="/operator/vehicles" class="quick-action-btn">
          <span class="qa-icon">🚗</span>
          <span>Add Vehicle</span>
        </RouterLink>
        <RouterLink to="/operator/homestays" class="quick-action-btn">
          <span class="qa-icon">🏡</span>
          <span>Add Homestay</span>
        </RouterLink>
        <RouterLink to="/operator/bookings" class="quick-action-btn">
          <span class="qa-icon">📅</span>
          <span>Manage Bookings</span>
        </RouterLink>
        <RouterLink to="/operator/contributions" class="quick-action-btn">
          <span class="qa-icon">📝</span>
          <span>My Contributions</span>
        </RouterLink>
        <RouterLink to="/operator/profile" class="quick-action-btn">
          <span class="qa-icon">🏢</span>
          <span>Agency Profile</span>
        </RouterLink>
      </div>
    </div>

    <!-- Recent Bookings -->
    <div class="dash-section">
      <div class="dash-section__header">
        <h2 class="dash-section__title">Recent Tour Bookings</h2>
        <RouterLink to="/operator/bookings" class="btn btn-ghost btn-sm">View All</RouterLink>
      </div>
      <div class="table-wrap card">
        <table class="table">
          <thead>
            <tr>
              <th>Booking #</th>
              <th>Package</th>
              <th>Customer</th>
              <th>Date</th>
              <th>Total</th>
              <th>Status</th>
              <th>Payment</th>
            </tr>
          </thead>
          <tbody>
            <tr v-if="loadingBookings">
              <td colspan="7" style="text-align:center;padding:32px"><div class="spinner"></div></td>
            </tr>
            <tr v-else-if="!recentBookings.length">
              <td colspan="7" class="empty-cell">No recent bookings yet</td>
            </tr>
            <tr v-else v-for="b in recentBookings" :key="b.id">
              <td><code class="booking-num">{{ b.booking_number }}</code></td>
              <td>{{ b.package_name || b.package?.name || '-' }}</td>
              <td>
                <div class="user-name">{{ b.user_name || b.user?.fullname || '-' }}</div>
              </td>
              <td>{{ formatDate(b.start_date) }}</td>
              <td class="price-val">Rp {{ formatPrice(b.total_price) }}</td>
              <td><span class="badge" :class="statusClass(b.status)">{{ b.status }}</span></td>
              <td><span class="badge" :class="paymentClass(b.payment_status)">{{ b.payment_status }}</span></td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- Revenue Summary -->
    <div class="dash-row">
      <!-- Homestay Bookings -->
      <div class="dash-col">
        <div class="dash-section__header">
          <h2 class="dash-section__title">Recent Homestay Bookings</h2>
          <RouterLink to="/operator/bookings" class="btn btn-ghost btn-sm">View All</RouterLink>
        </div>
        <div class="table-wrap card">
          <table class="table">
            <thead>
              <tr><th>Booking #</th><th>Guest</th><th>Check-In</th><th>Status</th></tr>
            </thead>
            <tbody>
              <tr v-if="!recentHomestayBookings.length">
                <td colspan="4" class="empty-cell">No homestay bookings</td>
              </tr>
              <tr v-for="b in recentHomestayBookings" :key="b.id">
                <td><code class="booking-num">{{ b.booking_number }}</code></td>
                <td>{{ b.guest_name }}</td>
                <td>{{ formatDate(b.check_in) }}</td>
                <td><span class="badge" :class="statusClass(b.status)">{{ b.status }}</span></td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <!-- Vehicle Rentals -->
      <div class="dash-col">
        <div class="dash-section__header">
          <h2 class="dash-section__title">Recent Vehicle Rentals</h2>
          <RouterLink to="/operator/bookings" class="btn btn-ghost btn-sm">View All</RouterLink>
        </div>
        <div class="table-wrap card">
          <table class="table">
            <thead>
              <tr><th>Rental #</th><th>Renter</th><th>Period</th><th>Status</th></tr>
            </thead>
            <tbody>
              <tr v-if="!recentRentals.length">
                <td colspan="4" class="empty-cell">No vehicle rentals</td>
              </tr>
              <tr v-for="r in recentRentals" :key="r.id">
                <td><code class="booking-num">{{ r.rental_number }}</code></td>
                <td>{{ r.renter_name }}</td>
                <td>{{ formatDate(r.start_date) }}</td>
                <td><span class="badge" :class="statusClass(r.status)">{{ r.status }}</span></td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { RouterLink } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { agencyApi } from '@/api'
import type { Booking, HomestayBooking, VehicleRental } from '@/types'

const auth = useAuthStore()
const loading = ref(true)
const loadingBookings = ref(true)
const dashData = ref<any>(null)
const recentBookings = ref<any[]>([])
const recentHomestayBookings = ref<any[]>([])
const recentRentals = ref<any[]>([])
let refreshInterval: any = null

const statCards = computed(() => {
  if (!dashData.value) return []
  return [
    { icon: '📅', label: 'Total Bookings', value: dashData.value.total_bookings, link: '/operator/bookings' },
    { icon: '⏳', label: 'Pending Bookings', value: dashData.value.pending_bookings, link: '/operator/bookings' },
    { icon: '💰', label: 'Total Revenue', value: `Rp ${(dashData.value.total_revenue || 0).toLocaleString('id-ID')}`, link: '/operator/bookings' },
    { icon: '🗺️', label: 'Active Packages', value: dashData.value.active_packages, link: '/operator/packages' },
    { icon: '🚗', label: 'Active Vehicles', value: dashData.value.active_vehicles, link: '/operator/vehicles' },
    { icon: '🏡', label: 'Active Homestays', value: dashData.value.active_homestays, link: '/operator/homestays' },
  ]
})

function formatDate(d: string) {
  if (!d) return '-'
  return new Date(d).toLocaleDateString('id-ID', { day: '2-digit', month: 'short', year: 'numeric' })
}

function formatPrice(val: number | string) {
  return new Intl.NumberFormat('id-ID').format(Math.round(Number(val || 0)))
}

function statusClass(s: string) {
  switch (s) {
    case 'confirmed': case 'completed': return 'badge-success'
    case 'pending': return 'badge-warning'
    case 'cancelled': return 'badge-danger'
    default: return 'badge-gray'
  }
}

function paymentClass(s: string) {
  switch (s) {
    case 'paid': return 'badge-success'
    case 'pending': return 'badge-warning'
    case 'failed': case 'refunded': return 'badge-danger'
    default: return 'badge-gray'
  }
}

async function refreshAll() {
  try {
    const results = await Promise.allSettled([
      agencyApi.dashboard(),
      agencyApi.bookings({ status: undefined }),
      agencyApi.homestayBookings(),
      agencyApi.rentalBookings(),
    ])

    loading.value = false
    loadingBookings.value = false

    if (results[0].status === 'fulfilled') {
      dashData.value = results[0].value.data
    } else {
      dashData.value = dashData.value || {
        total_bookings: 0, pending_bookings: 0, total_revenue: 0,
        active_packages: 0, active_vehicles: 0, active_homestays: 0
      }
    }

    if (results[1].status === 'fulfilled') {
      const d = results[1].value.data
      recentBookings.value = (Array.isArray(d) ? d : d.results || []).slice(0, 6)
    }

    if (results[2].status === 'fulfilled') {
      const d = results[2].value.data
      recentHomestayBookings.value = (Array.isArray(d) ? d : d.results || []).slice(0, 5)
    }

    if (results[3].status === 'fulfilled') {
      const d = results[3].value.data
      recentRentals.value = (Array.isArray(d) ? d : d.results || []).slice(0, 5)
    }
  } catch {
    loading.value = false
    loadingBookings.value = false
    if (!dashData.value) dashData.value = {
      total_bookings: 0, pending_bookings: 0, total_revenue: 0,
      active_packages: 0, active_vehicles: 0, active_homestays: 0
    }
  }
}

onMounted(async () => {
  await refreshAll()
  refreshInterval = setInterval(refreshAll, 30000)
})

onUnmounted(() => {
  if (refreshInterval) clearInterval(refreshInterval)
})
</script>

<style scoped>
.op-dash__header-row { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 4px; }
.admin-title { font-family: 'Barlow Condensed', sans-serif; font-size: 2rem; font-style: italic; font-weight: 800; margin-bottom: 4px; }
.admin-subtitle { color: var(--w40); font-size: .9rem; margin-bottom: 32px; }

.live-indicator {
  display: flex; align-items: center; gap: 8px;
  background: rgba(34,197,94,0.1); border: 1px solid rgba(34,197,94,0.2);
  color: #4ade80; font-size: 0.75rem; font-weight: 600;
  padding: 6px 12px; border-radius: 99px; text-transform: uppercase; letter-spacing: 0.5px;
  white-space: nowrap;
}
.pulse-dot {
  width: 8px; height: 8px; background: #22c55e; border-radius: 50%;
  box-shadow: 0 0 0 0 rgba(34,197,94,0.7); animation: pulse 2s infinite;
}
@keyframes pulse {
  0% { transform: scale(0.95); box-shadow: 0 0 0 0 rgba(34,197,94,0.7); }
  70% { transform: scale(1); box-shadow: 0 0 0 10px rgba(34,197,94,0); }
  100% { transform: scale(0.95); box-shadow: 0 0 0 0 rgba(34,197,94,0); }
}

.stats-grid { display: grid; grid-template-columns: repeat(3,1fr); gap: 16px; margin-bottom: 40px; }
.stat-card { background: var(--dark2); border: 1px solid var(--w08); border-radius: 16px; padding: 22px; transition: all .3s; }
.stat-card:hover { border-color: var(--blue); box-shadow: 0 0 20px rgba(26,143,255,.15); }
.stat-card__icon { font-size: 1.8rem; margin-bottom: 12px; }
.stat-card__value { font-family: 'Bebas Neue', sans-serif; font-size: 2rem; letter-spacing: 1px; margin-bottom: 4px; }
.stat-card__label { font-size: .75rem; color: var(--w40); text-transform: uppercase; letter-spacing: .8px; margin-bottom: 12px; }
.stat-card__link { font-size: .78rem; color: var(--blue-b); font-weight: 600; }

/* Skeleton */
.skeleton-card { opacity: 0.5; }
.skeleton-icon { width: 40px; height: 40px; background: var(--w08); border-radius: 8px; margin-bottom: 12px; animation: shimmer 1.5s infinite; }
.skeleton-value { width: 80px; height: 28px; background: var(--w08); border-radius: 4px; margin-bottom: 8px; animation: shimmer 1.5s infinite; }
.skeleton-label { width: 120px; height: 14px; background: var(--w08); border-radius: 4px; animation: shimmer 1.5s infinite; }
@keyframes shimmer { 0%,100%{opacity:.5} 50%{opacity:1} }

/* Quick Actions */
.quick-actions { display: grid; grid-template-columns: repeat(6, 1fr); gap: 12px; margin-bottom: 40px; }
.quick-action-btn {
  display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 8px;
  padding: 18px 12px; background: var(--dark2); border: 1px solid var(--w08); border-radius: 14px;
  color: var(--w70); font-size: .82rem; font-weight: 600; transition: all .25s; text-align: center;
}
.quick-action-btn:hover { background: rgba(26,143,255,.1); border-color: var(--blue); color: var(--blue-b); }
.qa-icon { font-size: 1.6rem; }

/* Sections */
.dash-section { margin-bottom: 36px; }
.dash-section__header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px; }
.dash-section__title { font-family: 'Barlow Condensed', sans-serif; font-size: 1.3rem; font-weight: 700; font-style: italic; }
.table-wrap { overflow-x: auto; }
.booking-num { font-family: monospace; font-weight: 700; color: var(--blue-b); font-size: .78rem; }
.user-name { font-weight: 600; }
.price-val { font-weight: 700; }
.empty-cell { text-align: center; color: var(--w40); padding: 32px; }

.dash-row { display: grid; grid-template-columns: 1fr 1fr; gap: 24px; }
.dash-col {}

@media (max-width: 1100px) {
  .stats-grid { grid-template-columns: repeat(2,1fr); }
  .quick-actions { grid-template-columns: repeat(3,1fr); }
  .dash-row { grid-template-columns: 1fr; }
}
@media (max-width: 640px) {
  .stats-grid { grid-template-columns: 1fr 1fr; }
  .quick-actions { grid-template-columns: repeat(2,1fr); }
  .op-dash__header-row { flex-direction: column; gap: 12px; }
}
</style>
