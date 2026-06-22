<template>
  <div class="admin-culture">
    <div class="admin-culture__header">
      <div>
        <h1 class="admin-title">Manage Culture</h1>
        <p class="admin-subtitle">View and manage local cultural events and traditions.</p>
      </div>
      <button class="btn btn-primary" @click="openAddModal">
        + Add Culture
      </button>
    </div>

    <!-- Filters -->
    <div class="card p-4 mb-4 filter-bar" style="margin-bottom: 24px;">
      <div class="filter-group">
        <input v-model="filters.search" type="text" class="form-input" placeholder="Search culture..." @keyup.enter="handleFilterChange" />
      </div>
      <div class="filter-group">
        <select v-model="filters.status" class="form-select" @change="handleFilterChange">
          <option value="">All Statuses</option>
          <option value="published">Published</option>
          <option value="pending">Pending</option>
          <option value="draft">Draft</option>
          <option value="archived">Archived</option>
        </select>
      </div>
      <button class="btn btn-ghost" @click="fetchData">Refresh</button>
    </div>

    <!-- Data Table -->
    <div class="card table-wrap">
      <table class="table">
        <thead>
          <tr>
            <th>Culture / Event</th>
            <th>Location</th>
            <th>Date / Frequency</th>
            <th>Status</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody v-if="loading">
          <tr><td colspan="5" style="text-align:center;padding:30px;"><div class="spinner"></div></td></tr>
        </tbody>
        <tbody v-else-if="cultures.length === 0">
          <tr><td colspan="5" style="text-align:center;padding:30px;color:var(--w40);">No cultural data found.</td></tr>
        </tbody>
        <tbody v-else>
          <tr v-for="item in cultures" :key="item.id">
            <td>
              <div class="item-info">
                <img :src="getPhotoUrl(item.images?.[0])" class="item-img" />
                <div class="item-name">{{ item.name }}</div>
              </div>
            </td>
            <td>{{ item.location || '-' }}</td>
            <td>
              <div class="date-val">{{ formatDate(item.event_date) }}</div>
              <div class="date-sub">{{ item.event_frequency || 'One-time' }}</div>
            </td>
            <td>
              <span class="badge" :class="getStatusBadge(item.status)">{{ item.status }}</span>
            </td>
            <td>
              <div class="action-btns">
                <button class="btn btn-blue-outline btn-sm" @click="openEditModal(item)">Edit</button>
                <button class="btn btn-danger btn-sm" @click="deleteItem(item.id)">Delete</button>
              </div>
            </td>
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

    <!-- Add/Edit Modal -->
    <div class="modal-overlay" v-if="showModal" @click.self="closeModal">
      <div class="modal-content card">
        <div class="modal-header">
          <h2 class="modal-title">{{ isEditing ? 'Edit Culture' : 'Add New Culture' }}</h2>
          <button class="btn-close" @click="closeModal">×</button>
        </div>
        <form @submit.prevent="handleSubmit" class="modal-form">
          <div class="form-grid">
            <div class="form-group full-width">
              <label>Culture Name</label>
              <input v-model="form.name" type="text" class="form-input" placeholder="e.g. Perang Topat" required />
            </div>
            <div class="form-group">
              <label>Location</label>
              <input v-model="form.location" type="text" class="form-input" placeholder="e.g. Pura Lingsar" />
            </div>
            <div class="form-group">
              <label>Event Date</label>
              <input v-model="form.event_date" type="date" class="form-input" />
            </div>
            <div class="form-group">
              <label>Event Frequency</label>
              <input v-model="form.event_frequency" type="text" class="form-input" placeholder="e.g. Annual" />
            </div>
            <div class="form-group">
              <label>Status</label>
              <select v-model="form.status" class="form-select">
                <option value="published">Published</option>
                <option value="pending">Pending</option>
                <option value="draft">Draft</option>
                <option value="archived">Archived</option>
              </select>
            </div>
            <div class="form-group full-width">
              <label>Description</label>
              <textarea v-model="form.description" class="form-input" rows="4" placeholder="Tell the history or tradition..."></textarea>
            </div>
            <div class="form-group full-width">
              <label>Image URLs (Comma separated)</label>
              <textarea v-model="form.images_text" class="form-input" rows="2" placeholder="https://url1, https://url2"></textarea>
            </div>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-ghost" @click="closeModal">Cancel</button>
            <button type="submit" class="btn btn-primary" :disabled="submitting">
              {{ submitting ? 'Saving...' : 'Save Culture' }}
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
import { cultureApi } from '@/api'
import type { Culture } from '@/types'

const loading = ref(false)
const submitting = ref(false)
const showModal = ref(false)
const isEditing = ref(false)
const currentId = ref<number | null>(null)

const cultures = ref<Culture[]>([])
const filters = ref({ search: '', status: '', page: 1 })
const totalItems = ref(0)
const itemsPerPage = 10

const form = ref({
  name: '',
  description: '',
  location: '',
  event_date: '',
  event_frequency: '',
  status: 'published',
  images_text: ''
})

const totalPages = computed(() => Math.ceil(totalItems.value / itemsPerPage))

async function fetchData() {
  loading.value = true
  try {
    const { data } = await cultureApi.list({ ...filters.value, page_size: itemsPerPage } as any)
    cultures.value = Array.isArray(data) ? data : data.results || []
    totalItems.value = Array.isArray(data) ? data.length : data.count || cultures.value.length
  } catch (error) {
    console.error(error)
  } finally {
    loading.value = false
  }
}

