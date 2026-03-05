import { defineStore } from 'pinia'
import { ref } from 'vue'
import { destinationApi } from '@/api'
import type { TourismDestination, DestinationCategory, DestinationFilterParams } from '@/types'

export const useDestinationStore = defineStore('destination', () => {
  const destinations = ref<TourismDestination[]>([])
  const featured = ref<TourismDestination[]>([])
  const categories = ref<DestinationCategory[]>([])
  const current = ref<TourismDestination | null>(null)
  const total = ref(0)
  const loading = ref(false)
  const error = ref<string | null>(null)
  const wishlisted = ref<Set<number>>(new Set())

  async function fetchAll(params?: DestinationFilterParams) {
    loading.value = true
    try {
      const { data } = await destinationApi.list(params)
      destinations.value = data.results
      total.value = data.count
    } catch {
      error.value = 'Failed to load destinations'
    } finally {
      loading.value = false
    }
  }

  async function fetchDetail(slug: string) {
    loading.value = true
    current.value = null
    try {
      const { data } = await destinationApi.detail(slug)
      current.value = data
    } catch {
      error.value = 'Destination not found'
    } finally {
      loading.value = false
    }
  }

  async function fetchFeatured() {
    try {
      const { data } = await destinationApi.popular()
      featured.value = data
    } catch { /* silent */ }
  }

  async function fetchCategories() {
    try {
      const { data } = await destinationApi.categories()
      categories.value = data
    } catch { /* silent */ }
  }

  async function toggleWishlist(destId: number) {
    try {
      const { data } = await destinationApi.toggleWishlist(destId)
      if (data.wishlisted) wishlisted.value.add(destId)
      else wishlisted.value.delete(destId)
    } catch { /* silent */ }
  }

  function isWishlisted(destId: number) {
    return wishlisted.value.has(destId)
  }

  return {
    destinations, featured, categories, current,
    total, loading, error, wishlisted,
    fetchAll, fetchDetail, fetchFeatured,
    fetchCategories, toggleWishlist, isWishlisted
  }
})
