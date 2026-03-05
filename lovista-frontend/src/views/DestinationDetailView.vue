<template>
  <div class="detail-page">
    <TheNavbar />

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
              <div class="map-placeholder">
                🗺️ Interactive Map — Leaflet.js integration point<br>
                <small>center: [{{ dest.latitude }}, {{ dest.longitude }}]</small>
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
                    <div class="review-card__avatar">{{ r.user?.fullname?.charAt(0) || '?' }}</div>
                    <div>
                      <div class="review-card__name">{{ r.user?.fullname }}</div>
                      <div class="review-card__date">{{ formatDate(r.created_at) }}</div>
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
                  <input type="date" class="form-input" v-model="bookingDate" />
                </div>
                <div class="form-group">
                  <label class="form-label">Visitors</label>
                  <input type="number" class="form-input" v-model="bookingPersons" min="1" placeholder="Number of people" />
                </div>
                <div class="booking-card__summary" v-if="bookingTotal > 0">
                  <div class="booking-card__summary-row">
                    <span>Ticket × {{ bookingPersons }}</span>
                    <span>Rp {{ formatPrice(dest.ticket_price * bookingPersons) }}</span>
                  </div>
                  <div class="booking-card__summary-row">
                    <span>Parking</span>
                    <span>Rp {{ formatPrice(dest.parking_fee) }}</span>
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
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter, RouterLink } from 'vue-router'
import { useDestinationStore } from '@/stores/destination'
import { useAuthStore } from '@/stores/auth'
import { destinationApi } from '@/api'
import TheNavbar from '@/components/layout/TheNavbar.vue'

const route = useRoute()
const router = useRouter()
const destStore = useDestinationStore()
const auth = useAuthStore()

const dest = computed(() => destStore.current)
const isWishlisted = computed(() => dest.value ? destStore.isWishlisted(dest.value.id) : false)

const bookingDate = ref('')
const bookingPersons = ref(1)
const writeReview = ref(false)
const reviewForm = ref({ rating: 5, comment: '' })

const bookingTotal = computed(() => {
  if (!dest.value || !bookingPersons.value) return 0
  return dest.value.ticket_price * bookingPersons.value + dest.value.parking_fee
})

function formatPrice(val: number) { return val.toLocaleString('id-ID') }
function formatDate(d: string) { return new Date(d).toLocaleDateString('id-ID', { year: 'numeric', month: 'long', day: 'numeric' }) }
function scrollTo(id: string) { document.getElementById(id)?.scrollIntoView({ behavior: 'smooth' }) }

async function toggleWishlist() {
  if (!auth.isLoggedIn) { router.push('/login'); return }
  if (dest.value) await destStore.toggleWishlist(dest.value.id)
}

async function submitReview() {
  if (!dest.value || !auth.isLoggedIn) return
  try {
    await destinationApi.addReview(dest.value.id, reviewForm.value)
    writeReview.value = false
    reviewForm.value = { rating: 5, comment: '' }
    await destStore.fetchDetail(route.params.slug as string)
  } catch { /* handle */ }
}

function handleBooking() {
  if (!auth.isLoggedIn) { router.push('/login'); return }
  if (!bookingDate.value) { alert('Please select a date'); return }
}

onMounted(() => {
  destStore.fetchDetail(route.params.slug as string)
})
</script>

