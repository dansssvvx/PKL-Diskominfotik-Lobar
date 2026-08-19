<template>
  <div class="detail-page">

    <div v-if="destStore.loading" class="page-loader" style="min-height:100vh">
      <div class="spinner"></div> Loading...
    </div>

    <template v-else-if="dest">
      <!-- Hero image -->
      <div class="detail__hero">
        <div class="detail__hero-bg"
          :style="{ backgroundImage: dest.main_image ? `url(${dest.main_image})` : 'none' }">
        </div>
        <div class="detail__hero-overlay"></div>
        <div class="detail__hero-content container">
          <div class="detail__breadcrumb">
            <RouterLink to="/">Home</RouterLink> /
            <RouterLink to="/destinations">Destinations</RouterLink> /
            <span>{{ dest.name }}</span>
          </div>
          <span class="badge badge-blue">{{ dest.category?.name }}</span>
          <h1 class="detail__title">{{ dest.name }}</h1>
          <div class="detail__location">📍 {{ dest.district }}, Lombok Barat</div>
          <div class="detail__rating" v-if="dest.avg_rating">
            <span v-for="s in 5" :key="s" :style="{ color: s <= (dest.avg_rating ?? 0) ? '#f59e0b' : 'rgba(255,255,255,0.3)' }">★</span>
            <strong>{{ dest.avg_rating?.toFixed(1) }}</strong>
            <span class="text-muted">({{ dest.review_count }} reviews)</span>
          </div>
          <div class="detail__actions">
            <button class="btn btn-primary btn-lg" @click="scrollTo('book')">
              🎫 Book Now
            </button>
            <button class="btn btn-ghost btn-lg" @click="toggleWishlist">
              {{ isWishlisted ? '❤️ Wishlisted' : '🤍 Add to Wishlist' }}
            </button>
          </div>
        </div>
      </div>

      <div class="container detail__body">
        <div class="detail__layout">
          <!-- LEFT: main content -->
          <div class="detail__main">
            <!-- Quick info cards -->
            <div class="detail__info-grid">
              <div class="info-card">
                <div class="info-card__icon">🎫</div>
                <div class="info-card__label">Ticket Price</div>
                <div class="info-card__value">Rp {{ formatPrice(dest.ticket_price) }}</div>
              </div>
              <div class="info-card">
                <div class="info-card__icon">🅿️</div>
                <div class="info-card__label">Parking Fee</div>
                <div class="info-card__value">Rp {{ formatPrice(dest.parking_fee) }}</div>
              </div>
              <div class="info-card">
                <div class="info-card__icon">🕐</div>
                <div class="info-card__label">Opening Hours</div>
                <div class="info-card__value">{{ dest.opening_hours || 'All day' }}</div>
              </div>
              <div class="info-card">
                <div class="info-card__icon">👁️</div>
                <div class="info-card__label">Views</div>
                <div class="info-card__value">{{ dest.views_count.toLocaleString() }}</div>
              </div>
            </div>

            <!-- Description -->
            <div class="detail__section">
              <h2 class="detail__section-title">About This Place</h2>
              <p class="detail__desc">{{ dest.description }}</p>
            </div>

            <!-- Local Culinary Section -->
            <div class="detail__section" v-if="dest.culinaries?.length">
              <h2 class="detail__section-title">Local Culinary</h2>
              <div class="culinary__grid">
                <div class="culinary-card" v-for="c in dest.culinaries" :key="c.id">
                  <div class="culinary-card__img" :style="{ backgroundImage: `url(${getPhotoUrl(c.image)})` }"></div>
                  <div class="culinary-card__content">
                    <h3>{{ c.name }}</h3>
                    <p class="culinary-card__desc">{{ c.description }}</p>
                    <div class="culinary-card__meta">
                      <span class="price-range">💰 {{ c.price_range }}</span>
                      <span class="contact" v-if="c.contact">📞 {{ c.contact }}</span>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            <!-- Location -->
            <div class="detail__section">
              <h2 class="detail__section-title">Location</h2>
              <div class="detail__location-box">
                <div>📍 {{ dest.address }}</div>
                <div v-if="dest.latitude" class="detail__coords">
                  <span>Lat: {{ dest.latitude }}</span>
                  <span>Lng: {{ dest.longitude }}</span>
                </div>
              </div>
              <div class="map-placeholder" id="map-container">
                🗺️ Loading Interactive Map...
              </div>
            </div>

            <!-- Facilities -->
            <div class="detail__section" v-if="dest.facilities?.length">
              <h2 class="detail__section-title">Facilities</h2>
              <div class="facilities__grid">
                <div
                  class="facility-item"
                  v-for="f in dest.facilities" :key="f.id"
                  :class="{ 'facility-item--unavailable': !f.is_available }"
                >
                  <span>{{ f.facility?.icon || '✅' }}</span>
                  <span>{{ f.facility?.name }}</span>
                </div>
              </div>
            </div>

            <!-- Photo Gallery -->
            <div class="detail__section" v-if="dest.images?.length">
              <h2 class="detail__section-title">Gallery</h2>
              <div class="gallery__grid">
                <div
                  class="gallery-item"
                  v-for="img in dest.images" :key="img.id"
                  :style="{ backgroundImage: `url(${img.image_url})` }"
                ></div>
              </div>
            </div>

            <!-- Reviews -->
            <div class="detail__section" id="reviews">
              <div class="detail__section-header">
                <h2 class="detail__section-title">Reviews</h2>
                <button class="btn btn-primary btn-sm" @click="writeReview = !writeReview" v-if="auth.isLoggedIn">
                  ✏️ Write Review
                </button>
              </div>

              <!-- Review form -->
              <Transition name="slide-up">
                <div class="review-form card" v-if="writeReview">
                  <h3 style="margin-bottom:16px;font-size:1rem">Your Review</h3>
                  <div class="rating-select">
                    <span
                      v-for="s in 5" :key="s"
                      class="rating-star"
                      :class="{ active: s <= reviewForm.rating }"
                      @click="reviewForm.rating = s"
                    >★</span>
                  </div>
                  <div class="form-group" style="margin-top:12px">
                    <textarea
                      class="form-input" rows="3"
                      v-model="reviewForm.comment"
                      placeholder="Share your experience..."
                      style="resize:vertical"
                    ></textarea>
                  </div>
                  <div style="display:flex;gap:8px">
                    <button class="btn btn-primary btn-sm" @click="submitReview">Submit</button>
                    <button class="btn btn-ghost btn-sm" @click="writeReview = false">Cancel</button>
                  </div>
                </div>
              </Transition>

              <div v-if="dest.reviews?.length">
                <div class="review-card" v-for="r in dest.reviews" :key="r.id">
                  <div class="review-card__header">
                    <div v-if="r.user_details?.profile_photo" class="review-card__avatar-img" 
                         :style="{ backgroundImage: `url(${r.user_details.profile_photo})` }">
                    </div>
                    <div v-else class="review-card__avatar">
                      {{ r.user_details?.fullname?.charAt(0) || '?' }}
                    </div>
                    <div>
                      <div class="review-card__name">{{ r.user_details?.fullname || 'Anonymous' }}</div>
                      <div class="review-card__date">{{ formatDate(r.created_at) }} • {{ formatTime(r.created_at) }}</div>
                    </div>
                    <div class="review-card__stars">
                      <span v-for="s in r.rating" :key="s" style="color:#f59e0b">★</span>
                    </div>
                  </div>
                  <p class="review-card__text">{{ r.comment }}</p>
                </div>
              </div>
              <div class="empty-state" v-else>
                <div class="icon">⭐</div>
                <h3>No reviews yet</h3>
                <p>Be the first to review this destination!</p>
              </div>
            </div>
          </div>

          <!-- RIGHT: sidebar -->
          <div class="detail__sidebar" id="book">
            <!-- Booking card -->
            <div class="booking-card card">
              <div class="booking-card__header">
                <div class="booking-card__price">Rp {{ formatPrice(dest.ticket_price) }}</div>
                <div class="booking-card__price-sub">per person</div>
              </div>
              <div class="booking-card__body">
                <div class="form-group">
                  <label class="form-label">Visit Date</label>
                  <input type="date" class="form-input" v-model="bookingDate" :min="todayDate" />
                </div>
                <div class="form-group">
                  <label class="form-label">Visitors</label>
                  <input type="number" class="form-input" v-model="bookingPersons" min="1" placeholder="Number of people" />
                </div>
                <div class="form-group">
                  <label class="form-label">Vehicles</label>
                  <input type="number" class="form-input" v-model="bookingVehicles" min="0" placeholder="Number of vehicles" />
                </div>
                <div class="booking-card__summary" v-if="bookingTotal > 0">
                  <div class="booking-card__summary-row">
                    <span>Ticket × {{ bookingPersons }}</span>
                    <span>Rp {{ formatPrice(Number(dest.ticket_price) * Number(bookingPersons)) }}</span>
                  </div>
                  <div class="booking-card__summary-row" v-if="bookingVehicles > 0">
                    <span>Parking × {{ bookingVehicles }}</span>
                    <span>Rp {{ formatPrice(Number(dest.parking_fee) * bookingVehicles) }}</span>
                  </div>
                  <div class="divider"></div>
                  <div class="booking-card__summary-row booking-card__summary-total">
                    <strong>Total</strong>
                    <strong>Rp {{ formatPrice(bookingTotal) }}</strong>
                  </div>
                </div>
                <button class="btn btn-primary" style="width:100%" @click="handleBooking">
                  Confirm Booking
                </button>
                <button class="btn btn-ghost" style="width:100%;margin-top:8px" @click="toggleWishlist">
                  {{ isWishlisted ? '❤️ Remove Wishlist' : '🤍 Save to Wishlist' }}
                </button>
              </div>
            </div>

            <!-- Contact info -->
            <div class="contact-card card" v-if="dest.contact_phone || dest.contact_email">
              <div class="contact-card__title">Contact</div>
              <div v-if="dest.contact_phone" class="contact-card__item">📞 {{ dest.contact_phone }}</div>
              <div v-if="dest.contact_email" class="contact-card__item">✉️ {{ dest.contact_email }}</div>
              <div v-if="dest.website" class="contact-card__item">🌐 {{ dest.website }}</div>
            </div>
          </div>
        </div>
      </div>
    </template>

    <div class="page-loader" v-else>
      <div class="empty-state">
        <div class="icon">😕</div>
        <h3>Destination not found</h3>
        <RouterLink to="/destinations" class="btn btn-primary" style="margin-top:16px">Back to Destinations</RouterLink>
      </div>
    </div>
    <!-- E-Receipt Modal -->
    <div class="receipt-modal-overlay" v-if="showReceipt" @click="showReceipt = false">
      <div class="receipt-container" @click.stop id="receipt-content" style="background:#fff;color:#000;padding:32px;width:100%;max-width:500px;border-radius:12px;position:relative">
        <div style="text-align:center;border-bottom:2px dashed #ccc;padding-bottom:16px;margin-bottom:16px">
          <h2 style="font-family:'Bebas Neue',sans-serif;font-size:2.5rem;color:#2563eb;margin:0">LOVISTA</h2>
          <p style="margin:4px 0 0;font-size:0.9rem;color:#666">E-Receipt - Tourism Destination Booking</p>
        </div>
        
        <div style="margin-bottom:24px">
          <div style="font-weight:bold;font-size:1.2rem;margin-bottom:4px">{{ dest.name }}</div>
          <div style="font-size:0.9rem;color:#444">{{ dest.village }}, {{ dest.district }}</div>
        </div>

        <table style="width:100%;font-size:0.95rem;margin-bottom:24px;border-collapse:collapse">
          <tr style="border-bottom:1px solid #eee">
            <td style="padding:8px 0;color:#666">Visit Date</td>
            <td style="padding:8px 0;text-align:right;font-weight:bold">{{ formatDate(bookingDate) }}</td>
          </tr>
          <tr style="border-bottom:1px solid #eee">
            <td style="padding:8px 0;color:#666">Visitors</td>
            <td style="padding:8px 0;text-align:right;font-weight:bold">{{ bookingPersons }} Person(s)</td>
          </tr>
          <tr style="border-bottom:1px solid #eee">
            <td style="padding:8px 0;color:#666">Vehicles</td>
            <td style="padding:8px 0;text-align:right;font-weight:bold">{{ bookingVehicles }} Vehicle(s)</td>
          </tr>
        </table>

        <div style="background:#f8fafc;padding:16px;border-radius:8px">
          <div style="display:flex;justify-content:space-between;margin-bottom:8px">
            <span style="color:#666">Ticket (x{{ bookingPersons }})</span>
            <span>Rp {{ formatPrice(Number(dest.ticket_price) * Number(bookingPersons)) }}</span>
          </div>
          <div style="display:flex;justify-content:space-between;margin-bottom:12px" v-if="bookingVehicles > 0">
            <span style="color:#666">Parking (x{{ bookingVehicles }})</span>
            <span>Rp {{ formatPrice(Number(dest.parking_fee) * bookingVehicles) }}</span>
          </div>
          <div style="display:flex;justify-content:space-between;border-top:1px solid #cbd5e1;padding-top:12px;font-weight:bold;font-size:1.2rem;color:#0f172a">
            <span>Total Paid</span>
            <span>Rp {{ formatPrice(bookingTotal) }}</span>
          </div>
        </div>
        
        <div style="margin-top:24px;text-align:center">
          <svg id="receipt-barcode"></svg>
        </div>

        <div style="margin-top:16px;text-align:center;font-size:0.8rem;color:#94a3b8">
          This is an automatically generated receipt.<br>Please present this barcode upon arrival.
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
import { ref, computed, onMounted, nextTick, watch } from 'vue'
import { useRoute, useRouter, RouterLink } from 'vue-router'
import { useDestinationStore } from '@/stores/destination'
import { useAuthStore } from '@/stores/auth'
import { destinationApi } from '@/api'
import TheNavbar from '@/components/layout/TheNavbar.vue'
import L from 'leaflet'
import 'leaflet/dist/leaflet.css'
// @ts-ignore
import html2pdf from 'html2pdf.js'
// @ts-ignore
import JsBarcode from 'jsbarcode'

