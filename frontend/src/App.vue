<script setup lang="ts">
import { RouterView } from 'vue-router'
</script>

<template>
  <div class="app-container">
    <header class="app-header">
      <nav>
        <RouterLink to="/">Home</RouterLink> |
        <RouterLink to="/destinations">Destinations</RouterLink> |
        <RouterLink to="/login">Login</RouterLink>
      </nav>
    </header>

    <main>
      <RouterView />
    </main>

    <footer class="app-footer">
      <p>&copy; 2026 LoVista - Lombok Barat Tourism Information</p>
    </footer>
  </div>
</template>

<style>
:root {
  font-family: Inter, system-ui, Avenir, Helvetica, Arial, sans-serif;
  line-height: 1.5;
  font-weight: 400;
  color-scheme: light dark;
  color: rgba(255, 255, 255, 0.87);
  background-color: #242424;
}

body {
  margin: 0;
  display: flex;
  place-items: center;
  min-width: 320px;
  min-height: 100vh;
}

#app {
  max-width: 1280px;
  margin: 0 auto;
  padding: 2rem;
  text-align: center;
}

.app-container {
  display: flex;
  flex-direction: column;
  min-height: 100vh;
  width: 100%;
}

.app-header {
  padding: 1rem;
  border-bottom: 1px solid #444;
}

.app-footer {
  margin-top: auto;
  padding: 2rem;
  font-size: 0.8rem;
  color: #888;
}

nav a {
  color: #646cff;
  text-decoration: inherit;
  margin: 0 0.5rem;
}

nav a:hover {
  color: #535bf2;
}
</style>
