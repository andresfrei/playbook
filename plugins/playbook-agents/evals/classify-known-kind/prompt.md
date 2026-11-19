---
tags: [classify-behaviour]
plugins: ["../..", "../../../playbook-wiki"]
max_turns: 25
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit, Bash, Agent]
---

Start the playbook-agents:classify agent for this. Review U9 is done and found one thing: the tests of the date check still pass when the check is removed, because they only try valid dates. Keep it in our evidence. Identifier: U9 2026-11-19 11:00. Give it the findings, the identifier, and the root of this project (`git rev-parse --show-toplevel`).
