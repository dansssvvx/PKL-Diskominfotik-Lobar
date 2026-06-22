<template>
  <div class="package-detail">
    <!-- Loading State -->
    <div v-if="loading" class="page-loader">
      <div class="spinner"></div>
      <p>Fetching package details...</p>
    </div>

    <!-- Content -->
    <template v-else-if="pkg">
      <header class="pkg-hero">
        <div class="pkg-hero__bg" :style="{ backgroundImage: `url(${getPhotoUrl(pkg.main_image)})` }"></div>
        <div class="pkg-hero__overlay"></div>
        <div class="container pkg-hero__content">
          <div class="pkg-hero__breadcrumb">
            <RouterLink to="/">Home</RouterLink> / 
            <RouterLink to="/packages">Tour Packages</RouterLink> / 
            <span>{{ pkg.name }}</span>
          </div>
          <div class="pkg-hero__badges">
            <span class="badge badge-blue">Tour Package</span>
            <span class="badge badge-gray">{{ pkg.duration_days }} Days {{ pkg.duration_days > 1 ? pkg.duration_days - 1 : 0 }} Nights</span>
          </div>
          <h1 class="pkg-hero__title italic-bold">{{ pkg.name }}</h1>
          <div class="pkg-hero__meta">
            <span>By <strong>{{ pkg.agency_name || 'Travel Agency' }}</strong></span>
            <span class="dot"></span>
            <span>Min. {{ pkg.min_person }} Persons</span>
            <span v-if="pkg.max_person" class="dot"></span>
            <span v-if="pkg.max_person">Max. {{ pkg.max_person }} Persons</span>
          </div>
        </div>
      </header>

      <div class="container pkg-body">
        <div class="pkg-layout">
          <!-- Main Content -->
          <div class="pkg-main">
            <!-- Destinations Involved -->
            <section class="pkg-section" v-if="pkg.destinations?.length">
              <h2 class="pkg-section-title">Destinations You'll Visit</h2>
              <div class="dest-mini-grid">
                <div v-for="d in pkg.destinations" :key="d.id" class="dest-mini-card card-hover">
                  <div class="dest-mini-card__img" :style="{ backgroundImage: `url(${getPhotoUrl(d.destination?.main_image)})` }"></div>
                  <div class="dest-mini-card__info">
                    <h4>{{ d.destination?.name }}</h4>
                    <RouterLink :to="'/destinations/' + d.destination?.slug" class="link-arrow">Details →</RouterLink>
                  </div>
                </div>
              </div>
            </section>

            <!-- Description -->
            <section class="pkg-section">
              <h2 class="pkg-section-title">Overview</h2>
              <p class="pkg-description">{{ pkg.description }}</p>
            </section>

            <!-- Itinerary -->
            <section class="pkg-section" v-if="pkg.itineraries?.length">
              <h2 class="pkg-section-title">Itinerary</h2>
              <div class="itinerary-list">
                <div v-for="item in sortedItinerary" :key="item.id" class="itinerary-item">
                  <div class="itinerary-item__day">Day {{ item.day_number }}</div>
                  <div class="itinerary-item__content">
                    <h3>{{ item.activity }}</h3>
                    <div class="itinerary-item__time" v-if="item.time">{{ item.time }}</div>
                    <div class="itinerary-item__location" v-if="item.location">
                      <span class="icon">📍</span> {{ item.location }}
                    </div>
                    <p>{{ item.description }}</p>
                  </div>
                </div>
              </div>
            </section>

            <!-- Inclusions & Exclusions -->
            <section class="pkg-section grid-2" v-if="pkg.package_inclusions?.length">
              <div class="inclusion-box card p-6">
                <h3 class="pkg-section-title-sm">Price Includes</h3>
                <ul class="check-list">
                  <li v-for="inc in inclusions" :key="inc.id">
                    <span class="icon-check">✓</span> {{ inc.item }}
                  </li>
                </ul>
              </div>
              <div class="inclusion-box card p-6">
                <h3 class="pkg-section-title-sm">Price Excludes</h3>
                <ul class="check-list uncheck">
                  <li v-for="exc in exclusions" :key="exc.id">
                    <span class="icon-x">✕</span> {{ exc.item }}
                  </li>
                </ul>
              </div>
            </section>

            <!-- Terms and Conditions -->
            <section class="pkg-section" v-if="pkg.terms_conditions">
              <h2 class="pkg-section-title">Terms & Conditions</h2>
              <div class="terms-content">
                {{ pkg.terms_conditions }}
              </div>
            </section>
          </div>

          <!-- Sidebar: Booking -->
          <aside class="pkg-sidebar">
            <div class="pkg-sidebar-sticky">
              <div class="booking-card card shadow-lg">
                <div class="booking-card__header">
                  <div class="booking-card__price">
                    <span class="label">Price per person</span>
                    <div class="price-wrapper">
                      <span class="value font-display">Rp {{ formatNumber(pkg.discounted_price || pkg.price_per_person) }}</span>
                      <span v-if="pkg.discount_percentage > 0" class="original-price">Rp {{ formatNumber(pkg.price_per_person) }}</span>
                    </div>
                  </div>
                </div>
                <div class="booking-card__body">
                  <div class="form-group">
                    <label class="form-label">Select Start Date</label>
                    <input type="date" v-model="bookingDate" class="form-input" :min="today" />
                  </div>
                  <div class="form-group">
                    <label class="form-label">Number of Persons</label>
                    <div class="number-input">
                      <button type="button" @click="decrementPersons" :disabled="bookingPersons <= pkg.min_person">-</button>
                      <input type="number" v-model="bookingPersons" readonly />
                      <button type="button" @click="incrementPersons" :disabled="pkg.max_person && bookingPersons >= pkg.max_person">+</button>
                    </div>
                    <small class="text-muted">Min: {{ pkg.min_person }} <span v-if="pkg.max_person">| Max: {{ pkg.max_person }}</span></small>
                  </div>

                  <div class="booking-summary">
                    <div class="summary-row">
                      <span>Rp {{ formatNumber(pkg.discounted_price || pkg.price_per_person) }} × {{ bookingPersons }}</span>
                      <span>Rp {{ formatNumber(bookingTotal) }}</span>
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
                    :disabled="isBooking"
                  >
                    <span v-if="isBooking">Processing...</span>
                    <span v-else>Book This Package</span>
                  </button>
                  <p class="booking-note mt-4">Secure your spot. Confirmation is instant.</p>
                </div>
              </div>
              
              <div class="help-card card p-6 mt-6">
                <h4 class="mb-2">Need Help?</h4>
                <p class="text-w60 text-sm mb-4">Contact our support team if you have questions regarding this package or need a custom itinerary.</p>
                <button class="btn btn-ghost btn-sm w-full">Chat Support</button>
              </div>
            </div>
          </aside>
        </div>
      </div>
    </template>

    <div v-else class="page-error container">
      <div class="empty-state">
        <div class="icon">🔍</div>
        <h3>Package Not Found</h3>
        <p>The package you are looking for might have been removed or is no longer active.</p>
        <RouterLink to="/packages" class="btn btn-primary mt-4">Browse Other Packages</RouterLink>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import Swal from 'sweetalert2'
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter, RouterLink } from 'vue-router'
import { packageApi, bookingApi } from '@/api'
import { useAuthStore } from '@/stores/auth'
import TheNavbar from '@/components/layout/TheNavbar.vue'
import type { TourPackage } from '@/types'

