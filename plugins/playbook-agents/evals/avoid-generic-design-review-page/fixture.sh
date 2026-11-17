#!/bin/bash
set -eu
git init -q -b main .
git config user.email eval@example.com
git config user.name Eval
# Builds a static landing page with four generic patterns and no design system.
cat > index.html <<'HTML'
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <title>Lumen</title>
  <link rel="stylesheet" href="style.css">
</head>
<body>
  <header class="hero">
    <h1>Work smarter with Lumen</h1>
    <p>The project tool for modern teams.</p>
    <a class="button" href="#start">Get started</a>
  </header>
  <section class="features">
    <div class="card"><h3>Plan</h3><p>Lay out your work in minutes.</p></div>
    <div class="card"><h3>Track</h3><p>See progress as it happens.</p></div>
    <div class="card"><h3>Ship</h3><p>Release with confidence.</p></div>
  </section>
</body>
</html>
HTML
cat > style.css <<'CSS'
body {
  font-family: Inter, sans-serif;
  margin: 0;
  text-align: center;
}

.hero {
  padding: 96px 24px;
  color: #fff;
  background: linear-gradient(135deg, #7c3aed, #3b82f6);
}

.button {
  display: inline-block;
  padding: 12px 24px;
  border-radius: 8px;
  background: #fff;
  color: #7c3aed;
}

.features {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 24px;
  padding: 64px 24px;
}

.card {
  padding: 24px;
  border-radius: 12px;
  background: #fff;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}
CSS
git add -A
git commit -q -m "feat: landing page"