const route = useRoute()
const router = useRouter()
const destStore = useDestinationStore()
const auth = useAuthStore()

const dest = computed(() => destStore.current)
const isWishlisted = computed(() => dest.value ? destStore.isWishlisted(dest.value.id) : false)

const bookingDate = ref('')
const today = new Date()
const todayDate = `${today.getFullYear()}-${String(today.getMonth() + 1).padStart(2, '0')}-${String(today.getDate()).padStart(2, '0')}`
const bookingPersons = ref(1)
const bookingVehicles = ref(1)
const writeReview = ref(false)
const showReceipt = ref(false)
const receiptId = ref('')
const reviewForm = ref({ rating: 5, comment: '' })

let map: L.Map | null = null

const initMap = () => {
  if (!dest.value?.latitude || !dest.value?.longitude) return
  
  // Hapus map lama jika ada (untuk navigasi antar destinasi)
  if (map) {
    map.remove()
  }

  const lat = Number(dest.value.latitude)
  const lng = Number(dest.value.longitude)

  map = L.map('map-container').setView([lat, lng], 15)

  L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
    attribution: '&copy; OpenStreetMap contributors'
  }).addTo(map)

  // Custom icon karena Leaflet default sering bermasalah dengan path image di build tools
  const customIcon = L.icon({
    iconUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-icon.png',
    shadowUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-shadow.png',
    iconSize: [25, 41],
    iconAnchor: [12, 41]
  })

  L.marker([lat, lng], { icon: customIcon })
    .addTo(map)
    .bindPopup(dest.value.name)
    .openPopup()
}

