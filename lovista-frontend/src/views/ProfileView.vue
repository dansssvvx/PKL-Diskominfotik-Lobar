<template>
  <div class="profile-page">
    <div class="container slide-up-enter-active">
      <div class="profile-layout">
        <!-- Sidebar Navigation -->
        <aside class="profile-sidebar">
          <div class="user-brief">
            <div class="user-avatar-container" @click="triggerPhotoUpload">
              <div class="user-avatar-lg" v-if="!authStore.user?.profile_photo">
                {{ authStore.user?.fullname.charAt(0).toUpperCase() }}
              </div>
              <img 
                v-else 
                :src="getPhotoUrl(authStore.user.profile_photo)" 
                class="user-avatar-img"
              />
              <div class="avatar-overlay">
                <span>📸 Change</span>
              </div>
              <input 
                type="file" 
                ref="photoInput" 
                class="hidden-input" 
                accept="image/*"
                @change="onFileSelected"
              />
            </div>
            <h3 class="user-name">{{ authStore.user?.fullname }}</h3>
            <p class="user-role-badge badge badge-blue">{{ authStore.user?.role?.display_name || 'Traveler' }}</p>
          </div>

          <nav class="sidebar-nav">
            <button 
              v-for="tab in tabs" 
              :key="tab.id"
              class="nav-item"
              :class="{ 'nav-item--active': activeTab === tab.id }"
              @click="activeTab = tab.id"
            >
              <span class="icon">{{ tab.icon }}</span>
              {{ tab.label }}
            </button>
            <div class="divider"></div>
            <button class="nav-item nav-item--danger" @click="handleLogout">
              <span class="icon">🚪</span>
              Logout
            </button>
          </nav>
        </aside>

        <!-- Main Content Area -->
        <main class="profile-content card">
          <!-- Overview / Profile Info -->
          <div v-if="activeTab === 'overview'" class="tab-pane">
            <h2 class="font-display">PERSONAL INFORMATION</h2>
            <div class="divider"></div>
            
            <div class="info-grid">
              <div class="info-item">
                <label class="form-label">Full Name</label>
                <div class="info-value">{{ authStore.user?.fullname }}</div>
              </div>
              <div class="info-item">
                <label class="form-label">Email Address</label>
                <div class="info-value">{{ authStore.user?.email }}</div>
              </div>
              <div class="info-item">
                <label class="form-label">Phone Number</label>
                <div class="info-value">{{ authStore.user?.phone || 'Not provided' }}</div>
              </div>
              <div class="info-item">
                <label class="form-label">Account Status</label>
                <div class="info-value">
                  <span class="badge" :class="authStore.user?.is_verified ? 'badge-success' : 'badge-warning'">
                    {{ authStore.user?.is_verified ? 'Verified' : 'Pending Verification' }}
                  </span>
                </div>
              </div>
              <div class="info-item">
                <label class="form-label">Joined Since</label>
                <div class="info-value">{{ formatDate(authStore.user?.created_at) }}</div>
              </div>
            </div>

            <div class="action-footer">
              <button class="btn btn-ghost btn-sm">Edit Profile</button>
            </div>
          </div>

          <!-- My Bookings Placeholder -->
          <div v-if="activeTab === 'bookings'" class="tab-pane">
            <h2 class="font-display">MY BOOKINGS</h2>
            <div class="divider"></div>
            <div class="empty-state">
              <div class="icon">📅</div>
              <h3>No bookings found</h3>
              <p>Start your adventure by booking a tour package or homestay.</p>
              <RouterLink to="/packages" class="btn btn-primary btn-sm mt-4">Explore Packages</RouterLink>
            </div>
          </div>

          <!-- Notifications Placeholder -->
          <div v-if="activeTab === 'notifications'" class="tab-pane">
            <h2 class="font-display">NOTIFICATIONS</h2>
            <div class="divider"></div>
            <div class="empty-state">
              <div class="icon">🔔</div>
              <h3>You're all caught up!</h3>
              <p>New notifications will appear here.</p>
            </div>
          </div>

          <!-- Settings Placeholder -->
          <div v-if="activeTab === 'settings'" class="tab-pane">
            <h2 class="font-display">ACCOUNT SETTINGS</h2>
            <div class="divider"></div>
            <div class="settings-list">
              <div class="settings-item">
                <div class="settings-text">
                  <h4>Email Notifications</h4>
                  <p>Receive updates about your bookings via email.</p>
                </div>
                <div class="toggle-switch"></div>
              </div>
              <div class="settings-item">
                <div class="settings-text">
                  <h4>Public Profile</h4>
                  <p>Make your profile visible to other travelers.</p>
                </div>
                <div class="toggle-switch"></div>
              </div>
              <div class="settings-item">
                <div class="settings-text">
                  <h4>Change Password</h4>
                  <p>Update your account security credentials.</p>
                </div>
                <button class="btn btn-ghost btn-sm">Update</button>
              </div>
            </div>
          </div>
        </main>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useAuthStore } from '@/stores/auth'
import { useRouter } from 'vue-router'
import { authApi } from '@/api'

