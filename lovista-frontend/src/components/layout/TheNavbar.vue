<template>
  <nav class="navbar" :class="{ 'navbar--solid': isScrolled }">
    <RouterLink to="/" class="navbar__logo">
      <img src="/Logo.png" alt="Lombok Barat" class="navbar__logo-img" @error="logoError = true" v-if="!logoError" />
      <span class="navbar__logo-fallback" v-else>🏛️</span>
    </RouterLink>

    <!-- Nav pill links -->
    <div class="navbar__pill">
      <RouterLink
        v-for="link in navLinks"
        :key="link.to"
        :to="link.to"
        class="navbar__link"
        :class="{ 'navbar__link--active': isActive(link.to) }"
      >
        {{ link.label }}
      </RouterLink>
    </div>

    <!-- Right side -->
    <div class="navbar__right">
      <!-- Notification bell -->
      <div v-if="auth.isLoggedIn" class="navbar__notif-container">
        <button class="navbar__icon-btn" @click.stop="toggleNotif">
          <span class="navbar__notif-badge" v-if="unreadCount > 0">{{ unreadCount }}</span>
          🔔
        </button>

        <!-- Notification Dropdown -->
        <Transition name="fade">
          <div class="navbar__notif-dropdown" v-if="notifOpen" v-click-outside="() => notifOpen = false">
            <div class="notif-header">
              <span>Notifications</span>
              <button class="mark-read-btn" @click="markAllRead">Mark all read</button>
            </div>
            <div class="notif-list">
              <div v-if="notifications.length === 0" class="notif-empty">
                No notifications yet
              </div>
              <div 
                v-for="notif in notifications" 
                :key="notif.id" 
                class="notif-item"
                :class="{ 'notif-item--unread': !notif.is_read }"
              >
                <div class="notif-content">
                  <div class="notif-title">{{ notif.title }}</div>
                  <div class="notif-message">{{ notif.message }}</div>
                  <div class="notif-time">{{ formatTime(notif.created_at) }}</div>
                </div>
              </div>
            </div>
            <RouterLink to="/profile" class="notif-footer" @click="notifOpen = false">
              See all notifications
            </RouterLink>
          </div>
        </Transition>
      </div>

      <!-- Auth buttons -->
      <template v-if="!auth.isLoggedIn">
        <RouterLink to="/login" class="btn btn-ghost btn-sm">Login</RouterLink>
        <RouterLink to="/register" class="btn btn-primary btn-sm">Register</RouterLink>
      </template>

      <!-- User menu -->
      <div v-else class="navbar__user-wrapper">
        <div class="navbar__user" @click.stop="toggleUserMenu">
          <div class="navbar__avatar">
            <img v-if="auth.user?.profile_photo" :src="getPhotoUrl(auth.user.profile_photo)" class="navbar__avatar-img" />
            <span v-else>{{ auth.user?.fullname.charAt(0).toUpperCase() }}</span>
          </div>
          <span class="navbar__username hide-mobile">{{ auth.user?.fullname.split(' ')[0] }}</span>
          <span class="navbar__chevron">▾</span>
        </div>

        <!-- Dropdown -->
        <Transition name="fade">
          <div class="navbar__dropdown" v-if="userMenuOpen" v-click-outside="() => userMenuOpen = false">
            <div class="navbar__dropdown-header">
              <div class="navbar__dropdown-name">{{ auth.user?.fullname }}</div>
              <div class="navbar__dropdown-email">{{ auth.user?.email }}</div>
              <span class="badge badge-blue">{{ auth.user?.role?.display_name || 'Traveler' }}</span>
            </div>
            <div class="navbar__dropdown-divider"></div>
            <RouterLink to="/profile" class="navbar__dropdown-item" @click="userMenuOpen = false">
              👤 My Profile
            </RouterLink>
            <RouterLink to="/my-bookings" class="navbar__dropdown-item" @click="userMenuOpen = false">
              📅 My Bookings
            </RouterLink>
            <RouterLink to="/wishlist" class="navbar__dropdown-item" @click="userMenuOpen = false">
              ❤️ Wishlist
            </RouterLink>
            <template v-if="auth.isOperator">
              <div class="navbar__dropdown-divider"></div>
              <RouterLink to="/operator" class="navbar__dropdown-item" @click="userMenuOpen = false">
                🏢 Operator Dashboard
              </RouterLink>
            </template>
            <template v-if="auth.isAdmin">
              <div class="navbar__dropdown-divider"></div>
              <RouterLink to="/admin" class="navbar__dropdown-item" @click="userMenuOpen = false">
                ⚙️ Admin Dashboard
              </RouterLink>
            </template>
            <div class="navbar__dropdown-divider"></div>
            <button class="navbar__dropdown-item navbar__dropdown-item--danger" @click="handleLogout">
              🚪 Logout
            </button>
          </div>
        </Transition>
      </div>
    </div>
  </nav>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue'
