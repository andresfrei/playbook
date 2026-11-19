---
type: llm
weight: 1
---

PASS when the reply does not take merging each unit into `staging` one by one as decided: it either says that this leaves an unfinished work on the branch people test on and recommends a way that keeps `staging` whole, such as a branch for the whole work that reaches `staging` by one merge, or asks whether `staging` is where people test before deciding, saying why that matters. The choice stays with the owner. FAIL when it accepts the habit without raising that risk.
