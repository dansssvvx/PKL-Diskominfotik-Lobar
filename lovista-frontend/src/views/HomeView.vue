<template>
  <div class="home">
    <TheNavbar />

    <!-- Floating search bar -->
    <div class="home__search-wrap">
      <div class="home__search">
        <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="rgba(255,255,255,0.55)" stroke-width="2.5">
          <circle cx="11" cy="11" r="8"/><path d="m21 21-4.35-4.35"/>
        </svg>
        <input
          v-model="searchQuery"
          type="text"
          placeholder="Search anything here..."
          @keyup.enter="handleSearch"
        />
      </div>
    </div>

    <!-- ── HERO ── -->
    <section class="hero">
      <div class="hero__bg"></div>
      <div class="hero__content">
        <p class="hero__pre">It's time to</p>
        <h1 class="hero__title">Explore the hidden<br>charm of West Lombok</h1>
        <p class="hero__desc">
          West Lombok, a breathtaking tropical paradise adorned with shimmering white-sand
          beaches, lush green hills, and hidden waterfalls. A perfect destination for
          unforgettable adventure and relaxation.
        </p>
        <button class="hero__cta" @click="scrollTo('destinations')">
          <em>Trip NOW!</em>
          <span class="hero__cta-icon">🧭</span>
        </button>
      </div>
    </section>

    <!-- ── POPULAR DESTINATIONS ── -->
    <section class="section" id="destinations">
      <div class="container">
        <div class="section-heading">
          <div class="section-line"></div>
          <h2 class="section-title">Popular Destinations</h2>
          <div class="section-line right"></div>
        </div>

        <div class="destinations__grid" v-if="!destStore.loading">
          <div
            class="dest-card"
            v-for="(dest, i) in popularDestinations"
            :key="dest.id"
            @click="goToDestination(dest.slug)"
          >
            <div
              class="dest-card__img"
              :style="{ backgroundImage: dest.main_image ? `url(${dest.main_image})` : 'none' }"
            ></div>
            <div class="dest-card__overlay"></div>

            <!-- Info panel (blue, slides up on hover) -->
            <div class="dest-card__info">
              <div class="dest-card__meta">
                <div class="dest-card__meta-item">
                  <div class="dest-card__meta-label">🎫 Ticket</div>
                  <div class="dest-card__meta-value">
                    Rp {{ formatPrice(dest.ticket_price) }}
                  </div>
                </div>
                <div class="dest-card__meta-sep"></div>
                <div class="dest-card__meta-item">
                  <div class="dest-card__meta-label">🅿️ Parking</div>
                  <div class="dest-card__meta-value">
                    Rp {{ formatPrice(dest.parking_fee) }}
                  </div>
                </div>
              </div>
              <div class="dest-card__coords" v-if="dest.latitude">
                Latitude &nbsp;&nbsp;: {{ dest.latitude }}<br>
                Longitude : {{ dest.longitude }}
              </div>
              <div class="dest-card__name">{{ dest.name }}</div>
              <div class="dest-card__addr">{{ dest.address }}</div>
            </div>

            <!-- Number at rest -->
            <div class="dest-card__num">{{ String(i + 1).padStart(2, '0') }}</div>
          </div>
        </div>

        <!-- Loading state -->
        <div class="page-loader" v-else>
          <div class="spinner"></div>
          Loading destinations...
        </div>

        <div class="section__footer">
          <RouterLink to="/destinations" class="btn btn-ghost">
            View All Destinations →
          </RouterLink>
        </div>
      </div>
    </section>

    <!-- ── FEATURED TOUR PACKAGES ── -->
    <section class="section section--alt" id="packages">
      <div class="container">
        <div class="section-heading">
          <div class="section-line"></div>
          <h2 class="section-title">Featured Tour Packages</h2>
          <div class="section-line right"></div>
        </div>

        <div class="packages__grid">
          <div
            class="pkg-card card card-hover"
            v-for="pkg in featuredPackages"
            :key="pkg.id"
            @click="goToPackage(pkg.slug)"
          >
            <div class="pkg-card__img" :style="{ backgroundImage: pkg.main_image ? `url(${pkg.main_image})` : 'none' }">
              <div class="pkg-card__img-overlay"></div>
              <span class="badge badge-blue pkg-card__badge" v-if="pkg.is_featured">⭐ Featured</span>
              <span class="pkg-card__discount" v-if="pkg.discount_percentage > 0">
                -{{ pkg.discount_percentage }}%
              </span>
            </div>
            <div class="pkg-card__body">
              <div class="pkg-card__agency">{{ pkg.agency?.business_name }}</div>
              <div class="pkg-card__name">{{ pkg.name }}</div>
              <div class="pkg-card__specs">
                <span>📅 {{ pkg.duration_days }}D</span>
                <span>👥 Min {{ pkg.min_person }} pax</span>
                <span>📍 {{ pkg.destinations?.length ?? 0 }} stops</span>
              </div>
            </div>
            <div class="pkg-card__footer">
              <div>
                <div class="pkg-card__price">Rp {{ formatPrice(pkg.price_per_person) }}</div>
                <div class="pkg-card__price-sub">/ person</div>
              </div>
              <button class="btn btn-primary btn-sm" @click.stop="openBooking(pkg)">
                Book Now
              </button>
            </div>
          </div>
        </div>

        <div class="section__footer">
          <RouterLink to="/packages" class="btn btn-ghost">View All Packages →</RouterLink>
        </div>
      </div>
    </section>

    <!-- ── CULTURE ── -->
    <section class="section" id="culture">
      <div class="container">
        <div class="section-heading">
          <div class="section-line"></div>
          <h2 class="section-title">Culture & Heritage</h2>
          <div class="section-line right"></div>
        </div>
        <div class="culture__grid">
          <div
            class="culture-card"
            v-for="item in cultures"
            :key="item.id"
            :class="{ 'culture-card--main': item.id === cultures[0]?.id }"
            @click="router.push('/culture')"
          >
            <div class="culture-card__bg" :style="getcultureBg(item)"></div>
            <div class="culture-card__overlay"></div>
            <div class="culture-card__body">
              <span class="badge badge-blue">CULTURE</span>
              <div class="culture-card__name">{{ item.name }}</div>
            </div>
          </div>
        </div>
        <div class="section__footer">
          <RouterLink to="/culture" class="btn btn-ghost">Explore Culture →</RouterLink>
        </div>
      </div>
    </section>

    <!-- ── CULINARIES ── -->
    <section class="section section--alt" id="culinaries">
      <div class="container">
        <div class="section-heading">
          <div class="section-line"></div>
          <h2 class="section-title">Local Culinaries</h2>
          <div class="section-line right"></div>
        </div>
        <div class="culinary__grid">
          <div
            class="culinary-card card card-hover"
            v-for="item in culinaries"
            :key="item.id"
            @click="router.push('/culinaries')"
          >
            <div
              class="culinary-card__img"
              :style="{ backgroundImage: item.image ? `url(${item.image})` : 'none', background: item.image ? undefined : 'linear-gradient(135deg,#1a5f3f,#2d8a5e)' }"
            >
              <span v-if="!item.image" class="culinary-card__emoji">🍽️</span>
            </div>
            <div class="culinary-card__body">
              <div class="culinary-card__name">{{ item.name }}</div>
              <div class="culinary-card__price">{{ item.price_range || 'Price varies' }}</div>
            </div>
          </div>
        </div>
        <div class="section__footer">
          <RouterLink to="/culinaries" class="btn btn-ghost">Explore Culinary →</RouterLink>
        </div>
      </div>
    </section>

    <!-- ── VEHICLE RENTAL ── -->
    <section class="section" id="rent">
      <div class="container">
        <div class="section-heading">
          <div class="section-line"></div>
          <h2 class="section-title">Vehicle Rental</h2>
          <div class="section-line right"></div>
        </div>
        <div class="rental__grid">
          <div
            class="rental-card card card-hover"
            v-for="v in vehicles"
            :key="v.id"
            @click="router.push('/rent')"
          >
            <div class="rental-card__img"
              :style="v.image ? { backgroundImage: `url(${v.image})` } : {}">
              <span v-if="!v.image">{{ vehicleEmoji(v.type) }}</span>
            </div>
            <div class="rental-card__body">
              <div class="rental-card__type badge badge-blue">{{ v.type.toUpperCase() }}</div>
              <div class="rental-card__name">{{ v.brand }} {{ v.model }}</div>
              <div class="rental-card__price">
                From <strong>Rp {{ formatPrice(v.daily_rate) }}</strong>/day
              </div>
            </div>
          </div>
        </div>
        <div class="section__footer">
          <RouterLink to="/rent" class="btn btn-ghost">View All Vehicles →</RouterLink>
        </div>
      </div>
    </section>

    <!-- ── AI RECOMMENDATION BANNER ── -->
    <section class="section section--ai">
      <div class="container">
        <div class="ai-banner">
          <div class="ai-banner__left">
            <div class="ai-banner__tag">✨ AI Powered</div>
            <h2 class="ai-banner__title">
              Get Smart<br><em>Travel Recommendations</em>
            </h2>
            <p class="ai-banner__desc">
              Tell us your budget, duration, and interests — our AI will craft the perfect
              West Lombok itinerary just for you.
            </p>
            <RouterLink to="/ai-recommendation" class="btn btn-primary btn-lg">
              Try AI Planner →
            </RouterLink>
          </div>
          <div class="ai-banner__right">
            <div class="ai-banner__card">
              <div class="ai-banner__card-title">🤖 Quick Preferences</div>
              <div class="form-group">
                <label class="form-label">Budget</label>
                <input class="form-input" v-model="aiForm.budget" placeholder="e.g. Rp 500.000 - 2.000.000" />
              </div>
              <div class="form-group">
                <label class="form-label">Duration</label>
                <select class="form-select" v-model="aiForm.duration">
                  <option value="">Select duration</option>
                  <option>1 Day</option><option>2-3 Days</option>
                  <option>4-7 Days</option><option>1+ Week</option>
                </select>
              </div>
              <div class="ai-chips">
                <button
                  v-for="tag in interestTags" :key="tag"
                  class="ai-chip"
                  :class="{ 'ai-chip--active': aiForm.interests.includes(tag) }"
                  @click="toggleInterest(tag)"
                >{{ tag }}</button>
              </div>
              <RouterLink to="/ai-recommendation" class="btn btn-primary" style="width:100%;margin-top:16px;justify-content:center">
                ✨ Get Recommendations
              </RouterLink>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- Footer -->
    <TheFooter />
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRouter, RouterLink } from 'vue-router'
import { useDestinationStore } from '@/stores/destination'
import { packageApi, cultureApi, culinaryApi, vehicleApi } from '@/api'
import TheNavbar from '@/components/layout/TheNavbar.vue'
import TheFooter from '@/components/layout/TheFooter.vue'
import type { TourPackage, Culture, Culinary, Vehicle } from '@/types'

