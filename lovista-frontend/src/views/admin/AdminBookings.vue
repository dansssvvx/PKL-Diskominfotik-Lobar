<template>
  <div class="admin-bookings">
    <div class="admin-bookings__header">
      <div>
        <h1 class="admin-title">Manage Bookings</h1>
        <p class="admin-subtitle">Monitor and manage all platform transactions and reservations.</p>
      </div>
    </div>

    <!-- Booking Type Tabs -->
    <div class="tabs mb-4">
      <button 
        class="tab-btn" 
        :class="{ active: filters.type === 'package' }" 
        @click="changeType('package')"
      >
        Tour Packages
      </button>
      <button 
        class="tab-btn" 
        :class="{ active: filters.type === 'homestay' }" 
        @click="changeType('homestay')"
      >
        Homestays
      </button>
      <button 
        class="tab-btn" 
        :class="{ active: filters.type === 'vehicle' }" 
        @click="changeType('vehicle')"
      >
        Vehicle Rentals
      </button>
    </div>

    <!-- Filters -->
    <div class="card p-4 mb-4 filter-bar" style="padding: 10px;">
      <div class="filter-group">
        <select v-model="filters.status" class="form-select" @change="handleFilterChange">
          <option value="">All Statuses</option>
          <option value="pending">Pending</option>
          <option value="confirmed">Confirmed</option>
          <option value="completed">Completed</option>
          <option value="cancelled">Cancelled</option>
        </select>
      </div>
      <button class="btn btn-ghost" @click="fetchData">Refresh</button>
    </div>

    <!-- Data Table -->
    <div class="card table-wrap">
      <table class="table">
        <thead>
          <tr v-if="filters.type === 'package'">
            <th>Booking #</th>
            <th>Customer</th>
            <th>Package / Agency</th>
            <th>Schedule</th>
            <th>Total</th>
            <th>Status</th>
            <th>Payment</th>
            <th>Actions</th>
          </tr>
          <tr v-else-if="filters.type === 'homestay'">
            <th>Booking #</th>
            <th>Guest</th>
            <th>Homestay / Room</th>
            <th>Stay Duration</th>
            <th>Total</th>
            <th>Status</th>
            <th>Payment</th>
            <th>Actions</th>
          </tr>
          <tr v-else>
            <th>Rental #</th>
            <th>Renter</th>
            <th>Vehicle / Agency</th>
            <th>Period</th>
            <th>Total</th>
            <th>Status</th>
            <th>Payment</th>
            <th>Actions</th>
          </tr>
        </thead>
        
        <tbody v-if="loading">
          <tr><td colspan="8" style="text-align:center;padding:40px;"><div class="spinner"></div></td></tr>
        </tbody>
        <tbody v-else-if="bookings.length === 0">
          <tr><td colspan="8" style="text-align:center;padding:40px;color:var(--w40);">No bookings found for this type.</td></tr>
        </tbody>
        
        <tbody v-else>
          <tr v-for="b in bookings" :key="b.id">
            <!-- ID / Number -->
            <td>
              <span class="booking-num">#{{ b.booking_number || b.rental_number || b.id }}</span>
            </td>

            <!-- User -->
            <td>
              <div class="user-cell">
                <div class="user-name">{{ b.user_name || b.guest_name || b.renter_name }}</div>
                <div class="user-email">{{ b.user_email || b.guest_email || b.renter_phone }}</div>
              </div>
            </td>

            <!-- Item / Business -->
            <td>
              <div class="item-cell">
                <div class="item-name">{{ b.package_name || b.room_name || b.vehicle_name }}</div>
                <div class="biz-name">{{ b.agency_name || b.homestay_name }}</div>
              </div>
            </td>

            <!-- Schedule -->
            <td>
              <div class="date-cell">
                <div class="date-val">{{ formatDate(b.start_date || b.check_in) }}</div>
                <div class="date-sub">to {{ formatDate(b.end_date || b.check_out) }}</div>
              </div>
            </td>

            <!-- Price -->
            <td>
              <div class="price-val">Rp {{ formatPrice(b.total_price) }}</div>
            </td>

            <!-- Status -->
            <td>
              <span class="badge" :class="getStatusBadge(b.status)">{{ b.status }}</span>
            </td>

            <!-- Payment -->
            <td>
              <span class="badge badge-outline" :class="getPaymentBadge(b.payment_status)">
                {{ b.payment_status }}
              </span>
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
      <button class="btn btn-ghost btn-sm" :disabled="filters.page === 1" @click="filters.page--; fetchData()">Prev</button>
      <span>Page {{ filters.page }} of {{ totalPages }}</span>
      <button class="btn btn-ghost btn-sm" :disabled="filters.page === totalPages" @click="filters.page++; fetchData()">Next</button>
    </div>

    <!-- Manage Booking Modal -->
    <div class="modal-overlay" v-if="showManageModal" @click.self="closeManageModal">
      <div class="modal-content card manage-modal">
        <div class="modal-header">
          <h2 class="modal-title">Manage Booking</h2>
          <button class="btn-close" @click="closeManageModal">×</button>
        </div>
        <div class="modal-body" v-if="selectedBooking">
          <div class="manage-grid">
            <div class="info-block">
              <h4 class="block-label">Update Status</h4>
              <div class="status-options">
                <label class="status-option">
                  <input type="radio" v-model="manageForm.status" value="pending" />
                  <span>Pending</span>
                </label>
                <label class="status-option">
                  <input type="radio" v-model="manageForm.status" value="confirmed" />
                  <span>Confirmed</span>
                </label>
                <label class="status-option">
                  <input type="radio" v-model="manageForm.status" value="completed" />
                  <span>Completed</span>
                </label>
                <label class="status-option">
                  <input type="radio" v-model="manageForm.status" value="cancelled" />
                  <span>Cancelled</span>
                </label>
              </div>
            </div>

            <div class="info-block mt-4">
              <h4 class="block-label">Update Payment Status</h4>
              <div class="status-options">
                <label class="status-option">
                  <input type="radio" v-model="manageForm.payment_status" value="pending" />
                  <span>Pending</span>
                </label>
                <label class="status-option">
                  <input type="radio" v-model="manageForm.payment_status" value="paid" />
                  <span>Paid</span>
                </label>
                <label class="status-option">
                  <input type="radio" v-model="manageForm.payment_status" value="failed" />
                  <span>Failed</span>
                </label>
                <label class="status-option">
                  <input type="radio" v-model="manageForm.payment_status" value="refunded" />
                  <span>Refunded</span>
                </label>
              </div>
            </div>
            
            <div class="payment-proof-view mt-4" v-if="selectedBooking.payment_proof">
              <h4 class="block-label">Payment Proof</h4>
              <a :href="getPhotoUrl(selectedBooking.payment_proof)" target="_blank" class="proof-link">
                View Uploaded Proof
              </a>
            </div>
          </div>
        </div>
        <div class="modal-footer">
          <button class="btn btn-ghost" @click="closeManageModal">Cancel</button>
          <button class="btn btn-primary" :disabled="submitting" @click="saveStatus">
            {{ submitting ? 'Updating...' : 'Update Booking' }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import Swal from 'sweetalert2'
import { ref, onMounted, computed } from 'vue'
import { adminApi } from '@/api'

const loading = ref(false)
const submitting = ref(false)
const bookings = ref<any[]>([])
const filters = ref({
  type: 'package',
  status: '',
  page: 1
})
const totalItems = ref(0)
const itemsPerPage = 10

const showManageModal = ref(false)
const selectedBooking = ref<any | null>(null)
const manageForm = ref({
  status: '',
  payment_status: ''
})

const totalPages = computed(() => Math.ceil(totalItems.value / itemsPerPage))

async function fetchData() {
  loading.value = true
  try {
    const { data } = await adminApi.allBookings({ 
      ...filters.value, 
      page_size: itemsPerPage 
    } as any)
    bookings.value = Array.isArray(data) ? data : data.results || []
    totalItems.value = Array.isArray(data) ? data.length : data.count || bookings.value.length
  } catch (error) {
    console.error(error)
  } finally {
    loading.value = false
  }
}

function changeType(type: string) {
  filters.value.type = type
  filters.value.page = 1
  fetchData()
}

function handleFilterChange() {
  filters.value.page = 1
  fetchData()
}

function openManageModal(booking: any) {
  selectedBooking.value = booking
  manageForm.value = {
    status: booking.status,
    payment_status: booking.payment_status
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
      type: filters.value.type,
      ...manageForm.value
    })
    showManageModal.value = false
    fetchData()
  } catch (error) {
    Swal.fire({ title: 'Notification', text: 'Failed to update booking status', icon: 'info' })
  } finally {
    submitting.value = false
  }
}

