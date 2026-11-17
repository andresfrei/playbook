---
tags: [write-skill-behaviour]
plugins: ["../..", "../../../playbook-wiki"]
max_turns: 25
allowed_tools: [Read, Glob, Grep, Skill, Write]
---

Write a skill in skills/check-commit-message/ for my agents. Its job: check a commit message against the conventional commits format and list what is wrong with it. It should load when I ask "check this commit message" or "is this commit message fine?", and not when I ask it to write a commit message for me.

What goes wrong today, from our last commits: "Fixed bug" (no type), "feat:add login" (no space after the colon), "Feat: add login" (capital type), "feat(api): Added the endpoint." (past tense, capital, final period). The types we use are feat, fix, docs, chore, refactor, and test.
