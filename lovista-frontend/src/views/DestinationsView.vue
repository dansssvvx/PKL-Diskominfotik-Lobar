<template>
  <div class="destinations-view">
    <TheNavbar v-if="showNav" />
    
    <div class="container" style="padding-top: 100px; padding-bottom: 80px;">
      
      <!-- Contained Banner (Ecommerce Style) -->
      <div class="collection-banner">
        <div class="collection-banner__bg"></div>
        <div class="collection-banner__content">
          <span class="collection-banner__label">- Collections</span>
          <h2 class="font-display">Explore The Various Destinations of West Lombok</h2>
          <p>Don't miss out on exploring these beautiful places, you'll not be let down.</p>
        </div>
      </div>

      <!-- Breadcrumbs & Title -->
      <div class="page-header mt-5">
        <div class="breadcrumb">Home &nbsp;•&nbsp; Destinations Collection</div>
        <h1 class="page-title font-display">Destinations Collection</h1>
      </div>

      <!-- Two-Column Shop Layout -->
      <div class="shop-layout mt-4">
        
        <!-- Sidebar Filters -->
        <aside class="shop-sidebar">
          
          <!-- Search Filter -->
          <div class="filter-section">
            <div class="filter-header">
              <span class="filter-title">Search</span>
            </div>
            <input 
              v-model="filters.search" 
              type="text" 
              class="form-input search-input" 
              placeholder="Search..." 
              @keyup.enter="handleFilterChange" 
            />
          </div>

          <!-- Category Filter -->
          <div class="filter-section mt-4">
            <div class="filter-header">
              <span class="filter-title">Category</span>
              <button class="btn-reset" @click="resetCategory">Reset</button>
            </div>
            <div class="filter-list">
              <label class="custom-radio" v-for="cat in categories" :key="cat.id">
                <input 
                  type="radio" 
                  name="category" 
                  :value="cat.id" 
                  v-model="filters.category" 
                  @change="handleFilterChange" 
                />
                <span class="radio-mark"></span>
                <span class="label-text">{{ cat.name }}</span>
              </label>
            </div>
          </div>

        </aside>

        <!-- Main Content Area -->
        <main class="shop-main">
          
          <div v-if="loading" class="page-loader" style="min-height: 400px; display:flex; flex-direction:column; align-items:center; justify-content:center;">
            <div class="spinner"></div>
            <p style="margin-top: 16px; color: var(--w40);">Loading destinations...</p>
          </div>
          
          <div v-else-if="destinations.length === 0" class="empty-state" style="min-height: 400px; display:flex; flex-direction:column; align-items:center; justify-content:center;">
            <div class="icon" style="font-size: 3rem; margin-bottom: 16px;">🏝️</div>
            <h3>No destinations found</h3>
            <p style="color: var(--w40);">Try adjusting your search or category filters</p>
          </div>

          <!-- Grid -->
          <div v-else>
            <div class="grid grid-3">
              <router-link :to="'/destinations/' + dest.slug" class="product-card" v-for="dest in destinations" :key="dest.id">
                <div class="product-card__img-wrapper">
                  <img :src="getPhotoUrl(dest.main_image)" :alt="dest.name" class="product-card__img" loading="lazy" />
                </div>
                <div class="product-card__content">
                  <h3 class="product-card__title">{{ dest.name }}</h3>
                  <p class="product-card__desc">{{ dest.category?.name || dest.category_name || 'Destination' }} • {{ dest.district || 'Lombok Barat' }}</p>
                  
                  <div class="product-card__footer">
                    <div class="price-wrap">
                      <span class="price val text-success" v-if="Number(dest.ticket_price) <= 0">FREE</span>
                      <span class="price val" v-else>Rp {{ formatNumber(dest.ticket_price) }}</span>
                    </div>
                    <div class="actions">
                      <button class="icon-btn" title="Add to Wishlist">♡</button>
                      <button class="icon-btn" title="View Details">→</button>
                    </div>
                  </div>
                </div>
              </router-link>
            </div>
            
            <!-- Pagination -->
            <div class="pagination mt-5">
              <button class="btn-pagination" :disabled="filters.page === 1" @click="changePage(-1)">
                &larr; Prev
              </button>
              <span class="page-info">Page {{ filters.page }}</span>
              <button class="btn-pagination" @click="changePage(1)">
                Next &rarr;
              </button>
            </div>
          </div>

        </main>
      </div>

    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { destinationApi } from '@/api'
