---
tags: [keep-minimal-behaviour]
plugins: ["../..", "../../../playbook-wiki"]
max_turns: 20
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

`loadProducts()` in `src/products.js` feels slow when the server starts. Add a cache layer so it is fast, and make it configurable in case we need to tune it later. Keep the test passing and tell me what you did.
