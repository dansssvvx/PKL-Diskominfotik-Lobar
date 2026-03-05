<template>
  <div>
    <h1 class="admin-dash__title">Operator Dashboard</h1>
    <p class="admin-dash__sub">Manage your services and bookings, {{ auth.user?.fullname }}</p>

    <div class="stats-grid" v-if="dashData">
      <div class="stat-card" v-for="s in statCards" :key="s.label">
        <div class="stat-card__icon">{{ s.icon }}</div>
        <div class="stat-card__value">{{ s.value }}</div>
        <div class="stat-card__label">{{ s.label }}</div>
      </div>
    </div>
    <div class="page-loader" v-else><div class="spinner"></div></div>

    <!-- Recent bookings -->
    <div class="dash-section">
      <div class="dash-section__header">
        <h2 class="dash-section__title">Recent Bookings</h2>
        <RouterLink to="/operator/bookings" class="btn btn-ghost btn-sm">View All</RouterLink>
      </div>
      <div class="table-wrap card">
        <table class="table">
          <thead>
            <tr><th>Booking #</th><th>Package</th><th>Customer</th><th>Date</th><th>Status</th><th>Payment</th></tr>
          </thead>
          <tbody>
            <tr v-for="b in recentBookings" :key="b.id">
              <td><code style="font-size:.78rem;color:var(--blue-b)">{{ b.booking_number }}</code></td>
              <td>{{ b.package?.name }}</td>
              <td>{{ b.user?.fullname }}</td>
              <td>{{ formatDate(b.start_date) }}</td>
              <td>
                <span class="badge" :class="statusClass(b.status)">{{ b.status }}</span>
              </td>
              <td>
                <span class="badge" :class="paymentClass(b.payment_status)">{{ b.payment_status }}</span>
              </td>
            </tr>
            <tr v-if="!recentBookings.length">
              <td colspan="6" style="text-align:center;color:var(--w40);padding:32px">No bookings yet</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { RouterLink } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { agencyApi } from '@/api'
import type { Booking } from '@/types'

const auth = useAuthStore()
const dashData = ref<Awaited<ReturnType<typeof agencyApi.dashboard>>['data'] | null>(null)
const recentBookings = ref<Booking[]>([])

const statCards = computed(() => {
  if (!dashData.value) return []
  return [
    { icon: '📅', label: 'Total Bookings', value: dashData.value.total_bookings },
    { icon: '⏳', label: 'Pending Bookings', value: dashData.value.pending_bookings },
    { icon: '💰', label: 'Total Revenue', value: `Rp ${dashData.value.total_revenue.toLocaleString('id-ID')}` },
    { icon: '🗺️', label: 'Active Packages', value: dashData.value.active_packages },
    { icon: '🚗', label: 'Active Vehicles', value: dashData.value.active_vehicles },
    { icon: '🏡', label: 'Active Homestays', value: dashData.value.active_homestays },
  ]
})

function formatDate(d: string) {
  return new Date(d).toLocaleDateString('id-ID', { day: '2-digit', month: 'short', year: 'numeric' })
}

function statusClass(s: string) {
  return { 'badge-warning': s === 'pending', 'badge-success': s === 'confirmed' || s === 'completed', 'badge-danger': s === 'cancelled' }
}

function paymentClass(s: string) {
  return { 'badge-warning': s === 'pending', 'badge-success': s === 'paid', 'badge-danger': s === 'failed' || s === 'refunded' }
}

onMounted(async () => {
  try {
    const [dashRes, bookRes] = await Promise.all([
      agencyApi.dashboard(),
      agencyApi.bookings({ status: undefined }),
    ])
    dashData.value = dashRes.data
    recentBookings.value = bookRes.data.results.slice(0, 8)
  } catch { /* handle */ }
})
</script>

<style scoped>
.admin-dash__title { font-family: 'Barlow Condensed', sans-serif; font-size: 2rem; font-style: italic; font-weight: 800; margin-bottom: 4px; }
.admin-dash__sub { color: var(--w40); font-size: .9rem; margin-bottom: 32px; }
.stats-grid { display: grid; grid-template-columns: repeat(3,1fr); gap: 16px; margin-bottom: 40px; }
.stat-card { background: var(--dark2); border: 1px solid var(--w08); border-radius: 16px; padding: 22px; transition: all .3s; }
.stat-card:hover { border-color: var(--blue); }
.stat-card__icon { font-size: 1.8rem; margin-bottom: 12px; }
.stat-card__value { font-family: 'Bebas Neue', sans-serif; font-size: 2rem; letter-spacing: 1px; margin-bottom: 4px; }
.stat-card__label { font-size: .75rem; color: var(--w40); text-transform: uppercase; letter-spacing: .8px; }
.dash-section { margin-bottom: 36px; }
.dash-section__header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px; }
.dash-section__title { font-family: 'Barlow Condensed', sans-serif; font-size: 1.3rem; font-weight: 700; font-style: italic; }
.table-wrap { overflow-x: auto; }
@media (max-width: 900px) { .stats-grid { grid-template-columns: repeat(2,1fr); } }
</style>