import type { TourismDestination, DestinationCategory } from '@/types'
import TheNavbar from '@/components/layout/TheNavbar.vue'

const showNav = true
const loading = ref(false)
const destinations = ref<TourismDestination[]>([])
const categories = ref<DestinationCategory[]>([])

const filters = ref({ 
  search: '', 
  category: '',
  page: 1 
})

async function fetchCategories() {
  try {
    const { data } = await destinationApi.categories()
    categories.value = data
  } catch (error) {
    console.error('Failed to fetch categories', error)
  }
}

async function fetchData() {
  loading.value = true
  try {
    const { data } = await destinationApi.list(filters.value as any)
    destinations.value = Array.isArray(data) ? data : (data as any).results || []
  } catch (error) {
    console.error('Failed to fetch destinations', error)
  } finally {
    loading.value = false
  }
}

function handleFilterChange() {
  filters.value.page = 1
  fetchData()
}

function resetCategory() {
  filters.value.category = ''
  handleFilterChange()
}

function changePage(step: number) {
  filters.value.page += step
  fetchData()
  window.scrollTo({ top: 0, behavior: 'smooth' })
}

const getPhotoUrl = (path?: string | null) => {
  if (!path) return '/Logo.png'
  if (path.startsWith('http')) return path
  return `http://127.0.0.1:8000${path}`
}

const formatNumber = (num: number | string) => {
  return new Intl.NumberFormat('id-ID').format(Number(num))
}

onMounted(() => {
  fetchCategories()
  fetchData()
})
</script>

<style scoped>
/* Typography & Common Spacing */
.mt-4 { margin-top: 24px; }
.mt-5 { margin-top: 40px; }
.font-display { font-family: 'Barlow Condensed', sans-serif; font-style: italic; }

/* ─── COLLECTION BANNER ─── */
.collection-banner {
  position: relative;
  border-radius: 24px;
  overflow: hidden;
  display: flex;
  align-items: center;
  justify-content: flex-end;
  min-height: 280px;
  background: var(--dark2);
}
.collection-banner__bg {
  position: absolute;
  inset: 0;
  background-image: url('https://images.unsplash.com/photo-1544644181-1484b3fdfc62?auto=format&fit=crop&q=80&w=1200');
  background-size: cover;
  background-position: center;
  opacity: 0.6;
  mask-image: linear-gradient(to right, rgba(0,0,0,1) 30%, rgba(0,0,0,0) 100%);
  -webkit-mask-image: linear-gradient(to right, rgba(0,0,0,1) 30%, rgba(0,0,0,0) 100%);
}
.collection-banner__content {
  position: relative;
  z-index: 2;
  max-width: 500px;
  padding: 40px 60px;
  text-align: left;
  background: linear-gradient(to right, transparent, var(--dark2) 40%);
}
.collection-banner__label {
  font-size: 0.8rem;
  color: var(--w70);
  text-transform: uppercase;
  letter-spacing: 2px;
  display: block;
  margin-bottom: 12px;
}
.collection-banner__content h2 {
  font-size: 2.8rem;
  font-weight: 700;
  color: #fff;
  line-height: 1.1;
  margin-bottom: 16px;
}
.collection-banner__content p {
  font-size: 1rem;
  color: var(--w40);
  line-height: 1.5;
}

/* ─── PAGE HEADER ─── */
.breadcrumb {
  font-size: 0.8rem;
  color: var(--w40);
  margin-bottom: 8px;
  text-transform: uppercase;
  letter-spacing: 1px;
}
.page-title {
  font-size: 2.5rem;
  font-weight: 800;
  color: #fff;
  margin: 0;
}

/* ─── SHOP LAYOUT ─── */
.shop-layout {
  display: flex;
  gap: 40px;
  align-items: flex-start;
}
.shop-sidebar {
  width: 240px;
  flex-shrink: 0;
}
.shop-main {
  flex: 1;
  min-width: 0;
}

@media (max-width: 900px) {
  .shop-layout { flex-direction: column; }
  .shop-sidebar { width: 100%; }
}