<style scoped>
.detail-page { min-height: 100vh; }
.detail__hero { height: 60vh; min-height: 480px; position: relative; display: flex; align-items: flex-end; }
.detail__hero-bg { position: absolute; inset: 0; background-size: cover; background-position: center; background-color: var(--dark3); }
.detail__hero-overlay { position: absolute; inset: 0; background: linear-gradient(to bottom,rgba(5,6,8,.2) 0%,rgba(5,6,8,.85) 100%); }
.detail__hero-content { position: relative; z-index: 2; padding-bottom: 48px; }
.detail__breadcrumb { font-size: .78rem; color: rgba(255,255,255,.5); margin-bottom: 12px; }
.detail__breadcrumb a { color: rgba(255,255,255,.5); transition: color .2s; }
.detail__breadcrumb a:hover { color: var(--blue-b); }
.detail__title { font-family: 'Barlow Condensed', sans-serif; font-size: clamp(2.5rem,5vw,4.5rem); font-weight: 800; font-style: italic; line-height: 1; margin: 10px 0 8px; }
.detail__location { font-size: .9rem; color: rgba(255,255,255,.6); margin-bottom: 10px; }
.detail__rating { display: flex; align-items: center; gap: 6px; margin-bottom: 20px; font-size: .9rem; }
.detail__actions { display: flex; gap: 12px; }
.detail__body { padding: 48px 0; }
.detail__layout { display: grid; grid-template-columns: 1fr 360px; gap: 48px; align-items: start; }
.detail__section { margin-bottom: 40px; }
.detail__section-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; }
.detail__section-title { font-family: 'Barlow Condensed', sans-serif; font-size: 1.4rem; font-weight: 700; font-style: italic; margin-bottom: 16px; }
.detail__desc { color: var(--w70); line-height: 1.8; font-size: .95rem; font-weight: 300; }
.detail__info-grid { display: grid; grid-template-columns: repeat(4,1fr); gap: 12px; margin-bottom: 40px; }
.info-card { background: var(--dark2); border: 1px solid var(--w08); border-radius: 14px; padding: 16px; text-align: center; }
.info-card__icon { font-size: 1.5rem; margin-bottom: 8px; }
.info-card__label { font-size: .68rem; color: var(--w40); text-transform: uppercase; letter-spacing: .8px; margin-bottom: 4px; }
.info-card__value { font-weight: 700; font-size: .88rem; }
.detail__location-box { background: var(--dark2); border: 1px solid var(--w08); border-radius: 12px; padding: 16px; margin-bottom: 16px; font-size: .88rem; color: var(--w70); display: flex; justify-content: space-between; align-items: center; }
.detail__coords { display: flex; gap: 16px; font-family: monospace; font-size: .78rem; color: var(--w40); }
.map-placeholder { background: var(--dark2); border: 1px solid var(--w08); border-radius: 14px; height: 280px; display: flex; flex-direction: column; align-items: center; justify-content: center; color: var(--w40); font-size: .9rem; text-align: center; gap: 8px; }
.facilities__grid { display: grid; grid-template-columns: repeat(3,1fr); gap: 10px; }
.facility-item { background: var(--dark2); border: 1px solid var(--w08); border-radius: 10px; padding: 10px 14px; display: flex; align-items: center; gap: 8px; font-size: .85rem; }
.facility-item--unavailable { opacity: .4; }
.gallery__grid { display: grid; grid-template-columns: repeat(3,1fr); gap: 12px; }
.gallery-item { aspect-ratio: 4/3; border-radius: 12px; background-size: cover; background-position: center; background-color: var(--dark3); cursor: pointer; transition: transform .3s; }
.gallery-item:hover { transform: scale(1.03); }
.rating-select { display: flex; gap: 4px; }
.rating-star { font-size: 1.8rem; color: rgba(255,255,255,.2); cursor: pointer; transition: color .2s; }
.rating-star.active { color: #f59e0b; }
.review-form { padding: 20px; margin-bottom: 20px; }
.review-card { background: var(--dark2); border: 1px solid var(--w08); border-radius: 14px; padding: 18px; margin-bottom: 14px; }
.review-card__header { display: flex; align-items: center; gap: 12px; margin-bottom: 12px; }
.review-card__avatar { width: 38px; height: 38px; border-radius: 50%; background: var(--blue); display: flex; align-items: center; justify-content: center; font-weight: 700; flex-shrink: 0; }
.review-card__name { font-weight: 700; font-size: .9rem; }
.review-card__date { font-size: .72rem; color: var(--w40); }
.review-card__stars { margin-left: auto; }
.review-card__text { font-size: .88rem; color: var(--w70); line-height: 1.6; }
.booking-card { overflow: hidden; position: sticky; top: 100px; }
.booking-card__header { padding: 20px; background: var(--blue); }
.booking-card__price { font-family: 'Bebas Neue', sans-serif; font-size: 2rem; letter-spacing: 1px; }
.booking-card__price-sub { font-size: .78rem; opacity: .8; }
.booking-card__body { padding: 20px; display: flex; flex-direction: column; gap: 0; }
.booking-card__summary { background: var(--dark3); border-radius: 10px; padding: 14px; margin-bottom: 14px; }
.booking-card__summary-row { display: flex; justify-content: space-between; font-size: .85rem; margin-bottom: 6px; color: var(--w70); }
.booking-card__summary-total { color: var(--white); font-size: .95rem; }
.contact-card { padding: 18px; margin-top: 14px; }
.contact-card__title { font-weight: 700; margin-bottom: 12px; }
.contact-card__item { font-size: .85rem; color: var(--w70); margin-bottom: 8px; }
@media (max-width: 900px) {
  .detail__layout { grid-template-columns: 1fr; }
  .detail__info-grid { grid-template-columns: repeat(2,1fr); }
  .detail__sidebar { position: static; }
}
</style>
