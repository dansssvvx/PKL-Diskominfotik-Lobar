<template>
  <div class="admin-settings">
    <div class="admin-settings__header">
      <div>
        <h1 class="admin-title">Platform Settings</h1>
        <p class="admin-subtitle">Manage global configuration, site info, and operational parameters.</p>
      </div>
      <button class="btn btn-primary" @click="fetchData" :disabled="loading">
        {{ loading ? 'Syncing...' : 'Refresh Settings' }}
      </button>
    </div>

    <!-- Settings Grid -->
    <div class="settings-container mt-4">
      <div v-if="loading" class="card p-5" style="text-align:center">
        <div class="spinner"></div>
        <p class="mt-2 color-w40">Loading platform configuration...</p>
      </div>

      <div v-else class="settings-content">
        <!-- Site Info Group -->
        <div class="card mb-4">
          <div class="group-header">
            <h3 class="group-title">General Information</h3>
            <p class="group-desc">Core platform identity and public branding.</p>
          </div>
          <table class="settings-table">
            <thead>
              <tr>
                <th style="width: 250px">Setting Key</th>
                <th>Current Value</th>
                <th style="width: 120px">Action</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="s in generalSettings" :key="s.id">
                <td>
                  <div class="key-name">{{ formatKey(s.key_name) }}</div>
                  <div class="key-desc">{{ s.description || 'Global identity value' }}</div>
                </td>
                <td>
                  <div v-if="editingId !== s.id" class="val-display">
                    {{ s.value || '(Empty)' }}
                  </div>
                  <input 
                    v-else 
                    v-model="editValue" 
                    type="text" 
                    class="form-input" 
                    @keyup.enter="saveSetting(s)"
                    @keyup.esc="cancelEdit"
                    auto-focus
                  />
                </td>
                <td>
                  <button v-if="editingId !== s.id" class="btn btn-ghost btn-sm" @click="startEdit(s)">Edit</button>
                  <div v-else class="edit-actions">
                    <button class="btn btn-blue btn-sm" @click="saveSetting(s)">Save</button>
                    <button class="btn btn-ghost btn-sm" @click="cancelEdit">×</button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>

        <!-- System Config Group -->
        <div class="card">
          <div class="group-header">
            <h3 class="group-title">Platform Configuration</h3>
            <p class="group-desc">Internal limits, fees, and system behaviors.</p>
          </div>
          <table class="settings-table">
            <thead>
              <tr>
                <th style="width: 250px">Configuration</th>
                <th>Value</th>
                <th style="width: 120px">Action</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="s in configSettings" :key="s.id">
                <td>
                  <div class="key-name">{{ formatKey(s.key_name) }}</div>
                  <div class="key-desc">{{ s.description || 'System behavior parameter' }}</div>
                </td>
                <td>
                  <div v-if="editingId !== s.id" class="val-display">
                    <span v-if="s.type === 'number'" class="val-num">{{ s.value }}</span>
                    <span v-else>{{ s.value || '(Empty)' }}</span>
                  </div>
                  <input 
                    v-else 
                    v-model="editValue" 
                    :type="s.type === 'number' ? 'number' : 'text'" 
                    class="form-input" 
                    @keyup.enter="saveSetting(s)"
                  />
                </td>
                <td>
                  <button v-if="editingId !== s.id" class="btn btn-ghost btn-sm" @click="startEdit(s)">Edit</button>
                  <div v-else class="edit-actions">
                    <button class="btn btn-blue btn-sm" @click="saveSetting(s)">Save</button>
                    <button class="btn btn-ghost btn-sm" @click="cancelEdit">×</button>
                  </div>
                </td>
              </tr>
              <tr v-if="configSettings.length === 0">
                <td colspan="3" class="empty-row">No specific configuration keys found.</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import Swal from 'sweetalert2'
import { ref, onMounted, computed } from 'vue'
import { settingApi } from '@/api'

const loading = ref(false)
const settings = ref<any[]>([])
const editingId = ref<number | null>(null)
const editValue = ref('')

const generalSettings = computed(() => 
  settings.value.filter(s => s.type === 'site' || !['config', 'fee', 'limit'].includes(s.type))
)

const configSettings = computed(() => 
  settings.value.filter(s => ['config', 'fee', 'limit', 'number'].includes(s.type))
)

async function fetchData() {
  loading.value = true
  try {
    const { data } = await settingApi.list()
    settings.value = data
  } catch (error) {
    console.error('Failed to load settings:', error)
  } finally {
    loading.value = false
  }
}

function startEdit(setting: any) {
  editingId.value = setting.id
  editValue.value = setting.value
}

function cancelEdit() {
  editingId.value = null
  editValue.value = ''
}

async function saveSetting(setting: any) {
  if (editValue.value === setting.value) {
    cancelEdit()
    return
  }
  
  try {
    await settingApi.update(setting.id, { value: editValue.value })
    setting.value = editValue.value
    cancelEdit()
  } catch (error) {
    Swal.fire({ title: 'Notification', text: 'Failed to update setting', icon: 'info' })
  }
}

function formatKey(key: string) {
  return key.split('_').map(word => word.charAt(0).toUpperCase() + word.slice(1)).join(' ')
}

onMounted(() => {
  fetchData()
})
</script>

<style scoped>
.admin-settings__header { display: flex; justify-content: space-between; align-items: flex-end; margin-bottom: 24px; }
.admin-title { font-family: 'Barlow Condensed', sans-serif; font-size: 2rem; font-style: italic; font-weight: 800; margin-bottom: 4px; }
.admin-subtitle { color: var(--w40); font-size: 0.9rem; }

.group-header { padding: 20px 24px; border-bottom: 1px solid var(--w08); }
.group-title { font-family: 'Barlow Condensed', sans-serif; font-size: 1.3rem; font-style: italic; font-weight: 700; color: var(--blue-b); }
.group-desc { font-size: 0.8rem; color: var(--w40); }

.settings-table { width: 100%; border-collapse: collapse; }
.settings-table th { text-align: left; padding: 12px 24px; font-size: 0.75rem; text-transform: uppercase; color: var(--w30); letter-spacing: 1px; background: rgba(255,255,255,0.02); }
.settings-table td { padding: 16px 24px; border-bottom: 1px solid var(--w04); vertical-align: middle; }

.key-name { font-weight: 600; color: #fff; font-size: 0.95rem; }
.key-desc { font-size: 0.75rem; color: var(--w40); margin-top: 2px; }

.val-display { font-size: 0.9rem; color: var(--w70); min-height: 20px; }
.val-num { font-family: monospace; font-weight: 700; color: var(--blue-b); font-size: 1.1rem; }

.empty-row { text-align: center; padding: 30px; color: var(--w30); font-style: italic; }

.edit-actions { display: flex; gap: 8px; align-items: center; }

.color-w40 { color: var(--w40); }
.mt-2 { margin-top: 8px; }
.mb-4 { margin-bottom: 24px; }
</style>