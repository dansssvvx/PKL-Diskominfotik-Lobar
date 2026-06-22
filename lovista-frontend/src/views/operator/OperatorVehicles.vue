<template>
  <div class="op-vehicles">
    <!-- Header -->
    <div class="page-header">
      <div>
        <h1 class="admin-title">Vehicles</h1>
        <p class="admin-subtitle">Kelola armada kendaraan yang tersedia untuk disewa.</p>
      </div>
      <button class="btn btn-primary" @click="openAddModal">+ Add Vehicle</button>
    </div>

    <!-- Filters -->
    <div class="card filter-bar">
      <div class="filter-group">
        <input v-model="filters.search" type="text" class="form-input" placeholder="Search by brand or model..." @keyup.enter="handleFilterChange" />
      </div>
      <div class="filter-group">
        <select v-model="filters.type" class="form-select" @change="handleFilterChange">
          <option value="">All Types</option>
          <option value="car">Car</option>
          <option value="motorcycle">Motorcycle</option>
          <option value="bus">Bus</option>
          <option value="van">Van</option>
          <option value="other">Other</option>
        </select>
      </div>
      <div class="filter-group">
        <select v-model="filters.available" class="form-select" @change="handleFilterChange">
          <option value="">All Availability</option>
          <option value="true">Available</option>
          <option value="false">Unavailable</option>
        </select>
      </div>
      <button class="btn btn-ghost" @click="fetchData">🔄 Refresh</button>
    </div>

    <!-- Table -->
    <div class="card table-wrap">
      <table class="table">
        <thead>
          <tr>
            <th>Vehicle</th>
            <th>Type</th>
            <th>Plate Number</th>
            <th>Capacity</th>
            <th>Daily Rate</th>
            <th>Driver Rate</th>
            <th>Availability</th>
            <th>Status</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody v-if="loading">
          <tr><td colspan="9" style="text-align:center;padding:40px"><div class="spinner"></div></td></tr>
        </tbody>
        <tbody v-else-if="vehicles.length === 0">
          <tr>
            <td colspan="9">
              <div class="empty-state">
                <div class="icon">🚗</div>
                <h3>No vehicles yet</h3>
                <p>Add your first vehicle to start accepting rental bookings.</p>
                <button class="btn btn-primary" style="margin-top:16px" @click="openAddModal">+ Add Vehicle</button>
              </div>
            </td>
          </tr>
        </tbody>
        <tbody v-else>
          <tr v-for="item in vehicles" :key="item.id">
            <td>
              <div class="item-info">
                <img :src="getPhotoUrl(item.image)" class="item-img" @error="handleImgError" />
                <div>
                  <div class="item-name">{{ item.brand }} {{ item.model }}</div>
                  <div class="item-year">{{ item.year || '-' }}</div>
                </div>
              </div>
            </td>
            <td>
              <span class="type-badge">{{ item.type.toUpperCase() }}</span>
            </td>
            <td><code class="plate-num">{{ item.plate_number }}</code></td>
            <td>{{ item.capacity || '-' }} pax</td>
            <td class="price-val">Rp {{ formatPrice(item.daily_rate) }}/day</td>
            <td>
              <span v-if="Number(item.driver_rate) > 0" class="driver-rate">Rp {{ formatPrice(item.driver_rate) }}/day</span>
              <span v-else class="text-muted">No driver</span>
            </td>
            <td>
              <span class="badge" :class="item.is_available ? 'badge-success' : 'badge-warning'">
                {{ item.is_available ? '✓ Available' : '✗ Unavailable' }}
              </span>
            </td>
            <td>
              <span class="badge" :class="item.is_active ? 'badge-success' : 'badge-gray'">
                {{ item.is_active ? 'Active' : 'Inactive' }}
              </span>
            </td>
            <td>
              <div class="action-btns">
                <button class="btn btn-ghost btn-sm" @click="openEditModal(item)">Edit</button>
                <button class="btn btn-ghost btn-sm" @click="toggleAvailability(item)">
                  {{ item.is_available ? 'Set Unavail.' : 'Set Avail.' }}
                </button>
                <button class="btn btn-danger btn-sm" @click="openDeleteModal(item)">Delete</button>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <!-- Pagination -->
    <div class="pagination mt-4" v-if="totalPages > 1">
      <button class="btn btn-ghost btn-sm" :disabled="filters.page === 1" @click="filters.page--; fetchData()">← Prev</button>
      <span>Page {{ filters.page }} of {{ totalPages }}</span>
      <button class="btn btn-ghost btn-sm" :disabled="filters.page === totalPages" @click="filters.page++; fetchData()">Next →</button>
    </div>

    <!-- Add/Edit Modal -->
    <div class="modal-overlay" v-if="showModal" @click.self="closeModal">
      <div class="modal-content card">
        <div class="modal-header">
          <h2 class="modal-title">{{ isEditing ? 'Edit Vehicle' : 'Add New Vehicle' }}</h2>
          <button class="btn-close" @click="closeModal">×</button>
        </div>
        <form @submit.prevent="handleSubmit" class="modal-form">
          <!-- Image Upload -->
          <div class="image-upload-area" @click="triggerFileInput" @dragover.prevent @drop.prevent="handleDrop">
            <input type="file" ref="fileInput" accept="image/*" class="hidden-input" @change="handleFileChange" />
            <div v-if="imagePreview" class="image-preview-wrap">
              <img :src="imagePreview" class="image-preview" />
              <button type="button" class="img-remove-btn" @click.stop="clearImage">×</button>
            </div>
            <div v-else class="upload-placeholder">
              <span>🚗</span>
              <p>Click or drag to upload vehicle photo</p>
              <small>JPG, PNG, WEBP up to 5MB</small>
            </div>
          </div>

          <div class="form-grid">
            <div class="form-group">
              <label class="form-label">Type *</label>
              <select v-model="form.type" class="form-select" required>
                <option value="">Select Type</option>
                <option value="car">Car</option>
                <option value="motorcycle">Motorcycle</option>
                <option value="bus">Bus</option>
                <option value="van">Van</option>
                <option value="other">Other</option>
              </select>
            </div>
            <div class="form-group">
              <label class="form-label">Brand *</label>
              <input v-model="form.brand" type="text" class="form-input" placeholder="e.g. Toyota" required />
            </div>
            <div class="form-group">
              <label class="form-label">Model *</label>
              <input v-model="form.model" type="text" class="form-input" placeholder="e.g. Avanza" required />
            </div>
            <div class="form-group">
              <label class="form-label">Year</label>
              <input v-model.number="form.year" type="number" min="1990" :max="new Date().getFullYear()" class="form-input" placeholder="e.g. 2022" />
            </div>
            <div class="form-group">
              <label class="form-label">Plate Number *</label>
              <input v-model="form.plate_number" type="text" class="form-input" placeholder="e.g. DR 1234 AB" required />
            </div>
            <div class="form-group">
              <label class="form-label">Capacity (pax)</label>
              <input v-model.number="form.capacity" type="number" min="1" class="form-input" placeholder="e.g. 7" />
            </div>
            <div class="form-group">
              <label class="form-label">Daily Rate (Rp) *</label>
              <input v-model.number="form.daily_rate" type="number" min="0" class="form-input" required />
            </div>
            <div class="form-group">
              <label class="form-label">Driver Rate (Rp/day)</label>
              <input v-model.number="form.driver_rate" type="number" min="0" class="form-input" placeholder="0 if no driver option" />
            </div>
            <div class="form-group full-width">
              <label class="form-label">Features (comma separated)</label>
              <input v-model="featuresInput" type="text" class="form-input" placeholder="e.g. AC, GPS, Bluetooth" />
            </div>
            <div class="form-group">
              <div class="toggle-group">
                <label class="toggle-label">
                  <input type="checkbox" v-model="form.is_available" />
                  <span class="toggle-slider"></span>
                  Available
                </label>
                <label class="toggle-label">
                  <input type="checkbox" v-model="form.is_active" />
                  <span class="toggle-slider"></span>
                  Active
                </label>
              </div>
            </div>
          </div>

          <div class="modal-footer">
            <button type="button" class="btn btn-ghost" @click="closeModal">Cancel</button>
            <button type="submit" class="btn btn-primary" :disabled="submitting">
              <span v-if="submitting" class="btn-spinner"></span>
              {{ submitting ? 'Saving...' : (isEditing ? 'Save Changes' : 'Add Vehicle') }}
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- Delete Confirm -->
    <div class="modal-overlay" v-if="showDeleteModal" @click.self="showDeleteModal = false">
      <div class="modal-content card" style="max-width:400px">
        <div class="modal-header">
          <h2 class="modal-title">Delete Vehicle</h2>
          <button class="btn-close" @click="showDeleteModal = false">×</button>
        </div>
        <div class="modal-body">
          <p style="color:var(--w70);margin-bottom:8px">Delete <strong>{{ deleteTarget?.brand }} {{ deleteTarget?.model }}</strong>?</p>
          <p style="color:var(--w40);font-size:.85rem">This action cannot be undone.</p>
        </div>
        <div class="modal-footer">
          <button class="btn btn-ghost" @click="showDeleteModal = false">Cancel</button>
          <button class="btn btn-danger" :disabled="submitting" @click="confirmDelete">
            {{ submitting ? 'Deleting...' : 'Delete Vehicle' }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { vehicleApi } from '@/api'
import type { Vehicle } from '@/types'

const BASE_URL = 'http://127.0.0.1:8000'

const loading = ref(false)
const submitting = ref(false)
const showModal = ref(false)
const showDeleteModal = ref(false)
const isEditing = ref(false)
const currentId = ref<number | null>(null)
const deleteTarget = ref<Vehicle | null>(null)
const fileInput = ref<HTMLInputElement | null>(null)
const imagePreview = ref<string | null>(null)
const imageFile = ref<File | null>(null)
const featuresInput = ref('')

const vehicles = ref<Vehicle[]>([])
const filters = ref({ search: '', type: '', available: '', page: 1 })
const totalItems = ref(0)
const itemsPerPage = 10

const totalPages = computed(() => Math.ceil(totalItems.value / itemsPerPage))

const form = ref({
  type: '' as any,
  brand: '',
  model: '',
  year: null as number | null,
  plate_number: '',
  capacity: null as number | null,
  daily_rate: 0,
  driver_rate: 0,
  is_available: true,
  is_active: true,
})

async function fetchData() {
  loading.value = true
  try {
    const params: any = { page: filters.value.page, page_size: itemsPerPage }
    if (filters.value.type) params.type = filters.value.type
    if (filters.value.available !== '') params.available = filters.value.available
    const { data } = await vehicleApi.list(params)
    vehicles.value = Array.isArray(data) ? data : data.results || []
    totalItems.value = Array.isArray(data) ? data.length : data.count || vehicles.value.length
  } catch (err) {
    console.error('Failed to fetch vehicles:', err)
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

function openEditModal(v: Vehicle) {
  isEditing.value = true
  currentId.value = v.id
  form.value = {
    type: v.type,
    brand: v.brand,
    model: v.model,
    year: v.year,
    plate_number: v.plate_number,
    capacity: v.capacity,
    daily_rate: Number(v.daily_rate),
    driver_rate: Number(v.driver_rate),
    is_available: v.is_available,
    is_active: v.is_active,
  }
  featuresInput.value = v.features ? v.features.join(', ') : ''
  imagePreview.value = v.image ? getPhotoUrl(v.image) : null
  imageFile.value = null
  showModal.value = true
}

function closeModal() {
  showModal.value = false
  resetForm()
}

function resetForm() {
  form.value = {
    type: '', brand: '', model: '', year: null,
    plate_number: '', capacity: null, daily_rate: 0,
    driver_rate: 0, is_available: true, is_active: true,
  }
  featuresInput.value = ''
  imagePreview.value = null
  imageFile.value = null
}

function triggerFileInput() { fileInput.value?.click() }

function handleFileChange(e: Event) {
  const file = (e.target as HTMLInputElement).files?.[0]
  if (file) setImageFile(file)
}

function handleDrop(e: DragEvent) {
  const file = e.dataTransfer?.files?.[0]
  if (file && file.type.startsWith('image/')) setImageFile(file)
}

function setImageFile(file: File) {
  imageFile.value = file
  const reader = new FileReader()
  reader.onload = (e) => { imagePreview.value = e.target?.result as string }
  reader.readAsDataURL(file)
}

function clearImage() {
  imagePreview.value = null
  imageFile.value = null
  if (fileInput.value) fileInput.value.value = ''
}

async function handleSubmit() {
  submitting.value = true
  try {
    const features = featuresInput.value ? featuresInput.value.split(',').map(f => f.trim()).filter(Boolean) : []
    const payload: any = { ...form.value, features }
    if (!payload.year) delete payload.year
    if (!payload.capacity) delete payload.capacity

    if (imageFile.value) {
      const fd = new FormData()
      Object.entries(payload).forEach(([k, v]) => {
        if (v !== null && v !== undefined) {
          if (Array.isArray(v)) fd.append(k, JSON.stringify(v))
          else fd.append(k, String(v))
        }
      })
      fd.append('image', imageFile.value)
      if (isEditing.value && currentId.value) {
        await vehicleApi.update(currentId.value, fd as any)
      } else {
        await vehicleApi.create(fd as any)
      }
    } else {
      if (isEditing.value && currentId.value) {
        await vehicleApi.update(currentId.value, payload)
      } else {
        await vehicleApi.create(payload)
      }
    }

    showModal.value = false
    fetchData()
  } catch (err: any) {
    const msg = err.response?.data ? JSON.stringify(err.response.data) : 'Failed to save vehicle.'
    alert(msg)
  } finally {
    submitting.value = false
  }
}

async function toggleAvailability(item: Vehicle) {
  try {
    await vehicleApi.update(item.id, { is_available: !item.is_available } as any)
    item.is_available = !item.is_available
  } catch {
    alert('Failed to update availability.')
  }
}

function openDeleteModal(item: Vehicle) {
  deleteTarget.value = item
  showDeleteModal.value = true
}

async function confirmDelete() {
  if (!deleteTarget.value) return
  submitting.value = true
  try {
    await vehicleApi.delete(deleteTarget.value.id)
    showDeleteModal.value = false
    deleteTarget.value = null
    fetchData()
  } catch {
    alert('Failed to delete vehicle.')
  } finally {
    submitting.value = false
  }
}

function formatPrice(val: number | string) {
  return new Intl.NumberFormat('id-ID').format(Math.round(Number(val || 0)))
}

function getPhotoUrl(path?: string | null) {
  if (!path) return '/Logo.png'
  if (path.startsWith('http')) return path
  return `${BASE_URL}${path}`
}

function handleImgError(e: Event) {
  (e.target as HTMLImageElement).src = '/Logo.png'
}

onMounted(fetchData)
</script>

<style scoped>
.page-header { display: flex; justify-content: space-between; align-items: flex-end; margin-bottom: 24px; }
.admin-title { font-family: 'Barlow Condensed', sans-serif; font-size: 2rem; font-style: italic; font-weight: 800; margin-bottom: 4px; }
.admin-subtitle { color: var(--w40); font-size: 0.9rem; }
.filter-bar { display: flex; gap: 12px; align-items: center; padding: 16px; margin-bottom: 24px; flex-wrap: wrap; }
.filter-group { flex: 1; min-width: 140px; }
.filter-group .form-input, .filter-group .form-select { width: 100%; }
.table-wrap { overflow-x: auto; }
.item-info { display: flex; align-items: center; gap: 12px; }
.item-img { width: 48px; height: 48px; border-radius: 8px; object-fit: cover; background: var(--w04); flex-shrink: 0; }
.item-name { font-weight: 600; color: #fff; }
.item-year { font-size: .75rem; color: var(--w40); }
.type-badge { padding: 3px 10px; border-radius: 6px; border: 1px solid var(--w15); font-size: .72rem; color: var(--w70); background: var(--w04); font-weight: 700; }
.plate-num { font-family: monospace; font-weight: 700; color: var(--w90); font-size: .85rem; background: var(--dark3); padding: 3px 8px; border-radius: 4px; }
.price-val { font-weight: 700; color: #fff; }
.driver-rate { font-size: .82rem; color: var(--w60); }
.text-muted { color: var(--w40); font-size: .82rem; }
.action-btns { display: flex; gap: 6px; flex-wrap: wrap; }
.pagination { display: flex; align-items: center; justify-content: center; gap: 16px; font-size: 0.9rem; color: var(--w70); }
.mt-4 { margin-top: 24px; }

.image-upload-area {
  width: 100%; min-height: 160px; border: 2px dashed var(--w15); border-radius: 12px;
  display: flex; align-items: center; justify-content: center; cursor: pointer;
  transition: all .2s; margin-bottom: 24px; position: relative; overflow: hidden;
}
.image-upload-area:hover { border-color: var(--blue); background: rgba(26,143,255,.05); }
.hidden-input { display: none; }
.upload-placeholder { display: flex; flex-direction: column; align-items: center; gap: 8px; color: var(--w40); text-align: center; padding: 24px; font-size: .9rem; }
.image-preview-wrap { width: 100%; height: 160px; position: relative; }
.image-preview { width: 100%; height: 100%; object-fit: cover; }
.img-remove-btn { position: absolute; top: 8px; right: 8px; width: 28px; height: 28px; background: rgba(0,0,0,.7); border: none; border-radius: 50%; color: #fff; font-size: 1rem; display: flex; align-items: center; justify-content: center; cursor: pointer; }

.toggle-group { display: flex; gap: 24px; margin-top: 8px; }
.toggle-label { display: flex; align-items: center; gap: 10px; cursor: pointer; font-size: .9rem; color: var(--w70); }
.toggle-label input { display: none; }
.toggle-slider { width: 40px; height: 22px; background: var(--w15); border-radius: 99px; position: relative; transition: .2s; }
.toggle-slider::after { content: ''; position: absolute; top: 3px; left: 3px; width: 16px; height: 16px; background: #fff; border-radius: 50%; transition: .2s; }
.toggle-label input:checked + .toggle-slider { background: var(--blue); }
.toggle-label input:checked + .toggle-slider::after { transform: translateX(18px); }

.modal-overlay { position: fixed; inset: 0; background: rgba(0,0,0,.8); backdrop-filter: blur(8px); display: flex; align-items: center; justify-content: center; z-index: 1000; padding: 20px; }
.modal-content { width: 100%; max-width: 700px; max-height: 90vh; overflow-y: auto; animation: modalSlide .3s ease-out; }
@keyframes modalSlide { from{opacity:0;transform:translateY(20px)} to{opacity:1;transform:translateY(0)} }
.modal-header { display: flex; justify-content: space-between; align-items: center; padding: 20px 24px; border-bottom: 1px solid var(--w08); }
.modal-title { font-family: 'Barlow Condensed', sans-serif; font-style: italic; font-weight: 700; font-size: 1.5rem; }
.btn-close { background: none; border: none; color: var(--w40); font-size: 1.8rem; cursor: pointer; }
.modal-form { padding: 24px; }
.modal-body { padding: 24px; }
.modal-footer { display: flex; justify-content: flex-end; gap: 12px; padding: 16px 24px; border-top: 1px solid var(--w08); }
.form-grid { display: grid; grid-template-columns: repeat(2, 1fr); gap: 16px; }
.full-width { grid-column: span 2; }
.form-label { display: block; font-size: .72rem; font-weight: 600; color: var(--w40); text-transform: uppercase; letter-spacing: .8px; margin-bottom: 6px; }
.btn-spinner { width: 14px; height: 14px; border-radius: 50%; border: 2px solid rgba(255,255,255,.3); border-top-color: #fff; animation: spin .7s linear infinite; }
@keyframes spin { to { transform: rotate(360deg); } }
</style>
