<template>
  <div class="page-wrapper">
    
    <div class="bookings-container container">
      <div class="page-header">
        <h1 class="page-title">My Bookings</h1>
        <p class="page-subtitle">Riwayat pemesanan tiket wisata, penginapan, dan kendaraan Anda.</p>
      </div>

      <!-- Tabs -->
      <div class="tabs-wrap mb-4">
        <div class="tabs">
          <button class="tab-btn" :class="{ active: currentTab === 'packages' }" @click="currentTab = 'packages'">
            Tour Packages
          </button>
          <button class="tab-btn" :class="{ active: currentTab === 'homestays' }" @click="currentTab = 'homestays'">
            Homestays
          </button>
          <button class="tab-btn" :class="{ active: currentTab === 'vehicles' }" @click="currentTab = 'vehicles'">
            Vehicle Rentals
          </button>
        </div>
      </div>

      <div v-if="loading" class="loader-wrap">
        <div class="spinner"></div>
        <p>Memuat riwayat pemesanan...</p>
      </div>

      <div v-else>
        <!-- PACKAGES TAB -->
        <div v-if="currentTab === 'packages'">
          <div v-if="packageBookings.length === 0" class="empty-state">
            <div class="empty-icon">🎟️</div>
            <h2>Belum ada pesanan</h2>
            <p>Anda belum memesan paket tour apapun.</p>
            <router-link to="/packages" class="btn btn-primary mt-4">Cari Paket Tour</router-link>
          </div>
          <div v-else class="booking-list">
            <div v-for="b in packageBookings" :key="b.id" class="card booking-card">
              <div class="booking-header">
                <span class="booking-id">#PKG-{{ b.id.toString().padStart(4, '0') }}</span>
                <span class="badge" :class="getStatusClass(b.status)">{{ b.status.toUpperCase() }}</span>
              </div>
              <div class="booking-body">
                <div class="booking-info">
                  <h3>{{ b.package_name || 'Tour Package' }}</h3>
                  <div class="meta">📅 {{ formatDate(b.booking_date) }}</div>
                  <div class="meta">👥 {{ b.number_of_people }} Orang</div>
                </div>
                <div class="booking-price">
                  <span class="label">Total Price</span>
                  <span class="amount">Rp {{ b.total_price.toLocaleString('id-ID') }}</span>
                  <span class="payment-badge" :class="getPaymentClass(b.payment_status)">{{ b.payment_status }}</span>
                  <button v-if="b.payment_status === 'paid' && (b.status === 'confirmed' || b.status === 'completed')"
                          class="btn btn-sm btn-ghost mt-2" 
                          @click="openReceipt(b, 'package')">
                    📄 E-Receipt
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- HOMESTAYS TAB -->
        <div v-if="currentTab === 'homestays'">
          <div v-if="homestayBookings.length === 0" class="empty-state">
            <div class="empty-icon">🏠</div>
            <h2>Belum ada pesanan</h2>
            <p>Anda belum memesan penginapan.</p>
            <router-link to="/homestays" class="btn btn-primary mt-4">Cari Penginapan</router-link>
          </div>
          <div v-else class="booking-list">
            <div v-for="b in homestayBookings" :key="b.id" class="card booking-card">
              <div class="booking-header">
                <span class="booking-id">#HMS-{{ b.id.toString().padStart(4, '0') }}</span>
                <span class="badge" :class="getStatusClass(b.status)">{{ b.status.toUpperCase() }}</span>
              </div>
              <div class="booking-body">
                <div class="booking-info">
                  <h3>{{ b.homestay_name }} - {{ b.room_name }}</h3>
                  <div class="meta">📅 {{ formatDate(b.check_in) }} to {{ formatDate(b.check_out) }}</div>
                  <div class="meta">🛏️ {{ b.number_of_rooms }} Room(s)</div>
                </div>
                <div class="booking-price">
                  <span class="label">Total Price</span>
                  <span class="amount">Rp {{ b.total_price.toLocaleString('id-ID') }}</span>
                  <span class="payment-badge" :class="getPaymentClass(b.payment_status)">{{ b.payment_status }}</span>
                  <button v-if="b.payment_status === 'paid' && (b.status === 'confirmed' || b.status === 'completed')"
                          class="btn btn-sm btn-ghost mt-2" 
                          @click="openReceipt(b, 'homestay')">
                    📄 E-Receipt
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- VEHICLES TAB -->
        <div v-if="currentTab === 'vehicles'">
          <div v-if="vehicleBookings.length === 0" class="empty-state">
            <div class="empty-icon">🚗</div>
            <h2>Belum ada pesanan</h2>
            <p>Anda belum menyewa kendaraan.</p>
            <router-link to="/rent" class="btn btn-primary mt-4">Sewa Kendaraan</router-link>
          </div>
          <div v-else class="booking-list">
            <div v-for="b in vehicleBookings" :key="b.id" class="card booking-card">
              <div class="booking-header">
                <span class="booking-id">#RNT-{{ b.id.toString().padStart(4, '0') }}</span>
                <span class="badge" :class="getStatusClass(b.status)">{{ b.status.toUpperCase() }}</span>
              </div>
              <div class="booking-body">
                <div class="booking-info">
                  <h3>{{ b.vehicle_model }} ({{ b.vehicle_plate }})</h3>
                  <div class="meta">📅 {{ formatDate(b.start_date) }} to {{ formatDate(b.end_date) }}</div>
                  <div class="meta" v-if="b.with_driver">👨‍✈️ With Driver</div>
                </div>
                <div class="booking-price">
                  <span class="label">Total Price</span>
                  <span class="amount">Rp {{ b.total_price.toLocaleString('id-ID') }}</span>
                  <span class="payment-badge" :class="getPaymentClass(b.payment_status)">{{ b.payment_status }}</span>
                  <button v-if="b.payment_status === 'paid' && (b.status === 'confirmed' || b.status === 'completed')"
                          class="btn btn-sm btn-ghost mt-2" 
                          @click="openReceipt(b, 'vehicle')">
                    📄 E-Receipt
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- E-Receipt Modal -->
    <div class="receipt-modal-overlay" v-if="showReceipt" @click="showReceipt = false">
      <div class="receipt-container" @click.stop id="receipt-content" style="background:#fff;color:#000;padding:32px;width:100%;max-width:500px;border-radius:12px;position:relative">
        <div style="text-align:center;border-bottom:2px dashed #ccc;padding-bottom:16px;margin-bottom:16px">
          <h2 style="font-family:'Bebas Neue',sans-serif;font-size:2.5rem;color:#2563eb;margin:0">LOVISTA</h2>
          <p style="margin:4px 0 0;font-size:0.9rem;color:#666">E-Receipt - {{ receiptType.toUpperCase() }}</p>
        </div>
        
        <div style="margin-bottom:24px">
          <div style="font-weight:bold;font-size:1.2rem;margin-bottom:4px">
            {{ selectedReceipt.package_name || selectedReceipt.homestay_name || selectedReceipt.vehicle_model || 'Booking Receipt' }}
          </div>
          <div style="font-size:0.9rem;color:#444" v-if="receiptType === 'homestay'">{{ selectedReceipt.room_name }}</div>
          <div style="font-size:0.9rem;color:#444" v-if="receiptType === 'vehicle'">{{ selectedReceipt.vehicle_plate }}</div>
          <div style="font-size:0.9rem;color:#444" v-if="receiptType === 'package'">{{ selectedReceipt.number_of_people }} Person(s)</div>
        </div>

        <table style="width:100%;font-size:0.95rem;margin-bottom:24px;border-collapse:collapse">
          <tr style="border-bottom:1px solid #eee" v-if="receiptType === 'package'">
            <td style="padding:8px 0;color:#666">Booking Date</td>
            <td style="padding:8px 0;text-align:right;font-weight:bold">{{ formatDate(selectedReceipt.booking_date) }}</td>
          </tr>
          <tr style="border-bottom:1px solid #eee" v-if="receiptType === 'homestay'">
            <td style="padding:8px 0;color:#666">Check In - Check Out</td>
            <td style="padding:8px 0;text-align:right;font-weight:bold">{{ formatDate(selectedReceipt.check_in) }} to {{ formatDate(selectedReceipt.check_out) }}</td>
          </tr>
          <tr style="border-bottom:1px solid #eee" v-if="receiptType === 'vehicle'">
            <td style="padding:8px 0;color:#666">Rental Period</td>
            <td style="padding:8px 0;text-align:right;font-weight:bold">{{ formatDate(selectedReceipt.start_date) }} to {{ formatDate(selectedReceipt.end_date) }}</td>
          </tr>
        </table>

        <div style="background:#f8fafc;padding:16px;border-radius:8px">
          <div style="display:flex;justify-content:space-between;border-top:1px solid #cbd5e1;padding-top:12px;font-weight:bold;font-size:1.2rem;color:#0f172a">
            <span>Total Paid</span>
            <span>Rp {{ selectedReceipt.total_price.toLocaleString('id-ID') }}</span>
          </div>
        </div>
        
        <div style="margin-top:24px;text-align:center">
          <svg id="receipt-barcode"></svg>
        </div>

        <div style="margin-top:16px;text-align:center;font-size:0.8rem;color:#94a3b8">
          This is an automatically generated receipt.<br>Please present this barcode to the operator.
        </div>
        
        <!-- Action Buttons (ignored when generating PDF) -->
        <div data-html2canvas-ignore="true" style="margin-top:24px;display:flex;gap:12px">
          <button class="btn btn-primary" style="flex:1" @click="downloadReceipt">Save as PDF</button>
          <button class="btn btn-ghost" style="flex:1;background:#f1f5f9;color:#475569;border:1px solid #cbd5e1" @click="showReceipt = false">Close</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import TheNavbar from '@/components/layout/TheNavbar.vue'
