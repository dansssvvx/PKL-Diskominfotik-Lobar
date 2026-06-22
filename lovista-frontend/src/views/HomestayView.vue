<template>
  <div class="homestay-view">
    <TheNavbar v-if="showNav" />
    
    <div class="container" style="padding-top: 100px; padding-bottom: 80px;">
      
      <!-- Contained Banner -->
      <div class="collection-banner">
        <div class="collection-banner__bg" style="background-image: url('https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&q=80&w=1200');"></div>
        <div class="collection-banner__content">
          <span class="collection-banner__label">- Collections</span>
          <h2 class="font-display">Explore Homestays</h2>
          <p>Find a cozy and comfortable place to stay during your visit.</p>
        </div>
      </div>

      <!-- Breadcrumbs & Title -->
      <div class="page-header mt-5">
        <div class="breadcrumb">Home &nbsp;•&nbsp; Homestays</div>
        <h1 class="page-title font-display">Homestays</h1>
      </div>

      <!-- Two-Column Shop Layout -->
      <div class="shop-layout mt-4">
        
        <!-- Sidebar Filters -->
        <aside class="shop-sidebar">
          <div class="filter-section">
            <div class="filter-header">
              <span class="filter-title">Search District</span>
            </div>
            <input 
              v-model="filters.district" 
              type="text" 
              class="form-input search-input" 
              placeholder="e.g. Senggigi, Narmada..." 
              @keyup.enter="handleFilterChange" 
            />
          </div>
        </aside>

        <!-- Main Content Area -->
        <main class="shop-main">
          
          <div v-if="loading" class="page-loader" style="min-height: 400px; display:flex; flex-direction:column; align-items:center; justify-content:center;">
            <div class="spinner"></div>
            <p style="margin-top: 16px; color: var(--w40);">Loading homestays...</p>
          </div>
          
          <div v-else-if="items.length === 0" class="empty-state" style="min-height: 400px; display:flex; flex-direction:column; align-items:center; justify-content:center;">
            <div class="icon" style="font-size: 3rem; margin-bottom: 16px;">🏡</div>
            <h3>No homestays found</h3>
            <p style="color: var(--w40);">Try adjusting your search district</p>
          </div>

          <!-- Grid -->
          <div v-else>
            <div class="grid grid-3">
              <router-link :to="'/homestays/' + item.id" class="product-card" v-for="item in items" :key="item.id">
                <div class="product-card__img-wrapper">
                  <img :src="getPhotoUrl((item as any).main_image || (item as any).image)" :alt="item.name" class="product-card__img" loading="lazy" />
                </div>
                <div class="product-card__content">
                  <h3 class="product-card__title">{{ item.name }}</h3>
                  <p class="product-card__desc">{{ (item as any).district || 'Lombok Barat' }} • {{ item.address }}</p>
                  
                  <div class="product-card__footer">
                    <div class="price-wrap">
                      <span class="price val">Rp {{ formatNumber((item as any).price_per_night || 0) }}<span style="font-size: 0.7rem; font-weight: normal; color: var(--w40)">/night</span></span>
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
import { homestayApi } from '@/api'
import type { Homestay } from '@/types'
import TheNavbar from '@/components/layout/TheNavbar.vue'

const showNav = true
const loading = ref(false)
const items = ref<Homestay[]>([])

const filters = ref({ 
  district: '', 
  page: 1 
})

async function fetchData() {
  loading.value = true
  try {
    const { data } = await homestayApi.list(filters.value as any)
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