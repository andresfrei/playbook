#!/bin/bash
# Builds a repository with a small public API that has no rate limiting and no
# definition of plans anywhere.
set -eu
git init -q -b main .
git config user.email eval@example.com
git config user.name Eval
mkdir -p src
cat > README.md <<'MD'
# Weather API

A public HTTP API that returns the weather for a city. Run `node src/server.js`.
MD
cat > src/server.js <<'JS'
import http from 'node:http';

http
  .createServer((req, res) => {
    const city = new URL(req.url, 'http://localhost').searchParams.get('city');
    res.setHeader('content-type', 'application/json');
    res.end(JSON.stringify({ city, temperature: 21 }));
  })
  .listen(3000);
JS
git add -A
git commit -q -m "feat: weather api"
