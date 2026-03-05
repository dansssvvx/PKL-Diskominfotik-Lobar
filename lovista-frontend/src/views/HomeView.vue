<template>
  <div class="home-view">
    <!-- Global Overlay for the whole page -->
    <div class="home-global-overlay"></div>

    <!-- Hero Section -->
    <header class="hero">
      <div class="container hero__container">
        <div class="hero__content slide-up-enter-active">
          <span class="hero__badge">EXPLORE WEST LOMBOK</span>
          <h1 class="font-display hero__title">
            DISCOVER THE <span class="text-blue">EXTRAORDINARY</span>
          </h1>
          <p class="hero__subtitle">
            Experience the hidden gems of West Lombok, from pristine beaches to majestic mountains and rich cultural heritage.
          </p>
          <div class="hero__actions">
            <RouterLink to="/destinations" class="btn btn-primary btn-lg">Explore Now</RouterLink>
            <RouterLink to="/packages" class="btn btn-ghost btn-lg">View Packages</RouterLink>
          </div>
        </div>
      </div>
    </header>

    <!-- Popular Destinations Section -->
    <section class="section">
      <div class="container">
        <div class="section-header">
          <div>
            <h2 class="font-display">POPULAR DESTINATIONS</h2>
            <p class="section-subtitle">Top choice spots visited by travelers</p>
          </div>
          <RouterLink to="/destinations" class="link-more">View All →</RouterLink>
        </div>

        <div class="grid grid-5">
          <div v-for="dest in popularDestinations" :key="dest.id" class="card-modern slide-up-enter-active">
            <div class="card-modern__image-container">
              <img :src="getPhotoUrl(dest.main_image)" :alt="dest.name" class="card-modern__image" />
              <div class="card-modern__badge">{{ dest.category_name }}</div>
            </div>
            <div class="card-modern__content">
              <h3 class="card-modern__title">{{ dest.name }}</h3>
              <div class="card-modern__info">
                <span>📍 {{ dest.district }}</span>
                <span>⭐ 4.8</span>
              </div>
              <div class="card-modern__footer">
                <span class="card-modern__price">Rp {{ formatNumber(dest.ticket_price) }}</span>
                <RouterLink :to="'/destinations/' + dest.slug" class="btn btn-blue-outline btn-xs">Details</RouterLink>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- Featured Packages Section -->
    <section class="section bg-dark2">
      <div class="container">
        <div class="section-header">
          <div>
            <h2 class="font-display">FEATURED TOUR PACKAGES</h2>
            <p class="section-subtitle">Handpicked experiences for your best journey</p>
          </div>
          <RouterLink to="/packages" class="link-more">View All →</RouterLink>
        </div>

        <div class="grid grid-4">
          <div v-for="pkg in featuredPackages" :key="pkg.id" class="card-modern">
            <div class="card-modern__image-container">
              <img :src="getPhotoUrl(pkg.main_image)" :alt="pkg.name" class="card-modern__image" />
            </div>
            <div class="card-modern__content">
              <h3 class="card-modern__title">{{ pkg.name }}</h3>
              <p class="card-modern__desc">{{ pkg.description }}</p>
              <div class="card-modern__footer">
                <div class="price-box">
                  <span class="label">Starts from</span>
                  <span class="value text-blue">Rp {{ formatNumber(pkg.price_per_person) }}</span>
                </div>
                <RouterLink :to="'/packages/' + pkg.slug" class="btn btn-primary btn-xs">Book</RouterLink>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- Local Culinaries -->
    <section class="section">
      <div class="container">
        <div class="section-header">
          <div>
            <h2 class="font-display">LOCAL CULINARY</h2>
            <p class="section-subtitle">Authentic tastes of West Lombok</p>
          </div>
          <RouterLink to="/culinaries" class="link-more">View All →</RouterLink>
        </div>

        <div class="grid grid-4">
          <div v-for="item in culinaries" :key="item.id" class="card-simple">
            <div class="card-simple__img-box">
              <img :src="getPhotoUrl(item.image)" :alt="item.name" />
            </div>
            <div class="card-simple__body">
              <h4>{{ item.name }}</h4>
              <p>{{ item.price_range }}</p>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- Cultural Heritage -->
    <section class="section bg-dark2">
      <div class="container">
        <div class="section-header">
          <div>
            <h2 class="font-display">CULTURAL HERITAGE</h2>
            <p class="section-subtitle">Connect with the local traditions</p>
          </div>
          <RouterLink to="/culture" class="link-more">View All →</RouterLink>
        </div>

        <div class="grid grid-3">
          <div v-for="culture in cultures" :key="culture.id" class="culture-card" :style="{ backgroundImage: `url(${getPhotoUrl(culture.images?.[0])})` }">
            <div class="culture-card__overlay"></div>
            <div class="culture-card__content">
              <h3>{{ culture.name }}</h3>
              <p>{{ culture.description }}</p>
              <div class="culture-card__loc">📍 {{ culture.location }}</div>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- Vehicle Rental -->
    <section class="section">
      <div class="container">
        <div class="section-header">
          <div>
            <h2 class="font-display">VEHICLE RENTAL</h2>
            <p class="section-subtitle">Explore at your own pace</p>
          </div>
          <RouterLink to="/rent" class="link-more">Rent Now →</RouterLink>
        </div>

        <div class="grid grid-3">
          <div v-for="vehicle in vehicles" :key="vehicle.id" class="vehicle-card card">
            <div class="vehicle-card__img-container">
              <img :src="getPhotoUrl(vehicle.image)" :alt="vehicle.brand" class="vehicle-card__img" />
            </div>
            <div class="vehicle-card__body">
              <div class="vehicle-card__type badge">{{ vehicle.type }}</div>
              <h3>{{ vehicle.brand }} {{ vehicle.model }}</h3>
              <div class="divider"></div>
              <div class="vehicle-card__price">
                <span class="price">Rp {{ formatNumber(vehicle.daily_rate) }}</span>
                <span class="unit">/ day</span>
              </div>
              <button class="btn btn-blue-outline full-width mt-4">Check Availability</button>
            </div>
          </div>
        </div>
      </div>
    </section>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { 
  destinationApi, packageApi, culinaryApi, 
  cultureApi, vehicleApi 
} from '@/api'
import type { 
  TourismDestination, TourPackage, Culinary, 
  Culture, Vehicle 
} from '@/types'