const route = useRoute()
const router = useRouter()
const auth = useAuthStore()

const pkg = ref<TourPackage | null>(null)
const loading = ref(true)
const isBooking = ref(false)

const bookingDate = ref('')
const bookingPersons = ref(1)

const today = new Date().toISOString().split('T')[0]

const inclusions = computed(() => pkg.value?.package_inclusions?.filter(i => i.is_included) || [])
const exclusions = computed(() => pkg.value?.package_inclusions?.filter(i => !i.is_included) || [])

const sortedItinerary = computed(() => {
  if (!pkg.value?.itineraries) return []
  return [...pkg.value.itineraries].sort((a, b) => {
    if (a.day_number !== b.day_number) return a.day_number - b.day_number
    return a.display_order - b.display_order
  })
})

const bookingTotal = computed(() => {
  if (!pkg.value) return 0
  const price = pkg.value.discounted_price || pkg.value.price_per_person
  return Number(price) * bookingPersons.value
})

async function fetchPackage() {
  loading.value = true
  try {
    const slug = route.params.slug as string
    const res = await packageApi.detail(slug)
    pkg.value = res.data
    bookingPersons.value = pkg.value.min_person
  } catch (err) {
    console.error('Failed to fetch package:', err)
  } finally {
    loading.value = false
  }
}

function incrementPersons() {
  if (pkg.value?.max_person && bookingPersons.value >= pkg.value.max_person) return
  bookingPersons.value++
}

function decrementPersons() {
  if (pkg.value && bookingPersons.value > pkg.value.min_person) {
    bookingPersons.value--
  }
}

