<template>
  <div class="page-wrapper">
    
    <div class="map-container">
      <div class="map-sidebar" :class="{ 'is-open': sidebarOpen }">
        <div class="sidebar-header">
          <h2>Explore Lombok Barat</h2>
          <button class="btn-close-sidebar" @click="sidebarOpen = false">✕</button>
        </div>
        
        <div class="filter-box">
          <input v-model="searchQuery" type="text" class="form-input" placeholder="Cari destinasi..." />
        </div>

        <div class="dest-list" v-if="!loading">
          <div 
            v-for="dest in filteredDestinations" 
            :key="dest.unified_id" 
            class="dest-item"
            @click="focusMap(dest)"
          >
            <div class="dest-img-wrap">
              <img :src="getImgUrl(dest.main_image)" :alt="dest.name" @error="handleImgError" />
            </div>
            <div class="dest-info">
              <h4>{{ dest.name }}</h4>
              <span class="badge" :class="dest.type_label === 'Kuliner' ? 'badge-warning' : 'badge-blue'">{{ dest.type_label }}</span>
            </div>
          </div>
          <div v-if="filteredDestinations.length === 0" class="no-results">
            Tidak ada destinasi ditemukan.
          </div>
        </div>
        <div v-else class="loader-wrap">
          <div class="spinner"></div>
        </div>
      </div>

      <div class="map-view">
        <button class="btn-toggle-sidebar" @click="sidebarOpen = !sidebarOpen">
          ☰ Daftar Destinasi
        </button>
        <div id="lovista-map" class="map-element"></div>
      </div>
    </div>

  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, computed, watch, onBeforeUnmount } from 'vue'
import TheNavbar from '@/components/layout/TheNavbar.vue'
import { destinationApi, culinaryApi } from '@/api'

// Leaflet
import L from 'leaflet'
import 'leaflet/dist/leaflet.css'

// Fix leaflet default icon issue
import iconRetinaUrl from 'leaflet/dist/images/marker-icon-2x.png'
import iconUrl from 'leaflet/dist/images/marker-icon.png'
import shadowUrl from 'leaflet/dist/images/marker-shadow.png'

delete (L.Icon.Default.prototype as any)._getIconUrl
L.Icon.Default.mergeOptions({
  iconRetinaUrl,
  iconUrl,
  shadowUrl,
})

const BASE_URL = 'http://127.0.0.1:8000'
const loading = ref(true)
const destinations = ref<any[]>([])
const searchQuery = ref('')
const sidebarOpen = ref(true)
const isMobile = ref(window.innerWidth < 768)

let map: L.Map | null = null
let markersGroup: L.FeatureGroup | null = null
const markersMap = new Map<string, L.Marker>()

const filteredDestinations = computed(() => {
  if (!searchQuery.value) return destinations.value
  const q = searchQuery.value.toLowerCase()
  return destinations.value.filter(d => d.name.toLowerCase().includes(q) || d.type_label.toLowerCase().includes(q))
})

async function fetchDestinations() {
  loading.value = true
  try {
    const [destRes, culRes] = await Promise.all([
      destinationApi.list({ page_size: 100 } as any),
      culinaryApi.list({ page_size: 100 } as any)
    ])

    const destData = (destRes.data.results || destRes.data).map((d: any) => ({
      ...d,
      unified_id: `dest-${d.id}`,
      type_label: d.category_name || 'Wisata',
      unified_url: `/destinations/${d.slug}`
    }))

    const culData = (culRes.data.results || culRes.data).map((c: any) => ({
      ...c,
      unified_id: `cul-${c.id}`,
      type_label: 'Kuliner',
      main_image: c.images && c.images.length ? c.images[0] : null,
      unified_url: `/culinaries/${c.id}`
    }))

    destinations.value = [...destData, ...culData]
    initMap()
  } catch (err) {
    console.error('Failed to fetch map data', err)
  } finally {
    loading.value = false
  }
}

function initMap() {
  // Lombok Barat coordinates approx
  const center: L.LatLngTuple = [-8.5833, 116.1167]
  
  map = L.map('lovista-map').setView(center, 10)
  
  L.tileLayer('https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png', {
    attribution: '&copy; OpenStreetMap contributors &copy; CARTO',
    subdomains: 'abcd',
    maxZoom: 19
  }).addTo(map)

  markersGroup = L.featureGroup().addTo(map)
  updateMarkers()
}

