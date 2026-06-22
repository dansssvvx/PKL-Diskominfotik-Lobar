<template>
  <div class="admin-culinary">
    <div class="admin-culinary__header">
      <div>
        <h1 class="admin-title">Manage Culinary</h1>
        <p class="admin-subtitle">Manage local food, restaurants, and traditional cuisines.</p>
      </div>
      <button class="btn btn-primary" @click="openAddModal">
        + Add Culinary
      </button>
    </div>

    <!-- Filters -->
    <div class="card p-4 mb-4 filter-bar" style="margin-bottom: 24px;">
      <div class="filter-group">
        <input v-model="filters.search" type="text" class="form-input" placeholder="Search culinary..." @keyup.enter="handleFilterChange" />
      </div>
      <button class="btn btn-ghost" @click="fetchData">Refresh</button>
    </div>

    <!-- Data Table -->
    <div class="card table-wrap">
      <table class="table">
        <thead>
          <tr>
            <th>Food / Restaurant</th>
            <th>Price Range</th>
            <th>Contact</th>
            <th>Verified</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody v-if="loading">
          <tr><td colspan="5" style="text-align:center;padding:30px;"><div class="spinner"></div></td></tr>
        </tbody>
        <tbody v-else-if="culinaries.length === 0">
          <tr><td colspan="5" style="text-align:center;padding:30px;color:var(--w40);">No culinary data found.</td></tr>
        </tbody>
        <tbody v-else>
          <tr v-for="item in culinaries" :key="item.id">
            <td>
              <div class="item-info">
                <img :src="getPhotoUrl(item.images?.[0])" class="item-img" />
                <div class="item-name">{{ item.name }}</div>
              </div>
            </td>
            <td>{{ item.price_range || '-' }}</td>
            <td>{{ item.contact || '-' }}</td>
            <td>
              <span class="badge" :class="item.is_verified ? 'badge-success' : 'badge-warning'">
                {{ item.is_verified ? 'Verified' : 'Pending' }}
              </span>
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
          <h2 class="modal-title">{{ isEditing ? 'Edit Culinary' : 'Add New Culinary' }}</h2>
          <button class="btn-close" @click="closeModal">×</button>
        </div>
        <form @submit.prevent="handleSubmit" class="modal-form">
          <div class="form-grid">
            <div class="form-group full-width">
              <label>Culinary Name</label>
              <input v-model="form.name" type="text" class="form-input" placeholder="e.g. Sate Bulayak" required />
            </div>
            <div class="form-group">
              <label>Price Range</label>
              <input v-model="form.price_range" type="text" class="form-input" placeholder="e.g. Rp 20k - 50k" />
            </div>
            <div class="form-group">
              <label>Contact / Phone</label>
              <input v-model="form.contact" type="text" class="form-input" placeholder="e.g. 081..." />
            </div>
            <div class="form-group">
              <label>Verification Status</label>
              <select v-model="form.is_verified" class="form-select">
                <option :value="true">Verified</option>
                <option :value="false">Pending</option>
              </select>
            </div>
            <div class="form-group">
              <label>Latitude</label>
              <input v-model.number="form.latitude" type="number" step="any" class="form-input" />
            </div>
            <div class="form-group">
              <label>Longitude</label>
              <input v-model.number="form.longitude" type="number" step="any" class="form-input" />
            </div>
            <div class="form-group full-width">
              <label>Description</label>
              <textarea v-model="form.description" class="form-input" rows="3" placeholder="Description of the food or place..."></textarea>
            </div>
            <div class="form-group full-width">
              <label>Image URLs (Comma separated)</label>
              <textarea v-model="form.images_text" class="form-input" rows="2" placeholder="https://url1, https://url2"></textarea>
            </div>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-ghost" @click="closeModal">Cancel</button>
            <button type="submit" class="btn btn-primary" :disabled="submitting">
              {{ submitting ? 'Saving...' : 'Save Culinary' }}
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
import { culinaryApi } from '@/api'
import type { Culinary } from '@/types'