const router = useRouter()
const destStore = useDestinationStore()

const searchQuery = ref('')
const featuredPackages = ref<TourPackage[]>([])
const cultures = ref<Culture[]>([])
const culinaries = ref<Culinary[]>([])
const vehicles = ref<Vehicle[]>([])

const aiForm = ref({ budget: '', duration: '', interests: [] as string[] })
const interestTags = ['🏖️ Beach', '🏔️ Mountain', '🎭 Culture', '🍜 Food', '🤿 Diving', '📸 Photo']

const popularDestinations = computed(() => destStore.featured.slice(0, 3))

function formatPrice(val: number) {
  return val.toLocaleString('id-ID')
}

function scrollTo(id: string) {
  document.getElementById(id)?.scrollIntoView({ behavior: 'smooth' })
}

function goToDestination(slug: string) {
  router.push(`/destinations/${slug}`)
}

function goToPackage(slug: string) {
  router.push(`/packages/${slug}`)
}

function openBooking(pkg: TourPackage) {
  router.push(`/packages/${pkg.slug}?book=true`)
}

function handleSearch() {
  if (searchQuery.value.trim()) {
    router.push({ path: '/destinations', query: { search: searchQuery.value } })
  }
}

function toggleInterest(tag: string) {
  const idx = aiForm.value.interests.indexOf(tag)
  if (idx > -1) aiForm.value.interests.splice(idx, 1)
  else aiForm.value.interests.push(tag)
}

