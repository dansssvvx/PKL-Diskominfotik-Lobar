<template>
  <div class="admin-rent">
    <div class="admin-rent__header">
      <div>
        <h1 class="admin-title">Manage Vehicle Rentals</h1>
        <p class="admin-subtitle">Monitor and manage all vehicles available for rent.</p>
      </div>
    </div>

    <!-- Filters -->
    <div class="card p-4 mb-4 filter-bar">
      <div class="filter-group">
        <input v-model="filters.search" type="text" class="form-input" placeholder="Search by model or brand..." @keyup.enter="handleFilterChange" />
      </div>
      <div class="filter-group">
        <select v-model="filters.type" class="form-select" @change="handleFilterChange">
          <option value="">All Types</option>
          <option value="car">Car</option>
          <option value="motorcycle">Motorcycle</option>
          <option value="bus">Bus</option>
          <option value="van">Van</option>
        </select>
      </div>
      <button class="btn btn-ghost" @click="fetchData">Refresh</button>
    </div>

    <!-- Data Table -->
    <div class="card table-wrap">
      <table class="table">
        <thead>
          <tr>
            <th>Vehicle</th>
            <th>Type</th>
            <th>Agency</th>
            <th>Plate Number</th>
            <th>Daily Rate</th>
            <th>Status</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody v-if="loading">
          <tr><td colspan="7" style="text-align:center;padding:30px;"><div class="spinner"></div></td></tr>
        </tbody>
        <tbody v-else-if="vehicles.length === 0">
          <tr><td colspan="7" style="text-align:center;padding:30px;color:var(--w40);">No vehicles found.</td></tr>
        </tbody>
        <tbody v-else>
          <tr v-for="item in vehicles" :key="item.id">
            <td>
              <div class="item-info">
                <img :src="getPhotoUrl(item.image)" class="item-img" />
                <div class="item-name">{{ item.brand }} {{ item.model }}</div>
              </div>
            </td>
            <td>
              <span class="badge-outline">{{ item.type.toUpperCase() }}</span>
            </td>
            <td>
              <div class="biz-name">{{ (item.agency as any)?.business_name || (item as any).agency_name || 'Individual / System' }}</div>
            </td>
            <td><code>{{ item.plate_number }}</code></td>
            <td>
              <div class="price-val">Rp {{ formatPrice(item.daily_rate) }}</div>
              <div class="driver-val" v-if="item.driver_rate > 0">+ Rp {{ formatPrice(item.driver_rate) }} (Driver)</div>
            </td>
            <td>
              <span class="badge" :class="item.is_active ? 'badge-success' : 'badge-gray'">
                {{ item.is_active ? 'Active' : 'Inactive' }}
              </span>
            </td>
            <td>
              <div class="action-btns">
                <button class="btn btn-ghost btn-sm" @click="toggleStatus(item)">
                  {{ item.is_active ? 'Deactivate' : 'Activate' }}
                </button>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <!-- Pagination -->
    <div class="pagination mt-4" v-if="totalPages > 1">
      <button class="btn btn-ghost btn-sm" :disabled="filters.page === 1" @click="filters.page--; fetchData()">Prev</button>
      <span>Page {{ filters.page }} of {{ totalPages }}</span>
      <button class="btn btn-ghost btn-sm" :disabled="filters.page === totalPages" @click="filters.page++; fetchData()">Next</button>
    </div>
  </div>
</template>

<script setup lang="ts">
import Swal from 'sweetalert2'
import { ref, onMounted, computed } from 'vue'
import { vehicleApi } from '@/api'
import type { Vehicle } from '@/types'

const loading = ref(false)
const vehicles = ref<Vehicle[]>([])
const filters = ref({ search: '', type: '', page: 1 })
const totalItems = ref(0)
const itemsPerPage = 10

const totalPages = computed(() => Math.ceil(totalItems.value / itemsPerPage))

async function fetchData() {
  loading.value = true
  try {
    const { data } = await vehicleApi.list({ ...filters.value, page_size: itemsPerPage } as any)
    vehicles.value = Array.isArray(data) ? data : data.results || []
    totalItems.value = Array.isArray(data) ? data.length : data.count || vehicles.value.length
  } catch (error) {
    console.error(error)
  } finally {
    loading.value = false
  }
}

function handleFilterChange() {
  filters.value.page = 1
  fetchData()
}

async function toggleStatus(item: Vehicle) {
  try {
    const newStatus = !item.is_active
    await vehicleApi.update(item.id, { is_active: newStatus } as any)
    item.is_active = newStatus
  } catch (error) {
    Swal.fire({ title: 'Notification', text: 'Failed to update status', icon: 'info' })
  }
}

function formatPrice(val: number | string) {
  return new Intl.NumberFormat('id-ID').format(Math.round(Number(val)))
}

function getPhotoUrl(path?: string | null) {
  if (!path) return '/Logo.png'
  if (path.startsWith('http')) return path
  return `http://127.0.0.1:8000${path}`
}

onMounted(fetchData)
</script>

<style scoped>
.admin-rent__header { display: flex; justify-content: space-between; align-items: flex-end; margin-bottom: 24px; }
.admin-title { font-family: 'Barlow Condensed', sans-serif; font-size: 2rem; font-style: italic; font-weight: 800; margin-bottom: 4px; }
.admin-subtitle { color: var(--w40); font-size: 0.9rem; }

.p-4 { padding: 16px; }
.mb-4 { margin-bottom: 24px; }
.mt-4 { margin-top: 24px; }

.filter-bar { display: flex; gap: 12px; align-items: center; background: var(--dark2); }
.filter-group { flex: 1; min-width: 150px; }
.filter-group .form-input, .filter-group .form-select { width: 100%; }

.table-wrap { overflow-x: auto; }
.item-info { display: flex; align-items: center; gap: 12px; }
.item-img { width: 48px; height: 48px; border-radius: 8px; object-fit: cover; background: var(--w04); }
.item-details { display: flex; flex-direction: column; }
.item-name { font-weight: 600; color: #fff; font-size: 0.95rem; }
.item-agency { color: var(--w40); font-size: 0.8rem; }

.price-val { font-weight: 700; color: #fff; }
.driver-val { font-size: 0.75rem; color: var(--w40); margin-top: 2px; }

.action-btns { display: flex; gap: 8px; }
.btn-blue-outline { background: transparent; border: 1px solid var(--blue); color: var(--blue); }
.btn-blue-outline:hover { background: rgba(26,143,255,0.1); }

.badge-outline {
  padding: 4px 10px; border-radius: 6px; border: 1px solid var(--w15);
  font-size: 0.75rem; color: var(--w70); background: rgba(255,255,255,0.03);
}

.pagination { display: flex; align-items: center; justify-content: center; gap: 16px; font-size: 0.9rem; color: var(--w70); }
</style>