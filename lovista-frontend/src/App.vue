<template>
  <div class="app-layout">
    <TheNavbar v-if="!hideNav" />
    <main class="main-content">
      <RouterView />
    </main>
    <TheFooter v-if="!hideNav" />
  </div>
</template>

<script setup lang="ts">
import { RouterView, useRoute } from 'vue-router'
import { computed, onMounted } from 'vue'
import TheNavbar from '@/components/layout/TheNavbar.vue'
import TheFooter from '@/components/layout/TheFooter.vue'
import { useAuthStore } from '@/stores/auth'

const auth = useAuthStore()
const route = useRoute()

const hideNav = computed(() => {
  return ['login', 'register'].includes(route.name as string)
})

onMounted(() => {
  if (auth.token) {
    auth.fetchMe()
  }
})
</script>

<style>
.app-layout {
  display: flex;
  flex-direction: column;
  min-height: 100vh;
}

.main-content {
  flex: 1;
}
</style>