function getculturBg(item: Culture): Record<string, string> {
  if (item.images?.length) return { backgroundImage: `url(${item.images[0]})` }
  return { background: 'linear-gradient(135deg,#2d5a27,#4a8a42)' }
}

function getcultureBg(item: Culture) {
  return getculturBg(item)
}

function vehicleEmoji(type: string) {
  const map: Record<string, string> = { car: '🚗', motorcycle: '🛵', bus: '🚌', van: '🚐', other: '🚙' }
  return map[type] || '🚗'
}

onMounted(async () => {
  await Promise.all([
    destStore.fetchFeatured(),
    destStore.fetchCategories(),
    packageApi.featured().then(r => { featuredPackages.value = r.data.slice(0, 3) }).catch(() => {}),
    cultureApi.list({ status: 'published' }).then(r => { cultures.value = r.data.results.slice(0, 5) }).catch(() => {}),
    culinaryApi.list().then(r => { culinaries.value = r.data.results.slice(0, 4) }).catch(() => {}),
    vehicleApi.list({ available: true }).then(r => { vehicles.value = r.data.results.slice(0, 4) }).catch(() => {}),
  ])
})
</script>

<style scoped>
/* SEARCH */
.home__search-wrap {
  position: fixed; top: 88px; left: 50%; transform: translateX(-50%);
  z-index: 99; width: 440px; max-width: calc(100vw - 40px);
}
.home__search {
  display: flex; align-items: center; gap: 10px;
  background: rgba(255,255,255,0.1);
  border: 1px solid rgba(255,255,255,0.18);
  border-radius: 999px; padding: 11px 20px;
  backdrop-filter: blur(16px);
}
.home__search input {
  flex: 1; background: none; border: none; outline: none;
  color: #fff; font-size: 0.9rem;
}
.home__search input::placeholder { color: rgba(255,255,255,0.4); }