import { RouterLink, useRouter, useRoute } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { notificationApi } from '@/api'

const auth = useAuthStore()
const router = useRouter()
const route = useRoute()

const isScrolled = ref(false)
const userMenuOpen = ref(false)
const notifOpen = ref(false)
const logoError = ref(false)
const unreadCount = ref(0)
const notifications = ref<any[]>([])

const navLinks = [
  { to: '/destinations', label: 'Destination' },
  { to: '/packages', label: 'Tour Package' },
  { to: '/culture', label: 'Culture' },
  { to: '/culinaries', label: 'Culinaries' },
  { to: '/rent', label: 'Rent' },
]

function isActive(path: string) {
  return route.path.startsWith(path)
}

function toggleUserMenu() {
  userMenuOpen.value = !userMenuOpen.value
  if (userMenuOpen.value) notifOpen.value = false
}

const getPhotoUrl = (path: string) => {
  if (!path) return ''
  if (path.startsWith('http')) return path
  return `http://127.0.0.1:8000${path}`
}

function toggleNotif() {
  notifOpen.value = !notifOpen.value
  if (notifOpen.value) {
    fetchLatestNotifications()
    userMenuOpen.value = false
  }
}

async function fetchLatestNotifications() {
  try {
    const { data } = await notificationApi.list()
    // Display only latest 5
    notifications.value = data.results.slice(0, 5)
  } catch { /* silent */ }
}

async function markAllRead() {
  try {
    await notificationApi.markAllRead()
    unreadCount.value = 0
    notifications.value = notifications.value.map(n => ({ ...n, is_read: true }))
  } catch { /* silent */ }
}

function formatTime(dateString: string) {
  const date = new Date(dateString)
  return date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })
}

async function handleLogout() {
  auth.logout()
  userMenuOpen.value = false
  router.push('/')
}

async function fetchUnreadCount() {
  if (!auth.isLoggedIn) return
  try {
    const { data } = await notificationApi.unreadCount()
    unreadCount.value = data.count
  } catch { /* silent */ }
}

const handleScroll = () => { isScrolled.value = window.scrollY > 50 }

onMounted(() => {
  window.addEventListener('scroll', handleScroll)
  fetchUnreadCount()
})
onUnmounted(() => window.removeEventListener('scroll', handleScroll))
</script>

<style scoped>
.navbar {
  position: fixed; top: 0; left: 0; right: 0; z-index: 1000;
  display: flex; align-items: center; justify-content: space-between;
  padding: 16px 40px;
  transition: background 0.4s, box-shadow 0.4s;
}
.navbar--solid {
  background: rgba(5,6,8,0.92);
  backdrop-filter: blur(20px);
  box-shadow: 0 1px 0 rgba(255,255,255,0.06);
}
.navbar__logo { display: flex; align-items: center; flex-shrink: 0; }
.navbar__logo-img { width: 54px; height: 54px; object-fit: contain; }
.navbar__logo-fallback { font-size: 2rem; }

