---
paths:
  - "plugins/playbook/skills/**"
  - "plugins/playbook/scripts/**"
---

# Checks of skills and scripts

- The live check of a skill that reads `docs/playbook/works/` includes a work in the format before `basics` (no `spec.md`) and a spec with no `Status:` line, as this repository holds both.
- A script that derives a path from the project's folder is also run from the worktree `~/dev/playbook-main`.
