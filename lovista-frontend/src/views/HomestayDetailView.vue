<template>
  <div class="homestay-detail">
    <!-- Loading State -->
    <div v-if="loading" class="page-loader">
      <div class="spinner"></div>
      <p>Fetching homestay details...</p>
    </div>

    <!-- Content -->
    <template v-else-if="homestay">
      <header class="pkg-hero">
        <div class="pkg-hero__bg" :style="{ backgroundImage: `url(${getPhotoUrl(homestay.main_image)})` }"></div>
        <div class="pkg-hero__overlay"></div>
        <div class="container pkg-hero__content">
          <div class="pkg-hero__breadcrumb">
            <RouterLink to="/">Home</RouterLink> / 
            <RouterLink to="/homestays">Homestays</RouterLink> / 
            <span>{{ homestay.name }}</span>
          </div>
          <div class="pkg-hero__badges">
            <span class="badge badge-blue">Homestay</span>
            <span class="badge badge-gray" v-if="homestay.district">{{ homestay.district }}</span>
          </div>
          <h1 class="pkg-hero__title italic-bold">{{ homestay.name }}</h1>
          <div class="pkg-hero__meta">
            <span>By <strong>{{ homestay.owner_name || 'Owner' }}</strong></span>
            <span class="dot"></span>
            <span>📍 {{ homestay.address || 'Lombok Barat' }}</span>
          </div>
        </div>
      </header>

      <div class="container pkg-body">
        <div class="pkg-layout">
          <!-- Main Content -->
          <div class="pkg-main">
            <!-- Description -->
            <section class="pkg-section">
              <h2 class="pkg-section-title">Overview</h2>
              <p class="pkg-description">{{ homestay.description || 'No description available for this homestay.' }}</p>
            </section>

            <!-- Amenities -->
            <section class="pkg-section grid-2" v-if="homestay.amenities && Array.isArray(homestay.amenities) && homestay.amenities.length > 0">
              <div class="inclusion-box card p-6" style="grid-column: span 2;">
                <h3 class="pkg-section-title-sm">Amenities</h3>
                <ul class="check-list">
                  <li v-for="(am, idx) in homestay.amenities" :key="idx">
                    <span class="icon-check">✓</span> {{ am }}
                  </li>
                </ul>
              </div>
            </section>

            <!-- Rooms Selection -->
            <section class="pkg-section">
              <h2 class="pkg-section-title">Available Rooms</h2>
              <div class="rooms-list" v-if="homestay.rooms && homestay.rooms.length > 0">
                <div 
                  v-for="room in homestay.rooms" 
                  :key="room.id" 
                  class="room-card"
                  :class="{ 'selected': selectedRoom?.id === room.id }"
                  @click="selectRoom(room)"
                >
                  <div class="room-card__img" v-if="room.image" :style="{ backgroundImage: `url(${getPhotoUrl(room.image)})` }"></div>
                  <div class="room-card__img" v-else style="background-color: var(--dark3); display: flex; align-items: center; justify-content: center; font-size: 2rem; color: var(--w40);">🛏️</div>
                  
                  <div class="room-card__content">
                    <h3>{{ room.room_type || room.room_number }}</h3>
                    <div class="room-meta">
                      <span class="badge badge-gray">Capacity: {{ room.capacity }} Person(s)</span>
                    </div>
                    <div class="room-facilities" v-if="room.facilities && Array.isArray(room.facilities)">
                      <span v-for="(fac, fIdx) in room.facilities" :key="fIdx" class="facility-pill">{{ fac }}</span>
                    </div>
                    <div class="room-price font-display">
                      Rp {{ formatNumber(room.price_per_night) }}<span class="text-sm text-muted">/night</span>
                    </div>
                  </div>
                  <div class="room-card__select">
                    <div class="radio-circle">
                      <div class="inner" v-if="selectedRoom?.id === room.id"></div>
                    </div>
                  </div>
                </div>
              </div>
              <div v-else class="empty-state card p-6 text-center">
                <p>No rooms available at the moment.</p>
              </div>
            </section>

            <!-- Policies -->
            <section class="pkg-section" v-if="homestay.policies">
              <h2 class="pkg-section-title">Policies</h2>
              <div class="terms-content">
                {{ homestay.policies }}
              </div>
              <div class="mt-4" style="display: flex; gap: 32px; font-weight: bold; color: var(--w70)">
                <div>Check-in: {{ homestay.check_in_time }}</div>
                <div>Check-out: {{ homestay.check_out_time }}</div>
              </div>
            </section>
          </div>

          <!-- Sidebar: Booking -->
          <aside class="pkg-sidebar">
            <div class="pkg-sidebar-sticky">
              <div class="booking-card card shadow-lg">
                <div class="booking-card__header">
                  <div class="booking-card__price">
                    <span class="label">Total Price</span>
                    <div class="price-wrapper">
                      <span class="value font-display">Rp {{ formatNumber(bookingTotal) }}</span>
                    </div>
                  </div>
                </div>
                <div class="booking-card__body">
                  <div class="form-group" v-if="!selectedRoom">
                    <div class="alert text-sm" style="background: rgba(245, 158, 11, 0.1); color: var(--warning); padding: 12px; border-radius: 8px; border: 1px solid rgba(245, 158, 11, 0.2);">
                      Please select a room first
                    </div>
                  </div>

                  <div class="form-group">
                    <label class="form-label">Check-in Date</label>
                    <input type="date" v-model="form.check_in" class="form-input" :min="today" />
                  </div>
                  
                  <div class="form-group">
                    <label class="form-label">Check-out Date</label>
                    <input type="date" v-model="form.check_out" class="form-input" :min="checkoutMin" />
                  </div>

                  <div class="form-group">
                    <label class="form-label">Number of Guests</label>
                    <div class="number-input">
                      <button type="button" @click="form.guest_count > 1 && form.guest_count--" :disabled="form.guest_count <= 1">-</button>
                      <input type="number" v-model="form.guest_count" readonly />
                      <button type="button" @click="selectedRoom && form.guest_count < selectedRoom.capacity && form.guest_count++" :disabled="!selectedRoom || form.guest_count >= selectedRoom.capacity">+</button>
                    </div>
                    <small class="text-muted" v-if="selectedRoom">Max capacity: {{ selectedRoom.capacity }}</small>
                  </div>

                  <div class="form-group">
                    <label class="form-label">Guest Name</label>
                    <input type="text" v-model="form.guest_name" class="form-input" placeholder="Primary guest name" />
                  </div>
                  
                  <div class="form-group">
                    <label class="form-label">Phone Number</label>
                    <input type="tel" v-model="form.guest_phone" class="form-input" placeholder="e.g. 08123456789" />
                  </div>

                  <div class="booking-summary" v-if="selectedRoom && form.check_in && form.check_out">
                    <div class="summary-row">
                      <span>{{ selectedRoom.room_type || selectedRoom.room_number }}</span>
                      <span>Rp {{ formatNumber(selectedRoom.price_per_night) }}</span>
                    </div>
                    <div class="summary-row">
                      <span>Nights</span>
                      <span>{{ totalNights }}</span>
                    </div>
                    <div class="divider"></div>
                    <div class="summary-row total">
                      <strong>Total Amount</strong>
                      <strong class="text-blue">Rp {{ formatNumber(bookingTotal) }}</strong>
                    </div>
                  </div>

                  <button 
                    class="btn btn-primary btn-block btn-lg w-full" 
                    @click="handleBooking"
                    :disabled="isBooking || !selectedRoom || !form.check_in || !form.check_out || !form.guest_name"
                  >
                    <span v-if="isBooking">Processing...</span>
                    <span v-else>Book Homestay</span>
                  </button>
                </div>
              </div>
            </div>
          </aside>
        </div>
      </div>
    </template>

    <div v-else class="page-error container">
      <div class="empty-state">
        <div class="icon">🏠</div>
        <h3>Homestay Not Found</h3>
        <p>The homestay you are looking for might have been removed or is no longer active.</p>
        <RouterLink to="/homestays" class="btn btn-primary mt-4">Browse Other Homestays</RouterLink>
      </div>
    </div>
    
    <!-- E-Receipt Modal -->
    <div class="receipt-modal-overlay" v-if="showReceipt" @click="showReceipt = false">
      <div class="receipt-container card" @click.stop id="receipt-content" style="background:#fff;color:#000;padding:32px;width:100%;max-width:500px;border-radius:12px;position:relative">
        <div style="text-align:center;border-bottom:2px dashed #ccc;padding-bottom:16px;margin-bottom:16px">
          <h2 style="font-family:'Bebas Neue',sans-serif;font-size:2.5rem;color:#2563eb;margin:0">LOVISTA</h2>
          <p style="margin:4px 0 0;font-size:0.9rem;color:#666">E-Receipt - Homestay Booking</p>
        </div>
        
        <div style="margin-bottom:24px" v-if="homestay">
          <div style="font-weight:bold;font-size:1.2rem;margin-bottom:4px">{{ homestay.name }}</div>
          <div style="font-size:0.9rem;color:#444">{{ homestay.address || homestay.district }}</div>
        </div>

        <table style="width:100%;font-size:0.95rem;margin-bottom:24px;border-collapse:collapse">
          <tr style="border-bottom:1px solid #eee">
            <td style="padding:8px 0;color:#666">Guest Name</td>
            <td style="padding:8px 0;text-align:right;font-weight:bold">{{ form.guest_name }}</td>
          </tr>
          <tr style="border-bottom:1px solid #eee">
            <td style="padding:8px 0;color:#666">Room</td>
            <td style="padding:8px 0;text-align:right;font-weight:bold">{{ selectedRoom?.room_type || selectedRoom?.room_number }}</td>
          </tr>
          <tr style="border-bottom:1px solid #eee">
            <td style="padding:8px 0;color:#666">Check-in</td>
            <td style="padding:8px 0;text-align:right;font-weight:bold">{{ form.check_in }}</td>
          </tr>
          <tr style="border-bottom:1px solid #eee">
            <td style="padding:8px 0;color:#666">Check-out</td>
            <td style="padding:8px 0;text-align:right;font-weight:bold">{{ form.check_out }}</td>
          </tr>
          <tr style="border-bottom:1px solid #eee">
            <td style="padding:8px 0;color:#666">Nights</td>
            <td style="padding:8px 0;text-align:right;font-weight:bold">{{ totalNights }}</td>
          </tr>
        </table>

        <div style="background:#f8fafc;padding:16px;border-radius:8px" v-if="selectedRoom">
          <div style="display:flex;justify-content:space-between;margin-bottom:8px">
            <span style="color:#666">Price per night</span>
            <span>Rp {{ formatNumber(selectedRoom.price_per_night) }}</span>
          </div>
          <div style="display:flex;justify-content:space-between;border-top:1px solid #cbd5e1;padding-top:12px;font-weight:bold;font-size:1.2rem;color:#0f172a">
            <span>Total Paid</span>
            <span>Rp {{ formatNumber(bookingTotal) }}</span>
          </div>
        </div>
        
        <div style="margin-top:24px;text-align:center">
          <svg id="receipt-barcode"></svg>
        </div>

        <div style="margin-top:16px;text-align:center;font-size:0.8rem;color:#94a3b8">
          This is an automatically generated receipt.<br>Please present this barcode to the homestay owner.
        </div>
        
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
import { ref, computed, onMounted, nextTick } from 'vue'
import { useRoute, useRouter, RouterLink } from 'vue-router'
import { homestayApi, bookingApi } from '@/api'
import { useAuthStore } from '@/stores/auth'
import html2pdf from 'html2pdf.js'
import JsBarcode from 'jsbarcode'

