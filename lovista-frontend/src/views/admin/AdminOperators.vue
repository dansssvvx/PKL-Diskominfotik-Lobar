<template>
  <div class="admin-operators">
    <div class="admin-operators__header">
      <div>
        <h1 class="admin-title">Manage Operators</h1>
        <p class="admin-subtitle">View and verify travel agencies and homestay operators.</p>
      </div>
      <div class="header-stats">
        <div class="h-stat">
          <span class="h-stat__val">{{ operators.length }}</span>
          <span class="h-stat__lab">Total Operators</span>
        </div>
      </div>
    </div>

    <!-- Data Table -->
    <div class="card table-wrap mt-4">
      <table class="table">
        <thead>
          <tr>
            <th>Business / Agency</th>
            <th>Owner / Contact</th>
            <th>Assets</th>
            <th>Verification</th>
            <th>Account</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody v-if="loading">
          <tr><td colspan="6" style="text-align:center;padding:30px;"><div class="spinner"></div></td></tr>
        </tbody>
        <tbody v-else-if="operators.length === 0">
          <tr><td colspan="6" style="text-align:center;padding:30px;color:var(--w40);">No operators found.</td></tr>
        </tbody>
        <tbody v-else>
          <tr v-for="op in operators" :key="op.id">
            <td>
              <div class="agency-info">
                <div>
                  <div class="business-name">{{ op.agency_profile?.business_name || op.fullname }}</div>
                  <div class="license-no">{{ op.agency_profile?.license_number || 'Business Profile Not Completed' }}</div>
                </div>
              </div>
            </td>
            <td>
              <div class="owner-name">{{ op.fullname }}</div>
              <div class="owner-email">{{ op.email }}</div>
            </td>
            <td>
              <div class="asset-pills">
                <span class="pill" title="Packages">📦 {{ op.agency_profile?.package_count || 0 }}</span>
                <span class="pill" title="Vehicles">🚗 {{ op.agency_profile?.vehicle_count || 0 }}</span>
              </div>
            </td>
            <td>
              <span class="badge" :class="op.is_verified ? 'badge-success' : 'badge-warning'">
                {{ op.is_verified ? 'Verified' : 'Pending' }}
              </span>
            </td>
            <td>
              <button class="status-toggle" :class="{ 'is-active': op.is_active }" @click="toggleUserStatus(op)">
                {{ op.is_active ? 'Active' : 'Disabled' }}
              </button>
            </td>
            <td>
              <div class="action-btns">
                <button v-if="!op.is_verified" class="btn btn-blue btn-sm" @click="verifyOperator(op)">
                  Verify
                </button>
                <button class="btn btn-ghost btn-sm" @click="viewDetails(op)">Details</button>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <!-- Pagination -->
    <div class="pagination mt-4" v-if="totalPages > 1">
      <button class="btn btn-ghost btn-sm" :disabled="currentPage === 1" @click="currentPage--; fetchData()">Prev</button>
      <span>Page {{ currentPage }} of {{ totalPages }}</span>
      <button class="btn btn-ghost btn-sm" :disabled="currentPage === totalPages" @click="currentPage++; fetchData()">Next</button>
    </div>

    <!-- Operator Detail Modal -->
    <div class="modal-overlay" v-if="showDetailModal" @click.self="closeDetailModal">
      <div class="modal-content card detail-modal">
        <div class="modal-header">
          <h2 class="modal-title">Operator Details</h2>
          <button class="btn-close" @click="closeDetailModal">×</button>
        </div>
        <div class="modal-body" v-if="selectedOp">
          <div class="detail-header">
            <div class="detail-title-group">
              <h3 class="detail-biz-name">{{ selectedOp.agency_profile?.business_name || 'Individual Operator' }}</h3>
              <p class="detail-owner">Owned by {{ selectedOp.fullname }}</p>
              <div class="detail-badges">
                <span class="badge" :class="selectedOp.is_verified ? 'badge-success' : 'badge-warning'">
                  {{ selectedOp.is_verified ? 'Verified' : 'Pending Verification' }}
                </span>
                <span class="badge" :class="selectedOp.is_active ? 'badge-success' : 'badge-danger'">
                  Account {{ selectedOp.is_active ? 'Active' : 'Disabled' }}
                </span>
              </div>
            </div>
          </div>

          <div class="detail-grid mt-4">
            <div class="detail-section">
              <h4 class="section-label">Business Information</h4>
              <div class="info-row">
                <span class="info-label">License No:</span>
                <span class="info-val">{{ selectedOp.agency_profile?.license_number || 'N/A' }}</span>
              </div>
              <div class="info-row">
                <span class="info-label">Address:</span>
                <span class="info-val">{{ selectedOp.agency_profile?.address || 'No address provided' }}</span>
              </div>
              <div class="info-row">
                <span class="info-label">Member Since:</span>
                <span class="info-val">{{ formatDate(selectedOp.created_at) }}</span>
              </div>
            </div>

            <div class="detail-section">
              <h4 class="section-label">Contact Details</h4>
              <div class="info-row">
                <span class="info-label">Email:</span>
                <span class="info-val">{{ selectedOp.email }}</span>
              </div>
              <div class="info-row">
                <span class="info-label">Business Phone:</span>
                <span class="info-val">{{ selectedOp.agency_profile?.phone || selectedOp.phone || 'N/A' }}</span>
              </div>
            </div>
          </div>

          <div class="detail-section mt-4">
            <h4 class="section-label">Description</h4>
            <p class="detail-desc">{{ selectedOp.agency_profile?.description || 'No description provided.' }}</p>
          </div>

          <div class="detail-stats mt-4">
            <div class="stat-card">
              <span class="stat-num">{{ selectedOp.agency_profile?.package_count || 0 }}</span>
              <span class="stat-label">Tour Packages</span>
            </div>
            <div class="stat-card">
              <span class="stat-num">{{ selectedOp.agency_profile?.vehicle_count || 0 }}</span>
              <span class="stat-label">Vehicles for Rent</span>
            </div>
          </div>
        </div>
        <div class="modal-footer">
          <button class="btn btn-ghost" @click="closeDetailModal">Close</button>
          <button v-if="!selectedOp?.is_verified" class="btn btn-primary" @click="verifyOperator(selectedOp!)">
            Verify This Operator
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import Swal from 'sweetalert2'
import { ref, onMounted, computed } from 'vue'
import { adminApi } from '@/api'
import type { User } from '@/types'

