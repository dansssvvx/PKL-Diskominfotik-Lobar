<template>
  <div class="vehicle-detail-view">

    <!-- Hero Section -->
    <header class="vehicle-hero" v-if="vehicle">
      <div class="container">
        <RouterLink to="/" class="btn-back">← Back to Home</RouterLink>
        <div class="vehicle-hero__grid">
          
          <!-- Image Gallery / Main Image -->
          <div class="vehicle-gallery">
            <img :src="getPhotoUrl(vehicle.image)" :alt="vehicle.brand" class="main-image" />
          </div>

          <!-- Vehicle Summary Info -->
          <div class="vehicle-summary">
            <div class="badges">
              <span class="badge badge-primary">{{ vehicle.type.toUpperCase() }}</span>
              <span class="badge badge-dark" v-if="vehicle.year">{{ vehicle.year }} Model</span>
            </div>
            <h1 class="font-display">{{ vehicle.brand }} {{ vehicle.model }}</h1>
            <p class="plate-number">{{ vehicle.plate_number }}</p>

            <div class="key-features">
              <div class="feature-item" v-if="vehicle.capacity">
                <span class="icon">👥</span>
                <span>{{ vehicle.capacity }} Seats</span>
              </div>
              <div class="feature-item" v-if="vehicle.driver_rate > 0">
                <span class="icon">👨‍✈️</span>
                <span>Driver Available</span>
              </div>
            </div>

            <div class="price-section">
              <div class="daily-rate">
                <span class="amount">Rp {{ formatNumber(vehicle.daily_rate) }}</span>
                <span class="unit">/ day</span>
              </div>
              <p class="driver-rate" v-if="vehicle.driver_rate > 0">
                + Rp {{ formatNumber(vehicle.driver_rate) }} / day for driver
              </p>
            </div>

          </div>
        </div>
      </div>
    </header>

    <!-- Main Content -->
    <main class="container section" v-if="vehicle">
      <div class="vehicle-content-layout">
        
        <!-- Left: Details & Features -->
        <div class="vehicle-main-info">
          <h2>Vehicle Specifications & Features</h2>
          
          <div class="features-list" v-if="vehicle.features && vehicle.features.length">
            <div class="feature-bullet" v-for="(feature, idx) in vehicle.features" :key="idx">
              ✓ {{ feature }}
            </div>
          </div>
          <p v-else class="text-w40">No specific features listed for this vehicle.</p>

          <h2 class="mt-5">Agency Information</h2>
          <div class="agency-card" v-if="agency">
            <div class="agency-header">
              <div class="agency-avatar">
                <img v-if="agency.logo" :src="getPhotoUrl(agency.logo)" class="agency-logo" />
                <span v-else>🏢</span>
              </div>
              <div>
                <h3>{{ agency.business_name }}</h3>
                <p class="text-w60" v-if="agency.is_verified">✓ Verified Agency</p>
              </div>
            </div>
            <div class="agency-contact">
              <p v-if="agency.address">📍 {{ agency.address }}</p>
              <p v-if="agency.phone">📞 {{ agency.phone }}</p>
              <p v-if="agency.email">📧 {{ agency.email }}</p>
            </div>
          </div>
          <p v-else-if="!loading" class="text-w40">Agency information loading...</p>

        </div>

        <!-- Right: Booking Form Widget -->
        <aside class="vehicle-sidebar">
          <div class="booking-widget">
            <h3>Book this Vehicle</h3>
            
            <form @submit.prevent="handleBooking" class="booking-form">
              <div class="form-group">
                <label>Start Date</label>
                <input type="date" v-model="form.start_date" :min="todayDate" required />
              </div>
              
              <div class="form-group">
                <label>End Date</label>
                <input type="date" v-model="form.end_date" :min="form.start_date || todayDate" required />
              </div>

              <div class="form-group">
                <label>Full Name</label>
                <input type="text" v-model="form.renter_name" placeholder="Your full name" required />
              </div>

              <div class="form-group">
                <label>Phone Number</label>
                <input type="tel" v-model="form.renter_phone" placeholder="Your phone number" required />
              </div>

              <div class="form-group checkbox-group" v-if="vehicle.driver_rate > 0">
                <label>
                  <input type="checkbox" v-model="form.driver_included" />
                  Include Driver (+Rp {{ formatNumber(vehicle.driver_rate) }}/day)
                </label>
              </div>

              <div class="price-calculator mt-4" v-if="totalDays > 0">
                <div class="calc-row">
                  <span>{{ totalDays }} Days Rental</span>
                  <span>Rp {{ formatNumber(totalDays * vehicle.daily_rate) }}</span>
                </div>
                <div class="calc-row" v-if="form.driver_included">
                  <span>Driver ({{ totalDays }} Days)</span>
                  <span>Rp {{ formatNumber(totalDays * vehicle.driver_rate) }}</span>
                </div>
                <div class="divider"></div>
                <div class="calc-row total">
                  <span>Total Estimate</span>
                  <span class="text-blue">Rp {{ formatNumber(totalEstimate) }}</span>
                </div>
              </div>
              
              <p class="validation-error" v-if="totalDays <= 0 && form.start_date && form.end_date">
                End date must be after or equal to start date.
              </p>

              <button type="submit" class="btn btn-primary full-width mt-4" :disabled="totalDays <= 0 || !vehicle.is_available">
                {{ vehicle.is_available ? 'Proceed to Booking' : 'Currently Unavailable' }}
              </button>
            </form>
          </div>
        </aside>

      </div>
    </main>

    <!-- Loading State -->
    <div class="container section loading-state" v-else-if="loading">
      <p>Loading vehicle details...</p>
    </div>

    <div class="container section error-state" v-else>
      <h2 class="text-red">Failed to load vehicle details.</h2>
      <p>It might have been removed or doesn't exist.</p>
      <RouterLink to="/" class="btn btn-primary mt-4">Return Home</RouterLink>
    </div>

    <!-- E-Receipt Modal -->
    <div class="receipt-modal-overlay" v-if="showReceipt" @click="showReceipt = false">
      <div class="receipt-container" @click.stop id="receipt-content" style="background:#fff;color:#000;padding:32px;width:100%;max-width:500px;border-radius:12px;position:relative">
        <div style="text-align:center;border-bottom:2px dashed #ccc;padding-bottom:16px;margin-bottom:16px">
          <h2 style="font-family:'Bebas Neue',sans-serif;font-size:2.5rem;color:#2563eb;margin:0">LOVISTA</h2>
          <p style="margin:4px 0 0;font-size:0.9rem;color:#666">E-Receipt - Vehicle Rental</p>
        </div>
        
        <div style="margin-bottom:24px">
          <div style="font-weight:bold;font-size:1.2rem;margin-bottom:4px">{{ vehicle.brand }} {{ vehicle.model }}</div>
          <div style="font-size:0.9rem;color:#444">{{ vehicle.plate_number }} • {{ vehicle.type.toUpperCase() }}</div>
        </div>

        <table style="width:100%;font-size:0.95rem;margin-bottom:24px;border-collapse:collapse">
          <tr style="border-bottom:1px solid #eee">
            <td style="padding:8px 0;color:#666">Rental Period</td>
            <td style="padding:8px 0;text-align:right;font-weight:bold">{{ formatDate(form.start_date) }} - {{ formatDate(form.end_date) }}</td>
          </tr>
          <tr style="border-bottom:1px solid #eee">
            <td style="padding:8px 0;color:#666">Total Days</td>
            <td style="padding:8px 0;text-align:right;font-weight:bold">{{ totalDays }} Day(s)</td>
          </tr>
          <tr style="border-bottom:1px solid #eee">
            <td style="padding:8px 0;color:#666">Driver</td>
            <td style="padding:8px 0;text-align:right;font-weight:bold">{{ form.driver_included ? 'Included' : 'Not Included' }}</td>
          </tr>
        </table>

        <div style="background:#f8fafc;padding:16px;border-radius:8px">
          <div style="display:flex;justify-content:space-between;margin-bottom:8px">
            <span style="color:#666">Daily Rate (x{{ totalDays }})</span>
            <span>Rp {{ formatNumber(totalDays * vehicle.daily_rate) }}</span>
          </div>
          <div style="display:flex;justify-content:space-between;margin-bottom:12px" v-if="form.driver_included">
            <span style="color:#666">Driver Rate (x{{ totalDays }})</span>
            <span>Rp {{ formatNumber(totalDays * vehicle.driver_rate) }}</span>
          </div>
          <div style="display:flex;justify-content:space-between;border-top:1px solid #cbd5e1;padding-top:12px;font-weight:bold;font-size:1.2rem;color:#0f172a">
            <span>Total Paid</span>
            <span>Rp {{ formatNumber(totalEstimate) }}</span>
          </div>
        </div>
        
        <div style="margin-top:24px;text-align:center">
          <svg id="receipt-barcode"></svg>
        </div>

        <div style="margin-top:16px;text-align:center;font-size:0.8rem;color:#94a3b8">
          This is an automatically generated receipt.<br>Please present this barcode upon pickup.
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
import Swal from 'sweetalert2'
import { ref, onMounted, computed, nextTick } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { vehicleApi, agencyApi, bookingApi } from '@/api'
import type { Vehicle, TravelAgency } from '@/types'
import { useAuthStore } from '@/stores/auth'
import TheNavbar from '@/components/layout/TheNavbar.vue'
import TheFooter from '@/components/layout/TheFooter.vue'
import html2pdf from 'html2pdf.js'
import JsBarcode from 'jsbarcode'