const route = useRoute()
const router = useRouter()
const auth = useAuthStore()

const loading = ref(true)
const homestay = ref<any>(null)
const selectedRoom = ref<any>(null)
const isBooking = ref(false)
const showReceipt = ref(false)

const today = new Date().toISOString().split('T')[0]

const form = ref({
  check_in: today,
  check_out: '',
  guest_count: 1,
  guest_name: '',
  guest_phone: '',
  guest_email: ''
})

const checkoutMin = computed(() => {
  if (!form.value.check_in) return today
  const minDate = new Date(form.value.check_in)
  minDate.setDate(minDate.getDate() + 1)
  return minDate.toISOString().split('T')[0]
})

const totalNights = computed(() => {
  if (!form.value.check_in || !form.value.check_out) return 0
  const start = new Date(form.value.check_in).getTime()
  const end = new Date(form.value.check_out).getTime()
  const diffTime = Math.abs(end - start)
  const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24))
  return diffDays > 0 ? diffDays : 0
})

const bookingTotal = computed(() => {
  if (!selectedRoom.value) return 0
  return Number(selectedRoom.value.price_per_night) * totalNights.value
})

const formatNumber = (num: number | string) => {
  return new Intl.NumberFormat('id-ID').format(Number(num))
}

const getPhotoUrl = (path?: string | null) => {
  if (!path) return '/Logo.png'
  if (path.startsWith('http')) return path
  return `http://127.0.0.1:8000${path}`
}

