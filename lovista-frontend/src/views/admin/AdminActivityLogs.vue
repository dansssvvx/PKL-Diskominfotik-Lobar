<template>
  <div class="admin-logs">
    <div class="admin-logs__header">
      <div>
        <h1 class="admin-title">Activity Logs</h1>
        <p class="admin-subtitle">System-wide audit trail of user and administrative actions.</p>
      </div>
    </div>

    <!-- Filters -->
    <div class="card p-4 mb-4 filter-bar mt-4">
      <div class="filter-group">
        <label style="margin-left: 10px; margin-top: 10px;">Items per page</label>
        <select v-model="filters.page_size" class="form-select" style="margin-left: 10px; margin-bottom: 10px;" @change="handleFilterChange">
          <option :value="5">5</option>
          <option :value="10">10</option>
          <option :value="25">25</option>
          <option :value="100">100</option>
        </select>
      </div>
      <div class="filter-group">
        <label style="margin-left: 10px; margin-top: 10px;">Date From</label>
        <input v-model="filters.date_from" type="date" class="form-input" style="margin-left: 10px; margin-bottom: 10px;" @change="handleFilterChange" />
      </div>
      <div class="filter-group">
        <label style="margin-left: 10px; margin-top: 10px;">Date To</label>
        <input v-model="filters.date_to" type="date" class="form-input" style="margin-left: 10px;  margin-bottom: 10px;" @change="handleFilterChange" />
      </div>
      <button class="btn btn-ghost align-self-end" style="margin-left: 10px; margin-bottom: 10px; margin-right: 10px;" @click="handleFilterChange">Refresh</button>
    </div>

    <!-- Data Table -->
    <div class="card table-wrap mt-4">
      <table class="table">
        <thead>
          <tr>
            <th>User</th>
            <th>Action</th>
            <th>Entity</th>
            <th>Timestamp</th>
            <th>IP Address</th>
          </tr>
        </thead>
        <tbody v-if="loading">
          <tr><td colspan="5" style="text-align:center;padding:30px;"><div class="spinner"></div></td></tr>
        </tbody>
        <tbody v-else-if="logs.length === 0">
          <tr><td colspan="5" style="text-align:center;padding:30px;color:var(--w40);">No activity logs found.</td></tr>
        </tbody>
        <tbody v-else>
          <tr v-for="log in logs" :key="log.id">
            <td>
              <div style="font-weight: 600; color: #fff;">{{ log.user_fullname || 'System' }}</div>
              <div style="font-size: 0.75rem; color: var(--w40);" v-if="log.user">User ID: {{ log.user }}</div>
            </td>
            <td>
              <span class="badge badge-blue">{{ log.action }}</span>
            </td>
            <td>
              <div v-if="log.entity_type">
                <div style="font-size: 0.85rem; color: var(--w70);">{{ log.entity_type }}</div>
                <div style="font-size: 0.75rem; color: var(--w40);">Ref ID: #{{ log.entity_id }}</div>
              </div>
              <span v-else>-</span>
            </td>
            <td>{{ formatFullDate(log.created_at) }}</td>
            <td style="font-family: monospace; font-size: 0.8rem; color: var(--w40);">
              {{ log.ip_address || '-' }}
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <!-- Pagination -->
    <div class="pagination mt-4" v-if="totalPages > 1">
      <button class="btn btn-ghost btn-sm" :disabled="filters.page === 1" @click="changePage(filters.page - 1)">Prev</button>
      <span>Page {{ filters.page }} of {{ totalPages }}</span>
      <button class="btn btn-ghost btn-sm" :disabled="filters.page === totalPages" @click="changePage(filters.page + 1)">Next</button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { adminApi } from '@/api'
import type { ActivityLog } from '@/types'

const loading = ref(false)
const logs = ref<ActivityLog[]>([])
const totalItems = ref(0)

const filters = ref({
  page: 1,
  page_size: 10,
  date_from: '',
  date_to: ''
})

const totalPages = computed(() => Math.ceil(totalItems.value / filters.value.page_size))

async function fetchData() {
  loading.value = true
  try {
    const { data } = await adminApi.activityLogs(filters.value)
    logs.value = Array.isArray(data) ? data : data.results || []
    totalItems.value = Array.isArray(data) ? data.length : data.count || logs.value.length
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

function changePage(p: number) {
  filters.value.page = p
  fetchData()
}

function formatFullDate(dateString: string) {
  return new Date(dateString).toLocaleString('id-ID', {
    day: '2-digit', month: 'short', year: 'numeric',
    hour: '2-digit', minute: '2-digit', second: '2-digit'
  })
}

onMounted(() => {
  fetchData()
})
</script>

<style scoped>
.admin-logs__header { display: flex; justify-content: space-between; align-items: flex-end; margin-bottom: 24px; }
.admin-title { font-family: 'Barlow Condensed', sans-serif; font-size: 2rem; font-style: italic; font-weight: 800; margin-bottom: 4px; }
.admin-subtitle { color: var(--w40); font-size: 0.9rem; }

.mt-4 { margin-top: 24px; }

.filter-bar { display: flex; gap: 12px; align-items: flex-end; background: var(--dark2); }
.filter-group { flex: 1; min-width: 150px; }
.filter-group label { display: block; font-size: 0.8rem; color: var(--w40); margin-bottom: 8px; text-transform: uppercase; letter-spacing: 0.5px; }
.filter-group .form-input, .filter-group .form-select { width: 100%; }

.table-wrap { overflow-x: auto; }
.pagination { display: flex; align-items: center; justify-content: center; gap: 16px; font-size: 0.9rem; color: var(--w70); }
</style>