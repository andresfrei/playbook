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
| Work | Trabajo colaborativo (Proposed) | What one branch carries from its start to its merge: a phase with its six stages, or a smaller change outside phases. Several are open at once (D171). Not a job |
