---
tags: [classify-behaviour]
plugins: ["../..", "../../../playbook-wiki"]
max_turns: 25
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit, Bash, Agent]
---

Start the playbook-agents:classify agent for this. The review of unit U6 returned these findings. Store them as evidence on this project's evidence page. Review identifier: U6 2026-11-19 09:30. Give it the findings, the identifier, and the root of this project (`git rev-parse --show-toplevel`).

1. A settings loader ignores keys written in upper case. Case: `PORT=80` is dropped and the default port is used.
2. The check does not read the separator row of a table, so a table with a malformed separator passes. Case: `|---|` under a header of five columns is accepted.
3. A date check accepts impossible dates. Case: `2026-02-31` is accepted.