const auth = useAuthStore()
const tzOffset = (new Date()).getTimezoneOffset() * 60000
const todayDate = (new Date(Date.now() - tzOffset)).toISOString().split('T')[0]

const route = useRoute()
const router = useRouter()
const vehicle = ref<Vehicle | null>(null)
const agency = ref<TravelAgency | null>(null)
const loading = ref(true)

const form = ref({
  start_date: '',
  end_date: '',
  driver_included: false,
  renter_name: auth.user?.fullname || '',
  renter_phone: auth.user?.phone || ''
})

const getPhotoUrl = (path?: string) => {
  if (!path) return '/Logo.png'
  if (path.startsWith('http')) return path
  return `http://127.0.0.1:8000${path}`
}

const formatNumber = (num: number | string) => {
  return new Intl.NumberFormat('id-ID').format(Number(num))
}

const totalDays = computed(() => {
  if (!form.value.start_date || !form.value.end_date) return 0
  const start = new Date(form.value.start_date)
  const end = new Date(form.value.end_date)
  const diffTime = end.getTime() - start.getTime()
  if (diffTime < 0) return 0
  const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24))
  return diffDays + 1 // Inclusive of start day
})

const totalEstimate = computed(() => {
  if (!vehicle.value || totalDays.value <= 0) return 0
  let total = totalDays.value * vehicle.value.daily_rate
  if (form.value.driver_included) {
    total += totalDays.value * vehicle.value.driver_rate
  }
  return total
})

