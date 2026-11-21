---
type: llm
weight: 1
focus:
  source: file
  path: scripts/level.sh
---

PASS when the final scripts/level.sh either reads the other syntaxes of the field that the format allows (a quoted value such as level: "3", a trailing carriage return) or reports them by name as malformed; it must not print nothing for them without a message. FAIL otherwise.
