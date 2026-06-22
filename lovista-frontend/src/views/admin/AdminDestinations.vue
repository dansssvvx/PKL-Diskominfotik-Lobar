<template>
  <div class="admin-dest">
    <div class="admin-dest__header">
      <div>
        <h1 class="admin-title">Manage Destinations</h1>
        <p class="admin-subtitle">View, edit, and manage all tourism destinations.</p>
      </div>
      <button class="btn btn-primary" @click="openAddModal">
        + Add Destination
      </button>
    </div>

    <!-- Filters -->
    <div class="card p-4 mb-4 filter-bar">
      <div class="filter-group">
        <input v-model="filters.search" type="text" class="form-input" placeholder="Search destination..." @keyup.enter="handleFilterChange" />
      </div>
      <div class="filter-group">
        <select v-model="filters.category" class="form-select" @change="handleFilterChange">
          <option value="">All Categories</option>
          <option v-for="cat in categories" :key="cat.id" :value="cat.id">{{ cat.name }}</option>
        </select>
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
            <th>Name</th>
            <th>Category</th>
            <th>Location</th>
            <th>Price</th>
            <th>Status</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody v-if="loading">
          <tr><td colspan="6" style="text-align:center;padding:30px;"><div class="spinner"></div></td></tr>
        </tbody>
        <tbody v-else-if="destinations.length === 0">
          <tr><td colspan="6" style="text-align:center;padding:30px;color:var(--w40);">No destinations found.</td></tr>
        </tbody>
        <tbody v-else>
          <tr v-for="dest in destinations" :key="dest.id">
            <td>
              <div class="dest-info">
                <img :src="getPhotoUrl(dest.main_image)" class="dest-img" />
                <div class="dest-name">{{ dest.name }}</div>
              </div>
            </td>
            <td>
              <span class="badge-outline">{{ dest.category?.name || dest.category_name || 'Uncategorized' }}</span>
            </td>
            <td>{{ dest.district || '-' }}</td>
            <td>
              <span v-if="Number(dest.ticket_price) <= 0" class="text-free">Free</span>
              <span v-else>Rp {{ formatNumber(dest.ticket_price) }}</span>
            </td>
            <td>
              <span class="badge" :class="getStatusBadge(dest.status)">{{ dest.status }}</span>
            </td>
            <td>
              <div class="action-btns">
                <button class="btn btn-blue-outline btn-sm" @click="openEditModal(dest)">Edit</button>
                <button class="btn btn-ghost btn-sm" @click="toggleStatus(dest)">
                  {{ dest.status === 'published' ? 'Archive' : 'Publish' }}
                </button>
                <button class="btn btn-danger btn-sm" @click="deleteDest(dest.id)">Delete</button>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <!-- Pagination (Simple) -->
    <div class="pagination mt-4" v-if="totalPages > 1">
      <button class="btn btn-ghost btn-sm" :disabled="filters.page === 1" @click="filters.page--; fetchData()">Prev</button>
      <span>Page {{ filters.page }} of {{ totalPages }}</span>
      <button class="btn btn-ghost btn-sm" :disabled="filters.page === totalPages" @click="filters.page++; fetchData()">Next</button>
    </div>

    <!-- Add/Edit Destination Modal -->
    <div class="modal-overlay" v-if="showModal" @click.self="closeModal">
      <div class="modal-content card">
        <div class="modal-header">
          <h2 class="modal-title">{{ isEditing ? 'Edit Destination' : 'Add New Destination' }}</h2>
          <button class="btn-close" @click="closeModal">×</button>
        </div>
        <form @submit.prevent="handleSubmit" class="modal-form">
          <div class="form-grid">
            <div class="form-group">
              <label>Destination Name</label>
              <input v-model="form.name" type="text" class="form-input" placeholder="e.g. Pantai Senggigi" required />
            </div>
            <div class="form-group">
              <label>Category</label>
              <select v-model="form.category" class="form-select" required>
                <option value="">Select Category</option>
                <option v-for="cat in categories" :key="cat.id" :value="cat.id">{{ cat.name }}</option>
              </select>
            </div>
            <div class="form-group">
              <label>District (Kecamatan)</label>
              <input v-model="form.district" type="text" class="form-input" placeholder="e.g. Batu Layar" />
            </div>
            <div class="form-group">
              <label>Village (Desa)</label>
              <input v-model="form.village" type="text" class="form-input" placeholder="e.g. Senggigi" />
            </div>
            <div class="form-group">
              <label>Ticket Price (Rp)</label>
              <input v-model.number="form.ticket_price" type="number" min="0" class="form-input" placeholder="0 for Free" />
            </div>
            <div class="form-group">
              <label>Parking Fee (Rp)</label>
              <input v-model.number="form.parking_fee" type="number" min="0" class="form-input" placeholder="0" />
            </div>
            <div class="form-group">
              <label>Latitude</label>
              <input v-model="form.latitude" type="number" step="any" class="form-input" placeholder="e.g. -8.4896" />
            </div>
            <div class="form-group">
              <label>Longitude</label>
              <input v-model="form.longitude" type="number" step="any" class="form-input" placeholder="e.g. 116.0412" />
            </div>
            <div class="form-group full-width">
              <label>Address</label>
              <input v-model="form.address" type="text" class="form-input" placeholder="Complete address..." />
            </div>
            <div class="form-group full-width">
              <label>Description</label>
              <textarea v-model="form.description" class="form-input" rows="3" placeholder="Tell something about this place..."></textarea>
            </div>
            <div class="form-group full-width">
              <label>Main Image URL</label>
              <input v-model="form.main_image" type="url" class="form-input" placeholder="https://..." />
            </div>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-ghost" @click="closeModal">Cancel</button>
            <button type="submit" class="btn btn-primary" :disabled="submitting">
              {{ submitting ? 'Saving...' : (isEditing ? 'Save Changes' : 'Add Destination') }}
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
import { destinationApi } from '@/api'
import type { TourismDestination, DestinationCategory } from '@/types'