function updateMarkers() {
  if (!markersGroup || !map) return
  markersGroup.clearLayers()
  markersMap.clear()

  filteredDestinations.value.forEach(dest => {
    if (dest.latitude && dest.longitude) {
      const lat = parseFloat(dest.latitude)
      const lng = parseFloat(dest.longitude)
      if (!isNaN(lat) && !isNaN(lng)) {
        let icon = new L.Icon.Default()
        if (dest.type_label === 'Kuliner') {
          icon = L.icon({
            iconUrl,
            iconRetinaUrl,
            shadowUrl,
            iconSize: [25, 41],
            iconAnchor: [12, 41],
            popupAnchor: [1, -34],
            shadowSize: [41, 41],
            className: 'marker-kuliner'
          })
        }
        const marker = L.marker([lat, lng], { icon })
        
        const popupContent = `
          <div style="width: 200px">
            <img src="${getImgUrl(dest.main_image)}" style="width:100%;height:100px;object-fit:cover;border-radius:8px;margin-bottom:8px;" />
            <h4 style="margin:0 0 4px;font-family:'Barlow Condensed',sans-serif;font-size:1.2rem;font-weight:700">${dest.name}</h4>
            <p style="margin:0 0 8px;font-size:0.8rem;color:#666">${dest.village || ''} ${dest.district || ''}</p>
            <a href="${dest.unified_url}" style="display:block;text-align:center;background:#0066ff;color:#fff;padding:6px;border-radius:6px;text-decoration:none;font-weight:bold;font-size:0.85rem">Detail</a>
          </div>
        `
        marker.bindPopup(popupContent)
        markersGroup!.addLayer(marker)
        markersMap.set(dest.unified_id, marker)
      }
    }
  })

  // Fit bounds if there are markers
  if (markersGroup.getLayers().length > 0) {
    map.fitBounds(markersGroup.getBounds(), { padding: [50, 50] })
  }
}

function focusMap(dest: any) {
  if (isMobile.value) sidebarOpen.value = false
  const marker = markersMap.get(dest.id)
  if (marker && map) {
    map.flyTo(marker.getLatLng(), 15, { duration: 1.5 })
    marker.openPopup()
  }
}

watch(filteredDestinations, () => {
  updateMarkers()
})

function handleResize() {
  isMobile.value = window.innerWidth < 768
  if (!isMobile.value) sidebarOpen.value = true
}

function getImgUrl(path: string | null) {
  if (!path) return '/Logo.png'
  if (path.startsWith('http')) return path
  return `${BASE_URL}${path}`
}

function handleImgError(e: Event) {
  ;(e.target as HTMLImageElement).src = '/Logo.png'
}

onMounted(() => {
  window.addEventListener('resize', handleResize)
  fetchDestinations()
})

onBeforeUnmount(() => {
  window.removeEventListener('resize', handleResize)
  if (map) map.remove()
})
</script>

<style scoped>
.page-wrapper { height: 100vh; max-height: 100vh; display: flex; flex-direction: column; overflow: hidden; }
.map-container { display: flex; flex: 1; height: 100%; position: relative; overflow: hidden; }

.map-sidebar { height: 100%; width: 350px; background: var(--dark); border-right: 1px solid var(--w08); display: flex; flex-direction: column; z-index: 1000; transition: margin-left 0.3s ease, transform 0.3s ease; padding-top: 80px; }
.map-sidebar:not(.is-open) { margin-left: -350px; }
.sidebar-header { padding: 20px; border-bottom: 1px solid var(--w08); display: flex; justify-content: space-between; align-items: center; }
.sidebar-header h2 { font-family: 'Barlow Condensed', sans-serif; font-style: italic; font-weight: 800; font-size: 1.5rem; }
.btn-close-sidebar { background: none; border: none; color: var(--w40); font-size: 1.2rem; cursor: pointer; }

.filter-box { padding: 16px 20px; border-bottom: 1px solid var(--w08); }

.dest-list { flex: 1; overflow-y: auto; padding: 12px; }
.dest-item { display: flex; gap: 12px; padding: 12px; border-radius: 12px; cursor: pointer; transition: 0.2s; }
.dest-item:hover { background: var(--w04); }
.dest-img-wrap { width: 70px; height: 70px; flex-shrink: 0; border-radius: 8px; overflow: hidden; }
.dest-img-wrap img { width: 100%; height: 100%; object-fit: cover; }
.dest-info h4 { font-size: 0.95rem; font-weight: 700; margin-bottom: 6px; line-height: 1.3; }

.no-results { padding: 20px; text-align: center; color: var(--w40); font-size: 0.9rem; }

.loader-wrap { display: flex; justify-content: center; align-items: center; flex: 1; }
.spinner { width: 30px; height: 30px; border: 3px solid var(--w08); border-top-color: var(--blue); border-radius: 50%; animation: spin 1s linear infinite; }
@keyframes spin { to { transform: rotate(360deg); } }

.map-view { flex: 1; position: relative; }
.map-element { width: 100%; height: 100%; z-index: 1; }

.btn-toggle-sidebar { position: absolute; top: 50%; left: 16px; transform: translateY(-50%); z-index: 1000; background: var(--dark2); color: #fff; border: 1px solid var(--w20); padding: 8px 16px; border-radius: 20px; font-weight: 600; cursor: pointer; box-shadow: 0 4px 12px rgba(0,0,0,0.3); }

/* Custom Popup Styles inside Leaflet */
:deep(.leaflet-popup-content-wrapper) { background: var(--dark2); color: var(--w90); border-radius: 12px; border: 1px solid var(--w08); box-shadow: 0 10px 25px rgba(0,0,0,0.5); }
:deep(.leaflet-popup-tip) { background: var(--dark2); }

/* Custom Marker Colors */
:deep(.marker-kuliner) { filter: hue-rotate(160deg) saturate(2); }

@media (max-width: 768px) {
  .map-sidebar { position: absolute; top: 0; left: 0; bottom: 0; margin-left: 0 !important; transform: translateX(-100%); background: var(--dark); box-shadow: 4px 0 20px rgba(0,0,0,0.5); }
  .map-sidebar.is-open { transform: translateX(0); }
}
</style>