const showReceipt = ref(false)
const receiptId = ref('')

function formatDate(d: string) { return new Date(d).toLocaleDateString('id-ID', { year: 'numeric', month: 'long', day: 'numeric' }) }

const handleBooking = async () => {
  if (!auth.isLoggedIn) { router.push('/login'); return }
  if (totalDays.value <= 0) { Swal.fire({ title: 'Error', text: 'Tanggal end_date harus setelah start_date', icon: 'error' }); return }
  if (form.value.start_date < todayDate) {
    Swal.fire({ title: 'Error', text: 'Tanggal rental tidak boleh di masa lalu!', icon: 'error' });
    return;
  }
  
  try {
    const res = await bookingApi.rentalCreate({
      vehicle: vehicle.value!.id,
      start_date: form.value.start_date,
      end_date: form.value.end_date,
      driver_included: form.value.driver_included,
      renter_name: form.value.renter_name,
      renter_phone: form.value.renter_phone
    })
    
    Swal.fire({
      title: 'Success!',
      text: 'Booking berhasil diproses!',
      icon: 'success',
      confirmButtonText: 'Lihat E-Receipt'
    }).then(() => {
      receiptId.value = res.data.rental_number || 'RNT-' + Date.now().toString(36).toUpperCase()
      showReceipt.value = true
      nextTick(() => {
        JsBarcode("#receipt-barcode", receiptId.value, {
          format: "CODE128",
          displayValue: true,
          fontSize: 14,
          height: 50,
          margin: 0,
          lineColor: "#0f172a"
        })
      })
    })
  } catch (error: any) {
    console.error(error)
    Swal.fire({ title: 'Error', text: 'Gagal melakukan booking.', icon: 'error' })
  }
}

