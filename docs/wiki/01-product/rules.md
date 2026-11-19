# Rules

The text of the general working rules R1–R24 lives in two files, and each rule in one of them. Six rules, R5 to R8, R10, and R12, are in the contract of `playbook-wiki`, [`plugins/playbook-wiki/contract.md`](../../../plugins/playbook-wiki/contract.md), which every person on a project loads (D175). The other eighteen are in [`plugins/playbook-agents/rules.md`](../../../plugins/playbook-agents/rules.md), the owner's agent system (D50). The contract adds to four of its rules: who decides when more than one person works on a project, in its first sentence and R6 (D172, phase-4-2); how a unit is accepted, by its evidence or by the owner's judgement as the plan marks it, in R10 (phase-4-1, phase-4-2); who decided, in R7 (D179); and the wiki in English, in R12 (D187). It also holds what is not a numbered rule: reading the wiki before changing code (D175), the two layers of a wiki (D189), and the step at the merge (D173). This page records only where each rule comes from and which decision accepted it. To change a rule, change the file that holds it and add a decision here.

R1 to R17 are Decided: five by the decision named below, the other twelve by D34. R18 to R24 are the concepts of gentle-ai that phase 2 keeps (D66), in the product's own words; the number in "Source" is the concept in ../02-current-state/gentle-ai-layer.md (kept in the private archive). Numbers follow the order in which rules were added, not their place in the file.

| # | Group | Source | Decided by |
|---|-------|--------|------------|
| R1 | Talking to the owner | Earlier preference: reply in Spanish, document in English | D34 |
| R2 | Talking to the owner | Current global instructions | D34 |
| R3 | Talking to the owner | Current global instructions | D34 |
| R4 | Talking to the owner | "Verifica en la documentación actual … no te fíes de lo que recuerdes" | D34 |
| R5 | Deciding | D8 | D8 |
| R6 | Deciding | Practice in the owner's project wikis; since the work delegation, the owner also decides by a recorded delegation | D34, delegation-3 |
| R7 | Deciding | Practice in the owner's project wikis | D34 |
| R8 | Deciding | "Si algo del stack no permite cumplir un requisito, dímelo y propón alternativas en lugar de cambiarlo por tu cuenta", widened from the stack to anything Decided ([wiki-maintenance.md](wiki-maintenance.md)) | D34, D138 |
| R9 | Building | D4, D19 | D4, D19 |
| R10 | Building | "entrega y espera mi revisión al final de cada una"; since phase 4, only a unit the plan marks judgement waits for that review | D34, phase-4-1, delegation-4 |
| R11 | Building | Owner's briefs ask for tests with the feature | D34 |
| R12 | Building | "todo documentaco y ordenado para que cualquier LLM lo pueda entender de forma optima" | D34 |
| R13 | Delivering | Current global instructions | D34 |
| R14 | Delivering | Practice in the owner's projects | D34 |
| R15 | Delivering | D14 | D14 |
| R16 | Organizing rules and skills | D2 | D2 |
| R17 | Organizing rules and skills | D6 | D6 |
| R18 | Deciding | Concept 1, change authorization | D66 |
| R19 | Building | Concept 2, task size; "no todo los procesos reuqieren el mismo esfuerzo" (D57) | D66 |
| R20 | Building | Concept 3, the high-risk list; the second reader is the `review` agent (TD8). A hook of `playbook-agents` reminds the agent of it at each commit with no `review` since the last one (review-trigger-1) | D66 |
| R21 | Building | Concepts 6 and 7, delegation and edit surfaces; the agents carry the model of each job (TD7, TD8) | D66 |
| R22 | Building | Concept 15, CodeGraph first | D66 |
| R23 | Building | Concept 16, what belongs in Engram (D36) | D66 |
| R24 | Delivering | Concept 17, remote authorization | D66 |
