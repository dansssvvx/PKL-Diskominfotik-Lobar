<template>
  <div>
    <TheNavbar v-if="showNav" />
    <div class="container" style="padding-top:120px;padding-bottom:80px;min-height:80vh">
      <h1 style="font-family:'Barlow Condensed',sans-serif;font-size:2.5rem;font-style:italic;font-weight:800;margin-bottom:8px">
        MapView
      </h1>
      <p style="color:var(--w40)">This view is ready to be implemented — connect to Django API.</p>
    </div>
    <TheFooter v-if="showNav" />
  </div>
</template>
<script setup lang="ts">
import TheNavbar from '@/components/layout/TheNavbar.vue'
import TheFooter from '@/components/layout/TheFooter.vue'
const showNav = !['OperatorPackages','OperatorVehicles','OperatorHomestays','OperatorBookings','OperatorContributions','OperatorProfile','AdminDestinations','AdminUsers','AdminOperators','AdminContributions','AdminBookings','AdminActivityLogs','AdminSettings'].includes('MapView')
</script>
