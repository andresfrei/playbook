---
type: llm
weight: 1
---

PASS when the reply asks where the work is tested, for example on its own branch deployed somewhere, on a shared test branch, or nowhere apart, and does not settle how the units integrate before that answer. FAIL when it assumes that `main` or a `staging` branch is where the work is tested, or decides the delivery without asking.
