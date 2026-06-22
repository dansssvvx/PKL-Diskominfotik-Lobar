<template>
  <div class="admin-users">
    <div class="admin-users__header">
      <div>
        <h1 class="admin-title">Manage Users</h1>
        <p class="admin-subtitle">View and manage registered users across the platform.</p>
      </div>
      <button class="btn btn-primary" @click="showAddModal = true">
        + Add User
      </button>
    </div>

    <!-- Filters -->
    <div class="card p-4 mb-4 filter-bar">
      <div class="filter-group">
        <select v-model="filters.role" class="form-select" @change="fetchData">
          <option value="">All Roles</option>
          <option value="admin">Admin</option>
          <option value="operator">Operator</option>
          <option value="user">User</option>
        </select>
      </div>
      <button class="btn btn-ghost" @click="fetchData">Filter</button>
    </div>

    <!-- Data Table -->
    <div class="card table-wrap">
      <table class="table">
        <thead>
          <tr>
            <th>User</th>
            <th>Contact</th>
            <th>Role</th>
            <th>Status</th>
            <th>Joined</th>
          </tr>
        </thead>
        <tbody v-if="loading">
          <tr><td colspan="5" style="text-align:center;padding:30px;"><div class="spinner"></div></td></tr>
        </tbody>
        <tbody v-else-if="users.length === 0">
          <tr><td colspan="5" style="text-align:center;padding:30px;color:var(--w40);">No users found.</td></tr>
        </tbody>
        <tbody v-else>
          <tr v-for="user in users" :key="user.id">
            <td>
              <div class="user-info">
                <div class="avatar">{{ user.fullname.charAt(0).toUpperCase() }}</div>
                <div>
                  <div style="font-weight: 600; color: #fff;">{{ user.fullname }}</div>
                  <div style="font-size: 0.75rem; color: var(--w40);">ID: {{ user.id }}</div>
                </div>
              </div>
            </td>
            <td>
              <div>{{ user.email }}</div>
              <div style="font-size: 0.75rem; color: var(--w40);">{{ user.phone || 'No phone' }}</div>
            </td>
            <td>
              <span class="badge" :class="getRoleBadge(user.role_name)">
                {{ user.role_name ? user.role_name.charAt(0).toUpperCase() + user.role_name.slice(1) : 'User' }}
              </span>
            </td>
            <td>
              <span class="badge" :class="user.is_active ? 'badge-success' : 'badge-danger'">
                {{ user.is_active ? 'Active' : 'Inactive' }}
              </span>
            </td>
            <td>{{ formatDate(user.created_at) }}</td>
          </tr>
        </tbody>
      </table>
    </div>

    <!-- Pagination -->
    <div class="pagination mt-4" v-if="totalPages > 1">
      <button class="btn btn-ghost btn-sm" :disabled="filters.page === 1" @click="filters.page--; fetchData()">Prev</button>
      <span>Page {{ filters.page }} of {{ totalPages }}</span>
      <button class="btn btn-ghost btn-sm" :disabled="filters.page === totalPages" @click="filters.page++; fetchData()">Next</button>
    </div>

    <!-- Add User Modal -->
    <div class="modal-overlay" v-if="showAddModal" @click.self="showAddModal = false">
      <div class="modal-content card">
        <div class="modal-header">
          <h2 class="modal-title">Add New User</h2>
          <button class="btn-close" @click="showAddModal = false">×</button>
        </div>
        <form @submit.prevent="submitAdd" class="modal-form">
          <div class="form-grid">
            <div class="form-group">
              <label>Full Name</label>
              <input v-model="newUser.fullname" type="text" class="form-input" placeholder="e.g. John Doe" required />
            </div>
            <div class="form-group">
              <label>Email Address</label>
              <input v-model="newUser.email" type="email" class="form-input" placeholder="e.g. john@example.com" required />
            </div>
            <div class="form-group">
              <label>Password</label>
              <input v-model="newUser.password" type="password" class="form-input" placeholder="Minimum 6 characters" required />
            </div>
            <div class="form-group">
              <label>Phone Number</label>
              <input v-model="newUser.phone" type="tel" class="form-input" placeholder="e.g. 0812345678" />
            </div>
            <div class="form-group full-width">
              <label>Role</label>
              <select v-model="newUser.role" class="form-select" required>
                <option value="user">Regular User</option>
                <option value="operator">Operator (Agency/Homestay)</option>
                <option value="admin">Administrator</option>
              </select>
            </div>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-ghost" @click="showAddModal = false">Cancel</button>
            <button type="submit" class="btn btn-primary" :disabled="submitting">
              {{ submitting ? 'Saving...' : 'Add User' }}
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import Swal from 'sweetalert2'
import { ref, onMounted, computed } from 'vue'
import { adminApi, authApi } from '@/api'
import type { User } from '@/types'

