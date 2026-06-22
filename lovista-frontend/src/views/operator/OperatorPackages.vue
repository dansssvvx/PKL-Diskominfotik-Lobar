<template>
  <div class="op-packages">
    <!-- Header -->
    <div class="page-header">
      <div>
        <h1 class="admin-title">Tour Packages</h1>
        <p class="admin-subtitle">Kelola paket wisata yang ditawarkan bisnis Anda.</p>
      </div>
      <button class="btn btn-primary" @click="openAddModal">+ Add Package</button>
    </div>

    <!-- Filters -->
    <div class="card filter-bar">
      <div class="filter-group">
        <input v-model="filters.search" type="text" class="form-input" placeholder="Search packages..." @keyup.enter="handleFilterChange" />
      </div>
      <div class="filter-group">
        <select v-model="filters.is_active" class="form-select" @change="handleFilterChange">
          <option value="">All Status</option>
          <option value="true">Active</option>
          <option value="false">Inactive</option>
        </select>
      </div>
      <button class="btn btn-ghost" @click="fetchData">🔄 Refresh</button>
    </div>

    <!-- Table -->
    <div class="card table-wrap">
      <table class="table">
        <thead>
          <tr>
            <th>Package Name</th>
            <th>Duration</th>
            <th>Price / Person</th>
            <th>Min/Max Persons</th>
            <th>Status</th>
            <th>Featured</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody v-if="loading">
          <tr><td colspan="7" style="text-align:center;padding:40px"><div class="spinner"></div></td></tr>
        </tbody>
        <tbody v-else-if="packages.length === 0">
          <tr>
            <td colspan="7">
              <div class="empty-state">
                <div class="icon">🗺️</div>
                <h3>No packages yet</h3>
                <p>Create your first tour package to start accepting bookings.</p>
                <button class="btn btn-primary" style="margin-top:16px" @click="openAddModal">+ Add Package</button>
              </div>
            </td>
          </tr>
        </tbody>
        <tbody v-else>
          <tr v-for="item in packages" :key="item.id">
            <td>
              <div class="item-info">
                <img :src="getPhotoUrl(item.main_image)" class="item-img" @error="handleImgError" />
                <div>
                  <div class="item-name">{{ item.name }}</div>
                  <div v-if="Number(item.discount_percentage) > 0" class="discount-badge">{{ item.discount_percentage }}% OFF</div>
                </div>
              </div>
            </td>
            <td>{{ item.duration_days }} Hari</td>
            <td>
              <div class="price-val">Rp {{ formatPrice(item.price_per_person) }}</div>
              <div v-if="Number(item.discount_percentage) > 0" class="price-discounted">
                Rp {{ formatPrice(item.discounted_price || item.price_per_person) }}
              </div>
            </td>
            <td>{{ item.min_person }} – {{ item.max_person || '∞' }}</td>
            <td>
              <span class="badge" :class="item.is_active ? 'badge-success' : 'badge-gray'">
                {{ item.is_active ? 'Active' : 'Inactive' }}
              </span>
            </td>
            <td>
              <span class="badge" :class="item.is_featured ? 'badge-blue' : 'badge-gray'">
                {{ item.is_featured ? '⭐ Featured' : 'Regular' }}
              </span>
            </td>
            <td>
              <div class="action-btns">
                <button class="btn btn-ghost btn-sm" @click="openEditModal(item)">Edit</button>
                <button class="btn btn-ghost btn-sm" @click="toggleStatus(item)">
                  {{ item.is_active ? 'Deactivate' : 'Activate' }}
                </button>
                <button class="btn btn-danger btn-sm" @click="deleteItem(item)">Delete</button>
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
          <h2 class="modal-title">{{ isEditing ? 'Edit Tour Package' : 'Add New Tour Package' }}</h2>
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
              <span class="upload-icon">📸</span>
              <p>Click or drag to upload package photo</p>
              <small>JPG, PNG, WEBP up to 5MB</small>
            </div>
          </div>

          <div class="form-grid">
            <div class="form-group full-width">
              <label class="form-label">Package Name *</label>
              <input v-model="form.name" type="text" class="form-input" placeholder="e.g. Lombok Highlights 3D2N" required />
            </div>
            <div class="form-group">
              <label class="form-label">Duration (Days) *</label>
              <input v-model.number="form.duration_days" type="number" min="1" class="form-input" required />
            </div>
            <div class="form-group">
              <label class="form-label">Price Per Person (Rp) *</label>
              <input v-model.number="form.price_per_person" type="number" min="0" class="form-input" required />
            </div>
            <div class="form-group">
              <label class="form-label">Min Persons</label>
              <input v-model.number="form.min_person" type="number" min="1" class="form-input" />
            </div>
            <div class="form-group">
              <label class="form-label">Max Persons</label>
              <input v-model.number="form.max_person" type="number" min="1" class="form-input" placeholder="Leave empty for unlimited" />
            </div>
            <div class="form-group">
              <label class="form-label">Discount (%)</label>
              <input v-model.number="form.discount_percentage" type="number" min="0" max="100" class="form-input" />
            </div>
            <div class="form-group full-width">
              <label class="form-label">Description</label>
              <textarea v-model="form.description" class="form-input" rows="3" placeholder="Describe this tour package..."></textarea>
            </div>
            <div class="form-group full-width">
              <label class="form-label">What's Included</label>
              <textarea v-model="form.inclusions" class="form-input" rows="2" placeholder="e.g. Accommodation, Meals, Transport..."></textarea>
            </div>
            <div class="form-group full-width">
              <label class="form-label">What's Excluded</label>
              <textarea v-model="form.exclusions" class="form-input" rows="2" placeholder="e.g. Personal expenses, Airfare..."></textarea>
            </div>
            <div class="form-group full-width">
              <label class="form-label">Terms & Conditions</label>
              <textarea v-model="form.terms_conditions" class="form-input" rows="2" placeholder="Terms and conditions for this package..."></textarea>
            </div>
            <div class="form-group">
              <label class="form-label">Status</label>
              <div class="toggle-group">
                <label class="toggle-label">
                  <input type="checkbox" v-model="form.is_active" />
                  <span class="toggle-slider"></span>
                  Active
                </label>
                <label class="toggle-label">
                  <input type="checkbox" v-model="form.is_featured" />
                  <span class="toggle-slider"></span>
                  Featured
                </label>
              </div>
            </div>
          </div>

          <div class="modal-footer">
            <button type="button" class="btn btn-ghost" @click="closeModal">Cancel</button>
            <button type="submit" class="btn btn-primary" :disabled="submitting">
              <span v-if="submitting" class="btn-spinner"></span>
              {{ submitting ? 'Saving...' : (isEditing ? 'Save Changes' : 'Create Package') }}
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- Delete Confirm Modal -->
    <div class="modal-overlay" v-if="showDeleteModal" @click.self="showDeleteModal = false">
      <div class="modal-content card" style="max-width:400px">
        <div class="modal-header">
          <h2 class="modal-title">Delete Package</h2>
          <button class="btn-close" @click="showDeleteModal = false">×</button>
        </div>
        <div class="modal-body" style="padding:24px">
          <p style="color:var(--w70);margin-bottom:8px">Are you sure you want to delete <strong>{{ deleteTarget?.name }}</strong>?</p>
          <p style="color:var(--w40);font-size:.85rem">This action cannot be undone. All related bookings will be affected.</p>
        </div>
        <div class="modal-footer">
          <button class="btn btn-ghost" @click="showDeleteModal = false">Cancel</button>
          <button class="btn btn-danger" :disabled="submitting" @click="confirmDelete">
            {{ submitting ? 'Deleting...' : 'Delete Package' }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { packageApi } from '@/api'
import type { TourPackage } from '@/types'

const BASE_URL = 'http://127.0.0.1:8000'

const loading = ref(false)
const submitting = ref(false)
const showModal = ref(false)
const showDeleteModal = ref(false)
const isEditing = ref(false)
const currentSlug = ref<string | null>(null)
const deleteTarget = ref<TourPackage | null>(null)
const fileInput = ref<HTMLInputElement | null>(null)
const imagePreview = ref<string | null>(null)
const imageFile = ref<File | null>(null)

const packages = ref<TourPackage[]>([])
const filters = ref({ search: '', is_active: '', page: 1 })
const totalItems = ref(0)
const itemsPerPage = 10

const totalPages = computed(() => Math.ceil(totalItems.value / itemsPerPage))

const form = ref({
  name: '',
  description: '',
  duration_days: 1,
  min_person: 1,
  max_person: null as number | null,
  price_per_person: 0,
  discount_percentage: 0,
  inclusions: '',
  exclusions: '',
  terms_conditions: '',
  main_image: '',
  is_active: true,
  is_featured: false,
})

async function fetchData() {
  loading.value = true
  try {
    const params: any = { page: filters.value.page, page_size: itemsPerPage }
    if (filters.value.search) params.search = filters.value.search
    if (filters.value.is_active !== '') params.is_active = filters.value.is_active
    const { data } = await packageApi.list(params)
    packages.value = Array.isArray(data) ? data : data.results || []
    totalItems.value = Array.isArray(data) ? data.length : data.count || packages.value.length
  } catch (err) {
    console.error('Failed to fetch packages:', err)
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
  currentSlug.value = null
  resetForm()
  showModal.value = true
}

function openEditModal(pkg: TourPackage) {
  isEditing.value = true
  currentSlug.value = pkg.slug
  form.value = {
    name: pkg.name,
    description: pkg.description || '',
    duration_days: pkg.duration_days,
    min_person: pkg.min_person,
    max_person: pkg.max_person,
    price_per_person: Number(pkg.price_per_person),
    discount_percentage: Number(pkg.discount_percentage),
    inclusions: pkg.inclusions || '',
    exclusions: pkg.exclusions || '',
    terms_conditions: pkg.terms_conditions || '',
    main_image: pkg.main_image || '',
    is_active: pkg.is_active,
    is_featured: pkg.is_featured,
  }
  imagePreview.value = pkg.main_image ? getPhotoUrl(pkg.main_image) : null
  imageFile.value = null
  showModal.value = true
}

function closeModal() {
  showModal.value = false
  currentSlug.value = null
  resetForm()
}

function resetForm() {
  form.value = {
    name: '', description: '', duration_days: 1, min_person: 1,
    max_person: null, price_per_person: 0, discount_percentage: 0,
    inclusions: '', exclusions: '', terms_conditions: '',
    main_image: '', is_active: true, is_featured: false,
  }
  imagePreview.value = null
  imageFile.value = null
}

function triggerFileInput() {
  fileInput.value?.click()
}

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
  form.value.main_image = ''
  if (fileInput.value) fileInput.value.value = ''
}

async function handleSubmit() {
  submitting.value = true
  try {
    // Build multipart form data if there's a file
    let payload: any = { ...form.value }
    if (!payload.max_person) delete payload.max_person

    // Generate slug from name
    const slug = form.value.name.toLowerCase().replace(/\s+/g, '-').replace(/[^\w-]+/g, '')

    if (imageFile.value) {
      const fd = new FormData()
      Object.entries(payload).forEach(([k, v]) => {
        if (v !== null && v !== undefined) fd.append(k, String(v))
      })
      fd.append('main_image', imageFile.value)
      fd.append('slug', slug)

      if (isEditing.value && currentSlug.value) {
        await packageApi.update(currentSlug.value, fd as any)
      } else {
        await packageApi.create(fd as any)
      }
    } else {
      if (isEditing.value && currentSlug.value) {
        await packageApi.update(currentSlug.value, { ...payload, slug })
      } else {
        await packageApi.create({ ...payload, slug })
      }
    }

    showModal.value = false
    fetchData()
  } catch (err: any) {
    const msg = err.response?.data ? JSON.stringify(err.response.data) : 'Failed to save package.'
    alert(msg)
  } finally {
    submitting.value = false
  }
}

async function toggleStatus(item: TourPackage) {
  try {
    await packageApi.update(item.slug, { is_active: !item.is_active } as any)
    item.is_active = !item.is_active
  } catch {
    alert('Failed to update status.')
  }
}

function deleteItem(item: TourPackage) {
  deleteTarget.value = item
  showDeleteModal.value = true
}

async function confirmDelete() {
  if (!deleteTarget.value) return
  submitting.value = true
  try {
    await packageApi.delete(deleteTarget.value.slug)
    showDeleteModal.value = false
    deleteTarget.value = null
    fetchData()
  } catch {
    alert('Failed to delete package.')
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

.filter-bar { display: flex; gap: 12px; align-items: center; padding: 16px; margin-bottom: 24px; }
.filter-group { flex: 1; min-width: 150px; }
.filter-group .form-input, .filter-group .form-select { width: 100%; }

.table-wrap { overflow-x: auto; }
.item-info { display: flex; align-items: center; gap: 12px; }
.item-img { width: 48px; height: 48px; border-radius: 8px; object-fit: cover; background: var(--w04); flex-shrink: 0; }
.item-name { font-weight: 600; color: #fff; font-size: 0.95rem; }
.discount-badge { display: inline-block; font-size: 0.65rem; font-weight: 700; color: #4ade80; background: rgba(34,197,94,0.1); border: 1px solid rgba(34,197,94,0.2); padding: 2px 6px; border-radius: 99px; margin-top: 4px; }
.price-val { font-weight: 700; color: #fff; }
.price-discounted { font-size: 0.75rem; color: var(--w40); text-decoration: line-through; }
.action-btns { display: flex; gap: 6px; flex-wrap: wrap; }

.pagination { display: flex; align-items: center; justify-content: center; gap: 16px; font-size: 0.9rem; color: var(--w70); }
.mt-4 { margin-top: 24px; }

/* Upload area */
.image-upload-area {
  width: 100%; min-height: 180px; border: 2px dashed var(--w15); border-radius: 12px;
  display: flex; align-items: center; justify-content: center; cursor: pointer;
  transition: all .2s; margin-bottom: 24px; position: relative; overflow: hidden;
}
.image-upload-area:hover { border-color: var(--blue); background: rgba(26,143,255,.05); }
.hidden-input { display: none; }
.upload-placeholder { display: flex; flex-direction: column; align-items: center; gap: 8px; color: var(--w40); text-align: center; padding: 24px; }
.upload-icon { font-size: 2rem; }
.upload-placeholder p { font-size: .9rem; }
.upload-placeholder small { font-size: .75rem; }
.image-preview-wrap { width: 100%; height: 180px; position: relative; }
.image-preview { width: 100%; height: 100%; object-fit: cover; }
.img-remove-btn {
  position: absolute; top: 8px; right: 8px; width: 28px; height: 28px;
  background: rgba(0,0,0,.7); border: none; border-radius: 50%; color: #fff;
  font-size: 1rem; display: flex; align-items: center; justify-content: center; cursor: pointer;
}

/* Toggle */
.toggle-group { display: flex; gap: 24px; margin-top: 8px; }
.toggle-label { display: flex; align-items: center; gap: 10px; cursor: pointer; font-size: .9rem; color: var(--w70); }
.toggle-label input { display: none; }
.toggle-slider {
  width: 40px; height: 22px; background: var(--w15); border-radius: 99px;
  position: relative; transition: .2s;
}
.toggle-slider::after {
  content: ''; position: absolute; top: 3px; left: 3px;
  width: 16px; height: 16px; background: #fff; border-radius: 50%; transition: .2s;
}
.toggle-label input:checked + .toggle-slider { background: var(--blue); }
.toggle-label input:checked + .toggle-slider::after { transform: translateX(18px); }

/* Modal */
.modal-overlay {
  position: fixed; inset: 0; background: rgba(0,0,0,.8); backdrop-filter: blur(8px);
  display: flex; align-items: center; justify-content: center; z-index: 1000; padding: 20px;
}
.modal-content {
  width: 100%; max-width: 720px; max-height: 90vh; overflow-y: auto;
  animation: modalSlide .3s ease-out;
}
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
