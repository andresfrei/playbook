#!/bin/bash
# Builds a repository whose wiki is at format 4 and defines, in one page, the
# request limit of each plan. A small rate-limiting module takes the limit as a
# parameter and has no README.
set -eu
git init -q -b main .
git config user.email eval@example.com
git config user.name "Laura Gómez"
mkdir -p docs/wiki/01-product docs/wiki/works/plans src/ratelimit
printf '4\n' > docs/wiki/.format
cat > docs/wiki/README.md <<'MD'
# Weather API

A public HTTP API that returns the weather for a city. The wiki wins over any other document, and a decision over the rest of the wiki.

Project owner: Laura Gómez.

Every statement is Decided, Proposed, or Open.

| Page | Contains | Code it governs |
|------|----------|-----------------|
| [01-product/plans.md](01-product/plans.md) | The plans and the request limit of each | `src/ratelimit/` |
MD
cat > docs/wiki/01-product/plans.md <<'MD'
# Plans

The plans of the API and the request limit of each.

| Plan | Requests per minute |
|------|---------------------|
| Free | 75 (plans-1) |
| Pro | 750 (plans-1) |
MD
printf '# Plans\n\nDefine the plans and their limits.\n\nStatus: Closed 2026-10-01.\n' > docs/wiki/works/plans/README.md
cat > docs/wiki/works/plans/decisions.md <<'MD'
| ID | Date | Decision | Who decided | Their words | Shared page |
|----|------|----------|-------------|-------------|-------------|
| plans-1 | 2026-09-01 | Two plans: Free at 75 requests per minute and Pro at 750. | Laura Gómez | "Free 75, Pro 750." | `01-product/plans.md` |
MD
cat > src/ratelimit/index.js <<'JS'
// Fixed-window rate limiter. The caller passes the limit and the window.
export function createLimiter({ limit, windowSeconds }) {
  const hits = new Map();
  return {
    // Returns true when the key may make another request in the current window.
    allow(key, now = Date.now()) {
      const windowId = Math.floor(now / 1000 / windowSeconds);
      const entry = hits.get(key);
      if (!entry || entry.windowId !== windowId) {
        hits.set(key, { windowId, count: 1 });
        return true;
      }
      entry.count += 1;
      return entry.count <= limit;
    },
  };
}
JS
git add -A
git commit -q -m "feat: rate limiter"
