<template>
  <div class="auth-page">
    <div class="auth-overlay"></div>
    
    <div class="auth-container">
      <div class="auth-card card slide-up-enter-active">
        <div class="auth-header">
          <div class="brand">
            <span class="italic-bold">LO</span>VISTA
          </div>
          <h2 class="font-display">WELCOME BACK</h2>
          <p class="subtitle">Access your account to continue your journey</p>
        </div>

        <form @submit.prevent="handleLogin" class="auth-form">
          <div class="form-group">
            <label class="form-label" for="email">Email Address</label>
            <input 
              type="email" 
              id="email" 
              class="form-input"
              v-model="form.email" 
              placeholder="name@example.com" 
              required
            />
          </div>

          <div class="form-group">
            <label class="form-label" for="password">Password</label>
            <input 
              type="password" 
              id="password" 
              class="form-input"
              v-model="form.password" 
              placeholder="••••••••" 
              required
            />
          </div>

          <div v-if="authStore.error" class="form-error-box">
            <span class="icon">⚠️</span>
            {{ authStore.error }}
          </div>

          <button type="submit" :disabled="authStore.loading" class="btn btn-primary btn-lg full-width">
            <span v-if="!authStore.loading">SIGN IN</span>
            <div v-else class="spinner-sm"></div>
          </button>
        </form>

        <div class="auth-footer">
          <p>Don't have an account? <router-link to="/register" class="link">Create one now</router-link></p>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { reactive } from 'vue'
import { useAuthStore } from '@/stores/auth'

const authStore = useAuthStore()

const form = reactive({
  email: '',
  password: ''
})

const handleLogin = async () => {
  try {
    await authStore.login(form)
  } catch (err) {
    // Error is handled in the store
  }
}
</script>

<style scoped>
.auth-page {
  position: relative;
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: var(--black);
  padding: 40px 20px;
  overflow: hidden;
}

.auth-overlay {
  position: absolute;
  top: 0; left: 0; right: 0; bottom: 0;
  background: radial-gradient(circle at center, var(--dark4) 0%, var(--black) 100%);
  opacity: 0.4;
  pointer-events: none;
}

.auth-container {
  position: relative;
  z-index: 1;
  width: 100%;
  max-width: 440px;
}

.auth-card {
  padding: 48px;
  background: var(--dark1);
  border: 1px solid var(--w08);
}

.auth-header {
  text-align: center;
  margin-bottom: 32px;
}

.brand {
  font-size: 1.5rem;
  letter-spacing: 2px;
  margin-bottom: 16px;
  color: var(--white);
}

.brand .italic-bold {
  color: var(--blue);
}

h2 {
  font-size: 2rem;
  margin-bottom: 8px;
  color: var(--white);
}

.subtitle {
  color: var(--w40);
  font-size: 0.88rem;
}

.auth-form {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.form-error-box {
  background: rgba(239, 68, 68, 0.1);
  border: 1px solid rgba(239, 68, 68, 0.2);
  color: var(--danger);
  padding: 12px 16px;
  border-radius: var(--radius-md);
  font-size: 0.85rem;
  display: flex;
  align-items: center;
  gap: 10px;
}

.full-width {
  width: 100%;
  margin-top: 10px;
}

.spinner-sm {
  width: 20px;
  height: 20px;
  border: 2px solid rgba(255,255,255,0.2);
  border-top-color: white;
  border-radius: 50%;
  animation: spin 0.6s linear infinite;
}

@keyframes spin { to { transform: rotate(360deg); } }

.auth-footer {
  margin-top: 32px;
  text-align: center;
  font-size: 0.88rem;
  color: var(--w40);
}

.link {
  color: var(--blue);
  font-weight: 600;
  margin-left: 4px;
}

.link:hover {
  text-decoration: underline;
}

@media (max-width: 480px) {
  .auth-card {
    padding: 32px 24px;
  }
}
</style>
