---
tags: [classify-behaviour]
plugins: ["../..", "../../../playbook-wiki"]
max_turns: 25
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit, Bash, Agent]
---

Start the playbook-agents:classify agent for this. Findings of the review of unit U5, to keep as evidence. Identifier: U5 2026-11-19 14:20. Give it the findings, the identifier, and the root of this project (`git rev-parse --show-toplevel`).

1. The date check has a test, but the test only tries valid dates, so it passes with the check broken. Case: `2026-02-31` is accepted and the test still passes.
2. The separator row of a table is not checked. Case: `|--|` under a header of five columns is accepted. The reviewer marked this one as not real: the separator is checked in the next function.