function handleFilterChange() {
  filters.value.page = 1
  fetchData()
}

function openAddModal() {
  isEditing.value = false
  currentId.value = null
  resetForm()
  showModal.value = true
}

function openEditModal(item: Culture) {
  isEditing.value = true
  currentId.value = item.id
  form.value = {
    name: item.name,
    description: item.description || '',
    location: item.location || '',
    event_date: item.event_date || '',
    event_frequency: item.event_frequency || '',
    status: item.status || 'published',
    images_text: Array.isArray(item.images) ? item.images.join(', ') : ''
  }
  showModal.value = true
}

function closeModal() {
  showModal.value = false
  resetForm()
}

function resetForm() {
  form.value = {
    name: '', description: '', location: '',
    event_date: '', event_frequency: '',
    status: 'published', images_text: ''
  }
}

async function handleSubmit() {
  submitting.value = true
  try {
    const images = form.value.images_text.split(',').map(s => s.trim()).filter(s => s)
    const payload = { ...form.value, images }
    
    if (isEditing.value && currentId.value) {
      await cultureApi.update(currentId.value, payload as any)
    } else {
      await cultureApi.create(payload as any)
    }
    
    showModal.value = false
    fetchData()
  } catch (error) {
    Swal.fire({ title: 'Notification', text: 'Failed to save culture data', icon: 'info' })
  } finally {
    submitting.value = false
  }
}

async function deleteItem(id: number) {
  const result = await Swal.fire({ title: 'Are you sure?', text: 'Delete this culture entry?', icon: 'warning', showCancelButton: true });
  if (!result.isConfirmed) return
  try {
    await cultureApi.delete(id)
    fetchData()
  } catch (error) {
    Swal.fire({ title: 'Notification', text: 'Failed to delete', icon: 'info' })
  }
}

function formatDate(dateString?: string) {
  if (!dateString) return '-'
  return new Date(dateString).toLocaleDateString('id-ID', {
    day: '2-digit', month: 'short', year: 'numeric'
  })
}

function getPhotoUrl(path?: string | null) {
  if (!path) return '/Logo.png'
  if (path.startsWith('http')) return path
  return `http://127.0.0.1:8000${path}`
}

function getStatusBadge(status: string) {
  switch (status) {
    case 'published': return 'badge-success'
    case 'pending': return 'badge-warning'
    case 'archived': return 'badge-gray'
    default: return 'badge-gray'
  }
}

onMounted(fetchData)
</script>

<style scoped>
/* Reusing shared admin styles */
.admin-culture__header { display: flex; justify-content: space-between; align-items: flex-end; margin-bottom: 24px; }
.admin-title { font-family: 'Barlow Condensed', sans-serif; font-size: 2rem; font-style: italic; font-weight: 800; margin-bottom: 4px; }
.admin-subtitle { color: var(--w40); font-size: 0.9rem; }

.filter-bar { display: flex; gap: 12px; align-items: center; background: var(--dark2); }
.filter-group { flex: 1; min-width: 150px; }
.filter-group .form-input, .filter-group .form-select { width: 100%; }

.table-wrap { overflow-x: auto; }
.item-info { display: flex; align-items: center; gap: 12px; }
.item-img { width: 48px; height: 48px; border-radius: 8px; object-fit: cover; background: var(--w04); }
.item-name { font-weight: 600; color: #fff; font-size: 0.95rem; }

.date-val { font-size: 0.85rem; color: var(--w90); }
.date-sub { font-size: 0.7rem; color: var(--w40); }

.action-btns { display: flex; gap: 8px; }
.btn-blue-outline { background: transparent; border: 1px solid var(--blue); color: var(--blue); }
.btn-blue-outline:hover { background: rgba(26,143,255,0.1); }

.pagination { display: flex; align-items: center; justify-content: center; gap: 16px; font-size: 0.9rem; color: var(--w70); }

/* Modal Overlay & Content */
.modal-overlay {
  position: fixed; top: 0; left: 0; width: 100%; height: 100%;
  background: rgba(0,0,0,0.7); backdrop-filter: blur(4px);
  display: flex; align-items: center; justify-content: center; z-index: 1000;
  padding: 20px;
}
.modal-content {
  width: 100%; max-width: 800px; max-height: 90vh; overflow-y: auto;
  position: relative; animation: modalSlide 0.3s ease-out;
}
@keyframes modalSlide { from { opacity: 0; transform: translateY(20px); } to { opacity: 1; transform: translateY(0); } }
.modal-header { display: flex; justify-content: space-between; align-items: center; padding: 20px 24px; border-bottom: 1px solid var(--w08); }
.modal-title { font-family: 'Barlow Condensed', sans-serif; font-style: italic; font-weight: 700; font-size: 1.5rem; }
.btn-close { background: none; border: none; color: var(--w40); font-size: 1.8rem; cursor: pointer; }
.modal-form { padding: 24px; }
.form-grid { display: grid; grid-template-columns: repeat(2, 1fr); gap: 20px; }
.form-group label { display: block; font-size: 0.8rem; color: var(--w40); margin-bottom: 8px; text-transform: uppercase; }
.full-width { grid-column: span 2; }
.modal-footer { display: flex; justify-content: flex-end; gap: 12px; padding: 20px 24px; border-top: 1px solid var(--w08); }
</style>