function formatDate(dateString?: string) {
  if (!dateString) return '-'
  return new Date(dateString).toLocaleDateString('id-ID', {
    day: '2-digit', month: 'short', year: 'numeric'
  })
}

function formatPrice(val: number | string) {
  return new Intl.NumberFormat('id-ID').format(Math.round(Number(val)))
}

function getStatusBadge(status: string) {
  switch (status) {
    case 'confirmed': return 'badge-success'
    case 'completed': return 'badge-success'
    case 'pending': return 'badge-warning'
    case 'cancelled': return 'badge-danger'
    default: return 'badge-gray'
  }
}

function getPaymentBadge(status: string) {
  switch (status) {
    case 'paid': return 'badge-success'
    case 'refunded': return 'badge-blue'
    case 'failed': return 'badge-danger'
    default: return 'badge-warning' // pending
  }
}

function getPhotoUrl(path?: string | null) {
  if (!path) return '/Logo.png'
  if (path.startsWith('http')) return path
  return `http://127.0.0.1:8000${path}`
}

onMounted(() => {
  fetchData()
})
</script>

<style scoped>
.admin-bookings__header { display: flex; justify-content: space-between; align-items: flex-end; margin-bottom: 24px; }
.admin-title { font-family: 'Barlow Condensed', sans-serif; font-size: 2rem; font-style: italic; font-weight: 800; margin-bottom: 4px; }
.admin-subtitle { color: var(--w40); font-size: 0.9rem; }

