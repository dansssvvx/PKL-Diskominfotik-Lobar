<template>
  <div class="op-bookings">
    <!-- Header -->
    <div class="page-header">
      <div>
        <h1 class="admin-title">Bookings</h1>
        <p class="admin-subtitle">Kelola semua reservasi dan status pembayaran bisnis Anda.</p>
      </div>
      <button class="btn btn-ghost" @click="fetchData">🔄 Refresh</button>
    </div>

    <!-- Booking Type Tabs -->
    <div class="tabs mb-4">
      <button class="tab-btn" :class="{ active: activeTab === 'package' }" @click="changeTab('package')">
        🗺️ Tour Packages
      </button>
      <button class="tab-btn" :class="{ active: activeTab === 'homestay' }" @click="changeTab('homestay')">
        🏡 Homestays
      </button>
      <button class="tab-btn" :class="{ active: activeTab === 'vehicle' }" @click="changeTab('vehicle')">
        🚗 Vehicle Rentals
      </button>
    </div>

    <!-- Filters -->
    <div class="card filter-bar">
      <div class="filter-group">
        <input v-model="filters.search" type="text" class="form-input" placeholder="Search by name or booking #..." @keyup.enter="fetchData" />
      </div>
      <div class="filter-group">
        <select v-model="filters.status" class="form-select" @change="handleFilterChange">
          <option value="">All Statuses</option>
          <option value="pending">Pending</option>
          <option value="confirmed">Confirmed</option>
          <option value="completed">Completed</option>
          <option value="cancelled">Cancelled</option>
        </select>
      </div>
      <div class="filter-group">
        <input v-model="filters.date_from" type="date" class="form-input" @change="handleFilterChange" />
      </div>
      <div class="filter-group">
        <input v-model="filters.date_to" type="date" class="form-input" @change="handleFilterChange" />
      </div>
    </div>

    <!-- Summary Bar -->
    <div class="summary-bar" v-if="!loading && bookings.length > 0">
      <div class="summary-item">
        <span class="summary-label">Total</span>
        <span class="summary-value">{{ totalItems }}</span>
      </div>
      <div class="summary-item">
        <span class="summary-label">Pending</span>
        <span class="summary-value badge-warning-text">{{ countByStatus('pending') }}</span>
      </div>
      <div class="summary-item">
        <span class="summary-label">Confirmed</span>
        <span class="summary-value badge-success-text">{{ countByStatus('confirmed') }}</span>
      </div>
      <div class="summary-item">
        <span class="summary-label">Revenue</span>
        <span class="summary-value">Rp {{ totalRevenue }}</span>
      </div>
    </div>

    <!-- Table -->
    <div class="card table-wrap">
      <table class="table">
        <!-- Package Bookings Header -->
        <thead v-if="activeTab === 'package'">
          <tr>
            <th>Booking #</th>
            <th>Customer</th>
            <th>Package</th>
            <th>Schedule</th>
            <th>Persons</th>
            <th>Total</th>
            <th>Status</th>
            <th>Payment</th>
            <th>Actions</th>
          </tr>
        </thead>
        <!-- Homestay Header -->
        <thead v-else-if="activeTab === 'homestay'">
          <tr>
            <th>Booking #</th>
            <th>Guest</th>
            <th>Room / Homestay</th>
            <th>Stay Period</th>
            <th>Nights</th>
            <th>Total</th>
            <th>Status</th>
            <th>Payment</th>
            <th>Actions</th>
          </tr>
        </thead>
        <!-- Vehicle Header -->
        <thead v-else>
          <tr>
            <th>Rental #</th>
            <th>Renter</th>
            <th>Vehicle</th>
            <th>Period</th>
            <th>Days</th>
            <th>Total</th>
            <th>Status</th>
            <th>Payment</th>
            <th>Actions</th>
          </tr>
        </thead>

        <tbody v-if="loading">
          <tr><td :colspan="9" style="text-align:center;padding:40px"><div class="spinner"></div></td></tr>
        </tbody>
        <tbody v-else-if="bookings.length === 0">
          <tr>
            <td :colspan="9">
              <div class="empty-state">
                <div class="icon">📭</div>
                <h3>No bookings found</h3>
                <p>No {{ activeTab }} bookings match your current filters.</p>
              </div>
            </td>
          </tr>
        </tbody>
        <tbody v-else>
          <tr v-for="b in bookings" :key="b.id">
            <!-- Booking Number -->
            <td><code class="booking-num">#{{ b.booking_number || b.rental_number || b.id }}</code></td>

            <!-- Customer / Guest / Renter -->
            <td>
              <div class="user-cell">
                <div class="user-name">{{ b.user_name || b.guest_name || b.renter_name || b.user?.fullname || '-' }}</div>
                <div class="user-sub">{{ b.user_email || b.guest_email || b.renter_phone || '' }}</div>
              </div>
            </td>

            <!-- Item -->
            <td>
              <div class="item-cell">
                <div class="item-name">{{ b.package_name || b.room_name || b.vehicle_name || '-' }}</div>
                <div class="item-sub">{{ b.agency_name || b.homestay_name || b.vehicle_brand || '' }}</div>
              </div>
            </td>

            <!-- Dates -->
            <td>
              <div class="date-cell">
                <div>{{ formatDate(b.start_date || b.check_in) }}</div>
                <div class="date-sub">to {{ formatDate(b.end_date || b.check_out) }}</div>
              </div>
            </td>

            <!-- Persons / Nights / Days -->
            <td>
              <span v-if="activeTab === 'package'">{{ b.total_person }} pax</span>
              <span v-else-if="activeTab === 'homestay'">{{ b.total_nights || '-' }} nights</span>
              <span v-else>{{ b.total_days || '-' }} days</span>
            </td>

            <!-- Price -->
            <td class="price-val">Rp {{ formatPrice(b.total_price) }}</td>

            <!-- Status -->
            <td><span class="badge" :class="statusBadge(b.status)">{{ b.status }}</span></td>

            <!-- Payment -->
            <td>
              <span class="badge" :class="paymentBadge(b.payment_status)">{{ b.payment_status }}</span>
            </td>

            <!-- Actions -->
            <td>
              <button class="btn btn-ghost btn-sm" @click="openManageModal(b)">Manage</button>
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

    <!-- Manage Booking Modal -->
    <div class="modal-overlay" v-if="showManageModal" @click.self="closeManageModal">
      <div class="modal-content card" style="max-width:560px">
        <div class="modal-header">
          <h2 class="modal-title">Manage Booking</h2>
          <button class="btn-close" @click="closeManageModal">×</button>
        </div>
        <div class="modal-body" v-if="selectedBooking">
          <!-- Booking Detail -->
          <div class="booking-detail-grid">
            <div class="detail-row">
              <span class="detail-label">Booking #</span>
              <code class="booking-num">{{ selectedBooking.booking_number || selectedBooking.rental_number || selectedBooking.id }}</code>
            </div>
            <div class="detail-row">
              <span class="detail-label">Customer</span>
              <span>{{ selectedBooking.user_name || selectedBooking.guest_name || selectedBooking.renter_name || selectedBooking.user?.fullname || '-' }}</span>
            </div>
            <div class="detail-row">
              <span class="detail-label">Item</span>
              <span>{{ selectedBooking.package_name || selectedBooking.room_name || selectedBooking.vehicle_name || '-' }}</span>
            </div>
            <div class="detail-row">
              <span class="detail-label">Total</span>
              <span class="price-val">Rp {{ formatPrice(selectedBooking.total_price) }}</span>
            </div>
            <div class="detail-row" v-if="selectedBooking.special_request">
              <span class="detail-label">Special Request</span>
              <span>{{ selectedBooking.special_request }}</span>
            </div>
          </div>

          <div class="divider"></div>

          <!-- Update Status -->
          <div class="update-section">
            <h4 class="section-label">Update Booking Status</h4>
            <div class="status-options">
              <label class="status-option" v-for="s in ['pending','confirmed','completed','cancelled']" :key="s">
                <input type="radio" v-model="manageForm.status" :value="s" />
                <span class="status-option__dot" :class="`dot-${s}`"></span>
                <span class="capitalize">{{ s }}</span>
              </label>
            </div>
          </div>

          <div class="update-section">
            <h4 class="section-label">Update Payment Status</h4>
            <div class="status-options">
              <label class="status-option" v-for="s in ['pending','paid','failed','refunded']" :key="s">
                <input type="radio" v-model="manageForm.payment_status" :value="s" />
                <span class="status-option__dot" :class="`dot-${s}`"></span>
                <span class="capitalize">{{ s }}</span>
              </label>
            </div>
          </div>

          <!-- Payment Proof -->
          <div class="payment-proof-section" v-if="selectedBooking.payment_proof">
            <h4 class="section-label">Payment Proof</h4>
            <a :href="getPhotoUrl(selectedBooking.payment_proof)" target="_blank" class="proof-link">
              🖼️ View Uploaded Proof
            </a>
          </div>
        </div>
        <div class="modal-footer">
          <button class="btn btn-ghost" @click="closeManageModal">Cancel</button>
          <button class="btn btn-primary" :disabled="submitting" @click="saveStatus">
            <span v-if="submitting" class="btn-spinner"></span>
            {{ submitting ? 'Updating...' : 'Update Booking' }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { agencyApi, adminApi } from '@/api'

const BASE_URL = 'http://127.0.0.1:8000'

const loading = ref(false)
const submitting = ref(false)
const activeTab = ref<'package' | 'homestay' | 'vehicle'>('package')
const showManageModal = ref(false)
const selectedBooking = ref<any | null>(null)

const bookings = ref<any[]>([])
const filters = ref({ search: '', status: '', date_from: '', date_to: '', page: 1 })
const totalItems = ref(0)
const itemsPerPage = 15

const manageForm = ref({ status: '', payment_status: '' })

const totalPages = computed(() => Math.ceil(totalItems.value / itemsPerPage))

const totalRevenue = computed(() => {
  const total = bookings.value
    .filter(b => b.payment_status === 'paid')
    .reduce((sum, b) => sum + Number(b.total_price || 0), 0)
  return new Intl.NumberFormat('id-ID').format(Math.round(total))
})

function countByStatus(status: string) {
  return bookings.value.filter(b => b.status === status).length
}

async function fetchData() {
  loading.value = true
  try {
    let data: any
    const params: any = {
      page: filters.value.page,
      page_size: itemsPerPage,
    }
    if (filters.value.status) params.status = filters.value.status

    if (activeTab.value === 'package') {
      const res = await agencyApi.bookings(params)
      data = res.data
    } else if (activeTab.value === 'homestay') {
      const res = await agencyApi.homestayBookings(params)
      data = res.data
    } else {
      const res = await agencyApi.rentalBookings(params)
      data = res.data
    }

    bookings.value = Array.isArray(data) ? data : data.results || []
    totalItems.value = Array.isArray(data) ? data.length : data.count || bookings.value.length

    // Client-side search filter
    if (filters.value.search) {
      const q = filters.value.search.toLowerCase()
      bookings.value = bookings.value.filter(b => {
        const num = (b.booking_number || b.rental_number || '').toLowerCase()
        const name = (b.user_name || b.guest_name || b.renter_name || '').toLowerCase()
        return num.includes(q) || name.includes(q)
      })
    }
  } catch (err) {
    console.error('Failed to fetch bookings:', err)
  } finally {
    loading.value = false
  }
}

function changeTab(tab: 'package' | 'homestay' | 'vehicle') {
  activeTab.value = tab
  filters.value.page = 1
  filters.value.search = ''
  fetchData()
}

function handleFilterChange() {
  filters.value.page = 1
  fetchData()
}

function openManageModal(b: any) {
  selectedBooking.value = b
  manageForm.value = {
    status: b.status,
    payment_status: b.payment_status,
  }
  showManageModal.value = true
}

function closeManageModal() {
  showManageModal.value = false
  selectedBooking.value = null
}

async function saveStatus() {
  if (!selectedBooking.value) return
  submitting.value = true
  try {
    await adminApi.updateBookingStatus({
      id: selectedBooking.value.id,
      type: activeTab.value,
      ...manageForm.value,
    })
    // Update local state
    const idx = bookings.value.findIndex(b => b.id === selectedBooking.value!.id)
    if (idx !== -1) {
      bookings.value[idx].status = manageForm.value.status
      bookings.value[idx].payment_status = manageForm.value.payment_status
    }
    showManageModal.value = false
  } catch (err: any) {
    alert(err.response?.data?.detail || 'Failed to update booking status.')
  } finally {
    submitting.value = false
  }
}

function formatDate(d?: string) {
  if (!d) return '-'
  return new Date(d).toLocaleDateString('id-ID', { day: '2-digit', month: 'short', year: 'numeric' })
}

function formatPrice(val: number | string) {
  return new Intl.NumberFormat('id-ID').format(Math.round(Number(val || 0)))
}

function statusBadge(s: string) {
  switch (s) {
    case 'confirmed': case 'completed': return 'badge-success'
    case 'pending': return 'badge-warning'
    case 'cancelled': return 'badge-danger'
    default: return 'badge-gray'
  }
}

function paymentBadge(s: string) {
  switch (s) {
    case 'paid': return 'badge-success'
    case 'pending': return 'badge-warning'
    case 'failed': case 'refunded': return 'badge-danger'
    default: return 'badge-gray'
  }
}

function getPhotoUrl(path?: string | null) {
  if (!path) return '#'
  if (path.startsWith('http')) return path
  return `${BASE_URL}${path}`
}

onMounted(fetchData)
</script>

<style scoped>
.page-header { display: flex; justify-content: space-between; align-items: flex-end; margin-bottom: 24px; }
.admin-title { font-family: 'Barlow Condensed', sans-serif; font-size: 2rem; font-style: italic; font-weight: 800; margin-bottom: 4px; }
.admin-subtitle { color: var(--w40); font-size: 0.9rem; }

.tabs { display: flex; gap: 4px; border-bottom: 1px solid var(--w08); }
.tab-btn {
  padding: 12px 24px; background: transparent; border: none; border-bottom: 2px solid transparent;
  color: var(--w40); font-weight: 600; font-size: .9rem; cursor: pointer; transition: all 0.2s;
}
.tab-btn.active { color: var(--blue-b); border-bottom-color: var(--blue-b); background: rgba(26,143,255,0.05); }
.mb-4 { margin-bottom: 24px; }

.filter-bar { display: flex; gap: 12px; align-items: center; padding: 16px; margin-bottom: 16px; flex-wrap: wrap; }
.filter-group { flex: 1; min-width: 140px; }
.filter-group .form-input, .filter-group .form-select { width: 100%; }

.summary-bar {
  display: flex; gap: 0; margin-bottom: 16px;
  background: var(--dark2); border: 1px solid var(--w08); border-radius: 12px; overflow: hidden;
}
.summary-item { flex: 1; padding: 12px 20px; text-align: center; border-right: 1px solid var(--w08); }
.summary-item:last-child { border-right: none; }
.summary-label { display: block; font-size: .65rem; color: var(--w40); text-transform: uppercase; letter-spacing: .8px; margin-bottom: 4px; }
.summary-value { font-family: 'Bebas Neue', sans-serif; font-size: 1.3rem; letter-spacing: 1px; }
.badge-warning-text { color: #fbbf24; }
.badge-success-text { color: #4ade80; }

.table-wrap { overflow-x: auto; }
.booking-num { font-family: monospace; font-weight: 700; color: var(--blue-b); font-size: .78rem; }
.user-cell, .item-cell, .date-cell {}
.user-name, .item-name { font-weight: 600; color: #fff; font-size: .88rem; }
.user-sub, .item-sub, .date-sub { font-size: .72rem; color: var(--w40); }
.price-val { font-weight: 700; color: #fff; }
.capitalize { text-transform: capitalize; }
.pagination { display: flex; align-items: center; justify-content: center; gap: 16px; font-size: .9rem; color: var(--w70); }
.mt-4 { margin-top: 24px; }

/* Modal */
.modal-overlay { position: fixed; inset: 0; background: rgba(0,0,0,.8); backdrop-filter: blur(8px); display: flex; align-items: center; justify-content: center; z-index: 1000; padding: 20px; }
.modal-content { width: 100%; max-height: 90vh; overflow-y: auto; animation: modalSlide .3s ease-out; }
@keyframes modalSlide { from{opacity:0;transform:translateY(20px)} to{opacity:1;transform:translateY(0)} }
.modal-header { display: flex; justify-content: space-between; align-items: center; padding: 20px 24px; border-bottom: 1px solid var(--w08); }
.modal-title { font-family: 'Barlow Condensed', sans-serif; font-style: italic; font-weight: 700; font-size: 1.5rem; }
.btn-close { background: none; border: none; color: var(--w40); font-size: 1.8rem; cursor: pointer; }
.modal-body { padding: 24px; }
.modal-footer { display: flex; justify-content: flex-end; gap: 12px; padding: 16px 24px; border-top: 1px solid var(--w08); }

.booking-detail-grid { display: flex; flex-direction: column; gap: 12px; margin-bottom: 20px; }
.detail-row { display: flex; justify-content: space-between; align-items: center; }
.detail-label { font-size: .72rem; color: var(--w40); text-transform: uppercase; letter-spacing: .8px; }
.divider { height: 1px; background: var(--w08); margin: 16px 0; }
.update-section { margin-bottom: 20px; }
.section-label { font-size: .72rem; color: var(--w40); text-transform: uppercase; letter-spacing: .8px; margin-bottom: 12px; }
.status-options { display: grid; grid-template-columns: repeat(2, 1fr); gap: 8px; }
.status-option {
  display: flex; align-items: center; gap: 10px; padding: 10px 14px;
  border: 1px solid var(--w08); border-radius: 8px; cursor: pointer; transition: all .2s;
}
.status-option:hover { background: var(--w04); }
.status-option input { accent-color: var(--blue-b); }
.status-option__dot { width: 8px; height: 8px; border-radius: 50%; flex-shrink: 0; }
.dot-pending, .dot-failed { background: #fbbf24; }
.dot-confirmed, .dot-completed, .dot-paid { background: #4ade80; }
.dot-cancelled, .dot-refunded { background: #f87171; }

.payment-proof-section { margin-top: 16px; }
.proof-link { display: inline-flex; align-items: center; gap: 8px; padding: 10px 16px; background: var(--dark3); border: 1px solid var(--w08); border-radius: 8px; color: var(--blue-b); font-size: .88rem; text-decoration: none; }
.proof-link:hover { background: var(--w04); }
.btn-spinner { width: 14px; height: 14px; border-radius: 50%; border: 2px solid rgba(255,255,255,.3); border-top-color: #fff; animation: spin .7s linear infinite; }
@keyframes spin { to { transform: rotate(360deg); } }
</style>