const selectRoom = (room: any) => {
  selectedRoom.value = room
  if (form.value.guest_count > room.capacity) {
    form.value.guest_count = room.capacity
  }
}

const fetchData = async () => {
  const id = Number(route.params.id)
  if (!id) return
  
  loading.value = true
  try {
    const { data } = await homestayApi.detail(id)
    homestay.value = data
    if (auth.user) {
      form.value.guest_name = auth.user.fullname || ''
      form.value.guest_phone = auth.user.phone || ''
      form.value.guest_email = auth.user.email || ''
    }
  } catch (error) {
    console.error('Failed to fetch homestay', error)
  } finally {
    loading.value = false
  }
}

const handleBooking = async () => {
  if (!auth.isAuthenticated) {
    Swal.fire({
      icon: 'info',
      title: 'Login Required',
      text: 'Please login to book a homestay.',
      showCancelButton: true,
      confirmButtonText: 'Go to Login',
      cancelButtonText: 'Cancel'
    }).then((res) => {
      if (res.isConfirmed) router.push('/login')
    })
    return
  }

  if (!selectedRoom.value) return
  if (!form.value.check_in || !form.value.check_out || !form.value.guest_name) {
    Swal.fire('Incomplete Data', 'Please fill in all booking details.', 'warning')
    return
  }

  isBooking.value = true
  try {
    const res = await bookingApi.homestayCreate({
      room: selectedRoom.value.id,
      check_in: form.value.check_in,
      check_out: form.value.check_out,
      guest_count: form.value.guest_count,
      guest_name: form.value.guest_name,
      guest_phone: form.value.guest_phone,
      guest_email: form.value.guest_email
    })
    
    Swal.fire({
      title: 'Success!',
      text: 'Booking berhasil diproses!',
      icon: 'success',
      confirmButtonText: 'Lihat E-Receipt'
    }).then(() => {
      showReceipt.value = true
      nextTick(() => {
        const receiptId = res.data?.booking_number || "HSB" + Date.now().toString().slice(-8)
        JsBarcode("#receipt-barcode", receiptId, {
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
    Swal.fire('Booking Failed', error.response?.data?.detail || 'Something went wrong', 'error')
  } finally {
    isBooking.value = false
  }
}

const downloadReceipt = () => {
  const element = document.getElementById('receipt-content')
  if (!element) return
  const opt = {
    margin: 10,
    filename: `Homestay_Receipt_${Date.now()}.pdf`,
    image: { type: 'jpeg', quality: 0.98 },
    html2canvas: { scale: 2 },
    jsPDF: { unit: 'mm', format: 'a4', orientation: 'portrait' }
  }
  html2pdf().set(opt).from(element).save()
}

onMounted(() => {
  fetchData()
})
</script>

<style scoped>
.homestay-detail { min-height: 100vh; background: var(--black); color: var(--white); }

.pkg-hero { height: 60vh; min-height: 500px; position: relative; display: flex; align-items: flex-end; padding-bottom: 80px; margin-top: 60px; }
.pkg-hero__bg { position: absolute; inset: 0; background-size: cover; background-position: center; z-index: 1; }
.pkg-hero__overlay { position: absolute; inset: 0; background: linear-gradient(to bottom, transparent 0%, rgba(5,6,8,0.95) 100%); z-index: 2; }
.pkg-hero__content { position: relative; z-index: 3; }
.pkg-hero__breadcrumb { font-size: 0.8rem; color: var(--w40); margin-bottom: 20px; }
.pkg-hero__breadcrumb a { color: var(--w40); transition: color 0.2s; text-decoration: none; }
.pkg-hero__breadcrumb a:hover { color: var(--blue); }
.pkg-hero__badges { display: flex; gap: 10px; margin-bottom: 20px; }
.pkg-hero__title { font-size: 4rem; line-height: 1; margin-bottom: 16px; font-family: 'Barlow Condensed', sans-serif; text-transform: uppercase; }
.pkg-hero__meta { color: var(--w70); font-size: 1rem; display: flex; align-items: center; gap: 16px; }
.dot { width: 4px; height: 4px; background: var(--w20); border-radius: 50%; }

.pkg-body { padding: 80px 0; }
.pkg-layout { display: grid; grid-template-columns: 1fr 400px; gap: 80px; align-items: start; }
@media (max-width: 991px) { .pkg-layout { grid-template-columns: 1fr; gap: 40px; } }

.pkg-section { margin-bottom: 60px; }
.pkg-section-title { font-family: 'Barlow Condensed', sans-serif; font-size: 2.2rem; font-weight: 800; margin-bottom: 32px; font-style: italic; border-left: 5px solid var(--blue); padding-left: 20px; text-transform: uppercase; color: var(--white); }
.pkg-section-title-sm { font-size: 1.2rem; font-weight: 700; margin-bottom: 20px; color: var(--white); }
.pkg-description { color: var(--w70); line-height: 1.8; font-size: 1.1rem; white-space: pre-line; }

/* Grid utilities */
.grid-2 { display: grid; grid-template-columns: repeat(2, 1fr); gap: 24px; }
@media (max-width: 768px) { .grid-2 { grid-template-columns: 1fr; } }

/* Inclusion List */
.check-list { list-style: none; padding: 0; margin: 0; }
.check-list li { display: flex; gap: 14px; margin-bottom: 16px; color: var(--w70); font-size: 1rem; align-items: flex-start; }
.icon-check { color: var(--success); font-weight: bold; margin-top: 2px; }

/* Terms */
.terms-content { color: var(--w60); font-size: 0.95rem; line-height: 1.8; white-space: pre-line; background: var(--dark1); padding: 24px; border-radius: var(--radius-md); border-left: 4px solid var(--w15); }

/* Room Cards */
.rooms-list { display: flex; flex-direction: column; gap: 20px; }
.room-card { display: flex; background: var(--dark2); border: 1px solid var(--w08); border-radius: var(--radius-lg); overflow: hidden; cursor: pointer; transition: all 0.2s ease; }
.room-card:hover { border-color: var(--blue); box-shadow: 0 4px 15px rgba(26,143,255,0.15); }
.room-card.selected { border-color: var(--blue); background: var(--dark3); box-shadow: 0 0 0 1px var(--blue); }
.room-card__img { width: 220px; background-size: cover; background-position: center; flex-shrink: 0; }
.room-card__content { padding: 24px; flex-grow: 1; }
.room-card__content h3 { margin-bottom: 8px; color: var(--white); font-size: 1.4rem; }
.room-meta { margin-bottom: 12px; }
.room-facilities { display: flex; flex-wrap: wrap; gap: 8px; margin-bottom: 16px; }
.facility-pill { font-size: 0.8rem; padding: 4px 12px; background: var(--w08); color: var(--w70); border-radius: 100px; }
.room-price { font-size: 1.6rem; color: var(--blue-b); font-weight: bold; }
.room-card__select { width: 80px; display: flex; align-items: center; justify-content: center; border-left: 1px solid var(--w08); }
.radio-circle { width: 24px; height: 24px; border: 2px solid var(--w30); border-radius: 50%; display: flex; align-items: center; justify-content: center; }
.room-card.selected .radio-circle { border-color: var(--blue); }
.radio-circle .inner { width: 12px; height: 12px; background: var(--blue); border-radius: 50%; }

@media (max-width: 600px) {
  .room-card { flex-direction: column; }
  .room-card__img { width: 100%; height: 200px; }
  .room-card__select { width: 100%; height: 60px; border-left: none; border-top: 1px solid var(--w08); }
}

/* Booking Card */
.pkg-sidebar-sticky { position: sticky; top: 120px; }
.booking-card { background: var(--dark2); border: 1px solid var(--w08); border-radius: var(--radius-xl); overflow: hidden; }
.booking-card__header { padding: 32px; background: var(--blue); color: #fff; }
.booking-card__price .label { display: block; font-size: 0.85rem; font-weight: 600; opacity: 0.8; margin-bottom: 8px; text-transform: uppercase; letter-spacing: 1px; }
.price-wrapper { display: flex; align-items: baseline; gap: 12px; flex-wrap: wrap; }
.booking-card__price .value { font-size: 2.8rem; display: block; line-height: 1; }
.booking-card__body { padding: 32px; }

.number-input { display: flex; align-items: center; background: var(--dark3); border-radius: var(--radius-md); overflow: hidden; margin-bottom: 10px; border: 1.5px solid var(--w08); }
.number-input button { width: 50px; height: 50px; border: none; background: transparent; color: #fff; cursor: pointer; transition: all 0.2s; font-size: 1.2rem; }
.number-input button:hover:not(:disabled) { background: var(--w08); color: var(--blue); }
.number-input button:disabled { opacity: 0.3; cursor: not-allowed; }
.number-input input { flex: 1; text-align: center; background: transparent; border: none; color: #fff; font-weight: 800; font-size: 1.1rem; -moz-appearance: textfield; }
.number-input input::-webkit-outer-spin-button, .number-input input::-webkit-inner-spin-button { -webkit-appearance: none; margin: 0; }

.booking-summary { background: var(--dark3); padding: 20px; border-radius: var(--radius-lg); margin: 24px 0; border: 1px solid var(--w04); }
.summary-row { display: flex; justify-content: space-between; font-size: 0.95rem; color: var(--w60); margin-bottom: 12px; }
.summary-row:last-child { margin-bottom: 0; }
.summary-row.total { color: var(--white); font-size: 1.1rem; margin-top: 12px; }
.text-blue { color: var(--blue-b); }

.receipt-modal-overlay { position: fixed; inset: 0; background: rgba(0,0,0,0.8); z-index: 9999; display: flex; align-items: center; justify-content: center; padding: 1rem; }
.receipt-container { background: #fff; color: #000; padding: 32px; width: 100%; max-width: 500px; border-radius: 12px; position: relative; }

.w-full { width: 100%; }
.p-6 { padding: 24px; }
.mt-4 { margin-top: 16px; }
.text-sm { font-size: 0.875rem; }
.text-muted { color: var(--w40); }
</style>