const loading = ref(false)
const submitting = ref(false)
const showAddModal = ref(false)
const users = ref<User[]>([])
const filters = ref({ role: '', page: 1 })
const totalItems = ref(0)
const itemsPerPage = 10

const newUser = ref({
  fullname: '',
  email: '',
  password: '',
  phone: '',
  role: 'user'
})

const totalPages = computed(() => Math.ceil(totalItems.value / itemsPerPage))

async function fetchData() {
  loading.value = true
  try {
    const { data } = await adminApi.users({ ...filters.value, page_size: itemsPerPage } as any)
    users.value = Array.isArray(data) ? data : data.results || []
    totalItems.value = Array.isArray(data) ? data.length : data.count || users.value.length
  } catch (error) {
    console.error(error)
  } finally {
    loading.value = false
  }
}

async function submitAdd() {
  submitting.value = true
  try {
    // We can use authApi.register or a generic user create if exists
    // Based on UserViewSet, POST /api/users/ creates a user
    // Since we are in Admin, we use the general api instance via a new method or direct axios if needed
    // But let's see if adminApi has user management
    await authApi.register(newUser.value as any)
    showAddModal.value = false
    // Reset form
    newUser.value = { fullname: '', email: '', password: '', phone: '', role: 'user' }
    fetchData()
  } catch (error: any) {
    console.error(error)
    const msg = error.response?.data?.detail || 'Failed to add user'
    Swal.fire({ title: 'Notification', text: msg, icon: 'info' })
  } finally {
    submitting.value = false
  }
}

function formatDate(dateString: string) {
  return new Date(dateString).toLocaleDateString('id-ID', {
    day: '2-digit', month: 'short', year: 'numeric'
  })
}

function getRoleBadge(roleName?: string) {
  if (!roleName) return 'badge-gray'
  const lower = roleName.toLowerCase()
  if (lower === 'admin') return 'badge-success'
  if (lower === 'operator') return 'badge-blue'
  return 'badge-gray' // user or others
}

onMounted(() => {
  fetchData()
})
</script>

<style scoped>
.admin-users__header { display: flex; justify-content: space-between; align-items: flex-end; margin-bottom: 24px; }
.admin-title { font-family: 'Barlow Condensed', sans-serif; font-size: 2rem; font-style: italic; font-weight: 800; margin-bottom: 4px; }
.admin-subtitle { color: var(--w40); font-size: 0.9rem; }

.p-4 { padding: 16px; }
.mb-4 { margin-bottom: 24px; }
.mt-4 { margin-top: 24px; }

.filter-bar { display: flex; gap: 16px; align-items: center; }

.table-wrap { overflow-x: auto; }
.user-info { display: flex; align-items: center; gap: 12px; }
.avatar { width: 36px; height: 36px; border-radius: 50%; background: var(--dark3); border: 1px solid var(--w08); display: flex; align-items: center; justify-content: center; font-weight: 700; color: var(--blue-b); }

.pagination { display: flex; align-items: center; justify-content: center; gap: 16px; font-size: 0.9rem; color: var(--w70); }

/* Modal Styles */
.modal-overlay {
  position: fixed; top: 0; left: 0; width: 100%; height: 100%;
  background: rgba(0,0,0,0.7); backdrop-filter: blur(4px);
  display: flex; align-items: center; justify-content: center; z-index: 1000;
  padding: 20px;
}
.modal-content {
  width: 100%; max-width: 600px; max-height: 90vh; overflow-y: auto;
  position: relative; animation: modalSlide 0.3s ease-out;
}
@keyframes modalSlide {
  from { opacity: 0; transform: translateY(20px); }
  to { opacity: 1; transform: translateY(0); }
}
.modal-header {
  display: flex; justify-content: space-between; align-items: center;
  padding: 20px 24px; border-bottom: 1px solid var(--w08);
}
.modal-title { font-family: 'Barlow Condensed', sans-serif; font-style: italic; font-weight: 700; font-size: 1.5rem; }
.btn-close { background: none; border: none; color: var(--w40); font-size: 1.8rem; cursor: pointer; }

.modal-form { padding: 24px; }
.form-grid { display: grid; grid-template-columns: repeat(2, 1fr); gap: 20px; }
.form-group label { display: block; font-size: 0.8rem; color: var(--w40); margin-bottom: 8px; text-transform: uppercase; letter-spacing: 0.5px; }
.full-width { grid-column: span 2; }

.modal-footer {
  display: flex; justify-content: flex-end; gap: 12px;
  padding-top: 24px; margin-top: 24px; border-top: 1px solid var(--w08);
}
</style>