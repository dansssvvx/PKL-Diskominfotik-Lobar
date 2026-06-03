<template>
  <div class="culinary-detail-view">
    <TheNavbar />

    <!-- Hero Section -->
    <header class="culinary-hero" v-if="culinary">
      <div class="culinary-hero__bg" :style="{ backgroundImage: `url('${mainImage}')` }"></div>
      <div class="culinary-hero__overlay"></div>

      <div class="container culinary-hero__content">
        <RouterLink to="/" class="btn-back">← Back to Home</RouterLink>
        <div class="badges">
          <span class="badge badge-blue" v-if="culinary.is_verified">✓ Verified</span>
          <span class="badge badge-dark" v-if="culinary.is_standalone">Independent Resto</span>
        </div>
        <h1 class="font-display culinary-title">{{ culinary.name }}</h1>
        <div class="culinary-meta">
          <span class="meta-item">💰 {{ culinary.price_range || 'Price varies' }}</span>
          <span class="meta-item" v-if="culinary.contact">📞 {{ culinary.contact }}</span>
        </div>
      </div>
    </header>

    <!-- Main Content -->
    <main class="container section" v-if="culinary">
      <div class="culinary-content-layout">
        
        <!-- Left: Description -->
        <div class="culinary-main-info">
          <h2>About this Culinary</h2>
          <div class="culinary-description">
            <p v-if="culinary.description">{{ culinary.description }}</p>
            <p v-else class="text-w40">No description available for this culinary item.</p>
          </div>

          <!-- Gallery inserted below description -->
          <div class="culinary-gallery mt-5" v-if="allImages.length > 1">
            <h3>Gallery</h3>
            <div class="gallery-grid">
              <img 
                v-for="(img, idx) in allImages" 
                :key="idx" 
                :src="getPhotoUrl(img)" 
                :alt="`Gallery ${idx+1}`" 
                class="gallery-img" 
                @click="openModal(img)"
              />
            </div>
          </div>
        </div>

        <!-- Right: Location Info -->
        <aside class="culinary-sidebar">
          <h3>Location</h3>
          <div class="location-card">
            <div v-if="culinary.latitude && culinary.longitude" class="coordinates">
              <p><strong>Lat:</strong> {{ culinary.latitude }}</p>
              <p><strong>Lng:</strong> {{ culinary.longitude }}</p>
              <a 
                :href="`https://www.google.com/maps/search/?api=1&query=${culinary.latitude},${culinary.longitude}`" 
                target="_blank" 
                class="btn btn-blue-outline full-width mt-4"
              >
                Open in Google Maps
              </a>
            </div>
            <div v-else>
              <p class="text-w40">Exact coordinates not available.</p>
            </div>
          </div>
        </aside>

      </div>
    </main>

    <!-- Loading State -->
    <div class="container section loading-state" v-else-if="loading">
      <p>Loading culinary details...</p>
    </div>

    <!-- Error State -->
    <div class="container section error-state" v-else>
      <h2 class="text-red">Failed to load culinary details.</h2>
      <p>It might have been removed or doesn't exist.</p>
      <RouterLink to="/" class="btn btn-primary mt-4">Return Home</RouterLink>
    </div>

    <!-- Image Modal (Placed outside v-if chain) -->
    <div class="image-modal" v-if="selectedImage" @click="closeModal">
      <button class="image-modal__close" @click.stop="closeModal">×</button>
      <img :src="selectedImage" alt="Enlarged view" class="image-modal__img" @click.stop />
    </div>

    <TheFooter />
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { useRoute } from 'vue-router'
import { culinaryApi } from '@/api'
import type { Culinary } from '@/types'
import TheNavbar from '@/components/layout/TheNavbar.vue'
import TheFooter from '@/components/layout/TheFooter.vue'

const route = useRoute()
const culinary = ref<Culinary | null>(null)
const loading = ref(true)
const errorMessage = ref<string>('')
const rawError = ref<any>(null)

const selectedImage = ref<string | null>(null)

const openModal = (img: string) => {
  selectedImage.value = getPhotoUrl(img)
}

const closeModal = () => {
  selectedImage.value = null
}

const getPhotoUrl = (path?: string) => {
  if (!path) return '/Logo.png'
  if (path.startsWith('http')) return path
  return `http://127.0.0.1:8000${path}`
}

const allImages = computed(() => {
  if (!culinary.value || !culinary.value.images) return []
  
  const imgs = culinary.value.images
  let imgList: string[] = []

  if (typeof imgs === 'string') {
    try {
      const parsed = JSON.parse(imgs)
      if (Array.isArray(parsed)) {
        imgList = parsed
      } else {
        imgList = [imgs]
      }
    } catch {
      imgList = [imgs]
    }
  } else if ((imgs as any).Images && Array.isArray((imgs as any).Images)) {
    imgList = (imgs as any).Images
  } else if ((imgs as any).images && Array.isArray((imgs as any).images)) {
    imgList = (imgs as any).images
  } else if (Array.isArray(imgs)) {
    imgList = imgs
  }

  return imgList.map((img: any) => {
    if (typeof img === 'string') return img
    return img.image || img.image_url || '/Logo.png'
  })
})

const mainImage = computed(() => {
  if (allImages.value.length > 0) {
    return getPhotoUrl(allImages.value[0])
  }
  return '/Logo.png'
})