function downloadReceipt() {
  const element = document.getElementById('receipt-content')
  if (!element || !vehicle.value) return
  
  const opt = {
    margin: [10, 10, 10, 10],
    filename: `LoVista-Rental-${vehicle.value.id}-${Date.now()}.pdf`,
    image: { type: 'jpeg', quality: 0.98 },
    html2canvas: { scale: 2, useCORS: true },
    jsPDF: { unit: 'mm', format: 'a4', orientation: 'portrait' }
  }
  
  html2pdf().set(opt).from(element).save().then(() => {
    Swal.fire({ title: 'Success', text: 'E-Receipt saved successfully!', icon: 'success' })
    showReceipt.value = false
  })
}

onMounted(async () => {
  loading.value = true
  try {
    const id = Number(route.params.id)
    const res = await vehicleApi.detail(id)
    vehicle.value = res.data

    // Fetch agency details separately using the Travel Agency API
    if (vehicle.value && (vehicle.value as any).agency) {
      const agencyId = (vehicle.value as any).agency
      const agencyRes = await agencyApi.detail(agencyId)
      agency.value = agencyRes.data
    }
  } catch (error) {
    console.error('Error fetching vehicle details:', error)
  } finally {
    loading.value = false
  }
})
</script>

<style scoped>
.vehicle-detail-view {
  min-height: 100vh;
  background-color: var(--black);
  padding-top: 100px;
}

.btn-back {
  display: inline-block;
  color: var(--w70);
  font-size: 0.9rem;
  margin-bottom: 24px;
  transition: color 0.3s;
}
.btn-back:hover {
  color: var(--white);
}

.vehicle-hero {
  padding-bottom: 40px;
  border-bottom: 1px solid var(--w08);
}

.vehicle-hero__grid {
  display: grid;
  grid-template-columns: 1.5fr 1fr;
  gap: 60px;
  align-items: center;
}

.vehicle-gallery {
  width: 100%;
  border-radius: 16px;
  overflow: hidden;
  border: 1px solid var(--w08);
}

.main-image {
  width: 100%;
  aspect-ratio: 16 / 9;
  object-fit: cover;
  display: block;
}

.badges {
  display: flex;
  gap: 10px;
  margin-bottom: 16px;
}

.badge {
  padding: 6px 14px;
  border-radius: 99px;
  font-size: 0.75rem;
  font-weight: bold;
}
.badge-primary { background: var(--blue); color: white; }
.badge-dark { background: var(--dark1); color: var(--w80); border: 1px solid var(--w12); }

.vehicle-summary h1 {
  font-size: 3rem;
  margin-bottom: 8px;
  color: var(--white);
}

.plate-number {
  font-size: 1.1rem;
  color: var(--w60);
  font-family: monospace;
  background: var(--dark1);
  padding: 4px 12px;
  border-radius: 4px;
  display: inline-block;
  margin-bottom: 32px;
}

.key-features {
  display: flex;
  gap: 24px;
  margin-bottom: 40px;
}

.feature-item {
  display: flex;
  align-items: center;
  gap: 8px;
  color: var(--w80);
}

