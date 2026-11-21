---
type: llm
weight: 1
focus:
  source: file
  path: scripts/level.sh
---

PASS when the final scripts/level.sh, for a level that is not 1, 2, or 3 (such as 9 or abc), prints a message that names the value and exits non-zero, instead of printing nothing or a known word. FAIL otherwise.