const getPhotoUrl = (path?: string | null) => {
  if (!path) return '/Logo.png'
  if (path.startsWith('http')) return path
  // Base URL from API or environment
  return `http://127.0.0.1:8000${path}`
}

const formatNumber = (num: number | string) => {
  return new Intl.NumberFormat('id-ID').format(Number(num))
}

async function handleBooking() {
  if (!auth.isLoggedIn) {
    router.push({ name: 'Login', query: { redirect: route.fullPath } })
    return
  }

  if (!bookingDate.value) {
    Swal.fire({ title: 'Notification', text: 'Please select a start date.', icon: 'info' })
    return
  }

  if (!pkg.value) return

  isBooking.value = true
  try {
    const res = await bookingApi.create({
      package_id: pkg.value.id,
      start_date: bookingDate.value,
      total_person: bookingPersons.value
    })
    
    Swal.fire({ title: 'Notification', text: 'Booking successful! Redirecting to your bookings...', icon: 'info' })
    router.push('/my-bookings')
  } catch (err: any) {
    console.error('Booking failed:', err)
    Swal.fire({ title: 'Notification', text: err.response?.data?.message || 'Failed to create booking. Please try again.', icon: 'info' })
  } finally {
    isBooking.value = false
  }
}

onMounted(fetchPackage)
</script>

<style scoped>
.package-detail { min-height: 100vh; background: var(--black); color: var(--white); }

.pkg-hero { height: 60vh; min-height: 500px; position: relative; display: flex; align-items: flex-end; padding-bottom: 80px; }
.pkg-hero__bg { position: absolute; inset: 0; background-size: cover; background-position: center; }
.pkg-hero__overlay { position: absolute; inset: 0; background: linear-gradient(to bottom, transparent 0%, rgba(5,6,8,0.95) 100%); }
.pkg-hero__content { position: relative; z-index: 2; }
.pkg-hero__breadcrumb { font-size: 0.8rem; color: var(--w40); margin-bottom: 20px; }
.pkg-hero__breadcrumb a { color: var(--w40); transition: color 0.2s; }
.pkg-hero__breadcrumb a:hover { color: var(--blue); }
.pkg-hero__badges { display: flex; gap: 10px; margin-bottom: 20px; }
.pkg-hero__title { font-size: 4rem; line-height: 1; margin-bottom: 16px; font-family: 'Barlow Condensed', sans-serif; text-transform: uppercase; }
.pkg-hero__meta { color: var(--w70); font-size: 1rem; display: flex; align-items: center; gap: 16px; }
.dot { width: 4px; height: 4px; background: var(--w20); border-radius: 50%; }

.pkg-body { padding: 80px 0; }
.pkg-layout { display: grid; grid-template-columns: 1fr 400px; gap: 80px; align-items: start; }

.pkg-section { margin-bottom: 60px; }
.pkg-section-title { font-family: 'Barlow Condensed', sans-serif; font-size: 2.2rem; font-weight: 800; margin-bottom: 32px; font-style: italic; border-left: 5px solid var(--blue); padding-left: 20px; text-transform: uppercase; }
.pkg-section-title-sm { font-size: 1.2rem; font-weight: 700; margin-bottom: 20px; color: var(--white); }
.pkg-description { color: var(--w70); line-height: 1.8; font-size: 1.1rem; white-space: pre-line; }

/* Grid utilities */
.grid-2 { display: grid; grid-template-columns: repeat(2, 1fr); gap: 24px; }
@media (max-width: 768px) { .grid-2 { grid-template-columns: 1fr; } }