const loading = ref(false)
const operators = ref<User[]>([])
const currentPage = ref(1)
const totalItems = ref(0)
const itemsPerPage = 10

const showDetailModal = ref(false)
const selectedOp = ref<User | null>(null)

const totalPages = computed(() => Math.ceil(totalItems.value / itemsPerPage))

async function fetchData() {
  loading.value = true
  try {
    // We use the same users endpoint but specifically for operators
    const { data } = await adminApi.users({ role: 'operator', page: currentPage.value, page_size: itemsPerPage } as any)
    operators.value = Array.isArray(data) ? data : data.results || []
    totalItems.value = Array.isArray(data) ? data.length : data.count || operators.value.length
  } catch (error) {
    console.error(error)
  } finally {
    loading.value = false
  }
}

async function verifyOperator(op: User) {
  const result = await Swal.fire({ title: 'Are you sure?', text: `Verify ${op.agency_profile?.business_name || op.fullname}?`, icon: 'warning', showCancelButton: true });
  if (!result.isConfirmed) return
  try {
    await adminApi.verifyOperator(op.id)
    op.is_verified = true
  } catch (error) {
    Swal.fire({ title: 'Notification', text: 'Verification failed', icon: 'info' })
  }
}

async function toggleUserStatus(op: User) {
  try {
    const { data } = await adminApi.toggleUserStatus(op.id)
    op.is_active = data.is_active
  } catch (error) {
    Swal.fire({ title: 'Notification', text: 'Failed to toggle status', icon: 'info' })
  }
}

function viewDetails(op: User) {
  selectedOp.value = op
  showDetailModal.value = true
}

function closeDetailModal() {
  showDetailModal.value = false
  selectedOp.value = null
}

function formatDate(dateString: string) {
  return new Date(dateString).toLocaleDateString('id-ID', {
    day: '2-digit', month: 'long', year: 'numeric'
  })
}

function getPhotoUrl(path?: string | null) {
  if (!path) return '/Logo.png'
  if (path.startsWith('http')) return path
  return `http://127.0.0.1:8000${path}`
}

onMounted(() => {
  fetchData()
})
</script>

<style scoped>
.admin-operators__header { display: flex; justify-content: space-between; align-items: flex-end; margin-bottom: 24px; }
.admin-title { font-family: 'Barlow Condensed', sans-serif; font-size: 2rem; font-style: italic; font-weight: 800; margin-bottom: 4px; }
.admin-subtitle { color: var(--w40); font-size: 0.9rem; }

