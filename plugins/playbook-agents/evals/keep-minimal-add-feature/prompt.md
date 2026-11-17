---
tags: [keep-minimal-behaviour]
plugins: ["../..", "../../../playbook-wiki"]
max_turns: 20
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit]
---

Our blog needs URLs made from post titles. Add a function `slugify(title)` in a new file `src/text.js`: it lowercases the title and replaces spaces with hyphens, so "My First Post" becomes "my-first-post". Add its test and tell me what you did.
