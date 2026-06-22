<template>
  <div class="page-wrapper">
    <TheNavbar />
    
    <div class="ai-container container">
      <div class="header-section text-center">
        <div class="ai-icon">✨</div>
        <h1 class="title">LoVista AI Trip Planner</h1>
        <p class="subtitle">Beri tahu kami apa yang Anda cari, dan AI kami akan merancang rekomendasi destinasi terbaik khusus untuk Anda.</p>
      </div>

      <div class="wizard-wrap card">
        <form @submit.prevent="submitPreferences" v-if="!recommendations">
          <div class="form-grid">
            <div class="form-group">
              <label>Budget Liburan (IDR)</label>
              <input v-model="form.budget" type="number" class="form-input" placeholder="Contoh: 1500000" />
            </div>
            
            <div class="form-group">
              <label>Durasi Liburan</label>
              <select v-model="form.duration" class="form-select" required>
                <option value="1 Day">1 Hari (Day Trip)</option>
                <option value="2-3 Days">2-3 Hari</option>
                <option value="1 Week">1 Minggu</option>
              </select>
            </div>
            
            <div class="form-group">
              <label>Gaya Liburan</label>
              <select v-model="form.travel_style" class="form-select" required>
                <option value="Santai">Santai & Relaksasi</option>
                <option value="Petualangan">Petualangan & Alam</option>
                <option value="Budaya">Sejarah & Budaya</option>
                <option value="Keluarga">Ramah Keluarga</option>
              </select>
            </div>
          </div>

          <div class="form-group mt-4">
            <label>Minat & Aktivitas (Pisahkan dengan koma)</label>
            <input 
              v-model="interestsInput" 
              type="text" 
              class="form-input" 
              placeholder="Contoh: Pantai, Gunung, Makanan Pedas, Snorkeling..." 
            />
          </div>

          <div class="text-center mt-4">
            <button type="submit" class="btn btn-primary btn-lg" :disabled="loading">
              <span v-if="loading" class="spinner-small"></span>
              <span v-else>🔮 Buat Rekomendasi</span>
            </button>
          </div>
        </form>

        <div v-else class="results-view">
          <div class="results-header">
            <h2>Ini dia rekomendasi khusus untuk Anda!</h2>
            <button class="btn btn-ghost btn-sm" @click="resetForm">Mulai Ulang</button>
          </div>

          <div class="recom-grid mt-4">
            <div v-for="(dest, i) in recommendations" :key="i" class="recom-card">
              <div class="recom-img">
                <img :src="getImgUrl(dest.image)" :alt="dest.name" @error="handleImgError" />
              </div>
              <div class="recom-body">
                <div class="badge badge-blue mb-2">{{ dest.category }}</div>
                <h3>{{ dest.name }}</h3>
                <p>{{ dest.description }}</p>
                <router-link :to="`/destinations/${dest.slug}`" class="btn btn-outline btn-sm mt-3">Lihat Detail</router-link>
              </div>
            </div>
          </div>

          <div class="feedback-section mt-5">
            <p>Seberapa akurat rekomendasi ini?</p>
            <div class="rating-stars">
              <span v-for="star in 5" :key="star" class="star" :class="{ active: rating >= star }" @click="rate(star)">★</span>
            </div>
            <p v-if="ratingSubmitted" class="text-success mt-2">Terima kasih atas masukannya!</p>
          </div>
        </div>
      </div>
    </div>

    <TheFooter />
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import TheNavbar from '@/components/layout/TheNavbar.vue'
import TheFooter from '@/components/layout/TheFooter.vue'
import { aiApi } from '@/api'
import Swal from 'sweetalert2'

const BASE_URL = 'http://127.0.0.1:8000'

const loading = ref(false)
const recommendations = ref<any[] | null>(null)
const recommendationId = ref<number | null>(null)
const rating = ref(0)
const ratingSubmitted = ref(false)

const form = ref({
  budget: '',
  duration: '1 Day',
  travel_style: 'Santai',
})
const interestsInput = ref('')

