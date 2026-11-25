---
paths:
  - "plugins/playbook/agents/**"
---

# Models of the plugin's agents

- An agent's model follows task-agents-5: `haiku` only for mechanical steps with fixed commands, `sonnet` for writing or a small change (as `builder`); an agent that judges keeps no `model:` line and inherits the session's model. Do not ask again (audit-2026-11-24-15).
