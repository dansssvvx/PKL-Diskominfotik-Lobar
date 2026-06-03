<template>
  <div class="culture-detail-view">
    <TheNavbar />

    <!-- Hero / Header Section -->
    <header class="culture-hero" v-if="culture">
      <!-- Background Image -->
      <div class="culture-hero__bg" :style="{ backgroundImage: `url('${mainImage}')` }"></div>
      <div class="culture-hero__overlay"></div>

      <div class="container culture-hero__content">
        <RouterLink to="/" class="btn-back">← Back to Home</RouterLink>
        <h1 class="font-display culture-title">{{ culture.name }}</h1>
        <div class="culture-meta">
          <span class="meta-item">📍 {{ culture.location || 'West Lombok' }}</span>
          <span class="meta-item" v-if="culture.event_date">📅 Date: {{ culture.event_date }}</span>
          <span class="meta-item" v-if="culture.event_frequency">⏳ Frequency: {{ culture.event_frequency }}</span>
        </div>
      </div>
    </header>

    <!-- Main Content Section -->
    <main class="container section" v-if="culture">
      <div class="culture-content-layout">
        
        <!-- Left: Description & Info -->
        <div class="culture-main-info">
          <h2>About this Culture</h2>
          <div class="culture-description">
            <p v-if="culture.description">{{ culture.description }}</p>
            <p v-else class="text-w40">No description available for this cultural heritage.</p>
          </div>
        </div>

        <!-- Right: Gallery -->
        <aside class="culture-gallery" v-if="allImages.length > 0">
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
        </aside>

      </div>
    </main>

    <!-- Image Modal -->
    <div class="image-modal" v-if="selectedImage" @click="closeModal">
      <button class="image-modal__close" @click.stop="closeModal">×</button>
      <img :src="selectedImage" alt="Enlarged gallery view" class="image-modal__img" @click.stop />
    </div>

    <!-- Loading State -->
    <div class="container section loading-state" v-else-if="loading">
      <p>Loading cultural heritage details...</p>
    </div>

    <!-- Error State -->
    <div class="container section error-state" v-else>
      <h2 class="text-red">Failed to load culture details.</h2>
      <p>It might have been removed or doesn't exist.</p>
      <RouterLink to="/" class="btn btn-primary mt-4">Return Home</RouterLink>
    </div>

    <TheFooter />
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { useRoute } from 'vue-router'
import { cultureApi } from '@/api'
import type { Culture } from '@/types'
import TheNavbar from '@/components/layout/TheNavbar.vue'
import TheFooter from '@/components/layout/TheFooter.vue'

const route = useRoute()
const culture = ref<Culture | null>(null)
const loading = ref(true)

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
  if (!culture.value || !culture.value.images) return []
  
  const imgs = culture.value.images
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

  // extract actual strings if objects are returned
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
    const res = await cultureApi.detail(id)
    culture.value = res.data
  } catch (error) {
    console.error('Error fetching culture details:', error)
  } finally {
    loading.value = false
  }
})
</script>

<style scoped>
.culture-detail-view {
  min-height: 100vh;
  background-color: var(--black);
}

.culture-hero {
  position: relative;
  height: 50vh;
  min-height: 400px;
  display: flex;
  align-items: flex-end;
  padding-bottom: 60px;
  margin-top: 80px; /* Offset for navbar */
}

.culture-hero__bg {
  position: absolute;
  top: 0; left: 0; right: 0; bottom: 0;
  background-size: cover;
  background-position: center;
  z-index: 0;
}

.culture-hero__overlay {
  position: absolute;
  top: 0; left: 0; right: 0; bottom: 0;
  background: linear-gradient(to top, var(--black) 0%, rgba(5,6,8,0.5) 60%, rgba(5,6,8,0.2) 100%);
  z-index: 1;
}

.culture-hero__content {
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

.culture-title {
  font-size: 4rem;
  line-height: 1.1;
  margin-bottom: 16px;
  color: var(--white);
}

.culture-meta {
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

.culture-content-layout {
  display: grid;
  grid-template-columns: 2fr 1fr;
  gap: 60px;
}

.culture-main-info h2 {
  font-size: 2rem;
  margin-bottom: 24px;
  color: var(--white);
  border-bottom: 1px solid var(--w08);
  padding-bottom: 12px;
}

.culture-description {
  font-size: 1.05rem;
  line-height: 1.8;
  color: var(--w70);
  white-space: pre-line;
}

.culture-gallery {
  background: var(--dark1);
  padding: 24px;
  border-radius: 16px;
  border: 1px solid var(--w08);
  height: fit-content;
}

.culture-gallery h3 {
  font-size: 1.5rem;
  margin-bottom: 20px;
  color: var(--white);
}

.gallery-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
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

/* Modal Styles */
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

.mt-4 {
  margin-top: 24px;
}

@media (max-width: 900px) {
  .culture-content-layout {
    grid-template-columns: 1fr;
    gap: 40px;
  }
  .culture-title {
    font-size: 3rem;
  }
}
</style>
