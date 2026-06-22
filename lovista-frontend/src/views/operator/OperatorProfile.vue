<template>
  <div class="op-profile">
    <!-- Header -->
    <div class="page-header">
      <div>
        <h1 class="admin-title">Agency Profile</h1>
        <p class="admin-subtitle">Kelola profil bisnis dan informasi akun operator Anda.</p>
      </div>
      <span class="badge" :class="agency?.is_verified ? 'badge-success' : 'badge-warning'">
        {{ agency?.is_verified ? '✅ Verified Operator' : '⏳ Pending Verification' }}
      </span>
    </div>

    <div class="profile-grid" v-if="!loading">
      <!-- Left: Agency Profile -->
      <div class="profile-left">
        <!-- Agency Card -->
        <div class="card profile-card">
          <div class="agency-logo-wrap">
            <img :src="getPhotoUrl(agency?.logo)" class="agency-logo" @error="handleImgError" />
            <button class="logo-upload-btn" @click="triggerLogoInput" title="Change Logo">📸</button>
            <input type="file" ref="logoInput" accept="image/*" class="hidden-input" @change="handleLogoChange" />
          </div>
          <div class="agency-info">
            <h2 class="agency-name">{{ agency?.business_name || 'Your Agency' }}</h2>
            <div class="agency-license" v-if="agency?.license_number">
              🪪 License: {{ agency.license_number }}
            </div>
            <div class="agency-email" v-if="agency?.email">📧 {{ agency.email }}</div>
            <div class="agency-phone" v-if="agency?.phone">📞 {{ agency.phone }}</div>
            <div class="agency-address" v-if="agency?.address">📍 {{ agency.address }}</div>
          </div>
        </div>

        <!-- Bank Account Card -->
        <div class="card section-card">
          <div class="section-header">
            <h3 class="section-title">Bank Account</h3>
            <button class="btn btn-ghost btn-sm" @click="showBankModal = true">Edit</button>
          </div>
          <div v-if="agency?.bank_account" class="bank-info">
            <div class="bank-row">
              <span class="bank-label">Bank</span>
              <span class="bank-val">{{ agency.bank_account.bank_name }}</span>
            </div>
            <div class="bank-row">
              <span class="bank-label">Account Number</span>
              <span class="bank-val account-num">{{ agency.bank_account.account_number }}</span>
            </div>
            <div class="bank-row">
              <span class="bank-label">Account Holder</span>
              <span class="bank-val">{{ agency.bank_account.account_holder }}</span>
            </div>
          </div>
          <div v-else class="empty-bank">
            <p class="text-muted">No bank account configured</p>
            <p class="text-muted-sm">Add bank details to receive payments</p>
            <button class="btn btn-primary btn-sm" style="margin-top:12px" @click="showBankModal = true">+ Add Bank Account</button>
          </div>
        </div>
      </div>

      <!-- Right: Edit Forms -->
      <div class="profile-right">
        <!-- Edit Agency Info -->
        <div class="card section-card">
          <div class="section-header">
            <h3 class="section-title">Agency Information</h3>
          </div>
          <form @submit.prevent="saveAgency" class="form-section">
            <div class="form-grid">
              <div class="form-group full-width">
                <label class="form-label">Business Name *</label>
                <input v-model="agencyForm.business_name" type="text" class="form-input" placeholder="Your agency name" required />
              </div>
              <div class="form-group">
                <label class="form-label">License Number</label>
                <input v-model="agencyForm.license_number" type="text" class="form-input" placeholder="e.g. SIUP-12345" />
              </div>
              <div class="form-group">
                <label class="form-label">Phone</label>
                <input v-model="agencyForm.phone" type="text" class="form-input" placeholder="+62..." />
              </div>
              <div class="form-group">
                <label class="form-label">Email</label>
                <input v-model="agencyForm.email" type="email" class="form-input" placeholder="agency@email.com" />
              </div>
              <div class="form-group full-width">
                <label class="form-label">Address</label>
                <input v-model="agencyForm.address" type="text" class="form-input" placeholder="Full address..." />
              </div>
              <div class="form-group full-width">
                <label class="form-label">Description</label>
                <textarea v-model="agencyForm.description" class="form-input" rows="3" placeholder="Tell about your agency..."></textarea>
              </div>
            </div>
            <div class="form-actions">
              <button type="submit" class="btn btn-primary" :disabled="savingAgency">
                <span v-if="savingAgency" class="btn-spinner"></span>
                {{ savingAgency ? 'Saving...' : 'Save Agency Info' }}
              </button>
            </div>
            <div class="success-msg" v-if="agencySuccess">✅ Agency information updated successfully!</div>
            <div class="error-msg" v-if="agencyError">❌ {{ agencyError }}</div>
          </form>
        </div>

        <!-- Edit Personal Account -->
        <div class="card section-card">
          <div class="section-header">
            <h3 class="section-title">Personal Account</h3>
          </div>
          <div class="account-info-row">
            <div class="account-avatar" @click="triggerPhotoInput">
              <img v-if="auth.user?.profile_photo" :src="getPhotoUrl(auth.user.profile_photo)" class="avatar-img" @error="handleImgError" />
              <div v-else class="avatar-initials">{{ auth.user?.fullname?.charAt(0) }}</div>
              <div class="avatar-overlay">📸</div>
              <input type="file" ref="photoInput" accept="image/*" class="hidden-input" @change="handlePhotoChange" />
            </div>
            <div class="account-meta">
              <div class="account-name">{{ auth.user?.fullname }}</div>
              <div class="account-email">{{ auth.user?.email }}</div>
              <div class="account-role badge badge-blue">Operator</div>
            </div>
          </div>

          <form @submit.prevent="saveProfile" class="form-section">
            <div class="form-grid">
              <div class="form-group full-width">
                <label class="form-label">Full Name *</label>
                <input v-model="profileForm.fullname" type="text" class="form-input" required />
              </div>
              <div class="form-group">
                <label class="form-label">Email *</label>
                <input v-model="profileForm.email" type="email" class="form-input" required />
              </div>
              <div class="form-group">
                <label class="form-label">Phone</label>
                <input v-model="profileForm.phone" type="text" class="form-input" placeholder="+62..." />
              </div>
            </div>
            <div class="form-actions">
              <button type="submit" class="btn btn-primary" :disabled="savingProfile">
                <span v-if="savingProfile" class="btn-spinner"></span>
                {{ savingProfile ? 'Saving...' : 'Save Profile' }}
              </button>
            </div>
            <div class="success-msg" v-if="profileSuccess">✅ Profile updated successfully!</div>
            <div class="error-msg" v-if="profileError">❌ {{ profileError }}</div>
          </form>
        </div>

        <!-- Change Password -->
        <div class="card section-card">
          <div class="section-header">
            <h3 class="section-title">Change Password</h3>
          </div>
          <form @submit.prevent="changePassword" class="form-section">
            <div class="form-group">
              <label class="form-label">Current Password *</label>
              <div class="password-field">
                <input v-model="passwordForm.old_password" :type="showOldPwd ? 'text' : 'password'" class="form-input" required placeholder="Your current password" />
                <button type="button" class="pwd-toggle" @click="showOldPwd = !showOldPwd">{{ showOldPwd ? '🙈' : '👁️' }}</button>
              </div>
            </div>
            <div class="form-group">
              <label class="form-label">New Password *</label>
              <div class="password-field">
                <input v-model="passwordForm.new_password" :type="showNewPwd ? 'text' : 'password'" class="form-input" required placeholder="At least 8 characters" minlength="8" />
                <button type="button" class="pwd-toggle" @click="showNewPwd = !showNewPwd">{{ showNewPwd ? '🙈' : '👁️' }}</button>
              </div>
            </div>
            <div class="form-group">
              <label class="form-label">Confirm New Password *</label>
              <div class="password-field">
                <input v-model="passwordForm.confirm_password" :type="showConfirmPwd ? 'text' : 'password'" class="form-input" required placeholder="Repeat new password" />
                <button type="button" class="pwd-toggle" @click="showConfirmPwd = !showConfirmPwd">{{ showConfirmPwd ? '🙈' : '👁️' }}</button>
              </div>
              <div class="form-error" v-if="passwordForm.new_password && passwordForm.confirm_password && passwordForm.new_password !== passwordForm.confirm_password">
                Passwords do not match
              </div>
            </div>
            <div class="form-actions">
              <button type="submit" class="btn btn-primary" :disabled="savingPwd || passwordForm.new_password !== passwordForm.confirm_password">
                <span v-if="savingPwd" class="btn-spinner"></span>
                {{ savingPwd ? 'Changing...' : 'Change Password' }}
              </button>
            </div>
            <div class="success-msg" v-if="pwdSuccess">✅ Password changed successfully!</div>
            <div class="error-msg" v-if="pwdError">❌ {{ pwdError }}</div>
          </form>
        </div>
      </div>
    </div>

    <!-- Loading State -->
    <div class="page-loader" v-else>
      <div class="spinner"></div>
      <p>Loading profile...</p>
    </div>

    <!-- Bank Account Modal -->
    <div class="modal-overlay" v-if="showBankModal" @click.self="showBankModal = false">
      <div class="modal-content card" style="max-width:460px">
        <div class="modal-header">
          <h2 class="modal-title">Bank Account</h2>
          <button class="btn-close" @click="showBankModal = false">×</button>
        </div>
        <form @submit.prevent="saveBankAccount" class="modal-form">
          <div class="form-group">
            <label class="form-label">Bank Name *</label>
            <input v-model="bankForm.bank_name" type="text" class="form-input" placeholder="e.g. BNI, BRI, Mandiri" required />
          </div>
          <div class="form-group">
            <label class="form-label">Account Number *</label>
            <input v-model="bankForm.account_number" type="text" class="form-input" placeholder="e.g. 1234567890" required />
          </div>
          <div class="form-group">
            <label class="form-label">Account Holder Name *</label>
            <input v-model="bankForm.account_holder" type="text" class="form-input" placeholder="As on bank card" required />
          </div>
          <div class="modal-footer" style="padding-bottom:0">
            <button type="button" class="btn btn-ghost" @click="showBankModal = false">Cancel</button>
            <button type="submit" class="btn btn-primary" :disabled="savingBank">
              <span v-if="savingBank" class="btn-spinner"></span>
              {{ savingBank ? 'Saving...' : 'Save Bank Account' }}
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useAuthStore } from '@/stores/auth'
import { agencyApi, authApi } from '@/api'
import api from '@/api'
import type { TravelAgency } from '@/types'