.tabs { display: flex; gap: 8px; border-bottom: 1px solid var(--w08); }
.tab-btn {
  padding: 12px 24px; background: transparent; border: none; border-bottom: 2px solid transparent;
  color: var(--w40); font-weight: 600; cursor: pointer; transition: all 0.2s;
}
.tab-btn.active { color: var(--blue-b); border-bottom-color: var(--blue-b); background: rgba(26,143,255,0.05); }

.filter-bar { display: flex; gap: 12px; align-items: center; background: var(--dark2); }
.filter-group { flex: 1; max-width: 200px; }

.table-wrap { overflow-x: auto; }
.booking-num { font-family: monospace; font-weight: 700; color: var(--blue-b); }

.user-name { font-weight: 600; color: #fff; }
.user-email { font-size: 0.75rem; color: var(--w40); }

.item-name { font-weight: 600; color: #fff; font-size: 0.9rem; }
.biz-name { font-size: 0.75rem; color: var(--blue-b); }

.date-val { font-size: 0.85rem; color: var(--w90); }
.date-sub { font-size: 0.7rem; color: var(--w40); }

.price-val { font-weight: 700; color: #fff; }

.badge-outline { background: transparent; border: 1px solid currentColor; }

.pagination { display: flex; align-items: center; justify-content: center; gap: 16px; font-size: 0.9rem; color: var(--w70); }

/* Manage Modal Styles */
.manage-modal { max-width: 500px; }
.block-label { font-size: 0.75rem; text-transform: uppercase; color: var(--w40); letter-spacing: 1px; margin-bottom: 12px; }
.status-options { display: grid; grid-template-columns: repeat(2, 1fr); gap: 10px; }
.status-option {
  display: flex; align-items: center; gap: 10px; padding: 12px; border: 1px solid var(--w08);
  border-radius: 8px; cursor: pointer; transition: all 0.2s;
}
.status-option:hover { background: rgba(255,255,255,0.03); }
.status-option input { accent-color: var(--blue-b); }
.status-option span { font-size: 0.9rem; color: var(--w80); }

.proof-link { display: inline-block; padding: 10px 16px; background: var(--dark3); border: 1px solid var(--w08); border-radius: 6px; color: var(--blue-b); font-size: 0.9rem; text-decoration: none; }
.proof-link:hover { background: var(--w04); }

.modal-overlay {
  position: fixed; top: 0; left: 0; width: 100%; height: 100%;
  background: rgba(0,0,0,0.8); backdrop-filter: blur(8px);
  display: flex; align-items: center; justify-content: center; z-index: 1000;
  padding: 20px;
}
.modal-content {
  width: 100%; max-height: 90vh; overflow-y: auto;
  position: relative; animation: modalSlide 0.3s ease-out;
}
@keyframes modalSlide {
  from { opacity: 0; transform: translateY(20px); }
  to { opacity: 1; transform: translateY(0); }
}
.modal-header { display: flex; justify-content: space-between; align-items: center; padding: 20px 24px; border-bottom: 1px solid var(--w08); }
.modal-title { font-family: 'Barlow Condensed', sans-serif; font-style: italic; font-weight: 700; font-size: 1.5rem; }
.btn-close { background: none; border: none; color: var(--w40); font-size: 1.8rem; cursor: pointer; }
.modal-body { padding: 24px; }
.modal-footer { display: flex; justify-content: flex-end; gap: 12px; padding: 20px 24px; border-top: 1px solid var(--w08); }
</style>