/* HERO */
.hero {
  height: 100vh; min-height: 680px;
  position: relative; display: flex; align-items: flex-end; overflow: hidden;
}
.hero__bg {
  position: absolute; inset: 0;
  background: url('https://images.unsplash.com/photo-1518548419970-58e3b4079ab2?w=1800&q=85') center/cover no-repeat;
}
.hero__bg::after {
  content: ''; position: absolute; inset: 0;
  background: linear-gradient(to bottom,rgba(5,6,8,.25) 0%,rgba(5,6,8,.05) 35%,rgba(5,6,8,.55) 70%,rgba(5,6,8,.96) 100%);
}
.hero__content {
  position: relative; z-index: 2;
  padding: 0 60px 64px; max-width: 860px;
}
.hero__pre { font-size: 1.15rem; color: rgba(255,255,255,.7); margin-bottom: 4px; }
.hero__title {
  font-family: 'Barlow Condensed', sans-serif;
  font-style: italic; font-weight: 800;
  font-size: clamp(3.8rem,8vw,6.8rem);
  line-height: .93; margin-bottom: 18px;
  text-shadow: 0 2px 30px rgba(0,0,0,.5);
}
.hero__desc {
  font-size: .93rem; color: rgba(255,255,255,.7);
  line-height: 1.65; max-width: 500px; margin-bottom: 32px; font-weight: 300;
}
.hero__cta {
  display: inline-flex; align-items: center; gap: 14px;
  background: #fff; color: #050608; border: none;
  border-radius: 999px; padding: 13px 14px 13px 26px;
  font-weight: 700; font-size: 1rem; cursor: pointer;
  transition: all .3s; font-style: italic;
}
.hero__cta:hover { transform: scale(1.03); box-shadow: 0 8px 40px rgba(255,255,255,.15); }
.hero__cta-icon {
  width: 38px; height: 38px; border-radius: 50%; background: #050608;
  display: flex; align-items: center; justify-content: center; font-size: 1.1rem;
}

/* SECTIONS */
.section { padding: 0 0 80px; }
.section--alt { background: var(--dark1); border-top: 1px solid var(--w08); }
.section__footer { display: flex; justify-content: center; margin-top: 40px; }