const BASE_URL = 'http://127.0.0.1:8000'

const auth = useAuthStore()
const loading = ref(true)
const agency = ref<TravelAgency | null>(null)
const logoInput = ref<HTMLInputElement | null>(null)
const photoInput = ref<HTMLInputElement | null>(null)

// Agency form
const savingAgency = ref(false)
const agencySuccess = ref(false)
const agencyError = ref('')
const agencyForm = ref({
  business_name: '',
  license_number: '',
  phone: '',
  email: '',
  address: '',
  description: '',
})

// Profile form
const savingProfile = ref(false)
const profileSuccess = ref(false)
const profileError = ref('')
const profileForm = ref({ fullname: '', email: '', phone: '' })

// Password form
const savingPwd = ref(false)
const pwdSuccess = ref(false)
const pwdError = ref('')
const showOldPwd = ref(false)
const showNewPwd = ref(false)
const showConfirmPwd = ref(false)
const passwordForm = ref({ old_password: '', new_password: '', confirm_password: '' })

// Bank modal
const showBankModal = ref(false)
const savingBank = ref(false)
const bankForm = ref({ bank_name: '', account_number: '', account_holder: '' })

async function loadAll() {
  loading.value = true
  try {
    const [agencyRes] = await Promise.allSettled([agencyApi.me()])
    if (agencyRes.status === 'fulfilled') {
      agency.value = agencyRes.value.data
      fillAgencyForm(agency.value)
    }
    if (auth.user) fillProfileForm()
  } catch {}
  finally { loading.value = false }
}

