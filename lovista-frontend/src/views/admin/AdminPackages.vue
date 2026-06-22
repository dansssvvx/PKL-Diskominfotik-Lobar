<template>
  <div class="admin-packages">
    <div class="admin-packages__header">
      <div>
        <h1 class="admin-title">Manage Packages</h1>
        <p class="admin-subtitle">Monitor and manage all available tour packages.</p>
      </div>
    </div>

    <!-- Filters -->
    <div class="card p-4 mb-4 filter-bar" style="margin-bottom: 24px;">
      <div class="filter-group">
        <input v-model="filters.search" type="text" class="form-input" placeholder="Search packages..." @keyup.enter="handleFilterChange" />
      </div>
      <button class="btn btn-ghost" @click="fetchData">Refresh</button>
    </div>

    <!-- Data Table -->
    <div class="card table-wrap">
      <table class="table">
        <thead>
          <tr>
            <th>Package Name</th>
            <th>Agency / Business</th>
            <th>Duration</th>
            <th>Price / Person</th>
            <th>Status</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody v-if="loading">
          <tr><td colspan="6" style="text-align:center;padding:30px;"><div class="spinner"></div></td></tr>
        </tbody>
        <tbody v-else-if="packages.length === 0">
          <tr><td colspan="6" style="text-align:center;padding:30px;color:var(--w40);">No tour packages found.</td></tr>
        </tbody>
        <tbody v-else>
          <tr v-for="item in packages" :key="item.id">
            <td>
              <div class="item-info">
                <img :src="getPhotoUrl(item.main_image)" class="item-img" />
                <div class="item-name">{{ item.name }}</div>
              </div>
            </td>
            <td>
              <div class="biz-name">{{ item.agency_name || 'Individual' }}</div>
            </td>
            <td>{{ item.duration_days }} Days</td>
            <td>
              <div class="price-val">Rp {{ formatPrice(item.price_per_person) }}</div>
              <div v-if="Number(item.discount_percentage) > 0" class="discount-sub">
                {{ item.discount_percentage }}% OFF
              </div>
            </td>
            <td>
              <span class="badge" :class="item.is_active ? 'badge-success' : 'badge-gray'">
                {{ item.is_active ? 'Active' : 'Inactive' }}
              </span>
            </td>
            <td>
              <div class="action-btns">
                <button class="btn btn-blue-outline btn-sm" @click="togglePackageStatus(item)">
                  {{ item.is_active ? 'Deactivate' : 'Activate' }}
                </button>
                <button class="btn btn-danger btn-sm" @click="deleteItem(item.slug)">Delete</button>
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
import { packageApi } from '@/api'
import type { TourPackage } from '@/types'

const loading = ref(false)
const packages = ref<TourPackage[]>([])
const filters = ref({ search: '', page: 1 })
const totalItems = ref(0)
const itemsPerPage = 10

const totalPages = computed(() => Math.ceil(totalItems.value / itemsPerPage))

async function fetchData() {
  loading.value = true
  try {
    const { data } = await packageApi.list({ ...filters.value, page_size: itemsPerPage } as any)
    packages.value = Array.isArray(data) ? data : data.results || []
    totalItems.value = Array.isArray(data) ? data.length : data.count || packages.value.length
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

async function togglePackageStatus(item: TourPackage) {
  try {
    const newStatus = !item.is_active
    await packageApi.update(item.slug as any, { is_active: newStatus } as any)
    item.is_active = newStatus
  } catch (error) {
    Swal.fire({ title: 'Notification', text: 'Failed to update status', icon: 'info' })
  }
}

async function deleteItem(slug: string) {
  const result = await Swal.fire({ title: 'Are you sure?', text: 'Are you sure you want to delete this package?', icon: 'warning', showCancelButton: true });
  if (!result.isConfirmed) return
  try {
    await packageApi.delete(slug as any)
    fetchData()
  } catch (error) {
    Swal.fire({ title: 'Notification', text: 'Failed to delete package', icon: 'info' })
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
.admin-packages__header { display: flex; justify-content: space-between; align-items: flex-end; margin-bottom: 24px; }
.admin-title { font-family: 'Barlow Condensed', sans-serif; font-size: 2rem; font-style: italic; font-weight: 800; margin-bottom: 4px; }
.admin-subtitle { color: var(--w40); font-size: 0.9rem; }

.filter-bar { display: flex; gap: 12px; align-items: center; background: var(--dark2); }
.filter-group { flex: 1; min-width: 150px; }
.filter-group .form-input { width: 100%; }

.table-wrap { overflow-x: auto; }
.item-info { display: flex; align-items: center; gap: 12px; }
.item-img { width: 48px; height: 48px; border-radius: 8px; object-fit: cover; background: var(--w04); }
.item-name { font-weight: 600; color: #fff; font-size: 0.95rem; }

.biz-name { color: var(--blue-b); font-size: 0.85rem; font-weight: 600; }
.price-val { font-weight: 700; color: #fff; }
.discount-sub { font-size: 0.7rem; color: #4ade80; font-weight: 700; }

.action-btns { display: flex; gap: 8px; }
.btn-blue-outline { background: transparent; border: 1px solid var(--blue); color: var(--blue); }
.btn-blue-outline:hover { background: rgba(26,143,255,0.1); }

.pagination { display: flex; align-items: center; justify-content: center; gap: 16px; font-size: 0.9rem; color: var(--w70); }
</style>