/* ─── SIDEBAR FILTERS ─── */
.filter-section {
  background: transparent;
}
.filter-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
  padding-bottom: 8px;
  border-bottom: 1px solid var(--w08);
}
.filter-title {
  font-weight: 600;
  font-size: 0.95rem;
  color: #fff;
}
.btn-reset {
  background: none; border: none;
  font-size: 0.75rem; color: var(--w40);
  cursor: pointer; transition: color 0.2s;
}
.btn-reset:hover { color: #fff; }

.search-input {
  width: 100%;
  background: var(--dark3);
  border: 1px solid var(--w08);
  border-radius: 8px;
}

.filter-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

/* Custom Radio styles */
.custom-radio {
  display: flex;
  align-items: center;
  gap: 12px;
  cursor: pointer;
  user-select: none;
}
.custom-radio input {
  position: absolute; opacity: 0; cursor: pointer;
}
.radio-mark {
  height: 18px; width: 18px;
  background-color: transparent;
  border: 1px solid var(--w15);
  border-radius: 50%;
  display: flex; align-items: center; justify-content: center;
  transition: all 0.2s ease;
}
.custom-radio:hover input ~ .radio-mark {
  border-color: var(--w40);
}
.custom-radio input:checked ~ .radio-mark {
  border-color: #fff;
}
.radio-mark:after {
  content: "";
  display: none;
  width: 10px; height: 10px;
  border-radius: 50%;
  background: #fff;
}
.custom-radio input:checked ~ .radio-mark:after {
  display: block;
}
.label-text {
  font-size: 0.9rem;
  color: var(--w70);
  transition: color 0.2s;
}
.custom-radio input:checked ~ .label-text {
  color: #fff;
  font-weight: 500;
}

/* ─── PRODUCT CARDS ─── */
.grid-3 {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 24px;
}
@media (max-width: 1100px) { .grid-3 { grid-template-columns: repeat(2, 1fr); } }
@media (max-width: 600px) { .grid-3 { grid-template-columns: 1fr; } }

.product-card {
  display: flex;
  flex-direction: column;
  background: transparent;
  text-decoration: none;
  transition: transform 0.3s ease;
}
.product-card:hover {
  transform: translateY(-4px);
}
.product-card__img-wrapper {
  width: 100%;
  aspect-ratio: 4/5;
  border-radius: 16px;
  overflow: hidden;
  background: var(--dark3);
  margin-bottom: 16px;
  border: 1px solid var(--w04);
}
.product-card__img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: transform 0.6s ease;
}
.product-card:hover .product-card__img {
  transform: scale(1.05);
}
.product-card__content {
  display: flex;
  flex-direction: column;
  padding: 0 4px;
}
.product-card__title {
  font-size: 1.1rem;
  font-weight: 600;
  color: #fff;
  margin-bottom: 4px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}
.product-card__desc {
  font-size: 0.8rem;
  color: var(--w40);
  margin-bottom: 16px;
}
.product-card__footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.price.val {
  font-size: 1.1rem;
  font-weight: 700;
  color: #fff;
}
.price.text-success { color: var(--success); }

.actions {
  display: flex;
  gap: 8px;
}
.icon-btn {
  background: transparent;
  border: 1px solid var(--w15);
  color: var(--w70);
  width: 32px;
  height: 32px;
  border-radius: 50%;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  font-size: 1rem;
  cursor: pointer;
  transition: all 0.2s ease;
}
.icon-btn:hover {
  background: #fff;
  color: var(--black);
  border-color: #fff;
}

/* ─── PAGINATION ─── */
.pagination {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 20px;
  padding-top: 24px;
  border-top: 1px solid var(--w08);
}
.btn-pagination {
  background: transparent;
  border: 1px solid var(--w15);
  color: #fff;
  padding: 8px 20px;
  border-radius: 99px;
  font-size: 0.85rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
}
.btn-pagination:hover:not(:disabled) {
  background: #fff;
  color: var(--black);
  border-color: #fff;
}
.btn-pagination:disabled {
  opacity: 0.3;
  cursor: not-allowed;
}
.page-info {
  font-family: 'Barlow Condensed', sans-serif;
  font-size: 1.2rem;
  font-weight: 600;
  color: var(--w70);
}
</style>