// Watch perubahan data destinasi untuk update peta
watch(() => dest.value, (newVal) => {
  if (newVal) {
    nextTick(() => initMap())
  }
})

const bookingTotal = computed(() => {
  if (!dest.value || !bookingPersons.value) return 0
  const vehicles = bookingVehicles.value > 0 ? bookingVehicles.value : 0
  return (Number(dest.value.ticket_price) * Number(bookingPersons.value)) + (Number(dest.value.parking_fee) * vehicles)
})

function formatPrice(val: number) { return val.toLocaleString('id-ID') }
function formatDate(d: string) { return new Date(d).toLocaleDateString('id-ID', { year: 'numeric', month: 'long', day: 'numeric' }) }
function formatTime(d: string) { return new Date(d).toLocaleTimeString('id-ID', { hour: '2-digit', minute: '2-digit' }) }
function scrollTo(id: string) { document.getElementById(id)?.scrollIntoView({ behavior: 'smooth' }) }

const getPhotoUrl = (path?: string | null) => {
  if (!path) return '/Logo.png'
  if (path.startsWith('http')) return path
  return `http://127.0.0.1:8000${path}`
}

async function toggleWishlist() {
  if (!auth.isLoggedIn) { router.push('/login'); return }
  if (dest.value) await destStore.toggleWishlist(dest.value.slug)
}