const authStore = useAuthStore()
const router = useRouter()
const activeTab = ref('overview')
const photoInput = ref<HTMLInputElement | null>(null)

const tabs = [
  { id: 'overview', label: 'My Profile', icon: '👤' },
  { id: 'bookings', label: 'Bookings', icon: '📅' },
  { id: 'notifications', label: 'Notifications', icon: '🔔' },
  { id: 'settings', label: 'Settings', icon: '⚙️' },
]

const triggerPhotoUpload = () => {
  photoInput.value?.click()
}

const onFileSelected = async (event: Event) => {
  const target = event.target as HTMLInputElement
  if (target.files && target.files[0]) {
    const file = target.files[0]
    console.log('Uploading file:', file.name)
    try {
      const response = await authApi.uploadPhoto(file)
      console.log('Server response:', response.data)
      // Update local user data
      if (authStore.user) {
        authStore.user.profile_photo = response.data.profile_photo
      }
      alert('Profile photo updated!')
    } catch (err: any) {
      console.error('Upload error:', err)
      const msg = err.response?.data?.detail || JSON.stringify(err.response?.data) || 'Failed to upload photo.'
      alert('Error: ' + msg)
    }
  }
}

const getPhotoUrl = (path: string) => {
  if (!path) return ''
  if (path.startsWith('http')) return path
  // Jika path diawali dengan /media/, tambahkan host
  return `http://127.0.0.1:8000${path}`
}


const handleLogout = () => {
  authStore.logout()
  router.push('/login')
}

const formatDate = (dateString?: string) => {
  if (!dateString) return '-'
  return new Date(dateString).toLocaleDateString('en-US', {
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  })
}

onMounted(async () => {
  if (!authStore.isAuthenticated) {
    router.push('/login')
    return
  }
  await authStore.fetchMe()
})
</script>

<style scoped>
.profile-page {
  padding-top: 120px;
  padding-bottom: 80px;
  min-height: 100vh;
  background: var(--black);
}

.profile-layout {
  display: grid;
  grid-template-columns: 280px 1fr;
  gap: 40px;
  align-items: start;
}

@media (max-width: 992px) {
  .profile-layout {
    grid-template-columns: 1fr;
  }
}

/* Sidebar Styling */
.profile-sidebar {
  position: sticky;
  top: 120px;
}

.user-brief {
  text-align: center;
  margin-bottom: 32px;
  padding: 24px;
  background: var(--dark2);
  border-radius: var(--radius-lg);
  border: 1px solid var(--w08);
}

.user-avatar-container {
  position: relative;
  width: 100px;
  height: 100px;
  margin: 0 auto 16px;
  cursor: pointer;
}

.user-avatar-lg {
  width: 100%;
  height: 100%;
  background: var(--blue);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 3rem;
  font-weight: 700;
  box-shadow: var(--shadow-blue);
}

.user-avatar-img {
  width: 100%;
  height: 100%;
  border-radius: 50%;
  object-fit: cover;
  border: 2px solid var(--blue);
}

.avatar-overlay {
  position: absolute;
  top: 0; left: 0; width: 100%; height: 100%;
  background: rgba(0,0,0,0.6);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  opacity: 0;
  transition: opacity 0.3s;
}

.user-avatar-container:hover .avatar-overlay {
  opacity: 1;
}

.avatar-overlay span {
  color: white;
  font-size: 0.75rem;
  font-weight: 600;
}

.hidden-input {
  display: none;
}

.user-name {
  font-size: 1.25rem;
  margin-bottom: 8px;
  color: var(--white);
}

.sidebar-nav {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.nav-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 14px 20px;
  background: transparent;
  border: none;
  color: var(--w70);
  border-radius: var(--radius-md);
  font-weight: 500;
  transition: all 0.2s;
  text-align: left;
  width: 100%;
}

.nav-item:hover {
  background: var(--w08);
  color: var(--white);
}

.nav-item--active {
  background: var(--blue);
  color: var(--white);
}

.nav-item--active:hover {
  background: var(--blue-b);
}

.nav-item--danger {
  color: var(--danger);
}

.nav-item--danger:hover {
  background: rgba(239, 68, 68, 0.1);
}

/* Content Styling */
.profile-content {
  padding: 40px;
  background: var(--dark1);
  min-height: 500px;
}

h2 {
  font-size: 1.5rem;
  letter-spacing: 1px;
  color: var(--white);
}

.info-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
  gap: 24px;
  margin-top: 24px;
}

.info-item {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.info-value {
  font-size: 1rem;
  color: var(--white);
  padding: 8px 0;
}

.action-footer {
  margin-top: 40px;
  display: flex;
  justify-content: flex-end;
}

/* Settings Styling */
.settings-list {
  display: flex;
  flex-direction: column;
  gap: 24px;
}

.settings-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding-bottom: 24px;
  border-bottom: 1px solid var(--w04);
}

.settings-text h4 {
  margin-bottom: 4px;
  color: var(--white);
}

.settings-text p {
  font-size: 0.85rem;
  color: var(--w40);
}

.mt-4 { margin-top: 1.5rem; }
</style>