import TheFooter from '@/components/layout/TheFooter.vue'
import { bookingApi } from '@/api'

import html2pdf from 'html2pdf.js'
import JsBarcode from 'jsbarcode'
import { nextTick } from 'vue'

const loading = ref(true)
const currentTab = ref('packages')

const packageBookings = ref<any[]>([])
const homestayBookings = ref<any[]>([])
const vehicleBookings = ref<any[]>([])

// Receipt Modal State
const showReceipt = ref(false)
const selectedReceipt = ref<any>(null)
const receiptType = ref<string>('')

function openReceipt(booking: any, type: string) {
  selectedReceipt.value = booking
  receiptType.value = type
  showReceipt.value = true
  
  nextTick(() => {
    let codeStr = ''
    if (type === 'package') codeStr = booking.booking_number || `PKG-${booking.id.toString().padStart(4, '0')}`
    if (type === 'homestay') codeStr = booking.booking_number || `HMS-${booking.id.toString().padStart(4, '0')}`
    if (type === 'vehicle') codeStr = booking.rental_number || `RNT-${booking.id.toString().padStart(4, '0')}`
    
    JsBarcode('#receipt-barcode', codeStr, {
      format: 'CODE128',
      width: 2,
      height: 40,
      displayValue: true,
      fontSize: 14,
      margin: 0
    })
  })
}

