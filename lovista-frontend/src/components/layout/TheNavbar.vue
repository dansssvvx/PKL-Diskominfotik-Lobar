<template>
  <nav class="navbar" :class="{ 'navbar--solid': isScrolled }">
    <RouterLink to="/" class="navbar__logo">
      <img src="/logo.png" alt="Lombok Barat" class="navbar__logo-img" @error="logoError = true" v-if="!logoError" />
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
      <!-- Notification bell (logged in) -->
      <button v-if="auth.isLoggedIn" class="navbar__icon-btn" @click="goNotifications">
        <span class="navbar__notif-badge" v-if="unreadCount > 0">{{ unreadCount }}</span>
        🔔
      </button>

      <!-- Auth buttons -->
      <template v-if="!auth.isLoggedIn">
        <RouterLink to="/login" class="btn btn-ghost btn-sm">Login</RouterLink>
        <RouterLink to="/register" class="btn btn-primary btn-sm">Register</RouterLink>
      </template>

      <!-- User menu -->
      <div v-else class="navbar__user" @click="userMenuOpen = !userMenuOpen">
        <div class="navbar__avatar">
          {{ auth.user?.fullname.charAt(0).toUpperCase() }}
        </div>
        <span class="navbar__username hide-mobile">{{ auth.user?.fullname.split(' ')[0] }}</span>

        <!-- Dropdown -->
        <Transition name="fade">
          <div class="navbar__dropdown" v-if="userMenuOpen" v-click-outside="() => userMenuOpen = false">
            <div class="navbar__dropdown-header">
              <div class="navbar__dropdown-name">{{ auth.user?.fullname }}</div>
              <div class="navbar__dropdown-email">{{ auth.user?.email }}</div>
              <span class="badge badge-blue">{{ auth.user?.role?.display_name }}</span>
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
const logoError = ref(false)
const unreadCount = ref(0)

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

function goNotifications() {
  router.push('/profile#notifications')
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
  position: fixed; top: 0; left: 0; right: 0; z-index: 100;
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