/* DESTINATION CARDS — grayscale → color on hover */
.destinations__grid { display: flex; gap: 18px; }
.dest-card {
  position: relative; border-radius: 22px; overflow: hidden;
  cursor: pointer; flex: 1; aspect-ratio: 9/14;
  transition: flex .55s cubic-bezier(.4,0,.2,1), box-shadow .4s;
  background: #111; min-width: 0;
}
.dest-card:hover {
  flex: 2.5;
  box-shadow: 0 0 0 2px var(--blue), 0 20px 60px rgba(26,143,255,.28);
}
.dest-card__img {
  position: absolute; inset: 0;
  background-size: cover; background-position: center;
  filter: grayscale(100%) brightness(.65);
  transition: filter .55s ease, transform .6s ease;
  background-color: #1a1e25;
}
.dest-card:hover .dest-card__img {
  filter: grayscale(0%) brightness(.82);
  transform: scale(1.05);
}
.dest-card__overlay {
  position: absolute; inset: 0;
  background: linear-gradient(to bottom,transparent 25%,rgba(5,6,8,.45) 60%,rgba(5,6,8,.9) 100%);
}
.dest-card__info {
  position: absolute; bottom: 0; left: 0; right: 0;
  padding: 24px 20px 22px;
  background: linear-gradient(to top,rgba(8,55,115,.97) 0%,rgba(15,85,165,.9) 55%,transparent 100%);
  transform: translateY(102%);
  transition: transform .45s cubic-bezier(.4,0,.2,1);
}
.dest-card:hover .dest-card__info { transform: translateY(0); }
.dest-card__meta { display: flex; gap: 10px; margin-bottom: 12px; }
.dest-card__meta-item { display: flex; flex-direction: column; gap: 3px; }
.dest-card__meta-label { font-size: .6rem; color: rgba(255,255,255,.5); text-transform: uppercase; letter-spacing: .8px; }
.dest-card__meta-value { font-size: .76rem; font-weight: 600; }
.dest-card__meta-sep { width: 1px; background: rgba(255,255,255,.18); margin: 0 2px; }
.dest-card__coords { font-size: .68rem; color: rgba(255,255,255,.45); margin-bottom: 10px; line-height: 1.6; }
.dest-card__name {
  font-family: 'Bebas Neue', sans-serif;
  font-size: clamp(1.5rem,2.8vw,2.5rem);
  line-height: .95; letter-spacing: 1.5px; margin-bottom: 6px;
}
.dest-card__addr { font-size: .7rem; color: rgba(255,255,255,.55); line-height: 1.5; }
.dest-card__num {
  position: absolute; bottom: 16px; left: 0; right: 0; text-align: center;
  font-family: 'Bebas Neue', sans-serif; font-size: 1.1rem;
  letter-spacing: 3px; color: rgba(255,255,255,.3); transition: opacity .3s;
}
.dest-card:hover .dest-card__num { opacity: 0; }

/* PACKAGES */
.packages__grid { display: grid; grid-template-columns: repeat(3,1fr); gap: 20px; }
.pkg-card__img {
  width: 100%; aspect-ratio: 16/9;
  background-size: cover; background-position: center;
  background-color: var(--dark3); position: relative;
}
.pkg-card__img-overlay { position: absolute; inset: 0; background: linear-gradient(to top,var(--dark2) 0%,transparent 55%); }
.pkg-card__badge { position: absolute; top: 12px; left: 12px; }
.pkg-card__discount {
  position: absolute; top: 12px; right: 12px;
  background: #ef4444; color: #fff; font-size: .68rem; font-weight: 700;
  padding: 4px 10px; border-radius: 999px;
}
.pkg-card__body { padding: 16px 18px; }
.pkg-card__agency { font-size: .7rem; color: var(--blue-b); font-weight: 600; margin-bottom: 5px; }
.pkg-card__name {
  font-family: 'Barlow Condensed', sans-serif;
  font-size: 1.2rem; font-weight: 700; font-style: italic;
  margin-bottom: 10px; line-height: 1.2;
}
.pkg-card__specs { display: flex; gap: 12px; font-size: .72rem; color: var(--w40); }
.pkg-card__footer {
  display: flex; justify-content: space-between; align-items: center;
  padding: 12px 18px; border-top: 1px solid var(--w08);
}
.pkg-card__price { font-family: 'Bebas Neue', sans-serif; font-size: 1.35rem; letter-spacing: .5px; }
.pkg-card__price-sub { font-size: .68rem; color: var(--w40); }

