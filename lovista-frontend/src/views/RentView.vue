<template>
  <div class="rent-view">
    <TheNavbar v-if="showNav" />
    
    <div class="container" style="padding-top: 100px; padding-bottom: 80px;">
      
      <!-- Contained Banner -->
      <div class="collection-banner">
        <div class="collection-banner__bg" style="background-image: url('https://images.unsplash.com/photo-1549317661-bd32c8ce0db2?auto=format&fit=crop&q=80&w=1200');"></div>
        <div class="collection-banner__content">
          <span class="collection-banner__label">- Rentals</span>
          <h2 class="font-display">Explore Vehicle Rentals</h2>
          <p>Find the perfect vehicle to explore West Lombok at your own pace.</p>
        </div>
      </div>

      <!-- Breadcrumbs & Title -->
      <div class="page-header mt-5">
        <div class="breadcrumb">Home &nbsp;•&nbsp; Vehicle Rentals</div>
        <h1 class="page-title font-display">Vehicle Rentals</h1>
      </div>

      <!-- Two-Column Shop Layout -->
      <div class="shop-layout mt-4">
        
        <!-- Sidebar Filters -->
        <aside class="shop-sidebar">
          
          <!-- Category Filter -->
          <div class="filter-section">
            <div class="filter-header">
              <span class="filter-title">Vehicle Type</span>
              <button class="btn-reset" @click="resetType">Reset</button>
            </div>
            <div class="filter-list">
              <label class="custom-radio" v-for="t in types" :key="t.value">
                <input 
                  type="radio" 
                  name="type" 
                  :value="t.value" 
                  v-model="filters.type" 
                  @change="handleFilterChange" 
                />
                <span class="radio-mark"></span>
                <span class="label-text">{{ t.label }}</span>
              </label>
            </div>
          </div>

        </aside>

        <!-- Main Content Area -->
        <main class="shop-main">
          
          <div v-if="loading" class="page-loader" style="min-height: 400px; display:flex; flex-direction:column; align-items:center; justify-content:center;">
            <div class="spinner"></div>
            <p style="margin-top: 16px; color: var(--w40);">Loading vehicles...</p>
          </div>
          
          <div v-else-if="items.length === 0" class="empty-state" style="min-height: 400px; display:flex; flex-direction:column; align-items:center; justify-content:center;">
            <div class="icon" style="font-size: 3rem; margin-bottom: 16px;">🚗</div>
            <h3>No vehicles found</h3>
            <p style="color: var(--w40);">Try adjusting your filters</p>
          </div>

          <!-- Grid -->
          <div v-else>
            <div class="grid grid-3">
              <router-link :to="'/rent/' + item.id" class="product-card" v-for="item in items" :key="item.id">
                <div class="product-card__img-wrapper">
                  <img :src="getPhotoUrl(item.image)" :alt="item.brand + ' ' + item.model" class="product-card__img" loading="lazy" />
                </div>
                <div class="product-card__content">
                  <h3 class="product-card__title">{{ item.brand }} {{ item.model }}</h3>
                  <p class="product-card__desc">{{ (item.type || '').toUpperCase() }} • Capacity: {{ item.capacity || '-' }}</p>
                  
                  <div class="product-card__footer">
                    <div class="price-wrap">
                      <span class="price val">Rp {{ formatNumber(item.daily_rate) }}<span style="font-size: 0.7rem; font-weight: normal; color: var(--w40)">/day</span></span>
                    </div>
                    <div class="actions">
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
import { vehicleApi } from '@/api'
import type { Vehicle } from '@/types'
import TheNavbar from '@/components/layout/TheNavbar.vue'

const showNav = true
const loading = ref(false)
const items = ref<Vehicle[]>([])

const types = [
  { label: 'Car', value: 'car' },
  { label: 'Motorcycle', value: 'motorcycle' },
  { label: 'Bus', value: 'bus' },
  { label: 'Van', value: 'van' },
]

const filters = ref({ 
  type: '', 
  page: 1 
})

async function fetchData() {
  loading.value = true
  try {
    const { data } = await vehicleApi.list(filters.value as any)
    items.value = Array.isArray(data) ? data : (data as any).results || []
  } catch (error) {
    console.error('Failed to fetch', error)
  } finally {
    loading.value = false
  }
}

function handleFilterChange() {
  filters.value.page = 1
  fetchData()
}

function resetType() {
  filters.value.type = ''
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
  fetchData()
})
</script>

<style scoped>
@import '@/assets/styles/shop-layout.css';
</style>