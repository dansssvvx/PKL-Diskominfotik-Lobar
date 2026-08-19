<template>
  <div class="admin-homestays">
    <div class="admin-homestays__header">
      <div>
        <h1 class="admin-title">Manage Homestays</h1>
        <p class="admin-subtitle">Monitor and manage all homestay properties and their verification status.</p>
      </div>
    </div>

    <!-- Filters -->
    <div class="card p-4 mb-4 filter-bar" style="margin-bottom: 24px;">
      <div class="filter-group">
        <input v-model="filters.search" type="text" class="form-input" placeholder="Search homestays..." @keyup.enter="handleFilterChange" />
      </div>
      <button class="btn btn-ghost" @click="fetchData">Refresh</button>
    </div>

    <!-- Data Table -->
    <div class="card table-wrap">
      <table class="table">
        <thead>
          <tr>
            <th>Homestay Name</th>
            <th>Location</th>
            <th>Owner / Operator</th>
            <th>Status</th>
            <th>Verification</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody v-if="loading">
          <tr><td colspan="6" style="text-align:center;padding:30px;"><div class="spinner"></div></td></tr>
        </tbody>
        <tbody v-else-if="homestays.length === 0">
          <tr><td colspan="6" style="text-align:center;padding:30px;color:var(--w40);">No homestays found.</td></tr>
        </tbody>
        <tbody v-else>
          <tr v-for="item in homestays" :key="item.id">
            <td>
              <div class="item-info">
                <img :src="getPhotoUrl(item.main_image)" class="item-img" />
                <div class="item-name">{{ item.name }}</div>
              </div>
            </td>
            <td>
              <div class="location-info">{{ item.district || '-' }}</div>
              <div class="location-sub">{{ item.village || '-' }}</div>
            </td>
            <td>
              <div class="biz-name">{{ item.owner_name || 'Admin' }}</div>
            </td>
            <td>
              <span class="badge" :class="item.is_active ? 'badge-success' : 'badge-gray'">
                {{ item.is_active ? 'Active' : 'Inactive' }}
              </span>
            </td>
            <td>
              <span class="badge" :class="item.is_verified ? 'badge-success' : 'badge-warning'">
                {{ item.is_verified ? 'Verified' : 'Pending' }}
              </span>
            </td>
            <td>
              <div class="action-btns">
                <button class="btn btn-blue-outline btn-sm" @click="toggleVerification(item)">
                  {{ item.is_verified ? 'Unverify' : 'Verify' }}
                </button>
                <button class="btn btn-danger btn-sm" @click="deleteItem(item.id)">Delete</button>
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
import { homestayApi } from '@/api'
import type { Homestay } from '@/types'

const loading = ref(false)
const homestays = ref<Homestay[]>([])
const filters = ref({ search: '', page: 1 })
const totalItems = ref(0)
const itemsPerPage = 10

const totalPages = computed(() => Math.ceil(totalItems.value / itemsPerPage))

async function fetchData() {
  loading.value = true
  try {
    const { data } = await homestayApi.list({ ...filters.value, page_size: itemsPerPage } as any)
    homestays.value = Array.isArray(data) ? data : data.results || []
    totalItems.value = Array.isArray(data) ? data.length : data.count || homestays.value.length
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

async function toggleVerification(item: Homestay) {
  try {
    const newStatus = !item.is_verified
    await homestayApi.update(item.id, { is_verified: newStatus } as any)
    item.is_verified = newStatus
  } catch (error) {
    Swal.fire({ title: 'Error', text: 'Failed to update verification status', icon: 'error' })
  }
}

async function deleteItem(id: number) {
  const result = await Swal.fire({ title: 'Are you sure?', text: 'Are you sure you want to delete this homestay?', icon: 'warning', showCancelButton: true });
  if (!result.isConfirmed) return
  try {
    await homestayApi.delete(id)
    fetchData()
  } catch (error) {
    Swal.fire({ title: 'Error', text: 'Failed to delete homestay', icon: 'error' })
  }
}

function getPhotoUrl(path?: string | null) {
  if (!path) return '/Logo.png'
  if (path.startsWith('http')) return path
  return `http://127.0.0.1:8000${path}`
}

onMounted(fetchData)
</script>

<style scoped>
.admin-homestays__header { display: flex; justify-content: space-between; align-items: flex-end; margin-bottom: 24px; }
.admin-title { font-family: 'Barlow Condensed', sans-serif; font-size: 2rem; font-style: italic; font-weight: 800; margin-bottom: 4px; }
.admin-subtitle { color: var(--w40); font-size: 0.9rem; }

.filter-bar { display: flex; gap: 12px; align-items: center; background: var(--dark2); }
.filter-group { flex: 1; min-width: 150px; }
.filter-group .form-input { width: 100%; }

.table-wrap { overflow-x: auto; }
.item-info { display: flex; align-items: center; gap: 12px; }
.item-img { width: 48px; height: 48px; border-radius: 8px; object-fit: cover; background: var(--w04); }
.item-name { font-weight: 600; color: #fff; font-size: 0.95rem; }

.location-info { color: #fff; font-size: 0.9rem; font-weight: 500; }
.location-sub { font-size: 0.75rem; color: var(--w40); }
.biz-name { color: var(--blue-b); font-size: 0.85rem; font-weight: 600; }

.action-btns { display: flex; gap: 8px; }
.btn-blue-outline { background: transparent; border: 1px solid var(--blue); color: var(--blue); }
.btn-blue-outline:hover { background: rgba(26,143,255,0.1); }

.pagination { display: flex; align-items: center; justify-content: center; gap: 16px; font-size: 0.9rem; color: var(--w70); }
</style>