function fillAgencyForm(a: TravelAgency) {
  agencyForm.value = {
    business_name: a.business_name || '',
    license_number: a.license_number || '',
    phone: a.phone || '',
    email: a.email || '',
    address: a.address || '',
    description: a.description || '',
  }
  if (a.bank_account) {
    bankForm.value = { ...a.bank_account }
  }
}

function fillProfileForm() {
  profileForm.value = {
    fullname: auth.user?.fullname || '',
    email: auth.user?.email || '',
    phone: auth.user?.phone || '',
  }
}

async function saveAgency() {
  savingAgency.value = true
  agencySuccess.value = false
  agencyError.value = ''
  try {
    const res = await agencyApi.update(agencyForm.value)
    agency.value = res.data
    agencySuccess.value = true
    setTimeout(() => { agencySuccess.value = false }, 3000)
  } catch (err: any) {
    agencyError.value = err.response?.data?.detail || 'Failed to save agency info.'
    setTimeout(() => { agencyError.value = '' }, 4000)
  } finally { savingAgency.value = false }
}

async function saveProfile() {
  savingProfile.value = true
  profileSuccess.value = false
  profileError.value = ''
  try {
    await api.patch('/users/me/', profileForm.value)
    await auth.fetchMe()
    profileSuccess.value = true
    setTimeout(() => { profileSuccess.value = false }, 3000)
  } catch (err: any) {
    profileError.value = err.response?.data?.detail || 'Failed to update profile.'
    setTimeout(() => { profileError.value = '' }, 4000)
  } finally { savingProfile.value = false }
}