async function submitPreferences() {
  loading.value = true
  const interests = interestsInput.value.split(',').map(i => i.trim()).filter(i => i)
  
  const payload = {
    ...form.value,
    budget: form.value.budget ? parseFloat(form.value.budget) : null,
    interests
  }

  try {
    const res = await aiApi.recommend(payload as any)
    recommendations.value = res.data.recommendations
    recommendationId.value = res.data.id
  } catch (err) {
    Swal.fire('Error', 'Gagal memuat rekomendasi', 'error')
  } finally {
    loading.value = false
  }
}

async function rate(star: number) {
  if (!recommendationId.value) return
  rating.value = star
  try {
    await aiApi.rate(recommendationId.value, star)
    ratingSubmitted.value = true
  } catch (err) {
    console.error(err)
  }
}

function resetForm() {
  recommendations.value = null
  recommendationId.value = null
  rating.value = 0
  ratingSubmitted.value = false
}

function getImgUrl(path: string | null) {
  if (!path) return '/Logo.png'
  if (path.startsWith('http')) return path
  return `${BASE_URL}${path}`
}

function handleImgError(e: Event) {
  ;(e.target as HTMLImageElement).src = '/Logo.png'
}
</script>

<style scoped>
.page-wrapper { min-height: 100vh; display: flex; flex-direction: column; }
.ai-container { padding-top: 120px; padding-bottom: 80px; flex: 1; max-width: 900px; }

.header-section { margin-bottom: 40px; }
.ai-icon { font-size: 3rem; margin-bottom: 16px; animation: float 3s ease-in-out infinite; }
@keyframes float {
  0%, 100% { transform: translateY(0); }
  50% { transform: translateY(-10px); }
}
.title { font-family: 'Barlow Condensed', sans-serif; font-size: 2.8rem; font-style: italic; font-weight: 800; color: var(--w90); margin-bottom: 8px; }
.subtitle { color: var(--w40); font-size: 1.1rem; max-width: 600px; margin: 0 auto; }

.wizard-wrap { padding: 40px; border-radius: 24px; border: 1px solid var(--w08); }
.form-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 24px; }
.mt-4 { margin-top: 24px; }
.mt-5 { margin-top: 40px; }

.btn-lg { padding: 16px 32px; font-size: 1.1rem; border-radius: 30px; }
.spinner-small { display: inline-block; width: 20px; height: 20px; border: 3px solid rgba(255,255,255,0.3); border-top-color: #fff; border-radius: 50%; animation: spin 1s linear infinite; }

.results-header { display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid var(--w08); padding-bottom: 16px; }
.results-header h2 { font-family: 'Barlow Condensed', sans-serif; font-size: 1.8rem; font-style: italic; font-weight: 700; color: var(--blue); }

.recom-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(250px, 1fr)); gap: 24px; }
.recom-card { border: 1px solid var(--w08); border-radius: 16px; overflow: hidden; background: var(--w04); transition: transform 0.3s; }
.recom-card:hover { transform: translateY(-4px); }
.recom-img { height: 160px; }
.recom-img img { width: 100%; height: 100%; object-fit: cover; }
.recom-body { padding: 20px; }
.recom-body h3 { font-size: 1.2rem; font-weight: 700; margin-bottom: 8px; line-height: 1.3; }
.recom-body p { font-size: 0.85rem; color: var(--w60); line-height: 1.5; }
.mb-2 { margin-bottom: 8px; }
.mt-3 { margin-top: 16px; }

.feedback-section { text-align: center; padding: 32px 0 0; border-top: 1px dashed var(--w08); }
.feedback-section p { color: var(--w60); margin-bottom: 12px; }
.rating-stars { display: flex; justify-content: center; gap: 8px; font-size: 2rem; }
.star { color: var(--w20); cursor: pointer; transition: 0.2s; }
.star:hover, .star.active { color: #fbbf24; transform: scale(1.1); }
.text-success { color: #34d399; font-weight: 600; }
</style>
