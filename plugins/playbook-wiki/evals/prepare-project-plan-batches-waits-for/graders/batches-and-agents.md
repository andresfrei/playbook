---
type: llm
weight: 1
focus:
  source: file
  path: docs/wiki/works/pdf-invoice/plan.md
---

PASS when the plan puts units 1 (PDF layout) and 2 (invoice numbering) in batch 1, unit 3 (download button) in batch 2, and names the most `write` agents that run at once. FAIL when unit 3 shares a batch with unit 1 or 2, when the units are not in batches, or when no number of agents is named.