const popularDestinations = ref<TourismDestination[]>([])
const featuredPackages = ref<TourPackage[]>([])
const culinaries = ref<Culinary[]>([])
const cultures = ref<Culture[]>([])
const vehicles = ref<Vehicle[]>([])

async function fetchData() {
  try {
    const [destRes, pkgRes, culRes, cultRes, vehRes] = await Promise.all([
      destinationApi.popular(),
      packageApi.featured(),
      culinaryApi.featured(),
      cultureApi.featured(),
      vehicleApi.list({ page: 1 })
    ])
    
    popularDestinations.value = destRes.data
    featuredPackages.value = pkgRes.data
    culinaries.value = culRes.data
    cultures.value = cultRes.data
    vehicles.value = vehRes.data.results.slice(0, 3)
  } catch (err) {
    console.error('Failed to fetch home data:', err)
  }
}

const getPhotoUrl = (path?: string) => {
  if (!path) return '/Logo.png' // Fallback
  if (path.startsWith('http')) return path
  return `http://127.0.0.1:8000${path}`
}

const formatNumber = (num: number | string) => {
  return new Intl.NumberFormat('id-ID').format(Number(num))
}

onMounted(fetchData)
</script>

<style scoped>
.home-view {
  position: relative;
  background-image: url('https://images.unsplash.com/photo-1516690561799-46d8f74f9abf?q=80&w=2070');
  background-position: center;
  background-size: cover;
  background-attachment: scroll;
  min-height: 100vh;
}

.home-global-overlay {
  position: absolute;
  top: 0; left: 0; right: 0; bottom: 0;
  background: linear-gradient(to bottom, rgba(5,6,8,0.6) 0%, rgba(5,6,8,0.85) 20%, rgba(5,6,8,0.95) 100%);
  z-index: 0;
  pointer-events: none;
}

.hero {
  position: relative; 
  height: 100vh; 
  min-height: 750px;
  display: flex; 
  align-items: center; 
  padding-top: 80px;
  z-index: 1;
  background: transparent; /* Hilangkan background lokal */
}

