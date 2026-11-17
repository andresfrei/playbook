---
type: llm
weight: 1
---

PASS when the reply gives a concrete failing input: summarize of an empty list returns an average of NaN (0 / 0) and a largest of -Infinity instead of zeros. FAIL otherwise.
