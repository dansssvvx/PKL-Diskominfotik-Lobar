<template>
  <div class="admin-dash">
    <div class="admin-dash__header-row">
      <div>
        <h1 class="admin-dash__title">Dashboard Overview</h1>
        <p class="admin-dash__sub">Welcome back, {{ auth.user?.fullname }} — here's what's happening today.</p>
      </div>
      <div class="live-indicator">
        <span class="pulse-dot"></span>
        Live Updates Active
      </div>
    </div>

    <!-- Stats grid -->
    <div class="stats-grid" v-if="stats">
      <div class="stat-card" v-for="s in statCards" :key="s.label">
        <div class="stat-card__icon">{{ s.icon }}</div>
        <div class="stat-card__value">{{ s.value }}</div>
        <div class="stat-card__label">{{ s.label }}</div>
        <RouterLink :to="s.link" class="stat-card__link">View →</RouterLink>
      </div>
    </div>
    <div class="page-loader" v-else><div class="spinner"></div></div>

    <!-- Pending contributions -->
    <div class="dash-section">
      <div class="dash-section__header">
        <h2 class="dash-section__title">Pending Contributions</h2>
        <RouterLink to="/admin/contributions" class="btn btn-ghost btn-sm">View All</RouterLink>
      </div>
      <div class="table-wrap card">
        <table class="table">
          <thead>
            <tr>
              <th>Contributor</th><th>Type</th><th>Submitted</th><th>Status</th><th>Actions</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="c in pendingContributions" :key="c.id">
              <td>{{ c.contributor?.fullname }}</td>
              <td><span class="badge badge-blue">{{ c.type }}</span></td>
              <td>{{ formatDate(c.submitted_at) }}</td>
              <td><span class="badge badge-warning">Pending</span></td>
              <td>
                <div style="display:flex;gap:6px">
                  <button class="btn btn-success btn-sm" @click="reviewContribution(c.id,'approve')">✓ Approve</button>
                  <button class="btn btn-danger btn-sm" @click="reviewContribution(c.id,'reject')">✗ Reject</button>
                </div>
              </td>
            </tr>
            <tr v-if="!pendingContributions.length">
              <td colspan="5" style="text-align:center;color:var(--w40);padding:32px">No pending contributions</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- Recent activity logs -->
    <div class="dash-section">
      <div class="dash-section__header">
        <h2 class="dash-section__title">Recent Activity</h2>
        <RouterLink to="/admin/activity-logs" class="btn btn-ghost btn-sm">View All</RouterLink>
      </div>
      <div class="table-wrap card">
        <table class="table">
          <thead>
            <tr><th>User</th><th>Action</th><th>Entity</th><th>Time</th></tr>
          </thead>
          <tbody>
            <tr v-for="log in recentLogs" :key="log.id">
              <td>{{ log.user_fullname || 'System' }}</td>
              <td>{{ log.action }}</td>
              <td>{{ log.entity_type }} #{{ log.entity_id }}</td>
              <td>{{ formatFullDate(log.created_at) }}</td>
            </tr>
            <tr v-if="!recentLogs.length">
              <td colspan="4" style="text-align:center;color:var(--w40);padding:32px">No activity yet</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { RouterLink } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { adminApi, contributionApi } from '@/api'
import type { ActivityLog, Contribution } from '@/types'

const auth = useAuthStore()
const stats = ref<any>(null)
const pendingContributions = ref<Contribution[]>([])
const recentLogs = ref<ActivityLog[]>([])
let refreshInterval: any = null

const statCards = computed(() => {
  if (!stats.value) return []
  return [
    { icon: '🏝️', label: 'Total Destinations', value: stats.value.total_destinations, link: '/admin/destinations' },
    { icon: '👥', label: 'Total Users', value: stats.value.total_users, link: '/admin/users' },
    { icon: '📅', label: 'Total Bookings', value: stats.value.total_bookings, link: '/admin/bookings' },
    { icon: '🚗', label: 'Total Vehicles', value: stats.value.total_vehicles, link: '/admin/rent' },
    { icon: '💰', label: 'Total Revenue', value: `Rp ${stats.value.total_revenue.toLocaleString('id-ID')}`, link: '/admin/bookings' },
    { icon: '⏳', label: 'Pending Contributions', value: stats.value.pending_contributions, link: '/admin/contributions' },
    { icon: '🏢', label: 'Active Operators', value: stats.value.active_operators, link: '/admin/operators' },
  ]
})

function formatDate(d: string) {
  return new Date(d).toLocaleDateString('id-ID', { day: '2-digit', month: 'short', year: 'numeric' })
}

