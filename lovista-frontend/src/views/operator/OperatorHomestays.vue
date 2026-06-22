<template>
  <div class="op-homestays">
    <div class="page-header">
      <div>
        <h1 class="admin-title">Homestays</h1>
        <p class="admin-subtitle">Kelola properti homestay dan ketersediaan kamar.</p>
      </div>
      <button class="btn btn-primary" @click="openAddModal">+ Add Homestay</button>
    </div>

    <!-- Filters -->
    <div class="card filter-bar">
      <div class="filter-group">
        <input v-model="filters.search" type="text" class="form-input" placeholder="Search homestay..." @keyup.enter="handleFilterChange" />
      </div>
      <div class="filter-group">
        <select v-model="filters.district" class="form-select" @change="handleFilterChange">
          <option value="">All Districts</option>
          <option v-for="d in districts" :key="d" :value="d">{{ d }}</option>
        </select>
      </div>
      <button class="btn btn-ghost" @click="fetchData">🔄 Refresh</button>
    </div>

    <!-- Table -->
    <div class="card table-wrap">
      <table class="table">
        <thead>
          <tr>
            <th>Homestay</th>
            <th>Location</th>
            <th>Rooms</th>
            <th>Check-In/Out</th>
            <th>Status</th>
            <th>Verified</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody v-if="loading">
          <tr><td colspan="7" style="text-align:center;padding:40px"><div class="spinner"></div></td></tr>
        </tbody>
        <tbody v-else-if="homestays.length === 0">
          <tr>
            <td colspan="7">
              <div class="empty-state">
                <div class="icon">🏡</div>
                <h3>No homestays yet</h3>
                <p>Add your first homestay property to start receiving guests.</p>
                <button class="btn btn-primary" style="margin-top:16px" @click="openAddModal">+ Add Homestay</button>
              </div>
            </td>
          </tr>
        </tbody>
        <tbody v-else>
          <tr v-for="h in homestays" :key="h.id">
            <td>
              <div class="item-info">
                <img :src="getPhotoUrl(h.main_image)" class="item-img" @error="handleImgError" />
                <div>
                  <div class="item-name">{{ h.name }}</div>
                  <div class="item-phone" v-if="h.phone">📞 {{ h.phone }}</div>
                </div>
              </div>
            </td>
            <td>
              <div>{{ h.village || '-' }}</div>
              <div class="item-district">{{ h.district || '-' }}</div>
            </td>
            <td>
              <div class="rooms-info">
                <span class="total-rooms">{{ h.total_rooms }} rooms</span>
                <RouterLink :to="`/operator/homestays`" class="rooms-link">Manage rooms →</RouterLink>
              </div>
            </td>
            <td>
              <div class="checkin-info">
                <div>In: {{ h.check_in_time }}</div>
                <div>Out: {{ h.check_out_time }}</div>
              </div>
            </td>
            <td>
              <span class="badge" :class="h.is_active ? 'badge-success' : 'badge-gray'">
                {{ h.is_active ? 'Active' : 'Inactive' }}
              </span>
            </td>
            <td>
              <span class="badge" :class="h.is_verified ? 'badge-success' : 'badge-warning'">
                {{ h.is_verified ? '✅ Verified' : '⏳ Pending' }}
              </span>
            </td>
            <td>
              <div class="action-btns">
                <button class="btn btn-ghost btn-sm" @click="openEditModal(h)">Edit</button>
                <button class="btn btn-ghost btn-sm" @click="openRoomsModal(h)">Rooms</button>
                <button class="btn btn-danger btn-sm" @click="openDeleteModal(h)">Delete</button>
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

    <!-- Add/Edit Homestay Modal -->
    <div class="modal-overlay" v-if="showModal" @click.self="closeModal">
      <div class="modal-content card">
        <div class="modal-header">
          <h2 class="modal-title">{{ isEditing ? 'Edit Homestay' : 'Add New Homestay' }}</h2>
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
              <span>🏡</span>
              <p>Click or drag to upload homestay photo</p>
              <small>JPG, PNG, WEBP up to 5MB</small>
            </div>
          </div>

          <div class="form-grid">
            <div class="form-group full-width">
              <label class="form-label">Homestay Name *</label>
              <input v-model="form.name" type="text" class="form-input" placeholder="e.g. Penginapan Nyoman Bali" required />
            </div>
            <div class="form-group">
              <label class="form-label">Village (Desa)</label>
              <input v-model="form.village" type="text" class="form-input" placeholder="e.g. Senggigi" />
            </div>
            <div class="form-group">
              <label class="form-label">District (Kecamatan)</label>
              <input v-model="form.district" type="text" class="form-input" placeholder="e.g. Batu Layar" />
            </div>
            <div class="form-group full-width">
              <label class="form-label">Address</label>
              <input v-model="form.address" type="text" class="form-input" placeholder="Full address..." />
            </div>
            <div class="form-group">
              <label class="form-label">Phone</label>
              <input v-model="form.phone" type="text" class="form-input" placeholder="+62..." />
            </div>
            <div class="form-group">
              <label class="form-label">Total Rooms</label>
              <input v-model.number="form.total_rooms" type="number" min="1" class="form-input" />
            </div>
            <div class="form-group">
              <label class="form-label">Check-In Time</label>
              <input v-model="form.check_in_time" type="time" class="form-input" />
            </div>
            <div class="form-group">
              <label class="form-label">Check-Out Time</label>
              <input v-model="form.check_out_time" type="time" class="form-input" />
            </div>
            <div class="form-group full-width">
              <label class="form-label">Description</label>
              <textarea v-model="form.description" class="form-input" rows="3" placeholder="Describe your homestay..."></textarea>
            </div>
            <div class="form-group full-width">
              <label class="form-label">Amenities (comma separated)</label>
              <input v-model="amenitiesInput" type="text" class="form-input" placeholder="e.g. WiFi, AC, Breakfast, Parking" />
            </div>
            <div class="form-group full-width">
              <label class="form-label">Policies</label>
              <textarea v-model="form.policies" class="form-input" rows="2" placeholder="Policies and house rules..."></textarea>
            </div>
            <div class="form-group">
              <label class="form-label">Latitude</label>
              <input v-model="form.latitude" type="number" step="any" class="form-input" placeholder="-8.4896" />
            </div>
            <div class="form-group">
              <label class="form-label">Longitude</label>
              <input v-model="form.longitude" type="number" step="any" class="form-input" placeholder="116.0412" />
            </div>
            <div class="form-group">
              <div class="toggle-group">
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
              {{ submitting ? 'Saving...' : (isEditing ? 'Save Changes' : 'Add Homestay') }}
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- Rooms Management Modal -->
    <div class="modal-overlay" v-if="showRoomsModal" @click.self="showRoomsModal = false">
      <div class="modal-content card" style="max-width:760px">
        <div class="modal-header">
          <h2 class="modal-title">Rooms — {{ selectedHomestay?.name }}</h2>
          <button class="btn-close" @click="showRoomsModal = false">×</button>
        </div>
        <div style="padding:24px">
          <div style="display:flex;justify-content:flex-end;margin-bottom:16px">
            <button class="btn btn-primary btn-sm" @click="openAddRoomModal">+ Add Room</button>
          </div>
          <div class="table-wrap card">
            <table class="table">
              <thead>
                <tr><th>Room</th><th>Type</th><th>Capacity</th><th>Price/Night</th><th>Available</th><th>Actions</th></tr>
              </thead>
              <tbody v-if="loadingRooms">
                <tr><td colspan="6" style="text-align:center;padding:24px"><div class="spinner"></div></td></tr>
              </tbody>
              <tbody v-else-if="rooms.length === 0">
                <tr><td colspan="6" style="text-align:center;padding:24px;color:var(--w40)">No rooms configured yet</td></tr>
              </tbody>
              <tbody v-else>
                <tr v-for="r in rooms" :key="r.id">
                  <td><div class="item-name">{{ r.room_number || `Room ${r.id}` }}</div></td>
                  <td>{{ r.room_type || 'Standard' }}</td>
                  <td>{{ r.capacity }} pax</td>
                  <td class="price-val">Rp {{ formatPrice(r.price_per_night) }}/night</td>
                  <td>
                    <span class="badge" :class="r.is_available ? 'badge-success' : 'badge-warning'">
                      {{ r.is_available ? 'Available' : 'Booked' }}
                    </span>
                  </td>
                  <td>
                    <div class="action-btns">
                      <button class="btn btn-ghost btn-sm" @click="editRoom(r)">Edit</button>
                      <button class="btn btn-danger btn-sm" @click="deleteRoom(r.id)">Delete</button>
                    </div>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- Add/Edit Room Form -->
          <div v-if="showRoomForm" class="room-form-section">
            <h3 class="room-form-title">{{ editingRoomId ? 'Edit Room' : 'Add New Room' }}</h3>
            <div class="form-grid">
              <div class="form-group">
                <label class="form-label">Room Number</label>
                <input v-model="roomForm.room_number" type="text" class="form-input" placeholder="e.g. 101" />
              </div>
              <div class="form-group">
                <label class="form-label">Room Type</label>
                <input v-model="roomForm.room_type" type="text" class="form-input" placeholder="e.g. Deluxe, Standard" />
              </div>
              <div class="form-group">
                <label class="form-label">Capacity (pax)</label>
                <input v-model.number="roomForm.capacity" type="number" min="1" class="form-input" />
              </div>
              <div class="form-group">
                <label class="form-label">Price/Night (Rp) *</label>
                <input v-model.number="roomForm.price_per_night" type="number" min="0" class="form-input" required />
              </div>
              <div class="form-group full-width">
                <label class="form-label">Facilities (comma separated)</label>
                <input v-model="roomFacilitiesInput" type="text" class="form-input" placeholder="e.g. AC, TV, Hot Water" />
              </div>
              <div class="form-group">
                <div class="toggle-group">
                  <label class="toggle-label">
                    <input type="checkbox" v-model="roomForm.is_available" />
                    <span class="toggle-slider"></span>
                    Available
                  </label>
                </div>
              </div>
            </div>
            <div style="display:flex;gap:12px;margin-top:16px">
              <button class="btn btn-ghost btn-sm" @click="showRoomForm = false">Cancel</button>
              <button class="btn btn-primary btn-sm" :disabled="submitting" @click="saveRoom">
                {{ submitting ? 'Saving...' : (editingRoomId ? 'Update Room' : 'Add Room') }}
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Delete Confirm -->
    <div class="modal-overlay" v-if="showDeleteModal" @click.self="showDeleteModal = false">
      <div class="modal-content card" style="max-width:400px">
        <div class="modal-header">
          <h2 class="modal-title">Delete Homestay</h2>
          <button class="btn-close" @click="showDeleteModal = false">×</button>
        </div>
        <div class="modal-body">
          <p style="color:var(--w70);margin-bottom:8px">Delete <strong>{{ deleteTarget?.name }}</strong>?</p>
          <p style="color:var(--w40);font-size:.85rem">This action cannot be undone. All rooms and bookings will be affected.</p>
        </div>
        <div class="modal-footer">
          <button class="btn btn-ghost" @click="showDeleteModal = false">Cancel</button>
          <button class="btn btn-danger" :disabled="submitting" @click="confirmDelete">
            {{ submitting ? 'Deleting...' : 'Delete Homestay' }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { RouterLink } from 'vue-router'
import { homestayApi } from '@/api'
import type { Homestay, HomestayRoom } from '@/types'
import api from '@/api'

const BASE_URL = 'http://127.0.0.1:8000'

const loading = ref(false)
const loadingRooms = ref(false)
const submitting = ref(false)
const showModal = ref(false)
const showRoomsModal = ref(false)
const showRoomForm = ref(false)
const showDeleteModal = ref(false)
const isEditing = ref(false)
const currentId = ref<number | null>(null)
const deleteTarget = ref<Homestay | null>(null)
const fileInput = ref<HTMLInputElement | null>(null)
const imagePreview = ref<string | null>(null)
const imageFile = ref<File | null>(null)
const amenitiesInput = ref('')
const selectedHomestay = ref<Homestay | null>(null)
const editingRoomId = ref<number | null>(null)
const roomFacilitiesInput = ref('')

const homestays = ref<Homestay[]>([])
const rooms = ref<HomestayRoom[]>([])
const filters = ref({ search: '', district: '', page: 1 })
const totalItems = ref(0)
const itemsPerPage = 10
const totalPages = computed(() => Math.ceil(totalItems.value / itemsPerPage))

const districts = computed(() => {
  const ds = new Set(homestays.value.map(h => h.district).filter(Boolean))
  return Array.from(ds) as string[]
})

const form = ref({
  name: '',
  address: '',
  village: '',
  district: '',
  phone: '',
  total_rooms: 1,
  description: '',
  check_in_time: '14:00',
  check_out_time: '12:00',
  policies: '',
  latitude: null as number | null,
  longitude: null as number | null,
  is_active: true,
})

const roomForm = ref({
  room_number: '',
  room_type: '',
  capacity: 2,
  price_per_night: 0,
  is_available: true,
})

async function fetchData() {
  loading.value = true
  try {
    const params: any = { page: filters.value.page, page_size: itemsPerPage }
    if (filters.value.district) params.district = filters.value.district
    const { data } = await homestayApi.list(params)
    homestays.value = Array.isArray(data) ? data : data.results || []
    totalItems.value = Array.isArray(data) ? data.length : data.count || homestays.value.length
  } catch (err) {
    console.error(err)
  } finally {
    loading.value = false
  }
}

function handleFilterChange() { filters.value.page = 1; fetchData() }

function openAddModal() {
  isEditing.value = false; currentId.value = null; resetForm(); showModal.value = true
}

function openEditModal(h: Homestay) {
  isEditing.value = true; currentId.value = h.id
  form.value = {
    name: h.name, address: h.address || '', village: h.village || '',
    district: h.district || '', phone: h.phone || '',
    total_rooms: h.total_rooms, description: h.description || '',
    check_in_time: h.check_in_time || '14:00', check_out_time: h.check_out_time || '12:00',
    policies: h.policies || '', latitude: h.latitude, longitude: h.longitude,
    is_active: h.is_active,
  }
  amenitiesInput.value = h.amenities ? h.amenities.join(', ') : ''
  imagePreview.value = h.main_image ? getPhotoUrl(h.main_image) : null
  imageFile.value = null
  showModal.value = true
}

function closeModal() { showModal.value = false; resetForm() }

function resetForm() {
  form.value = {
    name: '', address: '', village: '', district: '', phone: '',
    total_rooms: 1, description: '', check_in_time: '14:00',
    check_out_time: '12:00', policies: '', latitude: null, longitude: null, is_active: true,
  }
  amenitiesInput.value = ''; imagePreview.value = null; imageFile.value = null
}

function triggerFileInput() { fileInput.value?.click() }
function handleFileChange(e: Event) {
  const file = (e.target as HTMLInputElement).files?.[0]
  if (file) setImageFile(file)
}
function handleDrop(e: DragEvent) {
  const file = e.dataTransfer?.files?.[0]
  if (file?.type.startsWith('image/')) setImageFile(file)
}
function setImageFile(file: File) {
  imageFile.value = file
  const reader = new FileReader()
  reader.onload = (e) => { imagePreview.value = e.target?.result as string }
  reader.readAsDataURL(file)
}
function clearImage() {
  imagePreview.value = null; imageFile.value = null
  if (fileInput.value) fileInput.value.value = ''
}

async function handleSubmit() {
  submitting.value = true
  try {
    const amenities = amenitiesInput.value ? amenitiesInput.value.split(',').map(a => a.trim()).filter(Boolean) : []
    const payload: any = { ...form.value, amenities }
    if (!payload.latitude) delete payload.latitude
    if (!payload.longitude) delete payload.longitude

    if (imageFile.value) {
      const fd = new FormData()
      Object.entries(payload).forEach(([k, v]) => {
        if (v !== null && v !== undefined) {
          if (Array.isArray(v)) fd.append(k, JSON.stringify(v))
          else fd.append(k, String(v))
        }
      })
      fd.append('main_image', imageFile.value)
      if (isEditing.value && currentId.value) {
        await homestayApi.update(currentId.value, fd as any)
      } else {
        await homestayApi.create(fd as any)
      }
    } else {
      if (isEditing.value && currentId.value) {
        await homestayApi.update(currentId.value, payload)
      } else {
        await homestayApi.create(payload)
      }
    }
    showModal.value = false; fetchData()
  } catch (err: any) {
    alert(err.response?.data ? JSON.stringify(err.response.data) : 'Failed to save homestay.')
  } finally {
    submitting.value = false
  }
}

async function openRoomsModal(h: Homestay) {
  selectedHomestay.value = h
  showRoomsModal.value = true
  showRoomForm.value = false
  loadingRooms.value = true
  try {
    const { data } = await api.get(`/rooms/?homestay=${h.id}`)
    rooms.value = Array.isArray(data) ? data : data.results || []
  } catch { rooms.value = [] }
  finally { loadingRooms.value = false }
}

function openAddRoomModal() {
  editingRoomId.value = null
  roomForm.value = { room_number: '', room_type: '', capacity: 2, price_per_night: 0, is_available: true }
  roomFacilitiesInput.value = ''
  showRoomForm.value = true
}

function editRoom(r: HomestayRoom) {
  editingRoomId.value = r.id
  roomForm.value = {
    room_number: r.room_number || '',
    room_type: r.room_type || '',
    capacity: r.capacity,
    price_per_night: Number(r.price_per_night),
    is_available: r.is_available,
  }
  roomFacilitiesInput.value = r.facilities ? r.facilities.join(', ') : ''
  showRoomForm.value = true
}

async function saveRoom() {
  if (!selectedHomestay.value) return
  submitting.value = true
  try {
    const facilities = roomFacilitiesInput.value ? roomFacilitiesInput.value.split(',').map(f => f.trim()).filter(Boolean) : []
    const payload = { ...roomForm.value, facilities, homestay: selectedHomestay.value.id }
    if (editingRoomId.value) {
      await api.patch(`/rooms/${editingRoomId.value}/`, payload)
    } else {
      await api.post(`/rooms/`, payload)
    }
    showRoomForm.value = false
    openRoomsModal(selectedHomestay.value)
  } catch (err: any) {
    alert(err.response?.data ? JSON.stringify(err.response.data) : 'Failed to save room.')
  } finally { submitting.value = false }
}

async function deleteRoom(id: number) {
  if (!confirm('Delete this room?')) return
  try {
    await api.delete(`/rooms/${id}/`)
    if (selectedHomestay.value) openRoomsModal(selectedHomestay.value)
  } catch { alert('Failed to delete room.') }
}

function openDeleteModal(h: Homestay) { deleteTarget.value = h; showDeleteModal.value = true }

async function confirmDelete() {
  if (!deleteTarget.value) return
  submitting.value = true
  try {
    await api.delete(`/homestays/${deleteTarget.value.id}/`)
    showDeleteModal.value = false; deleteTarget.value = null; fetchData()
  } catch { alert('Failed to delete homestay.') }
  finally { submitting.value = false }
}

function formatPrice(val: number | string) {
  return new Intl.NumberFormat('id-ID').format(Math.round(Number(val || 0)))
}

function getPhotoUrl(path?: string | null) {
  if (!path) return '/Logo.png'
  if (path.startsWith('http')) return path
  return `${BASE_URL}${path}`
}

function handleImgError(e: Event) { (e.target as HTMLImageElement).src = '/Logo.png' }

onMounted(fetchData)
</script>

<style scoped>
.page-header { display: flex; justify-content: space-between; align-items: flex-end; margin-bottom: 24px; }
.admin-title { font-family: 'Barlow Condensed', sans-serif; font-size: 2rem; font-style: italic; font-weight: 800; margin-bottom: 4px; }
.admin-subtitle { color: var(--w40); font-size: 0.9rem; }
.filter-bar { display: flex; gap: 12px; align-items: center; padding: 16px; margin-bottom: 24px; flex-wrap: wrap; }
.filter-group { flex: 1; min-width: 150px; }
.filter-group .form-input, .filter-group .form-select { width: 100%; }
.table-wrap { overflow-x: auto; }
.item-info { display: flex; align-items: center; gap: 12px; }
.item-img { width: 52px; height: 52px; border-radius: 10px; object-fit: cover; background: var(--w04); flex-shrink: 0; }
.item-name { font-weight: 600; color: #fff; }
.item-phone { font-size: .75rem; color: var(--w40); margin-top: 2px; }
.item-district { font-size: .75rem; color: var(--w40); }
.rooms-info { display: flex; flex-direction: column; gap: 4px; }
.total-rooms { font-weight: 600; font-size: .88rem; }
.rooms-link { font-size: .75rem; color: var(--blue-b); }
.checkin-info { font-size: .82rem; color: var(--w70); }
.action-btns { display: flex; gap: 6px; flex-wrap: wrap; }
.price-val { font-weight: 700; }
.pagination { display: flex; align-items: center; justify-content: center; gap: 16px; font-size: 0.9rem; color: var(--w70); }
.mt-4 { margin-top: 24px; }

.image-upload-area { width: 100%; min-height: 160px; border: 2px dashed var(--w15); border-radius: 12px; display: flex; align-items: center; justify-content: center; cursor: pointer; transition: all .2s; margin-bottom: 24px; position: relative; overflow: hidden; }
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

.room-form-section { border-top: 1px solid var(--w08); margin-top: 24px; padding-top: 24px; }
.room-form-title { font-family: 'Barlow Condensed', sans-serif; font-style: italic; font-weight: 700; font-size: 1.2rem; margin-bottom: 16px; }

.modal-overlay { position: fixed; inset: 0; background: rgba(0,0,0,.8); backdrop-filter: blur(8px); display: flex; align-items: center; justify-content: center; z-index: 1000; padding: 20px; }
.modal-content { width: 100%; max-width: 720px; max-height: 90vh; overflow-y: auto; animation: modalSlide .3s ease-out; }
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