async function changePassword() {
  if (passwordForm.value.new_password !== passwordForm.value.confirm_password) return
  savingPwd.value = true
  pwdSuccess.value = false
  pwdError.value = ''
  try {
    await api.post('/users/change-password/', {
      old_password: passwordForm.value.old_password,
      new_password: passwordForm.value.new_password,
    })
    passwordForm.value = { old_password: '', new_password: '', confirm_password: '' }
    pwdSuccess.value = true
    setTimeout(() => { pwdSuccess.value = false }, 3000)
  } catch (err: any) {
    pwdError.value = err.response?.data?.detail || err.response?.data?.old_password?.[0] || 'Failed to change password.'
    setTimeout(() => { pwdError.value = '' }, 4000)
  } finally { savingPwd.value = false }
}

async function saveBankAccount() {
  savingBank.value = true
  try {
    await agencyApi.update({ bank_account: bankForm.value } as any)
    if (agency.value) agency.value.bank_account = { ...bankForm.value }
    showBankModal.value = false
  } catch (err: any) {
    alert(err.response?.data?.detail || 'Failed to save bank account.')
  } finally { savingBank.value = false }
}

function triggerLogoInput() { logoInput.value?.click() }
function triggerPhotoInput() { photoInput.value?.click() }

async function handleLogoChange(e: Event) {
  const file = (e.target as HTMLInputElement).files?.[0]
  if (!file) return
  try {
    const fd = new FormData()
    fd.append('logo', file)
    const res = await api.patch('/agencies/me/', fd, { headers: { 'Content-Type': 'multipart/form-data' } })
    if (agency.value) agency.value.logo = res.data.logo
  } catch { alert('Failed to upload logo.') }
}

async function handlePhotoChange(e: Event) {
  const file = (e.target as HTMLInputElement).files?.[0]
  if (!file) return
  try {
    await authApi.uploadPhoto(file)
    await auth.fetchMe()
  } catch { alert('Failed to upload photo.') }
}

function getPhotoUrl(path?: string | null) {
  if (!path) return '/Logo.png'
  if (path.startsWith('http')) return path
  return `${BASE_URL}${path}`
}

function handleImgError(e: Event) { (e.target as HTMLImageElement).src = '/Logo.png' }

onMounted(loadAll)
</script>

<style scoped>
.page-header { display: flex; justify-content: space-between; align-items: flex-end; margin-bottom: 32px; flex-wrap: wrap; gap: 12px; }
.admin-title { font-family: 'Barlow Condensed', sans-serif; font-size: 2rem; font-style: italic; font-weight: 800; margin-bottom: 4px; }
.admin-subtitle { color: var(--w40); font-size: 0.9rem; }

.profile-grid { display: grid; grid-template-columns: 300px 1fr; gap: 24px; align-items: start; }

/* Left panel */
.profile-left { display: flex; flex-direction: column; gap: 20px; }
.profile-card { padding: 24px; text-align: center; }
.agency-logo-wrap { position: relative; width: 96px; margin: 0 auto 16px; }
.agency-logo { width: 96px; height: 96px; border-radius: 16px; object-fit: cover; border: 2px solid var(--w08); }
.logo-upload-btn {
  position: absolute; bottom: -8px; right: -8px;
  width: 28px; height: 28px; background: var(--blue); border: 2px solid var(--dark2);
  border-radius: 50%; font-size: .8rem; display: flex; align-items: center; justify-content: center; cursor: pointer;
}
.hidden-input { display: none; }
.agency-name { font-family: 'Barlow Condensed', sans-serif; font-size: 1.4rem; font-weight: 800; font-style: italic; margin-bottom: 12px; }
.agency-license, .agency-email, .agency-phone, .agency-address {
  font-size: .82rem; color: var(--w40); margin-bottom: 4px; text-align: left;
}