.header-stats { display: flex; gap: 20px; }
.h-stat { text-align: right; }
.h-stat__val { display: block; font-size: 1.5rem; font-weight: 800; color: var(--blue-b); line-height: 1; }
.h-stat__lab { font-size: 0.7rem; text-transform: uppercase; color: var(--w40); letter-spacing: 1px; }

.mt-4 { margin-top: 24px; }

.table-wrap { overflow-x: auto; }
.agency-info { display: flex; align-items: center; gap: 12px; }
.agency-logo { width: 44px; height: 44px; border-radius: 8px; object-fit: cover; background: var(--w04); border: 1px solid var(--w08); }

.business-name { font-weight: 600; color: #fff; font-size: 0.95rem; }
.license-no { font-size: 0.7rem; color: var(--w40); font-family: monospace; }

.owner-name { font-size: 0.9rem; color: var(--w80); }
.owner-email { font-size: 0.75rem; color: var(--w40); }

.asset-pills { display: flex; gap: 6px; }
.pill { padding: 4px 8px; background: rgba(255,255,255,0.05); border-radius: 4px; font-size: 0.75rem; color: var(--w70); border: 1px solid var(--w08); }

.status-toggle {
  padding: 4px 12px; border-radius: 20px; font-size: 0.75rem; font-weight: 600;
  cursor: pointer; transition: all 0.2s; border: 1px solid var(--w15); background: transparent; color: var(--w40);
}
.status-toggle.is-active {
  background: rgba(74, 222, 128, 0.1); border-color: #4ade80; color: #4ade80;
}

.action-btns { display: flex; gap: 8px; }

.pagination { display: flex; align-items: center; justify-content: center; gap: 16px; font-size: 0.9rem; color: var(--w70); }

/* Detail Modal Styles */
.detail-modal { max-width: 700px; }
.detail-header { display: flex; gap: 20px; align-items: center; padding: 24px; background: rgba(255,255,255,0.02); border-bottom: 1px solid var(--w08); }
.detail-logo { width: 80px; height: 80px; border-radius: 12px; object-fit: cover; border: 2px solid var(--w08); }
.detail-biz-name { font-family: 'Barlow Condensed', sans-serif; font-size: 1.8rem; font-style: italic; font-weight: 700; color: #fff; margin-bottom: 4px; }
.detail-owner { color: var(--w40); font-size: 0.9rem; margin-bottom: 8px; }
.detail-badges { display: flex; gap: 8px; }

.modal-body { padding: 24px; }
.detail-grid { display: grid; grid-template-columns: 1.5fr 1fr; gap: 24px; }
.section-label { font-size: 0.7rem; text-transform: uppercase; color: var(--blue-b); letter-spacing: 1px; margin-bottom: 12px; border-bottom: 1px solid var(--w08); padding-bottom: 4px; }

.info-row { display: flex; flex-direction: column; margin-bottom: 12px; }
.info-label { font-size: 0.75rem; color: var(--w40); margin-bottom: 2px; }
.info-val { font-size: 0.9rem; color: var(--w90); }

.detail-desc { font-size: 0.9rem; color: var(--w70); line-height: 1.6; background: rgba(0,0,0,0.2); padding: 12px; border-radius: 8px; }

.detail-stats { display: flex; gap: 16px; }
.stat-card { flex: 1; padding: 16px; background: var(--dark3); border-radius: 12px; border: 1px solid var(--w08); text-align: center; }
.stat-num { display: block; font-size: 1.5rem; font-weight: 800; color: #fff; }
.stat-label { font-size: 0.75rem; color: var(--w40); }

/* Standard Modal Overlay */
.modal-overlay {
  position: fixed; top: 0; left: 0; width: 100%; height: 100%;
  background: rgba(0,0,0,0.8); backdrop-filter: blur(8px);
  display: flex; align-items: center; justify-content: center; z-index: 1000;
  padding: 20px;
}
.modal-content {
  width: 100%; max-height: 90vh; overflow-y: auto;
  position: relative; animation: modalSlide 0.3s ease-out;
}
@keyframes modalSlide {
  from { opacity: 0; transform: translateY(20px); }
  to { opacity: 1; transform: translateY(0); }
}
.modal-header { display: flex; justify-content: space-between; align-items: center; padding: 20px 24px; border-bottom: 1px solid var(--w08); }
.modal-title { font-family: 'Barlow Condensed', sans-serif; font-style: italic; font-weight: 700; font-size: 1.5rem; }
.btn-close { background: none; border: none; color: var(--w40); font-size: 1.8rem; cursor: pointer; }
.modal-footer { display: flex; justify-content: flex-end; gap: 12px; padding: 20px 24px; border-top: 1px solid var(--w08); }
</style>