function downloadReceipt() {
  const element = document.getElementById('receipt-content')
  if (!element) return
  
  const opt = {
    margin: 0,
    filename: `E-Receipt-${receiptType.value}-${selectedReceipt.value.id}.pdf`,
    image: { type: 'jpeg', quality: 0.98 },
    html2canvas: { scale: 2, useCORS: true },
    jsPDF: { unit: 'in', format: 'letter', orientation: 'portrait' }
  }
  
  html2pdf().set(opt).from(element).save()
}

async function fetchAll() {
  loading.value = true
  try {
    const [pkgRes, hsRes, vehRes] = await Promise.allSettled([
      bookingApi.list(),
      bookingApi.homestayList(),
      bookingApi.rentalList()
    ])
    if (pkgRes.status === 'fulfilled') packageBookings.value = pkgRes.value.data.results || pkgRes.value.data
    if (hsRes.status === 'fulfilled') homestayBookings.value = hsRes.value.data.results || hsRes.value.data
    if (vehRes.status === 'fulfilled') vehicleBookings.value = vehRes.value.data.results || vehRes.value.data
  } catch (err) {
    console.error('Failed to fetch bookings', err)
  } finally {
    loading.value = false
  }
}

function formatDate(dateStr: string) {
  if (!dateStr) return '-'
  return new Date(dateStr).toLocaleDateString('id-ID', { year: 'numeric', month: 'short', day: 'numeric' })
}

function getStatusClass(status: string) {
  switch (status) {
    case 'pending': return 'badge-warning'
    case 'confirmed': return 'badge-blue'
    case 'completed': return 'badge-success'
    case 'cancelled': return 'badge-danger'
    default: return 'badge-blue'
  }
}

