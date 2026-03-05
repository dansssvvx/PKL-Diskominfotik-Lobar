<template>
  <div class="home">
    <h1>Welcome to LoVista</h1>
    <p>Discover the beauty of West Lombok with our expert-curated tourism information.</p>
    <div class="features">
      <div class="feature-card">
        <h3>Destinations</h3>
        <p>Explore breathtaking beaches, waterfalls, and cultural sites.</p>
      </div>
      <div class="feature-card">
        <h3>Travel Services</h3>
        <p>Book homestays, rent vehicles, or join tour packages.</p>
      </div>
      <div class="feature-card">
        <h3>Culture & Culinary</h3>
        <p>Experience local traditions and taste authentic Lombok dishes.</p>
      </div>
    </div>
  </div>
</template>

<style scoped>
.home {
  padding: 2rem 0;
}

h1 {
  font-size: 3.2em;
  line-height: 1.1;
  color: #fff;
  margin-bottom: 0.5em;
}

p {
  color: #aaa;
  max-width: 600px;
  margin: 0 auto 2rem;
}

.features {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 2rem;
  margin-top: 3rem;
}

.feature-card {
  background: #333;
  padding: 1.5rem;
  border-radius: 12px;
  border: 1px solid #444;
  transition: transform 0.3s ease;
}

.feature-card:hover {
  transform: translateY(-5px);
  border-color: #646cff;
}

h3 {
  color: #646cff;
  margin-top: 0;
}
</style>