.price-section {
  background: rgba(255, 255, 255, 0.03);
  padding: 24px;
  border-radius: 12px;
  border: 1px solid var(--w08);
}

.daily-rate .amount {
  font-size: 2.5rem;
  font-weight: 700;
  color: var(--white);
}
.daily-rate .unit {
  font-size: 1rem;
  color: var(--w60);
}

.driver-rate {
  color: var(--blue);
  font-size: 0.9rem;
  margin-top: 8px;
}

.section { padding: 60px 0; }

.vehicle-content-layout {
  display: grid;
  grid-template-columns: 2fr 1fr;
  gap: 60px;
}

.vehicle-main-info h2 {
  font-size: 1.8rem;
  margin-bottom: 24px;
  color: var(--white);
  border-bottom: 1px solid var(--w08);
  padding-bottom: 12px;
}

.features-list {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 16px;
}

.feature-bullet {
  color: var(--w80);
  background: var(--dark1);
  padding: 12px 16px;
  border-radius: 8px;
}

.agency-card {
  background: var(--dark1);
  padding: 24px;
  border-radius: 12px;
  border: 1px solid var(--w08);
}

.agency-header {
  display: flex;
  align-items: center;
  gap: 16px;
  margin-bottom: 16px;
}

.agency-avatar {
  width: 50px;
  height: 50px;
  background: var(--w08);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.5rem;
}

.agency-contact p {
  color: var(--w80);
  margin-bottom: 8px;
}

.vehicle-sidebar {
  position: sticky;
  top: 100px;
}

.booking-widget {
  background: var(--dark1);
  padding: 24px;
  border-radius: 16px;
  border: 1px solid var(--blue);
}

.booking-widget h3 {
  font-size: 1.5rem;
  margin-bottom: 24px;
  color: var(--white);
}

.form-group {
  margin-bottom: 16px;
}

.form-group label {
  display: block;
  margin-bottom: 8px;
  color: var(--w80);
  font-size: 0.9rem;
}

.form-group input[type="text"],
.form-group input[type="date"],
.form-group input[type="tel"] {
  width: 100%;
  padding: 12px;
  background: var(--dark2);
  border: 1px solid var(--w12);
  border-radius: 8px;
  color: var(--white);
  color-scheme: dark;
}

.checkbox-group label {
  display: flex;
  align-items: center;
  gap: 12px;
  cursor: pointer;
  background: var(--dark2);
  padding: 16px;
  border-radius: 8px;
  border: 1px solid var(--w12);
  transition: border-color 0.3s;
}

.checkbox-group label:hover {
  border-color: var(--w40);
}

.checkbox-group input[type="checkbox"] {
  width: 20px;
  height: 20px;
  accent-color: var(--blue);
  cursor: pointer;
}

.price-calculator {
  background: var(--dark2);
  padding: 16px;
  border-radius: 8px;
}

.calc-row {
  display: flex;
  justify-content: space-between;
  margin-bottom: 8px;
  font-size: 0.9rem;
  color: var(--w80);
}

.calc-row.total {
  font-size: 1.1rem;
  font-weight: 700;
  color: var(--white);
  margin-bottom: 0;
}

.validation-error {
  color: #ff4757;
  font-size: 0.85rem;
  margin-top: 12px;
}

.full-width { width: 100%; }
.mt-4 { margin-top: 24px; }
.mt-5 { margin-top: 40px; }
.text-blue { color: var(--blue); }
.text-red { color: #ff4757; }
.text-w40 { color: var(--w40); }
.text-w60 { color: var(--w60); }
.divider { height: 1px; background: var(--w08); margin: 16px 0; }

@media (max-width: 900px) {
  .vehicle-hero__grid { grid-template-columns: 1fr; gap: 40px; }
  .vehicle-content-layout { grid-template-columns: 1fr; gap: 40px; }
  .vehicle-summary h1 { font-size: 2.5rem; }
}
.receipt-modal-overlay {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.85);
  backdrop-filter: blur(4px);
  z-index: 9999;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 20px;
}
</style>