function formatFullDate(d: string) {
  return new Date(d).toLocaleString('id-ID', {
    day: '2-digit', month: 'short', year: 'numeric',
    hour: '2-digit', minute: '2-digit'
  })
}

async function reviewContribution(id: number, action: 'approve' | 'reject') {
  try {
    await contributionApi.review(id, action)
    pendingContributions.value = pendingContributions.value.filter(c => c.id !== id)
    if (stats.value) stats.value.pending_contributions--
  } catch { /* handle */ }
}

async function refreshAll() {
  try {
    const results = await Promise.allSettled([
      adminApi.stats(),
      contributionApi.list({ status: 'pending' }),
      adminApi.activityLogs(),
    ])
    
    if (results[0].status === 'fulfilled') {
      stats.value = results[0].value.data
    } else {
      console.error('Failed to fetch stats:', results[0].reason)
      // Fallback stats to stop loading loop
      stats.value = stats.value || {
        total_destinations: 0, total_users: 0, total_bookings: 0,
        total_revenue: 0, pending_contributions: 0, active_operators: 0
      }
    }
    
    if (results[1].status === 'fulfilled') {
      const contribData = results[1].value.data
      pendingContributions.value = (Array.isArray(contribData) ? contribData : contribData.results || []).slice(0, 5)
    }
    
    if (results[2].status === 'fulfilled') {
      const logsData = results[2].value.data
      recentLogs.value = (Array.isArray(logsData) ? logsData : logsData.results || []).slice(0, 8)
    }
  } catch (error) {
    console.error('Critical error in dashboard refresh:', error)
    // Ensure stats is not null to break loading loop
    if (!stats.value) stats.value = {}
  }
}

onMounted(async () => {
  // Initial load
  await refreshAll()
  
  // Set polling interval (every 30 seconds)
  refreshInterval = setInterval(refreshAll, 30000)
})

onUnmounted(() => {
  if (refreshInterval) clearInterval(refreshInterval)
})
</script>

<style scoped>
.admin-dash__header-row { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 4px; }
.admin-dash__title { font-family: 'Barlow Condensed', sans-serif; font-size: 2rem; font-style: italic; font-weight: 800; margin-bottom: 4px; }
.admin-dash__sub { color: var(--w40); font-size: .9rem; margin-bottom: 32px; }

.live-indicator {
  display: flex; align-items: center; gap: 8px;
  background: rgba(34, 197, 94, 0.1); border: 1px solid rgba(34, 197, 94, 0.2);
  color: #4ade80; font-size: 0.75rem; font-weight: 600;
  padding: 6px 12px; border-radius: 99px; text-transform: uppercase; letter-spacing: 0.5px;
}

.pulse-dot {
  width: 8px; height: 8px; background: #22c55e; border-radius: 50%;
  box-shadow: 0 0 0 0 rgba(34, 197, 94, 0.7);
  animation: pulse 2s infinite;
}

@keyframes pulse {
  0% { transform: scale(0.95); box-shadow: 0 0 0 0 rgba(34, 197, 94, 0.7); }
  70% { transform: scale(1); box-shadow: 0 0 0 10px rgba(34, 197, 94, 0); }
  100% { transform: scale(0.95); box-shadow: 0 0 0 0 rgba(34, 197, 94, 0); }
}

.stats-grid { display: grid; grid-template-columns: repeat(3,1fr); gap: 16px; margin-bottom: 40px; }
.stat-card { background: var(--dark2); border: 1px solid var(--w08); border-radius: 16px; padding: 22px; transition: all .3s; }
.stat-card:hover { border-color: var(--blue); box-shadow: 0 0 20px rgba(26,143,255,.15); }
.stat-card__icon { font-size: 1.8rem; margin-bottom: 12px; }
.stat-card__value { font-family: 'Bebas Neue', sans-serif; font-size: 2rem; letter-spacing: 1px; margin-bottom: 4px; }
.stat-card__label { font-size: .75rem; color: var(--w40); text-transform: uppercase; letter-spacing: .8px; margin-bottom: 12px; }
.stat-card__link { font-size: .78rem; color: var(--blue-b); font-weight: 600; }
.dash-section { margin-bottom: 36px; }
.dash-section__header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px; }
.dash-section__title { font-family: 'Barlow Condensed', sans-serif; font-size: 1.3rem; font-weight: 700; font-style: italic; }
.table-wrap { overflow-x: auto; }
@media (max-width: 900px) { .stats-grid { grid-template-columns: repeat(2,1fr); } }
</style>