function getPaymentClass(status: string) {
  switch (status) {
    case 'unpaid': return 'text-red'
    case 'pending': return 'text-orange'
    case 'paid': return 'text-green'
    case 'refunded': return 'text-gray'
    default: return ''
  }
}

onMounted(() => {
  fetchAll()
})
</script>

<style scoped>
.page-wrapper { min-height: 100vh; display: flex; flex-direction: column; }
.bookings-container { padding-top: 120px; padding-bottom: 80px; flex: 1; max-width: 900px; }

.page-header { margin-bottom: 32px; text-align: center; }
.page-title { font-family: 'Barlow Condensed', sans-serif; font-size: 2.8rem; font-style: italic; font-weight: 800; color: var(--w90); margin-bottom: 8px; }
.page-subtitle { color: var(--w40); font-size: 1.1rem; }

.tabs-wrap { display: flex; justify-content: center; }
.tabs { display: flex; background: var(--w04); border-radius: 12px; padding: 4px; border: 1px solid var(--w08); }
.tab-btn { background: none; border: none; padding: 8px 24px; border-radius: 8px; color: var(--w60); font-weight: 600; cursor: pointer; transition: 0.3s; }
.tab-btn:hover { color: var(--w90); }
.tab-btn.active { background: var(--blue); color: var(--dark); }
.mb-4 { margin-bottom: 24px; }
.mt-4 { margin-top: 24px; }

.loader-wrap { text-align: center; padding: 60px 0; color: var(--w40); }
.spinner { width: 40px; height: 40px; border: 4px solid var(--w08); border-top-color: var(--blue); border-radius: 50%; animation: spin 1s linear infinite; margin: 0 auto 16px; }
@keyframes spin { to { transform: rotate(360deg); } }

.empty-state { text-align: center; padding: 80px 20px; background: var(--w04); border-radius: 24px; border: 1px dashed var(--w08); }
.empty-icon { font-size: 4rem; margin-bottom: 16px; filter: grayscale(1) opacity(0.5); transition: .3s; }
.empty-state:hover .empty-icon { filter: grayscale(0) opacity(1); transform: scale(1.1); }
.empty-state h2 { font-family: 'Barlow Condensed', sans-serif; font-size: 2rem; font-weight: 700; margin-bottom: 8px; }
.empty-state p { color: var(--w40); max-width: 400px; margin: 0 auto; }

.booking-list { display: flex; flex-direction: column; gap: 16px; }
.booking-card { padding: 20px; border-radius: 16px; }
.booking-header { display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid var(--w08); padding-bottom: 12px; margin-bottom: 16px; }
.booking-id { font-family: monospace; font-size: 1rem; color: var(--w40); font-weight: 600; }

.booking-body { display: flex; justify-content: space-between; align-items: flex-start; flex-wrap: wrap; gap: 20px; }
.booking-info h3 { font-size: 1.2rem; font-weight: 700; margin-bottom: 8px; }
.booking-info .meta { font-size: 0.85rem; color: var(--w60); margin-bottom: 4px; }

.booking-price { text-align: right; display: flex; flex-direction: column; align-items: flex-end; }
.booking-price .label { font-size: 0.75rem; color: var(--w40); text-transform: uppercase; letter-spacing: 1px; margin-bottom: 4px; }
.booking-price .amount { font-family: 'Barlow Condensed', sans-serif; font-size: 1.6rem; font-weight: 700; color: var(--w90); margin-bottom: 4px; }
.payment-badge { font-size: 0.75rem; font-weight: 700; text-transform: uppercase; letter-spacing: 1px; padding: 4px 10px; border-radius: 20px; background: var(--w04); }

.text-red { color: #f87171; }
.text-orange { color: #fbbf24; }
.text-green { color: #34d399; }
.text-gray { color: #9ca3af; }

/* Modal Styles */
.receipt-modal-overlay {
  position: fixed; top: 0; left: 0; width: 100%; height: 100%;
  background: rgba(0,0,0,0.6); backdrop-filter: blur(4px);
  display: flex; justify-content: center; align-items: center;
  z-index: 1000; padding: 20px; overflow-y: auto;
}

@media (max-width: 600px) {
  .tabs { flex-direction: column; width: 100%; }
  .tab-btn { text-align: center; }
  .booking-body { flex-direction: column; }
  .booking-price { text-align: left; align-items: flex-start; margin-top: 12px; }
}
</style>