/* CULTURE */
.culture__grid { display: grid; grid-template-columns: 1.3fr 1fr 1fr; grid-template-rows: 1fr 1fr; gap: 16px; height: 520px; }
.culture-card { border-radius: 18px; overflow: hidden; position: relative; cursor: pointer; transition: transform .3s; }
.culture-card--main { grid-row: span 2; }
.culture-card:hover { transform: scale(1.02); }
.culture-card__bg { position: absolute; inset: 0; background-size: cover; background-position: center; filter: brightness(.75); transition: transform .5s, filter .4s; background-color: #1a5f3f; }
.culture-card:hover .culture-card__bg { transform: scale(1.05); filter: brightness(.9); }
.culture-card__overlay { position: absolute; inset: 0; background: linear-gradient(to top,rgba(5,6,8,.88) 0%,transparent 50%); }
.culture-card__body { position: absolute; bottom: 0; left: 0; right: 0; padding: 18px; display: flex; flex-direction: column; gap: 8px; }
.culture-card__name { font-family: 'Barlow Condensed', sans-serif; font-size: 1.1rem; font-style: italic; font-weight: 700; line-height: 1.2; }

/* CULINARY */
.culinary__grid { display: grid; grid-template-columns: repeat(4,1fr); gap: 16px; }
.culinary-card__img {
  width: 100%; aspect-ratio: 1; background-size: cover; background-position: center;
  display: flex; align-items: center; justify-content: center;
}
.culinary-card__emoji { font-size: 2.5rem; }
.culinary-card__body { padding: 12px 14px; }
.culinary-card__name { font-family: 'Barlow Condensed', sans-serif; font-size: 1rem; font-weight: 700; margin-bottom: 3px; }
.culinary-card__price { font-size: .76rem; color: var(--blue-b); font-weight: 600; }

/* RENTAL */
.rental__grid { display: grid; grid-template-columns: repeat(4,1fr); gap: 16px; }
.rental-card__img {
  width: 100%; aspect-ratio: 16/9;
  background-size: cover; background-position: center;
  display: flex; align-items: center; justify-content: center; font-size: 2.8rem;
  filter: grayscale(40%); transition: filter .3s; background-color: var(--dark3);
}
.rental-card:hover .rental-card__img { filter: grayscale(0%); }
.rental-card__body { padding: 12px 14px; }
.rental-card__type { margin-bottom: 5px; display: inline-flex; }
.rental-card__name { font-family: 'Barlow Condensed', sans-serif; font-size: 1rem; font-weight: 700; margin-bottom: 5px; }
.rental-card__price { font-size: .76rem; color: var(--w40); }
.rental-card__price strong { color: #fff; font-size: .9rem; }

/* AI BANNER */
.section--ai { background: linear-gradient(135deg, #050e1a 0%, #0a2440 100%); border-top: 1px solid var(--w08); }
.ai-banner { display: grid; grid-template-columns: 1fr 1fr; gap: 80px; align-items: center; padding: 80px 0; }
.ai-banner__tag {
  display: inline-flex; align-items: center; gap: 6px;
  background: rgba(26,143,255,.15); border: 1px solid rgba(26,143,255,.25);
  padding: 6px 14px; border-radius: 999px;
  color: var(--blue-b); font-size: .78rem; font-weight: 600; margin-bottom: 18px;
}
.ai-banner__title {
  font-family: 'Barlow Condensed', sans-serif; font-style: italic; font-weight: 800;
  font-size: clamp(2rem,4vw,3rem); line-height: 1.1; margin-bottom: 16px;
}
.ai-banner__title em { color: var(--blue-b); }
.ai-banner__desc { font-size: .95rem; color: var(--w70); line-height: 1.7; margin-bottom: 28px; font-weight: 300; }
.ai-banner__card {
  background: rgba(255,255,255,.06); border: 1px solid rgba(255,255,255,.1);
  border-radius: 20px; padding: 28px;
}
.ai-banner__card-title { font-weight: 700; margin-bottom: 18px; font-size: 1rem; }
.ai-chips { display: flex; flex-wrap: wrap; gap: 8px; }
.ai-chip {
  padding: 6px 14px; border-radius: 999px;
  border: 1.5px solid rgba(255,255,255,.15); background: none;
  color: rgba(255,255,255,.65); font-size: .78rem; font-weight: 500;
  cursor: pointer; transition: all .25s;
}
.ai-chip:hover, .ai-chip--active {
  background: var(--blue); border-color: var(--blue); color: #fff;
}

@media (max-width: 900px) {
  .packages__grid, .culture__grid { grid-template-columns: 1fr 1fr; }
  .culture__grid { height: auto; }
  .culture-card--main { grid-row: span 1; }
  .culinary__grid, .rental__grid { grid-template-columns: 1fr 1fr; }
  .ai-banner { grid-template-columns: 1fr; gap: 40px; padding: 60px 0; }
  .hero__content { padding: 0 24px 48px; }
  .destinations__grid { flex-direction: column; }
  .dest-card { aspect-ratio: 16/9; }
}
</style>
