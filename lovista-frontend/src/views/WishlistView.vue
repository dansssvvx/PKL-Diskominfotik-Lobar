<template>
  <div class="page-wrapper">
    <TheNavbar />
    
    <div class="wishlist-container container">
      <div class="page-header">
        <h1 class="page-title">My Wishlist</h1>
        <p class="page-subtitle">Destinasi wisata yang Anda simpan untuk dikunjungi nanti.</p>
      </div>

      <div v-if="loading" class="loader-wrap">
        <div class="spinner"></div>
        <p>Memuat wishlist...</p>
      </div>

      <div v-else-if="items.length === 0" class="empty-state">
        <div class="empty-icon">❤️</div>
        <h2>Wishlist masih kosong</h2>
        <p>Anda belum menyimpan destinasi wisata apapun. Mulai jelajahi keindahan Lombok Barat sekarang!</p>
        <router-link to="/destinations" class="btn btn-primary mt-4">Jelajahi Destinasi</router-link>
      </div>

      <div v-else class="wishlist-grid">
        <div v-for="item in items" :key="item.id" class="card dest-card">
          <div class="dest-img-wrap">
            <img :src="getImgUrl(item.destination.main_image)" :alt="item.destination.name" class="dest-img" />
            <div class="dest-badge">{{ item.destination.category?.name || 'Destination' }}</div>
            <button class="btn-remove" @click.prevent="removeFromWishlist(item.destination.slug)" title="Hapus dari wishlist">
              ✖
            </button>
          </div>
          <div class="dest-content">
            <h3 class="dest-name">{{ item.destination.name }}</h3>
            <div class="dest-meta">
              <span class="meta-item">📍 {{ item.destination.village }}, {{ item.destination.district }}</span>
            </div>
            <p class="dest-desc">{{ truncate(item.destination.description, 100) }}</p>
            <div class="dest-footer">
              <router-link :to="`/destinations/${item.destination.slug}`" class="btn btn-ghost btn-sm">
                Lihat Detail
              </router-link>
            </div>
          </div>
        </div>
      </div>
    </div>

    <TheFooter />
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import TheNavbar from '@/components/layout/TheNavbar.vue'
import TheFooter from '@/components/layout/TheFooter.vue'
import { wishlistApi, destinationApi } from '@/api'
import Swal from 'sweetalert2'

const BASE_URL = 'http://127.0.0.1:8000'
const loading = ref(true)
const items = ref<any[]>([])

async function fetchWishlist() {
  loading.value = true
  try {
    const res = await wishlistApi.list()
    // Depending on pagination, extract results
    items.value = res.data.results || res.data
  } catch (err) {
    console.error('Failed to fetch wishlist', err)
  } finally {
    loading.value = false
  }
}

async function removeFromWishlist(slug: string) {
  try {
    await destinationApi.toggleWishlist(slug)
    // Remove from local list to update UI instantly
    items.value = items.value.filter(item => item.destination.slug !== slug)
    Swal.fire({
      toast: true,
      position: 'top-end',
      icon: 'success',
      title: 'Dihapus dari wishlist',
      showConfirmButton: false,
      timer: 2000
    })
  } catch (err) {
    Swal.fire('Error', 'Gagal menghapus dari wishlist', 'error')
  }
}

function getImgUrl(path: string | null) {
  if (!path) return '/Logo.png'
  if (path.startsWith('http')) return path
  return `${BASE_URL}${path}`
}

function truncate(text: string, length: number) {
  if (!text) return ''
  return text.length > length ? text.substring(0, length) + '...' : text
}

onMounted(() => {
  fetchWishlist()
})
</script>

<style scoped>
.page-wrapper { min-height: 100vh; display: flex; flex-direction: column; }
.wishlist-container { padding-top: 120px; padding-bottom: 80px; flex: 1; }

.page-header { margin-bottom: 40px; text-align: center; }
.page-title { font-family: 'Barlow Condensed', sans-serif; font-size: 2.8rem; font-style: italic; font-weight: 800; color: var(--w90); margin-bottom: 8px; }
.page-subtitle { color: var(--w40); font-size: 1.1rem; }

.loader-wrap { text-align: center; padding: 60px 0; color: var(--w40); }
.spinner { width: 40px; height: 40px; border: 4px solid var(--w08); border-top-color: var(--blue); border-radius: 50%; animation: spin 1s linear infinite; margin: 0 auto 16px; }
@keyframes spin { to { transform: rotate(360deg); } }

.empty-state { text-align: center; padding: 80px 20px; background: var(--w04); border-radius: 24px; border: 1px dashed var(--w08); }
.empty-icon { font-size: 4rem; margin-bottom: 16px; filter: grayscale(1) opacity(0.5); transition: .3s; }
.empty-state:hover .empty-icon { filter: grayscale(0) opacity(1); transform: scale(1.1); }
.empty-state h2 { font-family: 'Barlow Condensed', sans-serif; font-size: 2rem; font-weight: 700; margin-bottom: 8px; }
.empty-state p { color: var(--w40); max-width: 400px; margin: 0 auto; }
.mt-4 { margin-top: 24px; }

.wishlist-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); gap: 24px; }

.dest-card { display: flex; flex-direction: column; overflow: hidden; transition: transform 0.3s cubic-bezier(0.4, 0, 0.2, 1); }
.dest-card:hover { transform: translateY(-6px); border-color: var(--w20); }
.dest-img-wrap { position: relative; height: 200px; overflow: hidden; }
.dest-img { width: 100%; height: 100%; object-fit: cover; transition: transform .5s; }
.dest-card:hover .dest-img { transform: scale(1.05); }
.dest-badge { position: absolute; top: 12px; left: 12px; background: rgba(0,0,0,0.6); backdrop-filter: blur(4px); color: #fff; padding: 4px 12px; border-radius: 20px; font-size: 0.75rem; font-weight: 600; text-transform: uppercase; letter-spacing: 1px; }

.btn-remove { position: absolute; top: 12px; right: 12px; width: 32px; height: 32px; border-radius: 50%; background: rgba(220, 38, 38, 0.8); backdrop-filter: blur(4px); color: white; border: none; font-size: 0.8rem; cursor: pointer; display: flex; align-items: center; justify-content: center; opacity: 0; transform: translateY(-10px); transition: all 0.3s; }
.dest-card:hover .btn-remove { opacity: 1; transform: translateY(0); }
.btn-remove:hover { background: rgba(220, 38, 38, 1); transform: scale(1.1) !important; }

.dest-content { padding: 20px; display: flex; flex-direction: column; flex: 1; }
.dest-name { font-family: 'Barlow Condensed', sans-serif; font-size: 1.4rem; font-style: italic; font-weight: 700; margin-bottom: 8px; line-height: 1.2; }
.dest-meta { display: flex; gap: 12px; margin-bottom: 12px; font-size: 0.8rem; color: var(--w40); }
.dest-desc { font-size: 0.9rem; color: var(--w60); line-height: 1.5; margin-bottom: 20px; flex: 1; }
.dest-footer { margin-top: auto; display: flex; justify-content: flex-end; }
</style>