.section-card { padding: 20px 24px; }
.section-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px; }
.section-title { font-family: 'Barlow Condensed', sans-serif; font-size: 1.15rem; font-weight: 700; font-style: italic; }

.bank-info { display: flex; flex-direction: column; gap: 10px; }
.bank-row { display: flex; justify-content: space-between; align-items: center; }
.bank-label { font-size: .72rem; color: var(--w40); text-transform: uppercase; letter-spacing: .8px; }
.bank-val { font-size: .88rem; color: var(--w90); font-weight: 600; }
.account-num { font-family: monospace; font-size: 1rem; color: var(--blue-b); }
.empty-bank { text-align: center; padding: 12px 0; }
.text-muted { color: var(--w40); font-size: .88rem; }
.text-muted-sm { color: var(--w40); font-size: .75rem; margin-top: 4px; }

/* Right panel */
.profile-right { display: flex; flex-direction: column; gap: 20px; }
.form-section { padding-top: 4px; }
.form-grid { display: grid; grid-template-columns: repeat(2,1fr); gap: 16px; }
.full-width { grid-column: span 2; }
.form-label { display: block; font-size: .72rem; font-weight: 600; color: var(--w40); text-transform: uppercase; letter-spacing: .8px; margin-bottom: 6px; }
.form-error { font-size: .75rem; color: var(--danger); margin-top: 4px; }
.form-actions { margin-top: 16px; }
.success-msg { margin-top: 10px; font-size: .85rem; color: #4ade80; }
.error-msg { margin-top: 10px; font-size: .85rem; color: #f87171; }

/* Account avatar */
.account-info-row { display: flex; align-items: center; gap: 16px; padding: 16px 0; margin-bottom: 8px; border-bottom: 1px solid var(--w08); }
.account-avatar { position: relative; width: 64px; height: 64px; border-radius: 50%; overflow: hidden; cursor: pointer; flex-shrink: 0; }
.avatar-img { width: 100%; height: 100%; object-fit: cover; }
.avatar-initials { width: 100%; height: 100%; background: var(--blue); display: flex; align-items: center; justify-content: center; font-weight: 700; font-size: 1.5rem; }
.avatar-overlay { position: absolute; inset: 0; background: rgba(0,0,0,.5); display: flex; align-items: center; justify-content: center; font-size: 1.2rem; opacity: 0; transition: .2s; }
.account-avatar:hover .avatar-overlay { opacity: 1; }
.account-name { font-weight: 700; font-size: 1.05rem; margin-bottom: 4px; }
.account-email { font-size: .82rem; color: var(--w40); margin-bottom: 8px; }
.account-role { display: inline-flex; }

/* Password field */
.password-field { position: relative; }
.password-field .form-input { padding-right: 44px; }
.pwd-toggle { position: absolute; right: 12px; top: 50%; transform: translateY(-50%); background: none; border: none; cursor: pointer; font-size: 1rem; }

/* Modal */
.modal-overlay { position: fixed; inset: 0; background: rgba(0,0,0,.8); backdrop-filter: blur(8px); display: flex; align-items: center; justify-content: center; z-index: 1000; padding: 20px; }
.modal-content { width: 100%; max-height: 90vh; overflow-y: auto; animation: modalSlide .3s ease-out; }
@keyframes modalSlide { from{opacity:0;transform:translateY(20px)} to{opacity:1;transform:translateY(0)} }
.modal-header { display: flex; justify-content: space-between; align-items: center; padding: 20px 24px; border-bottom: 1px solid var(--w08); }
.modal-title { font-family: 'Barlow Condensed', sans-serif; font-style: italic; font-weight: 700; font-size: 1.5rem; }
.btn-close { background: none; border: none; color: var(--w40); font-size: 1.8rem; cursor: pointer; }
.modal-form { padding: 24px; }
.modal-footer { display: flex; justify-content: flex-end; gap: 12px; padding-top: 20px; border-top: 1px solid var(--w08); margin-top: 20px; }

.btn-spinner { width: 14px; height: 14px; border-radius: 50%; border: 2px solid rgba(255,255,255,.3); border-top-color: #fff; animation: spin .7s linear infinite; display: inline-block; }
@keyframes spin { to { transform: rotate(360deg); } }

@media (max-width: 900px) {
  .profile-grid { grid-template-columns: 1fr; }
  .form-grid { grid-template-columns: 1fr; }
  .full-width { grid-column: span 1; }
}
</style>