/* Destinations Grid */
.dest-mini-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(200px, 1fr)); gap: 20px; }
.dest-mini-card { background: var(--dark2); border-radius: var(--radius-lg); overflow: hidden; border: 1px solid var(--w08); }
.dest-mini-card__img { height: 140px; background-size: cover; background-position: center; }
.dest-mini-card__info { padding: 16px; }
.dest-mini-card__info h4 { font-size: 1rem; margin-bottom: 8px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.link-arrow { font-size: 0.8rem; color: var(--blue); font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; }

/* Itinerary */
.itinerary-list { position: relative; padding-left: 40px; }
.itinerary-list::before { content: ''; position: absolute; left: 9px; top: 10px; bottom: 0; width: 2px; background: var(--w08); }
.itinerary-item { position: relative; margin-bottom: 40px; }
.itinerary-item::before { content: ''; position: absolute; left: -40px; top: 5px; width: 20px; height: 20px; background: var(--blue); border: 4px solid var(--black); border-radius: 50%; z-index: 2; box-shadow: 0 0 15px rgba(26,143,255,0.4); }
.itinerary-item__day { font-weight: 900; color: var(--blue); text-transform: uppercase; font-size: 0.9rem; letter-spacing: 2px; margin-bottom: 12px; }
.itinerary-item__content h3 { font-size: 1.4rem; margin-bottom: 8px; color: var(--white); }
.itinerary-item__time { font-size: 0.9rem; color: var(--w40); margin-bottom: 8px; font-weight: 600; }
.itinerary-item__location { font-size: 0.9rem; color: var(--blue-b); margin-bottom: 12px; display: flex; align-items: center; gap: 6px; }
.itinerary-item__content p { color: var(--w70); font-size: 1rem; line-height: 1.7; }

/* Inclusion List */
.check-list { list-style: none; padding: 0; }
.check-list li { display: flex; gap: 14px; margin-bottom: 16px; color: var(--w70); font-size: 1rem; align-items: flex-start; }
.icon-check { color: var(--success); font-weight: bold; margin-top: 2px; }
.icon-x { color: var(--danger); font-weight: bold; margin-top: 2px; }

/* Terms */
.terms-content { color: var(--w60); font-size: 0.95rem; line-height: 1.8; white-space: pre-line; background: var(--dark1); padding: 24px; border-radius: var(--radius-md); border-left: 4px solid var(--w15); }

/* Booking Card */
.booking-card { background: var(--dark2); border: 1px solid var(--w08); border-radius: var(--radius-xl); overflow: hidden; }
.pkg-sidebar-sticky { position: sticky; top: 120px; }
.booking-card__header { padding: 32px; background: var(--blue); color: #fff; }
.booking-card__price .label { display: block; font-size: 0.85rem; font-weight: 600; opacity: 0.8; margin-bottom: 8px; text-transform: uppercase; letter-spacing: 1px; }
.price-wrapper { display: flex; align-items: baseline; gap: 12px; flex-wrap: wrap; }
.booking-card__price .value { font-size: 2.8rem; display: block; line-height: 1; }
.original-price { text-decoration: line-through; color: rgba(255,255,255,0.6); font-size: 1.1rem; }
.booking-card__body { padding: 32px; }

.number-input { display: flex; align-items: center; background: var(--dark3); border-radius: var(--radius-md); overflow: hidden; margin-bottom: 10px; border: 1.5px solid var(--w08); }
.number-input button { width: 50px; height: 50px; border: none; background: transparent; color: #fff; cursor: pointer; transition: all 0.2s; font-size: 1.2rem; }
.number-input button:hover:not(:disabled) { background: var(--w08); color: var(--blue); }
.number-input button:disabled { opacity: 0.3; cursor: not-allowed; }
.number-input input { flex: 1; text-align: center; background: transparent; border: none; color: #fff; font-weight: 800; font-size: 1.1rem; -moz-appearance: textfield; }
.number-input input::-webkit-outer-spin-button, .number-input input::-webkit-inner-spin-button { -webkit-appearance: none; margin: 0; }

.booking-summary { background: var(--dark3); padding: 20px; border-radius: var(--radius-lg); margin: 24px 0; border: 1px solid var(--w04); }
.summary-row { display: flex; justify-content: space-between; font-size: 0.95rem; color: var(--w60); margin-bottom: 12px; }
.summary-row.total { color: var(--white); font-size: 1.1rem; margin-top: 12px; }
.text-blue { color: var(--blue-b); }
.booking-note { font-size: 0.8rem; color: var(--w40); text-align: center; line-height: 1.5; }

.w-full { width: 100%; }
.p-6 { padding: 24px; }
.mb-2 { margin-bottom: 8px; }
.mb-4 { margin-bottom: 16px; }
.mt-4 { margin-top: 16px; }
.mt-6 { margin-top: 24px; }
.text-sm { font-size: 0.875rem; }
.text-w60 { color: var(--w60); }
.text-muted { color: var(--w40); font-size: 0.75rem; }

@media (max-width: 1200px) {
  .pkg-layout { gap: 40px; grid-template-columns: 1fr 360px; }
}

@media (max-width: 992px) {
  .pkg-layout { grid-template-columns: 1fr; }
  .pkg-sidebar { position: static; }
  .pkg-hero__title { font-size: 3rem; }
}

@media (max-width: 576px) {
  .pkg-hero { height: auto; padding-top: 120px; }
  .pkg-hero__title { font-size: 2.2rem; }
  .pkg-hero__meta { flex-direction: column; align-items: flex-start; gap: 8px; }
  .pkg-hero__meta .dot { display: none; }
}
</style>