const loading = ref(false)
const submitting = ref(false)
const showModal = ref(false)
const isEditing = ref(false)
const currentId = ref<number | null>(null)
const currentSlug = ref<string | null>(null)

const destinations = ref<TourismDestination[]>([])
const categories = ref<DestinationCategory[]>([])
const filters = ref({ search: '', status: '', category: '', page: 1 })
const totalItems = ref(0)
const itemsPerPage = 10

const form = ref({
  name: '',
  category: '' as any,
  district: '',
  village: '',
  ticket_price: 0,
  parking_fee: 0,
  latitude: null as number | null,
  longitude: null as number | null,
  address: '',
  description: '',
  main_image: '',
  status: 'published'
})

const totalPages = computed(() => Math.ceil(totalItems.value / itemsPerPage))

async function fetchData() {
  loading.value = true
  try {
    const { data } = await destinationApi.list({ ...filters.value, page_size: itemsPerPage } as any)
    destinations.value = Array.isArray(data) ? data : data.results || []
    totalItems.value = Array.isArray(data) ? data.length : data.count || destinations.value.length
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

async function fetchCategories() {
  try {
    const { data } = await destinationApi.categories()
    categories.value = data
  } catch (error) {
    console.error('Failed to fetch categories:', error)
  }
}

function openAddModal() {
  isEditing.value = false
  currentId.value = null
  resetForm()
  showModal.value = true
}

function openEditModal(dest: TourismDestination) {
  isEditing.value = true
  currentId.value = dest.id
  currentSlug.value = dest.slug
  
  // Clean numbers: round and prevent negatives
  const tPrice = Math.max(0, Math.round(Number(dest.ticket_price)))
  const pFee = Math.max(0, Math.round(Number(dest.parking_fee)))

  form.value = {
    name: dest.name,
    category: dest.category?.id || dest.category || '',
    district: dest.district || '',
    village: dest.village || '',
    ticket_price: tPrice,
    parking_fee: pFee,
    latitude: dest.latitude ? Number(dest.latitude) : null,
    longitude: dest.longitude ? Number(dest.longitude) : null,
    address: dest.address || '',
    description: dest.description || '',
    main_image: dest.main_image || '',
    status: dest.status || 'published'
  }
  showModal.value = true
}

function closeModal() {
  showModal.value = false
  currentSlug.value = null
  resetForm()
}

function resetForm() {
  form.value = {
    name: '', category: '', district: '', village: '',
    ticket_price: 0, parking_fee: 0, 
    latitude: null, longitude: null,
    address: '', description: '', main_image: '', status: 'published'
  }
}

async function handleSubmit() {
  submitting.value = true
  try {
    const slug = form.value.name.toLowerCase().replace(/ /g, '-').replace(/[^\w-]+/g, '')
    // Ensure payload numbers are clean before sending
    const payload = { 
      ...form.value, 
      slug,
      ticket_price: Math.max(0, Math.round(Number(form.value.ticket_price))),
      parking_fee: Math.max(0, Math.round(Number(form.value.parking_fee)))
    }

    if (isEditing.value && currentSlug.value) {
      await destinationApi.update(currentSlug.value, payload as any)
    } else {
      await destinationApi.create(payload as any)
    }
    
    showModal.value = false
    fetchData()
  } catch (error) {
    console.error(error)
    Swal.fire({ title: 'Notification', text: 'Failed to save destination. Please check your input.', icon: 'info' })
  } finally {
    submitting.value = false
  }
}

async function toggleStatus(dest: TourismDestination) {
  const newStatus = dest.status === 'published' ? 'archived' : 'published'
  try {
    await destinationApi.update(dest.slug, { status: newStatus })
    dest.status = newStatus
  } catch (error) {
    console.error(error)
    Swal.fire({ title: 'Notification', text: 'Failed to update status', icon: 'info' })
  }
}

async function deleteDest(id: number) {
  const result = await Swal.fire({ title: 'Are you sure?', text: 'Are you sure you want to delete this destination?', icon: 'warning', showCancelButton: true });
  if (!result.isConfirmed) return
  try {
    await destinationApi.delete(id as any)
    fetchData()
  } catch (error) {
    console.error(error)
    Swal.fire({ title: 'Notification', text: 'Failed to delete', icon: 'info' })
  }
}

function getPhotoUrl(path?: string | null) {
  if (!path) return '/Logo.png'
  if (path.startsWith('http')) return path
  return `http://127.0.0.1:8000${path}`
}

function formatNumber(num: number | string) {
  // Use round to prevent 4999.9999 issues from floating point
  return new Intl.NumberFormat('id-ID').format(Math.round(Number(num)))
}

function getStatusBadge(status: string) {
  switch (status) {
    case 'published': return 'badge-success'
    case 'pending': return 'badge-warning'
    case 'archived': return 'badge-gray'
    default: return 'badge-gray'
  }
}

onMounted(() => {
  fetchCategories()
  fetchData()
})
</script>

<style scoped>
.admin-dest__header { display: flex; justify-content: space-between; align-items: flex-end; margin-bottom: 24px; }
.admin-title { font-family: 'Barlow Condensed', sans-serif; font-size: 2rem; font-style: italic; font-weight: 800; margin-bottom: 4px; }
.admin-subtitle { color: var(--w40); font-size: 0.9rem; }

.p-4 { padding: 16px; }
.mb-4 { margin-bottom: 24px; }
.mt-4 { margin-top: 24px; }

.filter-bar { display: flex; gap: 12px; align-items: center; background: var(--dark2); }
.filter-group { flex: 1; min-width: 150px; }
.filter-group .form-input, .filter-group .form-select { width: 100%; }

.table-wrap { overflow-x: auto; }
.dest-info { display: flex; align-items: center; gap: 12px; }
.dest-img { width: 48px; height: 48px; border-radius: 8px; object-fit: cover; }
.dest-name { font-weight: 600; color: #fff; font-size: 0.95rem; }
.dest-cat { font-size: 0.75rem; color: var(--w40); }

.action-btns { display: flex; gap: 8px; }
.btn-blue-outline { background: transparent; border: 1px solid var(--blue); color: var(--blue); }
.btn-blue-outline:hover { background: rgba(26,143,255,0.1); }

.badge-outline {
  padding: 4px 10px; border-radius: 6px; border: 1px solid var(--w15);
  font-size: 0.75rem; color: var(--w70); background: rgba(255,255,255,0.03);
}

.text-free {
  color: #4ade80; font-weight: 700; text-transform: uppercase; font-size: 0.85rem;
}

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