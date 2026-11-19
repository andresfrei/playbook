# Glossary

| Term | Español | Meaning |
|------|---------|---------|
| Playbook | Manual de trabajo | This repository, and the product it publishes as three plugins: `playbook`, `playbook-wiki`, and `playbook-agents` (TD26, D182) |
| Rule | Regla | An instruction that always applies, in every project |
| Skill | Skill | A `SKILL.md` an agent loads for one kind of task |
| Job | Trabajo | The one thing a skill is for; no two skills share a job |
| General | General | Valid in every project |
| Project-specific | Particular | Valid in one project; lives in that project |
| Source | Origen | Whatever installs a skill: gentle-ai, the overlay, a manual copy, or the playbook |
| Stage | Etapa | One of the six steps that prepare a project |
| Unit | Unidad | One step of the work plan written in stage 5. Not a stage (D46) |
| Owner | Dueño | The person who decides; only they turn Proposed into Decided. In the core, a project names one owner, who decides what works share, and the person who leads a work decides inside it (D172) |
| Phase | Fase del producto | One of the steps in which the product is built: phases 1 and 2 (D30), phase 3 (D104), and phase 4 (D167). Not a stage |
| Core | Core | The part of the product that everyone who works on a project shares, and that lives in the project's repository: the wiki, the works, the decisions, the minimal contract, and the check (D168). It is delivered as the plugin `playbook-wiki` (D182) |
| Agent system | Sistema de agentes | What one person uses to work with an AI coding agent: rules, skills, agents, and tools. Each person has their own, built on the core (D168). The owner's is the plugin `playbook-agents` (D182) |
| Acceptance of a unit | Aceptación de una unidad | How a unit becomes Done, which the plan marks for each one: by evidence, when its ending condition holds and the evidence is recorded; or by judgement, when the owner also reviews it (phase-4-1) |
| Work | Trabajo colaborativo (Proposed) | What one branch carries from its start to its merge: a phase with its six stages, or a smaller change outside phases. Several are open at once (D171). Not a job |
| Work branch | Rama de la work | The branch that holds a whole work while its units integrate on it; the work leaves it by one merge. By default named `<type>/<work>`, such as `feat/user-login`, unless the project has its own convention (work-delivery-3, work-delivery-5) |
| Tracker pull request | Pull request de seguimiento | A draft pull request from the work branch to where the work goes, which shows the work's progress and is merged when the work is ready. Opened only when the owner says so (work-delivery-5) |
| Where the work is tested | Dónde se prueba la work | The place the owner checks a work before it closes: its own branch, deployed for instance from a worktree; a shared branch people test on; or nowhere apart (work-delivery-8) |
| Delegation | Delegación | A decision of the owner that lets the agent decide one kind of question in one project without asking; recorded as a decision, listed in `01-product/delegations.md`, and revoked by a later decision. Never for a new definition of the product, a push or merge into the main branch, an action outside the repository, or spending beyond a written ceiling (delegation-3, delegation-5, delegation-7) |
| Kind of a decision | Tipo de decisión | What a decision of a work is about, from a fixed list such as close-stage, definition, or consolidate, with how the owner answered; the check counts them to propose a delegation (delegation-6, delegation-8) |
| Evidence | Evidencia | One finding of `review` that the agent `classify` stored as a row of a project's `docs/wiki/evidence.md`, under a kind and a level (repeated-corrections-2, repeated-corrections-15, repeated-corrections-17) |
| Kind (of evidence) | Tipo de evidencia | The name of a mistake, not of the place, such as `test-passes-when-broken`, with one rule a step can act on; never renamed. Not the kind of a decision (repeated-corrections-11) |
| Level | Nivel | How many consolidations the records of a kind went through; only a statistic. A kind with no rule is at level 1 (repeated-corrections-5) |
| Consolidation | Consolidación | N records of one kind and level from 3 distinct reviews become one rule one level up, and the records are deleted, git keeping them. Proposed to the owner at the close of a work, or made by the agent when the owner delegated the kind `consolidate` (repeated-corrections-5, repeated-corrections-12, repeated-corrections-13) |
