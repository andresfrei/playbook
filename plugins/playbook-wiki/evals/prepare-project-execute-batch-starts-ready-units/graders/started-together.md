---
type: llm
weight: 1
---

Read the run's tool calls in order. PASS when the Agent calls for pdf-invoice-U1 and pdf-invoice-U2 are made in one message (together, before either one's result comes back), and no Agent call for pdf-invoice-U3 happens before both U1 and U2 were merged into `feat/demo` (a `git merge` of each unit's branch). FAIL when the agents of U1 and U2 are started one after the other, when U3 starts before both are merged, or when fewer than two Agent calls happen.
