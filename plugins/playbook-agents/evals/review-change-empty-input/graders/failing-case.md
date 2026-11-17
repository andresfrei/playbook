---
type: llm
weight: 1
---

PASS when the reply gives a concrete failing input: average of an empty list, which returns NaN (0 / 0) instead of a defined result or an error. FAIL otherwise.
