<template>
  <div class="layout">
    <header class="header">
      <NuxtLink to="/" class="brand">My-Libra</NuxtLink>
      <nav class="nav">
        <NuxtLink to="/">集計</NuxtLink>
        <NuxtLink to="/items">アイテム</NuxtLink>
        <NuxtLink to="/items/new">新規登録</NuxtLink>
      </nav>
    </header>
    <main class="main">
      <NuxtPage />
    </main>
  </div>
</template>

<style>
:root {
  --bg: #f7f7f8;
  --surface: #ffffff;
  --text: #1d1d1f;
  --muted: #6e6e73;
  --border: #d2d2d7;
  --accent: #f5a623;
  --plus: #1f8a3b;
  --minus: #d12f2f;
  color-scheme: light dark;
}
@media (prefers-color-scheme: dark) {
  :root {
    --bg: #111113;
    --surface: #1c1c1f;
    --text: #f2f2f7;
    --muted: #a1a1a6;
    --border: #3a3a3c;
    --plus: #4cc26b;
    --minus: #ff6b6b;
  }
}
* { box-sizing: border-box; }
body { margin: 0; font-family: system-ui, -apple-system, 'Hiragino Sans', sans-serif; background: var(--bg); color: var(--text); }
a { color: inherit; }
.header { display: flex; align-items: center; justify-content: space-between; gap: 16px; padding: 12px 16px; background: var(--surface); border-bottom: 1px solid var(--border); flex-wrap: wrap; }
.brand { font-weight: 700; text-decoration: none; font-size: 1.1rem; }
.nav { display: flex; gap: 16px; }
.nav a { text-decoration: none; color: var(--muted); }
.nav a.router-link-exact-active { color: var(--text); font-weight: 600; border-bottom: 2px solid var(--accent); }
.main { max-width: 960px; margin: 0 auto; padding: 16px; }
h1 { font-size: 1.4rem; }
.form { display: grid; gap: 12px; max-width: 480px; }
.form label { display: grid; gap: 4px; font-size: 0.9rem; }
input, select, textarea { font: inherit; padding: 8px; border: 1px solid var(--border); border-radius: 8px; background: var(--surface); color: var(--text); }
button { font: inherit; padding: 8px 16px; border: none; border-radius: 8px; background: var(--accent); color: #1d1d1f; font-weight: 600; cursor: pointer; }
button.secondary { background: transparent; color: var(--text); border: 1px solid var(--border); }
button.danger { background: var(--minus); color: #fff; }
button:disabled { opacity: 0.5; cursor: default; }
.actions { display: flex; gap: 8px; flex-wrap: wrap; }
.required { color: var(--minus); }
.error { color: var(--minus); white-space: pre-line; }
.profit-plus { color: var(--plus); font-weight: 600; }
.profit-minus { color: var(--minus); font-weight: 600; }
.profit-zero { color: var(--muted); }
.cards { display: grid; grid-template-columns: repeat(auto-fit, minmax(150px, 1fr)); gap: 12px; }
.card { background: var(--surface); border: 1px solid var(--border); border-radius: 12px; padding: 12px; }
.card-label { color: var(--muted); font-size: 0.8rem; }
.card-value { font-size: 1.2rem; font-weight: 700; margin-top: 4px; }
.table-wrap { overflow-x: auto; }
table { width: 100%; border-collapse: collapse; background: var(--surface); }
th, td { text-align: left; padding: 8px; border-bottom: 1px solid var(--border); white-space: nowrap; }
td.num, th.num { text-align: right; }
.filters { display: flex; gap: 8px; flex-wrap: wrap; margin-bottom: 12px; }
.muted { color: var(--muted); }
.badge { display: inline-block; padding: 2px 8px; border-radius: 999px; font-size: 0.75rem; border: 1px solid var(--border); }
.bar { height: 8px; background: var(--accent); border-radius: 4px; }
dl.detail { display: grid; grid-template-columns: max-content 1fr; gap: 8px 16px; }
dl.detail dt { color: var(--muted); }
dl.detail dd { margin: 0; }
section { margin-top: 24px; }
</style>