async function submitReview() {
  if (!dest.value || !auth.isLoggedIn) return
  try {
    await destinationApi.addReview(dest.value.slug, reviewForm.value)
    writeReview.value = false
    reviewForm.value = { rating: 5, comment: '' }
    // Refresh data to show new review and update average rating
    await destStore.fetchDetail(route.params.slug as string)
    Swal.fire({ title: 'Notification', text: 'Review submitted successfully!', icon: 'info' })
  } catch (err: any) {
    console.error('Failed to submit review:', err.response?.data || err.message)
    const errorData = err.response?.data
    let msg = 'Failed to submit review'
    if (typeof errorData === 'string') msg = errorData
    else if (errorData?.detail) msg = errorData.detail
    else if (typeof errorData === 'object') {
      // Handle validation errors like { rating: ["..."], comment: ["..."] }
      msg = Object.values(errorData).flat().join('\n')
    }
    Swal.fire({ title: 'Notification', text: msg, icon: 'info' })
  }
}

function handleBooking() {
  if (!auth.isLoggedIn) { router.push('/login'); return }
  if (!bookingDate.value) { Swal.fire({ title: 'Notification', text: 'Please select a date', icon: 'info' }); return }
  
  if (bookingDate.value < todayDate) {
    Swal.fire({ title: 'Error', text: 'Tanggal booking tidak boleh di masa lalu!', icon: 'error' });
    return;
  }
  
  Swal.fire({
    title: 'Success!',
    text: 'Booking berhasil diproses!',
    icon: 'success',
    confirmButtonText: 'Lihat E-Receipt'
  }).then(() => {
    receiptId.value = 'LV-' + Date.now().toString(36).toUpperCase() + '-' + Math.random().toString(36).substring(2, 6).toUpperCase()
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
}

function downloadReceipt() {
  const element = document.getElementById('receipt-content')
  if (!element || !dest.value) return
  
  const opt = {
    margin: [10, 10, 10, 10],
    filename: `LoVista-Booking-${dest.value.slug}-${Date.now()}.pdf`,
    image: { type: 'jpeg', quality: 0.98 },
    html2canvas: { scale: 2, useCORS: true },
    jsPDF: { unit: 'mm', format: 'a4', orientation: 'portrait' }
  }
  
  html2pdf().set(opt).from(element).save().then(() => {
    Swal.fire({ title: 'Success', text: 'E-Receipt saved successfully!', icon: 'success' })
    showReceipt.value = false
  })
}

onMounted(() => {
  destStore.fetchDetail(route.params.slug as string)
})
</script>

<style scoped>
.detail-page { 
  min-height: 100vh; 
  background-color: #050608;
  background-image: 
    radial-gradient(at 0% 0%, rgba(37, 99, 235, 0.08) 0px, transparent 50%),
    radial-gradient(at 100% 100%, rgba(139, 92, 246, 0.05) 0px, transparent 50%),
    radial-gradient(at 50% 50%, rgba(5, 6, 8, 1) 0px, transparent 80%);
}
.detail__hero { height: 60vh; min-height: 480px; position: relative; display: flex; align-items: flex-end; }
.detail__hero-bg { position: absolute; inset: 0; background-size: cover; background-position: center; background-color: var(--dark3); }
.detail__hero-overlay { position: absolute; inset: 0; background: linear-gradient(to bottom, transparent 0%, rgba(5,6,8,0.95) 100%); }
.detail__hero-content { position: relative; z-index: 2; padding-bottom: 48px; }
/* ... breadcrumb and title unchanged ... */
.detail__breadcrumb { font-size: .78rem; color: rgba(255,255,255,.5); margin-bottom: 12px; }
.detail__breadcrumb a { color: rgba(255,255,255,.5); transition: color .2s; }
.detail__breadcrumb a:hover { color: var(--blue-b); }
.detail__title { font-family: 'Barlow Condensed', sans-serif; font-size: clamp(2.5rem,5vw,4.5rem); font-weight: 800; font-style: italic; line-height: 1; margin: 10px 0 8px; }
.detail__location { font-size: .9rem; color: rgba(255,255,255,.6); margin-bottom: 10px; }
.detail__rating { display: flex; align-items: center; gap: 6px; margin-bottom: 20px; font-size: .9rem; }
.detail__actions { display: flex; gap: 12px; }
.detail__body { padding: 48px 0; position: relative; }
.detail__layout { display: grid; grid-template-columns: 1fr 360px; gap: 48px; align-items: start; }
.detail__section { margin-bottom: 40px; }
.detail__section-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; }
.detail__section-title { font-family: 'Barlow Condensed', sans-serif; font-size: 1.4rem; font-weight: 700; font-style: italic; margin-bottom: 16px; color: #fff; text-shadow: 0 2px 4px rgba(0,0,0,0.3); }
.detail__desc { color: var(--w70); line-height: 1.8; font-size: .95rem; font-weight: 300; }
.detail__info-grid { display: grid; grid-template-columns: repeat(4,1fr); gap: 12px; margin-bottom: 40px; }
.info-card { 
  background: rgba(255, 255, 255, 0.03); 
  backdrop-filter: blur(10px);
  border: 1px solid rgba(255, 255, 255, 0.08); 
  border-radius: 14px; padding: 16px; text-align: center; 
  transition: transform 0.3s;
}
.info-card:hover { transform: translateY(-5px); border-color: rgba(37, 99, 235, 0.3); }
.info-card__icon { font-size: 1.5rem; margin-bottom: 8px; }
.info-card__label { font-size: .68rem; color: var(--w40); text-transform: uppercase; letter-spacing: .8px; margin-bottom: 4px; }
.info-card__value { font-weight: 700; font-size: .88rem; }
.detail__location-box { 
  background: rgba(255, 255, 255, 0.02); 
  border: 1px solid rgba(255, 255, 255, 0.05); 
  border-radius: 12px; padding: 16px; margin-bottom: 16px; 
  font-size: .88rem; color: var(--w70); display: flex; justify-content: space-between; align-items: center; 
}
.detail__coords { display: flex; gap: 16px; font-family: monospace; font-size: .78rem; color: var(--w40); }
.map-placeholder { 
  background: #000; border: 1px solid var(--w08); border-radius: 14px; 
  height: 320px; width: 100%; overflow: hidden;
  box-shadow: 0 10px 30px rgba(0,0,0,0.5);
}
.facilities__grid { display: grid; grid-template-columns: repeat(3,1fr); gap: 10px; }
.facility-item { 
  background: rgba(255, 255, 255, 0.03); 
  border: 1px solid rgba(255, 255, 255, 0.05); 
  border-radius: 10px; padding: 10px 14px; display: flex; align-items: center; gap: 8px; font-size: .85rem; 
}
.facility-item--unavailable { opacity: .4; }
.gallery__grid { display: grid; grid-template-columns: repeat(3,1fr); gap: 12px; }
.gallery-item { aspect-ratio: 4/3; border-radius: 12px; background-size: cover; background-position: center; background-color: var(--dark3); cursor: pointer; transition: transform .3s, box-shadow 0.3s; }
.gallery-item:hover { transform: scale(1.03); box-shadow: 0 10px 20px rgba(0,0,0,0.4); }

/* Culinary Styles */
.culinary__grid { display: grid; grid-template-columns: repeat(2, 1fr); gap: 16px; margin-top: 10px; }
.culinary-card { 
  display: flex; gap: 16px; background: rgba(255,255,255,0.03); 
  border: 1px solid rgba(255,255,255,0.05); border-radius: 14px; padding: 12px; 
  transition: transform 0.3s;
}
.culinary-card:hover { transform: translateY(-5px); border-color: rgba(37, 99, 235, 0.2); }
.culinary-card__img { width: 100px; height: 100px; border-radius: 10px; flex-shrink: 0; background-size: cover; background-position: center; }
.culinary-card__content { flex: 1; min-width: 0; }
.culinary-card__content h3 { font-size: 1rem; margin-bottom: 6px; color: #fff; }
.culinary-card__desc { font-size: 0.82rem; color: var(--w60); line-height: 1.4; margin-bottom: 8px; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden; }
.culinary-card__meta { display: flex; gap: 12px; font-size: 0.75rem; color: var(--w40); }

.rating-select { display: flex; gap: 4px; }
.rating-star { font-size: 1.8rem; color: rgba(255,255,255,.2); cursor: pointer; transition: color .2s; }
.rating-star.active { color: #f59e0b; }
.review-form { background: rgba(255,255,255,0.03); border: 1px solid rgba(255,255,255,0.08); padding: 20px; margin-bottom: 20px; }
.review-card { 
  background: rgba(255, 255, 255, 0.02); 
  border: 1px solid rgba(255, 255, 255, 0.05); 
  border-radius: 14px; padding: 18px; margin-bottom: 14px; 
}
.review-card__header { display: flex; align-items: center; gap: 12px; margin-bottom: 12px; }
.review-card__avatar { width: 38px; height: 38px; border-radius: 50%; background: var(--blue); display: flex; align-items: center; justify-content: center; font-weight: 700; flex-shrink: 0; }
.review-card__avatar-img { width: 38px; height: 38px; border-radius: 50%; background-size: cover; background-position: center; background-color: var(--dark3); flex-shrink: 0; border: 1px solid var(--w08); }
.review-card__name { font-weight: 700; font-size: .9rem; color: #fff; }
.review-card__date { font-size: .72rem; color: var(--w40); }
.review-card__stars { margin-left: auto; }
.review-card__text { font-size: .88rem; color: var(--w70); line-height: 1.6; }
.booking-card { 
  overflow: hidden; position: sticky; top: 100px; 
  background: rgba(10, 11, 14, 0.8);
  backdrop-filter: blur(20px);
  border: 1px solid rgba(255, 255, 255, 0.1);
  box-shadow: 0 20px 50px rgba(0,0,0,0.5);
}
.booking-card__header { padding: 20px; background: linear-gradient(135deg, var(--blue) 0%, #1e40af 100%); }
.booking-card__price { font-family: 'Bebas Neue', sans-serif; font-size: 2rem; letter-spacing: 1px; color: #fff; }
.booking-card__price-sub { font-size: .78rem; opacity: .8; color: #fff; }
.booking-card__body { padding: 20px; display: flex; flex-direction: column; gap: 0; }
.booking-card__summary { background: rgba(255,255,255,0.03); border-radius: 10px; padding: 14px; margin-bottom: 14px; }
.booking-card__summary-row { display: flex; justify-content: space-between; font-size: .85rem; margin-bottom: 6px; color: var(--w70); }
.booking-card__summary-total { color: var(--white); font-size: .95rem; }
.contact-card { 
  background: rgba(255, 255, 255, 0.02); 
  border: 1px solid rgba(255, 255, 255, 0.05); 
  padding: 18px; margin-top: 14px; 
}
.contact-card__title { font-weight: 700; margin-bottom: 12px; color: #fff; }
.contact-card__item { font-size: .85rem; color: var(--w70); margin-bottom: 8px; }
@media (max-width: 900px) {
  .detail__layout { grid-template-columns: 1fr; }
  .detail__info-grid { grid-template-columns: repeat(2,1fr); }
  .culinary__grid { grid-template-columns: 1fr; }
  .detail__sidebar { position: static; }
}

/* Receipt Modal Styles */
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
