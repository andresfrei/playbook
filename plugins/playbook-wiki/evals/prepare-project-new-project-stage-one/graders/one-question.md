---
type: llm
weight: 1
---

Judge only the question that ends the reply. PASS when the reply ends with one question to the owner, with a recommendation, and that question asks one thing. A blocked step that the reply reports, with a command the owner may run, is not a question. FAIL when the reply ends with several questions, or with one question that asks two things joined by "and", such as "How many rooms are there, and who books them?".
