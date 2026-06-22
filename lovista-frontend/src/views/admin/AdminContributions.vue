<template>
  <div class="admin-contrib">
    <div class="admin-contrib__header">
      <div>
        <h1 class="admin-title">Review Contributions</h1>
        <p class="admin-subtitle">Review content submitted by users and operators.</p>
      </div>
    </div>

    <!-- Filters -->
    <div class="card p-4 mb-4 filter-bar">
      <select v-model="filters.type" class="form-select" @change="fetchData">
        <option value="">All Types</option>
        <option value="destination">Destination</option>
        <option value="culinary">Culinary</option>
        <option value="culture">Culture</option>
      </select>
      <select v-model="filters.status" class="form-select" @change="fetchData">
        <option value="">All Statuses</option>
        <option value="pending">Pending</option>
        <option value="approved">Approved</option>
        <option value="rejected">Rejected</option>
        <option value="revision_requested">Revision Requested</option>
      </select>
      <button class="btn btn-ghost" @click="fetchData">Filter</button>
    </div>

    <!-- Data Table -->
    <div class="card table-wrap">
      <table class="table">
        <thead>
          <tr>
            <th>Contributor</th>
            <th>Type</th>
            <th>Submitted At</th>
            <th>Status</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody v-if="loading">
          <tr><td colspan="5" style="text-align:center;padding:30px;"><div class="spinner"></div></td></tr>
        </tbody>
        <tbody v-else-if="contributions.length === 0">
          <tr><td colspan="5" style="text-align:center;padding:30px;color:var(--w40);">No contributions found.</td></tr>
        </tbody>
        <tbody v-else>
          <tr v-for="c in contributions" :key="c.id">
            <td>
              <div style="font-weight: 600; color: #fff;">{{ c.contributor?.fullname || 'Unknown' }}</div>
              <div style="font-size: 0.75rem; color: var(--w40);">{{ c.contributor?.email }}</div>
            </td>
            <td>
              <span class="badge badge-blue" style="text-transform: capitalize;">{{ c.type }}</span>
            </td>
            <td>{{ formatDate(c.submitted_at) }}</td>
            <td>
              <span class="badge" :class="getStatusBadge(c.status)">
                {{ c.status.replace('_', ' ') }}
              </span>
            </td>
            <td>
              <div class="action-btns" v-if="c.status === 'pending'">
                <button class="btn btn-success btn-sm" @click="reviewContribution(c.id, 'approve')">Approve</button>
                <button class="btn btn-danger btn-sm" @click="reviewContribution(c.id, 'reject')">Reject</button>
              </div>
              <div v-else>
                <span style="font-size: 0.8rem; color: var(--w40);">Reviewed</span>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script setup lang="ts">
import Swal from 'sweetalert2'
import { ref, onMounted } from 'vue'
import { contributionApi } from '@/api'
import type { Contribution } from '@/types'

const loading = ref(false)
const contributions = ref<Contribution[]>([])
const filters = ref({ type: '', status: 'pending' }) // Default to pending

async function fetchData() {
  loading.value = true
  try {
    const { data } = await contributionApi.list(filters.value)
    contributions.value = Array.isArray(data) ? data : data.results || []
  } catch (error) {
    console.error(error)
  } finally {
    loading.value = false
  }
}

async function reviewContribution(id: number, action: 'approve' | 'reject') {
  const result = await Swal.fire({ title: 'Are you sure?', text: `Are you sure you want to ${action} this contribution?`, icon: 'warning', showCancelButton: true });
  if (!result.isConfirmed) return
  try {
    await contributionApi.review(id, action)
    // Update local state instead of refetching to be faster
    const target = contributions.value.find(c => c.id === id)
    if (target) {
      target.status = action === 'approve' ? 'approved' : 'rejected'
    }
  } catch (error) {
    console.error(error)
    Swal.fire({ title: 'Notification', text: `Failed to ${action} contribution`, icon: 'info' })
  }
}

function formatDate(dateString: string) {
  return new Date(dateString).toLocaleDateString('id-ID', {
    day: '2-digit', month: 'short', year: 'numeric',
    hour: '2-digit', minute: '2-digit'
  })
}

function getStatusBadge(status: string) {
  switch (status) {
    case 'approved': return 'badge-success'
    case 'pending': return 'badge-warning'
    case 'rejected': return 'badge-danger'
    case 'revision_requested': return 'badge-blue'
    default: return 'badge-gray'
  }
}

onMounted(() => {
  fetchData()
})
</script>

<style scoped>
.admin-contrib__header { display: flex; justify-content: space-between; align-items: flex-end; margin-bottom: 24px; }
.admin-title { font-family: 'Barlow Condensed', sans-serif; font-size: 2rem; font-style: italic; font-weight: 800; margin-bottom: 4px; }
.admin-subtitle { color: var(--w40); font-size: 0.9rem; }

.p-4 { padding: 16px; }
.mb-4 { margin-bottom: 24px; }

.filter-bar { display: flex; gap: 16px; align-items: center; }

.table-wrap { overflow-x: auto; }
.action-btns { display: flex; gap: 8px; }
</style>