onMounted(async () => {
  loading.value = true
  try {
    const id = Number(route.params.id)
    const res = await culinaryApi.detail(id)
    culinary.value = res.data
  } catch (error: any) {
    console.error('Error fetching culinary details:', error)
    if (error.response) {
      rawError.value = JSON.stringify({ status: error.response.status, data: error.response.data }, null, 2)
    } else {
      rawError.value = error.message || String(error)
    }
  } finally {
    loading.value = false
  }
})
</script>

<style scoped>
.culinary-detail-view {
  min-height: 100vh;
  background-color: var(--black);
}

.culinary-hero {
  position: relative;
  height: 50vh;
  min-height: 400px;
  display: flex;
  align-items: flex-end;
  padding-bottom: 60px;
  margin-top: 80px;
}

.culinary-hero__bg {
  position: absolute;
  top: 0; left: 0; right: 0; bottom: 0;
  background-size: cover;
  background-position: center;
  z-index: 0;
}

.culinary-hero__overlay {
  position: absolute;
  top: 0; left: 0; right: 0; bottom: 0;
  background: linear-gradient(to top, var(--black) 0%, rgba(5,6,8,0.5) 60%, rgba(5,6,8,0.2) 100%);
  z-index: 1;
}

.culinary-hero__content {
  position: relative;
  z-index: 2;
  width: 100%;
}

.btn-back {
  display: inline-block;
  color: var(--w70);
  font-size: 0.9rem;
  margin-bottom: 24px;
  transition: color 0.3s;
}
.btn-back:hover {
  color: var(--white);
}

.badges {
  display: flex;
  gap: 10px;
  margin-bottom: 16px;
}

.badge-blue {
  background: var(--blue);
  color: white;
  padding: 4px 12px;
  border-radius: 99px;
  font-size: 0.75rem;
  font-weight: bold;
}

.badge-dark {
  background: var(--w20);
  color: white;
  padding: 4px 12px;
  border-radius: 99px;
  font-size: 0.75rem;
  font-weight: bold;
}

.culinary-title {
  font-size: 4rem;
  line-height: 1.1;
  margin-bottom: 16px;
  color: var(--white);
}

.culinary-meta {
  display: flex;
  flex-wrap: wrap;
  gap: 20px;
}

.meta-item {
  background: rgba(255, 255, 255, 0.1);
  backdrop-filter: blur(8px);
  padding: 8px 16px;
  border-radius: 99px;
  font-size: 0.85rem;
  color: var(--w80);
}

.section {
  padding: 60px 0;
}

.culinary-content-layout {
  display: grid;
  grid-template-columns: 2fr 1fr;
  gap: 60px;
}

.culinary-main-info h2 {
  font-size: 2rem;
  margin-bottom: 24px;
  color: var(--white);
  border-bottom: 1px solid var(--w08);
  padding-bottom: 12px;
}

.culinary-description {
  font-size: 1.05rem;
  line-height: 1.8;
  color: var(--w70);
  white-space: pre-line;
}

.culinary-sidebar {
  background: var(--dark1);
  padding: 24px;
  border-radius: 16px;
  border: 1px solid var(--w08);
  height: fit-content;
}

.culinary-sidebar h3 {
  font-size: 1.5rem;
  margin-bottom: 20px;
  color: var(--white);
}

.location-card p {
  margin-bottom: 8px;
  color: var(--w80);
}

.full-width {
  width: 100%;
  text-align: center;
  display: block;
}

.mt-4 {
  margin-top: 24px;
}

.loading-state, .error-state {
  text-align: center;
  padding: 100px 0;
  color: var(--w60);
}

.text-red {
  color: #ff4757;
}

.text-w40 {
  color: var(--w40);
}

/* Gallery & Modal */
.culinary-gallery {
  background: var(--dark1);
  padding: 24px;
  border-radius: 16px;
  border: 1px solid var(--w08);
}

.culinary-gallery h3 {
  font-size: 1.5rem;
  margin-bottom: 20px;
  color: var(--white);
}

.gallery-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
  gap: 12px;
}

.gallery-img {
  width: 100%;
  aspect-ratio: 1 / 1;
  object-fit: cover;
  border-radius: 8px;
  transition: transform 0.3s;
  cursor: pointer;
}

.gallery-img:hover {
  transform: scale(1.05);
}

.mt-5 {
  margin-top: 40px;
}

.image-modal {
  position: fixed;
  inset: 0;
  background-color: rgba(0, 0, 0, 0.9);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
  padding: 24px;
}

.image-modal__img {
  max-width: 100%;
  max-height: 100%;
  object-fit: contain;
  border-radius: 8px;
}

.image-modal__close {
  position: absolute;
  top: 24px;
  right: 24px;
  background: rgba(255, 255, 255, 0.1);
  border: none;
  color: white;
  font-size: 2rem;
  width: 48px;
  height: 48px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: background 0.3s;
}

.image-modal__close:hover {
  background: rgba(255, 255, 255, 0.3);
}

@media (max-width: 900px) {
  .culinary-content-layout {
    grid-template-columns: 1fr;
    gap: 40px;
  }
  .culinary-title {
    font-size: 3rem;
  }
}
</style>
