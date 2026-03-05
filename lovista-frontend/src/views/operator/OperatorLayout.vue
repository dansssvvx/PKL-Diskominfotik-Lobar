<template>
  <div class="admin-layout">
    <aside class="sidebar" :class="{ 'sidebar--open': sidebarOpen }">
      <div class="sidebar__header">
        <div class="sidebar__logo">LOVISTA</div>
        <div class="sidebar__badge badge badge-blue">Operator Panel</div>
        <div class="sidebar__agency" v-if="agency">{{ agency.business_name }}</div>
      </div>
      <nav class="sidebar__nav">
        <div class="sidebar__nav-group" v-for="group in navGroups" :key="group.title">
          <div class="sidebar__nav-group-title">{{ group.title }}</div>
          <RouterLink
            v-for="item in group.items" :key="item.to"
            :to="item.to"
            class="sidebar__nav-item"
            :class="{ 'sidebar__nav-item--active': $route.path === item.to }"
            @click="sidebarOpen = false"
          >
            <span>{{ item.icon }}</span><span>{{ item.label }}</span>
          </RouterLink>
        </div>
      </nav>
      <div class="sidebar__footer">
        <div class="sidebar__user">
          <div class="sidebar__avatar">{{ auth.user?.fullname.charAt(0) }}</div>
          <div>
            <div class="sidebar__user-name">{{ auth.user?.fullname }}</div>
            <div class="sidebar__user-role">Operator</div>
          </div>
        </div>
        <button class="btn btn-ghost btn-sm" @click="handleLogout">Logout</button>
      </div>
    </aside>
    <div class="sidebar-overlay" v-if="sidebarOpen" @click="sidebarOpen = false"></div>
    <div class="admin-main">
      <header class="admin-topbar">
        <button class="admin-topbar__menu hide-desktop" @click="sidebarOpen = !sidebarOpen">☰</button>
        <div class="admin-topbar__breadcrumb">
          Operator / <span>{{ currentPageTitle }}</span>
        </div>
        <div class="admin-topbar__right">
          <span class="badge" :class="agency?.is_verified ? 'badge-success' : 'badge-warning'">
            {{ agency?.is_verified ? '✅ Verified' : '⏳ Pending Verification' }}
          </span>
        </div>
      </header>
      <main class="admin-content"><RouterView /></main>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { RouterLink, RouterView, useRoute, useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { agencyApi } from '@/api'
import type { TravelAgency } from '@/types'

const auth = useAuthStore()
const router = useRouter()
const route = useRoute()
const sidebarOpen = ref(false)
const agency = ref<TravelAgency | null>(null)

const currentPageTitle = computed(() => {
  const map: Record<string, string> = {
    '/operator': 'Dashboard', '/operator/packages': 'Packages',
    '/operator/vehicles': 'Vehicles', '/operator/homestays': 'Homestays',
    '/operator/bookings': 'Bookings', '/operator/contributions': 'Contributions',
    '/operator/profile': 'Profile',
  }
  return map[route.path] || 'Dashboard'
})

const navGroups = [
  { title: 'Overview', items: [{ to: '/operator', icon: '📊', label: 'Dashboard' }] },
  { title: 'Services', items: [
    { to: '/operator/packages', icon: '🗺️', label: 'Tour Packages' },
    { to: '/operator/vehicles', icon: '🚗', label: 'Vehicles' },
    { to: '/operator/homestays', icon: '🏡', label: 'Homestays' },
  ]},
  { title: 'Transactions', items: [
    { to: '/operator/bookings', icon: '📅', label: 'Bookings' },
  ]},
  { title: 'Content', items: [
    { to: '/operator/contributions', icon: '📝', label: 'Contributions' },
  ]},
  { title: 'Account', items: [
    { to: '/operator/profile', icon: '🏢', label: 'Agency Profile' },
  ]},
]

function handleLogout() { auth.logout(); router.push('/') }

onMounted(async () => {
  try { const { data } = await agencyApi.me(); agency.value = data } catch { /* */ }
})
</script>

<style scoped>
/* Reuse admin-layout styles */
.admin-layout { display: flex; min-height: 100vh; background: var(--black); }
.sidebar { width: 260px; flex-shrink: 0; background: var(--dark1); border-right: 1px solid var(--w08); display: flex; flex-direction: column; position: sticky; top: 0; height: 100vh; overflow-y: auto; }
.sidebar__header { padding: 24px 20px 16px; }
.sidebar__logo { font-family: 'Bebas Neue', sans-serif; font-size: 1.8rem; letter-spacing: 3px; margin-bottom: 6px; }
.sidebar__agency { font-size: .78rem; color: var(--w40); margin-top: 8px; }
.sidebar__nav { flex: 1; padding: 8px 12px; overflow-y: auto; }
.sidebar__nav-group { margin-bottom: 24px; }
.sidebar__nav-group-title { font-size: .65rem; font-weight: 700; text-transform: uppercase; letter-spacing: 1.5px; color: var(--w40); padding: 0 8px; margin-bottom: 6px; }
.sidebar__nav-item { display: flex; align-items: center; gap: 10px; padding: 10px 12px; border-radius: 10px; font-size: .88rem; font-weight: 500; color: var(--w70); transition: all .2s; margin-bottom: 2px; }
.sidebar__nav-item:hover { background: var(--w08); color: var(--white); }
.sidebar__nav-item--active { background: rgba(26,143,255,.15); color: var(--blue-b); border: 1px solid rgba(26,143,255,.2); }
.sidebar__footer { padding: 16px 20px; border-top: 1px solid var(--w08); display: flex; justify-content: space-between; align-items: center; gap: 10px; }
.sidebar__user { display: flex; align-items: center; gap: 10px; min-width: 0; }
.sidebar__avatar { width: 32px; height: 32px; border-radius: 50%; background: var(--blue); display: flex; align-items: center; justify-content: center; font-weight: 700; font-size: .85rem; flex-shrink: 0; }
.sidebar__user-name { font-size: .82rem; font-weight: 700; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.sidebar__user-role { font-size: .68rem; color: var(--w40); }
.sidebar-overlay { position: fixed; inset: 0; background: rgba(0,0,0,.6); z-index: 99; }
.admin-main { flex: 1; display: flex; flex-direction: column; min-width: 0; }
.admin-topbar { height: 60px; background: var(--dark1); border-bottom: 1px solid var(--w08); display: flex; align-items: center; justify-content: space-between; padding: 0 28px; position: sticky; top: 0; z-index: 50; }
.admin-topbar__menu { background: none; border: none; color: var(--white); font-size: 1.3rem; cursor: pointer; }
.admin-topbar__breadcrumb { font-size: .85rem; color: var(--w40); }
.admin-topbar__breadcrumb span { color: var(--white); font-weight: 600; }
.admin-topbar__right { display: flex; gap: 10px; }
.admin-content { flex: 1; padding: 32px 28px; }
@media (max-width: 900px) {
  .sidebar { position: fixed; left: -260px; top: 0; bottom: 0; z-index: 100; transition: left .3s; }
  .sidebar--open { left: 0; }
}
</style>
