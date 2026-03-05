<template>
  <div class="destinations">
    <h1>Explore West Lombok</h1>
    <p>Find your next adventure in our beautiful beaches, islands, and hills.</p>
    <div class="grid">
      <div v-for="i in 6" :key="i" class="card">
        <div class="image-placeholder"></div>
        <div class="content">
          <h3>Destination Name {{ i }}</h3>
          <p class="location">Sekotong, West Lombok</p>
          <div class="meta">
            <span>⭐ 4.8</span>
            <span>Rp 10.000</span>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.destinations {
  padding: 2rem 0;
}

h1 {
  font-size: 2.5em;
  margin-bottom: 0.5em;
}

p {
  color: #aaa;
  margin-bottom: 3rem;
}

.grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 2rem;
  margin-top: 2rem;
}

.card {
  background: #333;
  border-radius: 12px;
  overflow: hidden;
  border: 1px solid #444;
  text-align: left;
  transition: transform 0.3s ease;
}

.card:hover {
  transform: scale(1.02);
  border-color: #646cff;
}

.image-placeholder {
  height: 200px;
  background: #222;
  position: relative;
}

.image-placeholder::after {
  content: 'Photo';
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  color: #444;
}

.content {
  padding: 1.5rem;
}

h3 {
  margin: 0 0 0.5rem;
  color: #fff;
}

.location {
  font-size: 0.9rem;
  color: #646cff;
  margin-bottom: 1rem;
}

.meta {
  display: flex;
  justify-content: space-between;
  font-size: 0.9rem;
  color: #888;
  border-top: 1px solid #444;
  padding-top: 1rem;
}
</style>
