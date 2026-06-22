<template>
  <div class="op-contributions">
    <!-- Header -->
    <div class="page-header">
      <div>
        <h1 class="admin-title">Contributions</h1>
        <p class="admin-subtitle">Kelola kontribusi konten wisata yang Anda ajukan.</p>
      </div>
      <button class="btn btn-primary" @click="openAddModal">+ New Contribution</button>
    </div>

    <!-- Stats -->
    <div class="contrib-stats" v-if="!loading">
      <div class="cs-card" v-for="s in statsCards" :key="s.label">
        <div class="cs-value" :class="s.color">{{ s.value }}</div>
        <div class="cs-label">{{ s.label }}</div>
      </div>
    </div>

    <!-- Filters -->
    <div class="card filter-bar">
      <div class="filter-group">
        <input v-model="filters.search" type="text" class="form-input" placeholder="Search contributions..." @keyup.enter="fetchData" />
      </div>
      <div class="filter-group">
        <select v-model="filters.type" class="form-select" @change="handleFilterChange">
          <option value="">All Types</option>
          <option value="destination">Destination</option>
          <option value="culinary">Culinary</option>
          <option value="culture">Culture</option>
          <option value="other">Other</option>
        </select>
      </div>
      <div class="filter-group">
        <select v-model="filters.status" class="form-select" @change="handleFilterChange">
          <option value="">All Statuses</option>
          <option value="pending">Pending</option>
          <option value="approved">Approved</option>
          <option value="rejected">Rejected</option>
          <option value="revision_requested">Revision Needed</option>
        </select>
      </div>
      <button class="btn btn-ghost" @click="fetchData">🔄 Refresh</button>
    </div>

    <!-- Table -->
    <div class="card table-wrap">
      <table class="table">
        <thead>
          <tr>
            <th>Type</th>
            <th>Content</th>
            <th>Submitted</th>
            <th>Status</th>
            <th>Reviewer Notes</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody v-if="loading">
          <tr><td colspan="6" style="text-align:center;padding:40px"><div class="spinner"></div></td></tr>
        </tbody>
        <tbody v-else-if="filtered.length === 0">
          <tr>
            <td colspan="6">
              <div class="empty-state">
                <div class="icon">📝</div>
                <h3>No contributions yet</h3>
                <p>Submit new tourism content to contribute to the LoVista platform.</p>
                <button class="btn btn-primary" style="margin-top:16px" @click="openAddModal">+ New Contribution</button>
              </div>
            </td>
          </tr>
        </tbody>
        <tbody v-else>
          <tr v-for="c in filtered" :key="c.id">
            <td>
              <span class="badge badge-blue" style="text-transform:capitalize">{{ c.type }}</span>
            </td>
            <td>
              <div class="content-preview">
                <div class="content-name">{{ getContentName(c) }}</div>
                <div class="content-id" v-if="c.entity_id">Entity #{{ c.entity_id }}</div>
              </div>
            </td>
            <td>
              <div class="date-val">{{ formatDate(c.submitted_at) }}</div>
              <div class="date-sub" v-if="c.reviewed_at">Reviewed: {{ formatDate(c.reviewed_at) }}</div>
            </td>
            <td>
              <span class="badge" :class="statusBadge(c.status)">{{ c.status.replace('_', ' ') }}</span>
            </td>
            <td>
              <div class="reviewer-notes" v-if="c.rejection_reason || c.revision_notes">
                {{ c.rejection_reason || c.revision_notes }}
              </div>
              <span v-else class="text-muted">—</span>
            </td>
            <td>
              <div class="action-btns">
                <button class="btn btn-ghost btn-sm" @click="viewDetail(c)">View</button>
                <button class="btn btn-ghost btn-sm" v-if="c.status === 'pending' || c.status === 'revision_requested'" @click="openEditModal(c)">Edit</button>
                <button class="btn btn-danger btn-sm" v-if="c.status === 'pending'" @click="openDeleteModal(c)">Delete</button>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <!-- Pagination -->
    <div class="pagination mt-4" v-if="totalPages > 1">
      <button class="btn btn-ghost btn-sm" :disabled="filters.page === 1" @click="filters.page--; fetchData()">← Prev</button>
      <span>Page {{ filters.page }} of {{ totalPages }}</span>
      <button class="btn btn-ghost btn-sm" :disabled="filters.page === totalPages" @click="filters.page++; fetchData()">Next →</button>
    </div>

    <!-- Add/Edit Contribution Modal -->
    <div class="modal-overlay" v-if="showModal" @click.self="closeModal">
      <div class="modal-content card">
        <div class="modal-header">
          <h2 class="modal-title">{{ isEditing ? 'Edit Contribution' : 'New Contribution' }}</h2>
          <button class="btn-close" @click="closeModal">×</button>
        </div>
        <form @submit.prevent="handleSubmit" class="modal-form">
          <div class="form-grid">
            <div class="form-group">
              <label class="form-label">Contribution Type *</label>
              <select v-model="form.type" class="form-select" required>
                <option value="">Select Type</option>
                <option value="destination">Destination</option>
                <option value="culinary">Culinary</option>
                <option value="culture">Culture</option>
                <option value="other">Other</option>
              </select>
            </div>
            <div class="form-group">
              <label class="form-label">Entity ID (Optional)</label>
              <input v-model.number="form.entity_id" type="number" class="form-input" placeholder="Existing entity to update" />
            </div>
            <div class="form-group full-width">
              <label class="form-label">Name *</label>
              <input v-model="form.data.name" type="text" class="form-input" placeholder="Name of the place or item..." required />
            </div>
            <div class="form-group full-width">
              <label class="form-label">Description *</label>
              <textarea v-model="form.data.description" class="form-input" rows="4" placeholder="Describe this contribution..." required></textarea>
            </div>
            <div class="form-group">
              <label class="form-label">Location / Village</label>
              <input v-model="form.data.location" type="text" class="form-input" placeholder="e.g. Senggigi" />
            </div>
            <div class="form-group">
              <label class="form-label">District (Kecamatan)</label>
              <input v-model="form.data.district" type="text" class="form-input" placeholder="e.g. Batu Layar" />
            </div>
            <div class="form-group">
              <label class="form-label">Contact / Phone</label>
              <input v-model="form.data.contact" type="text" class="form-input" placeholder="+62..." />
            </div>
            <div class="form-group">
              <label class="form-label">Image URL</label>
              <input v-model="form.data.image_url" type="url" class="form-input" placeholder="https://..." />
            </div>
            <div class="form-group full-width" v-if="form.type === 'culinary'">
              <label class="form-label">Price Range</label>
              <input v-model="form.data.price_range" type="text" class="form-input" placeholder="e.g. Rp 20.000 - 50.000" />
            </div>
            <div class="form-group full-width" v-if="form.type === 'culture'">
              <label class="form-label">Event Date / Frequency</label>
              <input v-model="form.data.event_frequency" type="text" class="form-input" placeholder="e.g. Every Nyepi Day" />
            </div>
          </div>

          <div class="modal-footer">
            <button type="button" class="btn btn-ghost" @click="closeModal">Cancel</button>
            <button type="submit" class="btn btn-primary" :disabled="submitting">
              <span v-if="submitting" class="btn-spinner"></span>
              {{ submitting ? 'Submitting...' : (isEditing ? 'Update Contribution' : 'Submit Contribution') }}
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- View Detail Modal -->
    <div class="modal-overlay" v-if="showDetailModal" @click.self="showDetailModal = false">
      <div class="modal-content card" style="max-width:600px">
        <div class="modal-header">
          <h2 class="modal-title">Contribution Detail</h2>
          <button class="btn-close" @click="showDetailModal = false">×</button>
        </div>
        <div class="modal-body" v-if="detailItem">
          <div class="detail-info-grid">
            <div class="di-row">
              <span class="di-label">Type</span>
              <span class="badge badge-blue" style="text-transform:capitalize">{{ detailItem.type }}</span>
            </div>
            <div class="di-row">
              <span class="di-label">Status</span>
              <span class="badge" :class="statusBadge(detailItem.status)">{{ detailItem.status.replace('_', ' ') }}</span>
            </div>
            <div class="di-row">
              <span class="di-label">Submitted</span>
              <span>{{ formatDate(detailItem.submitted_at) }}</span>
            </div>
            <div class="di-row" v-if="detailItem.reviewed_at">
              <span class="di-label">Reviewed</span>
              <span>{{ formatDate(detailItem.reviewed_at) }}</span>
            </div>
          </div>
          <div class="divider"></div>
          <div class="detail-data">
            <h4 class="detail-data-title">Submitted Data</h4>
            <pre class="data-preview">{{ JSON.stringify(detailItem.data, null, 2) }}</pre>
          </div>
          <div v-if="detailItem.rejection_reason || detailItem.revision_notes" class="review-notes">
            <h4 class="review-notes-title">Reviewer Notes</h4>
            <p>{{ detailItem.rejection_reason || detailItem.revision_notes }}</p>
          </div>
        </div>
        <div class="modal-footer">
          <button class="btn btn-ghost" @click="showDetailModal = false">Close</button>
        </div>
      </div>
    </div>

    <!-- Delete Confirm -->
    <div class="modal-overlay" v-if="showDeleteModal" @click.self="showDeleteModal = false">
      <div class="modal-content card" style="max-width:400px">
        <div class="modal-header">
          <h2 class="modal-title">Delete Contribution</h2>
          <button class="btn-close" @click="showDeleteModal = false">×</button>
        </div>
        <div class="modal-body">
          <p style="color:var(--w70);margin-bottom:8px">Delete this contribution?</p>
          <p style="color:var(--w40);font-size:.85rem">Only pending contributions can be deleted.</p>
        </div>
        <div class="modal-footer">
          <button class="btn btn-ghost" @click="showDeleteModal = false">Cancel</button>
          <button class="btn btn-danger" :disabled="submitting" @click="confirmDelete">
            {{ submitting ? 'Deleting...' : 'Delete' }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { contributionApi } from '@/api'
import api from '@/api'
import type { Contribution } from '@/types'

const loading = ref(false)
const submitting = ref(false)
const showModal = ref(false)
const showDetailModal = ref(false)
const showDeleteModal = ref(false)
const isEditing = ref(false)
const currentId = ref<number | null>(null)
const detailItem = ref<Contribution | null>(null)
const deleteTarget = ref<Contribution | null>(null)

const contributions = ref<Contribution[]>([])
const filters = ref({ search: '', type: '', status: '', page: 1 })
const totalItems = ref(0)
const itemsPerPage = 15
const totalPages = computed(() => Math.ceil(totalItems.value / itemsPerPage))

const form = ref({
  type: '' as any,
  entity_id: null as number | null,
  data: {
    name: '',
    description: '',
    location: '',
    district: '',
    contact: '',
    image_url: '',
    price_range: '',
    event_frequency: '',
  },
})

const filtered = computed(() => {
  if (!filters.value.search) return contributions.value
  const q = filters.value.search.toLowerCase()
  return contributions.value.filter(c => {
    const name = getContentName(c).toLowerCase()
    return name.includes(q) || c.type.includes(q)
  })
})

const statsCards = computed(() => {
  const all = contributions.value
  return [
    { label: 'Total Submitted', value: all.length, color: '' },
    { label: 'Pending Review', value: all.filter(c => c.status === 'pending').length, color: 'text-warning' },
    { label: 'Approved', value: all.filter(c => c.status === 'approved').length, color: 'text-success' },
    { label: 'Rejected', value: all.filter(c => c.status === 'rejected').length, color: 'text-danger' },
  ]
})

async function fetchData() {
  loading.value = true
  try {
    const params: any = { page: filters.value.page, page_size: itemsPerPage }
    if (filters.value.type) params.type = filters.value.type
    if (filters.value.status) params.status = filters.value.status
    const { data } = await contributionApi.list(params)
    contributions.value = Array.isArray(data) ? data : data.results || []
    totalItems.value = Array.isArray(data) ? data.length : data.count || contributions.value.length
  } catch (err) {
    console.error(err)
  } finally {
    loading.value = false
  }
}

function handleFilterChange() { filters.value.page = 1; fetchData() }

function openAddModal() {
  isEditing.value = false
  currentId.value = null
  resetForm()
  showModal.value = true
}

function openEditModal(c: Contribution) {
  isEditing.value = true
  currentId.value = c.id
  form.value = {
    type: c.type,
    entity_id: c.entity_id,
    data: {
      name: (c.data as any).name || '',
      description: (c.data as any).description || '',
      location: (c.data as any).location || '',
      district: (c.data as any).district || '',
      contact: (c.data as any).contact || '',
      image_url: (c.data as any).image_url || '',
      price_range: (c.data as any).price_range || '',
      event_frequency: (c.data as any).event_frequency || '',
    },
  }
  showModal.value = true
}

function closeModal() { showModal.value = false; resetForm() }

function resetForm() {
  form.value = {
    type: '', entity_id: null,
    data: { name: '', description: '', location: '', district: '', contact: '', image_url: '', price_range: '', event_frequency: '' },
  }
}

async function handleSubmit() {
  submitting.value = true
  try {
    // Clean empty data fields
    const cleanData: Record<string, any> = {}
    Object.entries(form.value.data).forEach(([k, v]) => { if (v) cleanData[k] = v })

    const payload: any = {
      type: form.value.type,
      data: cleanData,
    }
    if (form.value.entity_id) payload.entity_id = form.value.entity_id

    if (isEditing.value && currentId.value) {
      await api.patch(`/contributions/${currentId.value}/`, payload)
    } else {
      await contributionApi.submit(payload)
    }
    showModal.value = false
    fetchData()
  } catch (err: any) {
    alert(err.response?.data ? JSON.stringify(err.response.data) : 'Failed to submit contribution.')
  } finally {
    submitting.value = false
  }
}

function viewDetail(c: Contribution) {
  detailItem.value = c
  showDetailModal.value = true
}

function openDeleteModal(c: Contribution) { deleteTarget.value = c; showDeleteModal.value = true }

async function confirmDelete() {
  if (!deleteTarget.value) return
  submitting.value = true
  try {
    await api.delete(`/contributions/${deleteTarget.value.id}/`)
    showDeleteModal.value = false; deleteTarget.value = null; fetchData()
  } catch { alert('Failed to delete contribution.') }
  finally { submitting.value = false }
}

function getContentName(c: Contribution): string {
  return (c.data as any)?.name || `${c.type} #${c.id}`
}

function formatDate(d?: string) {
  if (!d) return '-'
  return new Date(d).toLocaleString('id-ID', { day: '2-digit', month: 'short', year: 'numeric', hour: '2-digit', minute: '2-digit' })
}

function statusBadge(s: string) {
  switch (s) {
    case 'approved': return 'badge-success'
    case 'pending': return 'badge-warning'
    case 'rejected': return 'badge-danger'
    case 'revision_requested': return 'badge-blue'
    default: return 'badge-gray'
  }
}

onMounted(fetchData)
</script>

<style scoped>
.page-header { display: flex; justify-content: space-between; align-items: flex-end; margin-bottom: 24px; }
.admin-title { font-family: 'Barlow Condensed', sans-serif; font-size: 2rem; font-style: italic; font-weight: 800; margin-bottom: 4px; }
.admin-subtitle { color: var(--w40); font-size: 0.9rem; }

.contrib-stats { display: grid; grid-template-columns: repeat(4,1fr); gap: 12px; margin-bottom: 24px; }
.cs-card { background: var(--dark2); border: 1px solid var(--w08); border-radius: 12px; padding: 16px; text-align: center; }
.cs-value { font-family: 'Bebas Neue', sans-serif; font-size: 2rem; letter-spacing: 1px; margin-bottom: 4px; }
.cs-label { font-size: .7rem; color: var(--w40); text-transform: uppercase; letter-spacing: .8px; }
.text-warning { color: #fbbf24; }
.text-success { color: #4ade80; }
.text-danger { color: #f87171; }

.filter-bar { display: flex; gap: 12px; align-items: center; padding: 16px; margin-bottom: 24px; flex-wrap: wrap; }
.filter-group { flex: 1; min-width: 140px; }
.filter-group .form-input, .filter-group .form-select { width: 100%; }

.table-wrap { overflow-x: auto; }
.content-preview {}
.content-name { font-weight: 600; color: #fff; }
.content-id { font-size: .72rem; color: var(--w40); }
.date-val { font-size: .85rem; }
.date-sub { font-size: .72rem; color: var(--w40); }
.reviewer-notes { font-size: .82rem; color: var(--w40); max-width: 200px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.text-muted { color: var(--w40); }
.action-btns { display: flex; gap: 6px; flex-wrap: wrap; }
.pagination { display: flex; align-items: center; justify-content: center; gap: 16px; font-size: .9rem; color: var(--w70); }
.mt-4 { margin-top: 24px; }

/* Detail Modal */
.detail-info-grid { display: flex; flex-direction: column; gap: 12px; }
.di-row { display: flex; justify-content: space-between; align-items: center; }
.di-label { font-size: .72rem; color: var(--w40); text-transform: uppercase; letter-spacing: .8px; }
.divider { height: 1px; background: var(--w08); margin: 16px 0; }
.detail-data-title { font-size: .82rem; color: var(--w40); text-transform: uppercase; letter-spacing: .8px; margin-bottom: 10px; }
.data-preview {
  background: var(--dark3); border: 1px solid var(--w08); border-radius: 8px;
  padding: 12px; font-size: .78rem; color: var(--w70);
  overflow: auto; max-height: 200px; white-space: pre-wrap; font-family: monospace;
}
.review-notes { margin-top: 16px; background: rgba(239,68,68,.08); border: 1px solid rgba(239,68,68,.2); border-radius: 8px; padding: 12px; }
.review-notes-title { font-size: .72rem; color: #f87171; text-transform: uppercase; letter-spacing: .8px; margin-bottom: 6px; }
.review-notes p { color: var(--w70); font-size: .88rem; }

/* Modal */
.modal-overlay { position: fixed; inset: 0; background: rgba(0,0,0,.8); backdrop-filter: blur(8px); display: flex; align-items: center; justify-content: center; z-index: 1000; padding: 20px; }
.modal-content { width: 100%; max-width: 680px; max-height: 90vh; overflow-y: auto; animation: modalSlide .3s ease-out; }
@keyframes modalSlide { from{opacity:0;transform:translateY(20px)} to{opacity:1;transform:translateY(0)} }
.modal-header { display: flex; justify-content: space-between; align-items: center; padding: 20px 24px; border-bottom: 1px solid var(--w08); }
.modal-title { font-family: 'Barlow Condensed', sans-serif; font-style: italic; font-weight: 700; font-size: 1.5rem; }
.btn-close { background: none; border: none; color: var(--w40); font-size: 1.8rem; cursor: pointer; }
.modal-form { padding: 24px; }
.modal-body { padding: 24px; }
.modal-footer { display: flex; justify-content: flex-end; gap: 12px; padding: 16px 24px; border-top: 1px solid var(--w08); }
.form-grid { display: grid; grid-template-columns: repeat(2, 1fr); gap: 16px; }
.full-width { grid-column: span 2; }
.form-label { display: block; font-size: .72rem; font-weight: 600; color: var(--w40); text-transform: uppercase; letter-spacing: .8px; margin-bottom: 6px; }
.btn-spinner { width: 14px; height: 14px; border-radius: 50%; border: 2px solid rgba(255,255,255,.3); border-top-color: #fff; animation: spin .7s linear infinite; }
@keyframes spin { to { transform: rotate(360deg); } }

@media (max-width: 768px) {
  .contrib-stats { grid-template-columns: repeat(2,1fr); }
}
</style>