.hero__container { position: relative; z-index: 2; }
.hero__content { max-width: 800px; }
.hero__badge {
  display: inline-block; padding: 6px 16px; background: var(--w08);
  border: 1px solid var(--w12); border-radius: 99px;
  font-size: 0.75rem; font-weight: 700; letter-spacing: 2px; margin-bottom: 24px;
}
.hero__title { font-size: 5rem; line-height: 1.1; margin-bottom: 24px; }
.hero__subtitle { font-size: 1.25rem; color: var(--w60); margin-bottom: 40px; line-height: 1.6; }
.hero__actions { display: flex; gap: 16px; }

.section { 
  position: relative;
  padding: 100px 0; 
  background: transparent !important; /* Buat semua section transparan */
  z-index: 1;
}
.bg-dark2 { background: transparent !important; }

.section-header {
  display: flex; justify-content: space-between; align-items: flex-end;
  margin-bottom: 48px;
}
.section-header h2 { font-size: 2.25rem; letter-spacing: 1px; }
.section-subtitle { color: var(--w40); margin-top: 8px; }
.link-more { color: var(--blue); font-weight: 600; font-size: 0.9rem; }

/* Grid Utilities */
.grid { display: grid; gap: 24px; }
.grid-5 { grid-template-columns: repeat(5, 1fr); }
.grid-4 { grid-template-columns: repeat(4, 1fr); }
.grid-3 { grid-template-columns: repeat(3, 1fr); }

/* Card Modern */
.card-modern {
  background: var(--dark2); border-radius: 16px; overflow: hidden;
  border: 1px solid var(--w08); transition: transform 0.3s, border-color 0.3s;
}
.card-modern:hover { transform: translateY(-10px); border-color: var(--blue); }
.card-modern__image-container { position: relative; height: 200px; }
.card-modern__image { width: 100%; height: 100%; object-fit: cover; }
.card-modern__badge {
  position: absolute; top: 12px; left: 12px; padding: 4px 12px;
  background: rgba(5,6,8,0.6); backdrop-filter: blur(8px);
  border-radius: 99px; font-size: 0.7rem; font-weight: 700;
}
.card-modern__content { padding: 20px; }
.card-modern__title { font-size: 1.1rem; margin-bottom: 8px; color: #fff; }
.card-modern__info { display: flex; justify-content: space-between; font-size: 0.8rem; color: var(--w40); margin-bottom: 16px; }
.card-modern__footer { display: flex; justify-content: space-between; align-items: center; padding-top: 16px; border-top: 1px solid var(--w04); }
.card-modern__price { font-weight: 700; color: #fff; font-size: 0.95rem; }
.card-modern__desc { font-size: 0.85rem; color: var(--w40); line-height: 1.5; margin-bottom: 20px; }

/* Simple Card for Culinary */
.card-simple { display: flex; align-items: center; gap: 16px; background: var(--dark2); padding: 12px; border-radius: 12px; border: 1px solid var(--w08); }
.card-simple__img-box { width: 70px; height: 70px; border-radius: 8px; overflow: hidden; }
.card-simple__img-box img { width: 100%; height: 100%; object-fit: cover; }
.card-simple__body h4 { font-size: 0.95rem; margin-bottom: 4px; }
.card-simple__body p { font-size: 0.8rem; color: var(--blue); font-weight: 600; }

/* Culture Card */
.culture-card {
  position: relative;
  height: 240px; border-radius: 16px; padding: 32px;
  background-size: cover;
  background-position: center;
  border: 1px solid var(--w08); display: flex; align-items: flex-end;
  overflow: hidden;
}
.culture-card__overlay {
  position: absolute; inset: 0;
  background: linear-gradient(to top, rgba(5,6,8,0.9) 0%, transparent 100%);
}
.culture-card__content { position: relative; z-index: 2; }

.vehicle-card__img-container { height: 160px; overflow: hidden; }
.vehicle-card__img { width: 100%; height: 100%; object-fit: cover; }

.full-width { width: 100%; }
.text-blue { color: var(--blue); }

@media (max-width: 1200px) {
  .grid-5, .grid-4 { grid-template-columns: repeat(3, 1fr); }
  .hero__title { font-size: 3.5rem; }
}
@media (max-width: 768px) {
  .grid-5, .grid-4, .grid-3 { grid-template-columns: 1fr; }
  .hero__title { font-size: 2.5rem; }
  .section { padding: 60px 0; }
}
</style>