const loading = ref(false)
const submitting = ref(false)
const showModal = ref(false)
const isEditing = ref(false)
const currentId = ref<number | null>(null)

const culinaries = ref<Culinary[]>([])
const filters = ref({ search: '', page: 1 })
const totalItems = ref(0)
const itemsPerPage = 10

const form = ref({
  name: '',
  description: '',
  price_range: '',
  contact: '',
  is_verified: true,
  latitude: null as number | null,
  longitude: null as number | null,
  images_text: ''
})

const totalPages = computed(() => Math.ceil(totalItems.value / itemsPerPage))

async function fetchData() {
  loading.value = true
  try {
    const { data } = await culinaryApi.list({ ...filters.value, page_size: itemsPerPage } as any)
    culinaries.value = Array.isArray(data) ? data : data.results || []
    totalItems.value = Array.isArray(data) ? data.length : data.count || culinaries.value.length
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

function openEditModal(item: Culinary) {
  isEditing.value = true
  currentId.value = item.id
  form.value = {
    name: item.name,
    description: item.description || '',
    price_range: item.price_range || '',
    contact: item.contact || '',
    is_verified: item.is_verified || false,
    latitude: item.latitude ? Number(item.latitude) : null,
    longitude: item.longitude ? Number(item.longitude) : null,
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
    name: '', description: '', price_range: '',
    contact: '', is_verified: true,
    latitude: null, longitude: null,
    images_text: ''
  }
}

async function handleSubmit() {
  submitting.value = true
  try {
    const images = form.value.images_text.split(',').map(s => s.trim()).filter(s => s)
    const payload = { ...form.value, images }
    
    if (isEditing.value && currentId.value) {
      await culinaryApi.update(currentId.value, payload as any)
    } else {
      await culinaryApi.create(payload as any)
    }
    
    showModal.value = false
    fetchData()
  } catch (error) {
    Swal.fire({ title: 'Notification', text: 'Failed to save culinary data', icon: 'info' })
  } finally {
    submitting.value = false
  }
}

async function deleteItem(id: number) {
  const result = await Swal.fire({ title: 'Are you sure?', text: 'Delete this culinary entry?', icon: 'warning', showCancelButton: true });
  if (!result.isConfirmed) return
  try {
    await culinaryApi.delete(id)
    fetchData()
  } catch (error) {
    Swal.fire({ title: 'Notification', text: 'Failed to delete', icon: 'info' })
  }
}

function getPhotoUrl(path?: string | null) {
  if (!path) return '/Logo.png'
  if (path.startsWith('http')) return path
  return `http://127.0.0.1:8000${path}`
}

onMounted(fetchData)
</script>

<style scoped>
.admin-culinary__header { display: flex; justify-content: space-between; align-items: flex-end; margin-bottom: 24px; }
.admin-title { font-family: 'Barlow Condensed', sans-serif; font-size: 2rem; font-style: italic; font-weight: 800; margin-bottom: 4px; }
.admin-subtitle { color: var(--w40); font-size: 0.9rem; }

.filter-bar { display: flex; gap: 12px; align-items: center; background: var(--dark2); }
.filter-group { flex: 1; min-width: 150px; }
.filter-group .form-input { width: 100%; }

.table-wrap { overflow-x: auto; }
.item-info { display: flex; align-items: center; gap: 12px; }
.item-img { width: 48px; height: 48px; border-radius: 8px; object-fit: cover; background: var(--w04); }
.item-name { font-weight: 600; color: #fff; font-size: 0.95rem; }

.action-btns { display: flex; gap: 8px; }
.btn-blue-outline { background: transparent; border: 1px solid var(--blue); color: var(--blue); }
.btn-blue-outline:hover { background: rgba(26,143,255,0.1); }

.pagination { display: flex; align-items: center; justify-content: center; gap: 16px; font-size: 0.9rem; color: var(--w70); }

/* Modal Styles */
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