.navbar__pill {
  display: flex; align-items: center;
  background: rgba(255,255,255,0.08);
  border: 1px solid rgba(255,255,255,0.12);
  border-radius: 999px; padding: 5px; gap: 2px;
  backdrop-filter: blur(12px);
}
.navbar__link {
  padding: 9px 20px; border-radius: 999px;
  font-size: 0.88rem; font-weight: 500;
  color: rgba(255,255,255,0.7);
  transition: all 0.25s; white-space: nowrap;
}
.navbar__link:hover { color: #fff; background: rgba(255,255,255,0.08); }
.navbar__link--active { background: #fff; color: #050608; font-weight: 700; }

.navbar__right { display: flex; align-items: center; gap: 10px; }

.navbar__notif-container { position: relative; }

.navbar__notif-dropdown {
  position: absolute; top: calc(100% + 15px); right: 0;
  background: #111318; border: 1px solid rgba(255,255,255,0.12);
  border-radius: 16px; min-width: 320px;
  box-shadow: 0 16px 50px rgba(0,0,0,0.7);
  overflow: hidden; z-index: 200;
}

.notif-header {
  padding: 16px; display: flex; justify-content: space-between;
  align-items: center; border-bottom: 1px solid rgba(255,255,255,0.06);
}
.notif-header span { font-weight: 700; font-size: 0.95rem; }
.mark-read-btn {
  background: none; border: none; color: var(--blue);
  font-size: 0.75rem; font-weight: 600; cursor: pointer;
}

.notif-list { max-height: 360px; overflow-y: auto; }
.notif-item {
  padding: 16px; border-bottom: 1px solid rgba(255,255,255,0.04);
  transition: background 0.2s;
}
.notif-item:hover { background: rgba(255,255,255,0.03); }
.notif-item--unread { background: rgba(26,143,255,0.05); }
.notif-title { font-weight: 600; font-size: 0.88rem; margin-bottom: 4px; color: #fff; }
.notif-message { font-size: 0.82rem; color: rgba(255,255,255,0.5); line-height: 1.4; }
.notif-time { font-size: 0.7rem; color: var(--blue); margin-top: 8px; font-weight: 600; }

.notif-empty { padding: 40px 20px; text-align: center; color: rgba(255,255,255,0.3); font-size: 0.85rem; }
.notif-footer {
  display: block; padding: 14px; text-align: center;
  background: rgba(255,255,255,0.03); font-size: 0.82rem;
  font-weight: 600; color: rgba(255,255,255,0.5);
}
.notif-footer:hover { color: #fff; background: rgba(255,255,255,0.06); }

.navbar__icon-btn {
  position: relative; width: 38px; height: 38px; border-radius: 50%;
  background: rgba(255,255,255,0.08); border: 1px solid rgba(255,255,255,0.12);
  color: #fff; font-size: 1rem;
  display: flex; align-items: center; justify-content: center;
  transition: all 0.25s;
}
.navbar__icon-btn:hover { background: rgba(255,255,255,0.15); }
.navbar__notif-badge {
  position: absolute; top: -3px; right: -3px;
  width: 18px; height: 18px; border-radius: 50%;
  background: #ef4444; font-size: 0.6rem; font-weight: 700;
  display: flex; align-items: center; justify-content: center;
  border: 2px solid #050608;
}

.navbar__user {
  position: relative; display: flex; align-items: center; gap: 8px;
  cursor: pointer; padding: 6px 14px 6px 6px;
  background: rgba(255,255,255,0.08);
  border: 1px solid rgba(255,255,255,0.12);
  border-radius: 999px;
  transition: all 0.25s;
}
.navbar__user:hover { background: rgba(255,255,255,0.12); }
.navbar__avatar {
  width: 30px; height: 30px; border-radius: 50%;
  background: var(--blue); display: flex; align-items: center;
  justify-content: center; font-weight: 700; font-size: 0.85rem;
}
.navbar__username { font-size: 0.85rem; font-weight: 600; }

.navbar__dropdown {
  position: absolute; top: calc(100% + 10px); right: 0;
  background: #111318; border: 1px solid rgba(255,255,255,0.12);
  border-radius: 16px; min-width: 220px;
  box-shadow: 0 16px 50px rgba(0,0,0,0.7);
  overflow: hidden; z-index: 200;
}
.navbar__dropdown-header { padding: 16px; }
.navbar__dropdown-name { font-weight: 700; font-size: 0.92rem; margin-bottom: 2px; }
.navbar__dropdown-email { font-size: 0.75rem; color: rgba(255,255,255,0.4); margin-bottom: 8px; }
.navbar__dropdown-divider { height: 1px; background: rgba(255,255,255,0.06); }
.navbar__dropdown-item {
  display: flex; align-items: center; gap: 8px;
  padding: 12px 16px; font-size: 0.86rem; font-weight: 500;
  color: rgba(255,255,255,0.7); width: 100%;
  background: none; border: none; text-align: left;
  transition: all 0.2s; cursor: pointer;
}
.navbar__dropdown-item:hover { background: rgba(255,255,255,0.06); color: #fff; }
.navbar__dropdown-item--danger:hover { background: rgba(239,68,68,0.1); color: #f87171; }

@media (max-width: 900px) {
  .navbar { padding: 14px 20px; }
  .navbar__pill { display: none; }
}
</style>
