<template>
  <div class="login-view">
    <h2>Login to LoVista</h2>
    <div class="card">
      <form @submit.prevent="handleLogin">
        <div class="form-group">
          <label>Email</label>
          <input type="email" placeholder="email@example.com" />
        </div>
        <div class="form-group">
          <label>Password</label>
          <input type="password" placeholder="********" />
        </div>
        <button type="submit">Login</button>
      </form>
      <p class="mt-4">Don't have an account? <RouterLink to="/register">Register</RouterLink></p>
    </div>
  </div>
</template>

<style scoped>
.login-view {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 4rem 1rem;
}

.card {
  background: #333;
  padding: 2rem;
  border-radius: 12px;
  width: 100%;
  max-width: 400px;
  border: 1px solid #444;
}

.form-group {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  margin-bottom: 1.5rem;
}

label {
  margin-bottom: 0.5rem;
  font-weight: bold;
  color: #aaa;
}

input {
  width: 100%;
  padding: 0.75rem;
  border-radius: 6px;
  border: 1px solid #555;
  background: #222;
  color: #fff;
}

button {
  width: 100%;
  padding: 0.75rem;
  border-radius: 6px;
  border: none;
  background: #646cff;
  color: white;
  font-weight: bold;
  cursor: pointer;
}

button:hover {
  background: #535bf2;
}

.mt-4 {
  margin-top: 1rem;
  font-size: 0.9rem;
  color: #888;
}
</style>
