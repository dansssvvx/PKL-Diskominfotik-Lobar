import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { authApi } from '@/api'
import type { User, LoginForm, RegisterForm } from '@/types'

export const useAuthStore = defineStore('auth', () => {
  const user = ref<User | null>(null)
  const token = ref<string | null>(localStorage.getItem('lovista_token'))
  const loading = ref(false)
  const error = ref<string | null>(null)

  const isLoggedIn = computed(() => !!token.value && !!user.value)
  const isAdmin = computed(() => user.value?.role?.name === 'admin')
  const isOperator = computed(() => user.value?.role?.name === 'operator')
  const isUser = computed(() => user.value?.role?.name === 'user')

  async function login(form: LoginForm) {
    loading.value = true
    error.value = null
    try {
      const { data } = await authApi.login(form)
      token.value = data.access
      user.value = data.user
      localStorage.setItem('lovista_token', data.access)
      localStorage.setItem('lovista_refresh', data.refresh)
      return { success: true }
    } catch (e: unknown) {
      const err = e as { response?: { data?: { detail?: string } } }
      error.value = err.response?.data?.detail || 'Login failed'
      return { success: false, error: error.value }
    } finally {
      loading.value = false
    }
  }

  async function register(form: RegisterForm) {
    loading.value = true
    error.value = null
    try {
      await authApi.register(form)
      return { success: true }
    } catch (e: unknown) {
      const err = e as { response?: { data?: Record<string, string[]> } }
      const errs = err.response?.data
      error.value = errs ? Object.values(errs).flat().join(', ') : 'Registration failed'
      return { success: false, error: error.value }
    } finally {
      loading.value = false
    }
  }

  async function fetchMe() {
    if (!token.value) return
    try {
      const { data } = await authApi.me()
      user.value = data
    } catch {
      logout()
    }
  }

  function logout() {
    user.value = null
    token.value = null
    localStorage.removeItem('lovista_token')
    localStorage.removeItem('lovista_refresh')
  }

  return { user, token, loading, error, isLoggedIn, isAdmin, isOperator, isUser, login, register, fetchMe, logout }
})
