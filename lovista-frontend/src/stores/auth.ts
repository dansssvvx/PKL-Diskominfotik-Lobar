import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { authApi } from '@/api'
import type { User, LoginForm, RegisterForm } from '@/types'
import router from '@/router'

export const useAuthStore = defineStore('auth', () => {
  const user = ref<User | null>(null)
  const token = ref<string | null>(localStorage.getItem('lovista_token'))
  const loading = ref(false)
  const error = ref<string | null>(null)

  const isAuthenticated = computed(() => !!token.value)
  const isLoggedIn = computed(() => !!token.value)
  
  const isAdmin = computed(() => {
    if (!user.value) return false
    return user.value.role_name === 'admin' || (user.value.role as any) === 1 || (user.value.role as any)?.name === 'admin'
  })

  const isOperator = computed(() => {
    if (!user.value) return false
    return user.value.role_name === 'operator' || (user.value.role as any) === 2 || (user.value.role as any)?.name === 'operator'
  })

  async function login(credentials: LoginForm) {
    loading.value = true
    error.value = null
    try {
      // Django JWT returns { access, refresh }
      // We map 'username' to 'email' if needed, but our API uses email
      const response = await authApi.login({
        email: credentials.email,
        password: credentials.password
      })
      
      const { access, refresh } = response.data
      token.value = access // Update reactive ref
      localStorage.setItem('lovista_token', access)
      localStorage.setItem('lovista_refresh', refresh)
      
      console.log('Login successful, token saved.')
      
      // Fetch user details
      await fetchMe()
      
      router.push('/')
    } catch (err: any) {
      error.value = err.response?.data?.detail || 'Login failed. Please check your credentials.'
      throw err
    } finally {
      loading.value = false
    }
  }

  async function register(formData: RegisterForm) {
    loading.value = true
    error.value = null
    try {
      await authApi.register(formData)
      router.push('/login')
    } catch (err: any) {
      const data = err.response?.data
      if (data) {
        if (data.email) error.value = `Email: ${data.email[0]}`
        else if (data.detail) error.value = data.detail
        else if (typeof data === 'object') {
          // Join all first errors from object
          error.value = Object.values(data).map((v: any) => v[0]).join(', ')
        } else {
          error.value = 'Registration failed.'
        }
      } else {
        error.value = 'Cannot connect to server.'
      }
      throw err
    } finally {
      loading.value = false
    }
  }

  async function fetchMe() {
    try {
      const response = await authApi.me()
      user.value = response.data
    } catch (err) {
      logout()
    }
  }

  function logout() {
    user.value = null
    token.value = null
    localStorage.removeItem('lovista_token')
    localStorage.removeItem('lovista_refresh')
    router.push('/login')
  }

  return {
    user,
    token,
    loading,
    error,
    isAuthenticated,
    isLoggedIn,
    isAdmin,
    isOperator,
    login,
    register,
    fetchMe,
    logout
  }
})
