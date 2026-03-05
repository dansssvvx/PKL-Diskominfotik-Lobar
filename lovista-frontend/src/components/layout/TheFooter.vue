<template>
  <footer class="footer">
    <div class="container">
      <div class="footer__grid">
        <div class="footer__brand">
          <div class="footer__logo">LOVISTA</div>
          <p class="footer__desc">
            Platform informasi pariwisata digital resmi Kabupaten Lombok Barat.
            Menghubungkan wisatawan dengan keajaiban alam, budaya, dan layanan terbaik Lombok Barat.
          </p>
          <div class="footer__socials">
            <a href="#" class="footer__social">📘</a>
            <a href="#" class="footer__social">📸</a>
            <a href="#" class="footer__social">🐦</a>
            <a href="#" class="footer__social">▶️</a>
          </div>
        </div>
        <div v-for="col in columns" :key="col.title">
          <div class="footer__col-title">{{ col.title }}</div>
          <ul class="footer__links">
            <li v-for="link in col.links" :key="link.label">
              <RouterLink :to="link.to">{{ link.label }}</RouterLink>
            </li>
          </ul>
        </div>
      </div>
      <div class="footer__bottom">
        <span>© 2026 LoVista — Dinas Kominfotik Kabupaten Lombok Barat</span>
        <span>Django + Vue.js + TypeScript</span>
      </div>
    </div>
  </footer>
</template>

<script setup lang="ts">
import { RouterLink } from 'vue-router'
const columns = [
  { title: 'Explore', links: [
    { label: 'Destinations', to: '/destinations' },
    { label: 'Tour Packages', to: '/packages' },
    { label: 'Culture', to: '/culture' },
    { label: 'Culinaries', to: '/culinaries' },
    { label: 'Rental', to: '/rent' },
    { label: 'Homestay', to: '/homestays' },
  ]},
  { title: 'Services', links: [
    { label: 'AI Recommendation', to: '/ai-recommendation' },
    { label: 'Interactive Map', to: '/map' },
    { label: 'Online Booking', to: '/my-bookings' },
    { label: 'Partner Dashboard', to: '/operator' },
    { label: 'Admin Panel', to: '/admin' },
  ]},
  { title: 'Info', links: [
    { label: 'About LoVista', to: '/' },
    { label: 'Diskominfotik', to: '/' },
    { label: 'Privacy Policy', to: '/' },
    { label: 'Contact Us', to: '/' },
  ]},
]
</script>

<style scoped>
.footer { background: var(--dark1); border-top: 1px solid var(--w08); padding: 56px 0 28px; }
.footer__grid { display: grid; grid-template-columns: 2fr 1fr 1fr 1fr; gap: 48px; margin-bottom: 44px; }
.footer__logo { font-family: 'Bebas Neue', sans-serif; font-size: 2.2rem; letter-spacing: 4px; margin-bottom: 12px; }
.footer__desc { font-size: .83rem; color: var(--w40); line-height: 1.7; margin-bottom: 20px; }
.footer__socials { display: flex; gap: 8px; }
.footer__social {
  width: 36px; height: 36px; border-radius: 8px;
  background: var(--w08); border: 1px solid var(--w08);
  display: flex; align-items: center; justify-content: center;
  font-size: .9rem; transition: all .2s;
}
.footer__social:hover { background: var(--blue-d); }
.footer__col-title { font-size: .72rem; font-weight: 700; text-transform: uppercase; letter-spacing: 1.5px; color: var(--w70); margin-bottom: 14px; }
.footer__links { list-style: none; display: flex; flex-direction: column; gap: 9px; }
.footer__links a { color: var(--w40); font-size: .83rem; transition: color .2s; }
.footer__links a:hover { color: var(--blue-b); }
.footer__bottom { border-top: 1px solid var(--w08); padding-top: 22px; display: flex; justify-content: space-between; font-size: .76rem; color: var(--w40); }
@media (max-width: 900px) {
  .footer__grid { grid-template-columns: 1fr 1fr; }
  .footer__bottom { flex-direction: column; gap: 6px; }
}
</style>
