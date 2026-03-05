<template>
  <div class="admin-layout">
    <!-- Sidebar -->
    <aside class="sidebar" :class="{ 'sidebar--open': sidebarOpen }">
      <div class="sidebar__header">
        <div class="sidebar__logo">LOVISTA</div>
        <div class="sidebar__badge badge badge-blue">Admin Panel</div>
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
            <span>{{ item.icon }}</span>
            <span>{{ item.label }}</span>
            <span class="sidebar__nav-badge" v-if="item.badge">{{ item.badge }}</span>
          </RouterLink>
        </div>
      </nav>

      <div class="sidebar__footer">
        <div class="sidebar__user">
          <div class="sidebar__avatar">{{ auth.user?.fullname.charAt(0) }}</div>
          <div>
            <div class="sidebar__user-name">{{ auth.user?.fullname }}</div>
            <div class="sidebar__user-role">Administrator</div>
          </div>
        </div>
        <button class="btn btn-ghost btn-sm" @click="handleLogout">Logout</button>
      </div>
    </aside>

    <!-- Mobile overlay -->
    <div class="sidebar-overlay" v-if="sidebarOpen" @click="sidebarOpen = false"></div>

    <!-- Main content -->
    <div class="admin-main">
      <!-- Top bar -->
      <header class="admin-topbar">
        <button class="admin-topbar__menu hide-desktop" @click="sidebarOpen = !sidebarOpen">☰</button>
        <div class="admin-topbar__breadcrumb">
          <span>Admin</span> / <span>{{ currentPageTitle }}</span>
        </div>
        <div class="admin-topbar__right">
          <span class="badge badge-success">● System Online</span>
        </div>
      </header>

      <main class="admin-content">
        <RouterView />
      </main>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { RouterLink, RouterView, useRoute, useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const auth = useAuthStore()
const router = useRouter()
const route = useRoute()
const sidebarOpen = ref(false)

const currentPageTitle = computed(() => {
  const map: Record<string, string> = {
    '/admin': 'Dashboard', '/admin/destinations': 'Destinations',
    '/admin/users': 'Users', '/admin/operators': 'Operators',
    '/admin/contributions': 'Contributions', '/admin/bookings': 'Bookings',
    '/admin/activity-logs': 'Activity Logs', '/admin/settings': 'Settings',
  }
  return map[route.path] || 'Dashboard'
})

const navGroups = [
  { title: 'Overview', items: [
    { to: '/admin', icon: '📊', label: 'Dashboard' },
  ]},
  { title: 'Content', items: [
    { to: '/admin/destinations', icon: '🏝️', label: 'Destinations' },
    { to: '/admin/contributions', icon: '📝', label: 'Contributions', badge: '5' },
  ]},
  { title: 'Users & Partners', items: [
    { to: '/admin/users', icon: '👥', label: 'Users' },
    { to: '/admin/operators', icon: '🏢', label: 'Operators' },
  ]},
  { title: 'Transactions', items: [
    { to: '/admin/bookings', icon: '📅', label: 'All Bookings' },
  ]},
  { title: 'System', items: [
    { to: '/admin/activity-logs', icon: '📋', label: 'Activity Logs' },
    { to: '/admin/settings', icon: '⚙️', label: 'Settings' },
  ]},
]

function handleLogout() {
  auth.logout()
  router.push('/')
}
</script>

<style scoped>
.admin-layout { display: flex; min-height: 100vh; background: var(--black); }
.sidebar {
  width: 260px; flex-shrink: 0; background: var(--dark1);
  border-right: 1px solid var(--w08);
  display: flex; flex-direction: column;
  position: sticky; top: 0; height: 100vh; overflow-y: auto;
}
.sidebar__header { padding: 24px 20px 16px; }
.sidebar__logo { font-family: 'Bebas Neue', sans-serif; font-size: 1.8rem; letter-spacing: 3px; margin-bottom: 6px; }
.sidebar__nav { flex: 1; padding: 8px 12px; overflow-y: auto; }
.sidebar__nav-group { margin-bottom: 24px; }
.sidebar__nav-group-title { font-size: .65rem; font-weight: 700; text-transform: uppercase; letter-spacing: 1.5px; color: var(--w40); padding: 0 8px; margin-bottom: 6px; }
.sidebar__nav-item {
  display: flex; align-items: center; gap: 10px;
  padding: 10px 12px; border-radius: 10px;
  font-size: .88rem; font-weight: 500; color: var(--w70);
  transition: all .2s; margin-bottom: 2px;
}
.sidebar__nav-item:hover { background: var(--w08); color: var(--white); }
.sidebar__nav-item--active { background: rgba(26,143,255,.15); color: var(--blue-b); border: 1px solid rgba(26,143,255,.2); }
.sidebar__nav-badge { margin-left: auto; background: var(--blue); color: #fff; font-size: .62rem; font-weight: 700; padding: 2px 7px; border-radius: 999px; }
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
.admin-topbar__breadcrumb span:last-child { color: var(--white); font-weight: 600; }
.admin-topbar__right { display: flex; gap: 10px; align-items: center; }
.admin-content { flex: 1; padding: 32px 28px; overflow-y: auto; }
@media (max-width: 900px) {
  .sidebar { position: fixed; left: -260px; top: 0; bottom: 0; z-index: 100; transition: left .3s; }
  .sidebar--open { left: 0; }
}
</style>
