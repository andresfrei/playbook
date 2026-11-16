# Playbook wiki

Single source of truth for the playbook repository. When this wiki and any other document disagree, the wiki wins; inside the wiki, [decisions.md](decisions.md) wins.

Every statement is one of:

- **Decided** — accepted by the owner, numbered in [decisions.md](decisions.md).
- **Proposed** — a recommendation waiting for the owner's answer.
- **Open** — a question listed in [01-product/open-questions.md](01-product/open-questions.md).

## Where work stands

Updated 2026-11-16, after D208.

Phase 4 is open at stage 6, Execution (D167). Stages 1 to 5 are closed (D197), and U28 to U36 are done: [05-plan/plan-phase-4.md](05-plan/plan-phase-4.md). It is version 2 of the product and removes the support for opencode (TD32, D191). It splits the product into a shared core, `playbook-wiki`, and the owner's agent system, `playbook-agents`: [01-product/phase-4.md](01-product/phase-4.md).

Wiki maintenance and the doctor (D133 to D142) are built, merged into `main`, and pushed (D144): [01-product/wiki-maintenance.md](01-product/wiki-maintenance.md).

Wiki format 3 (D155 to D165) is built and merged into `main`: [01-product/wiki-format-3.md](01-product/wiki-format-3.md). This wiki, the pilot, reached format 3 with the doctor on 2026-11-15.

The repository is public since 2026-11-14 (D145 to D152): https://github.com/andresfrei/playbook. Every pull request needs the owner's approval. The full earlier history, with the pages about the owner's installation, is in the private `andresfrei/playbook-archive`.

Waiting for the owner:

- Six proposals to spend fewer tokens, P1 to P6: 02-current-state/token-economy.md (kept in the private archive).
- The plugin's version: an installation from GitHub gets wiki format 3 only when the owner raises it (TD22).

Next steps:

1. U37 to U41 in the order of the plan, one at a time.
2. The owner reviews each unit when it ends.

Finished:

- Phase 3, support for opencode 2.x (D128), which phase 4 removes (D191): [05-plan/plan-phase-3.md](05-plan/plan-phase-3.md).
- Phase 2, replacing gentle-ai (D28, D98): [05-plan/plan-phase-2.md](05-plan/plan-phase-2.md).
- Phase 1 (D61): [05-plan/plan.md](05-plan/plan.md).
- Work done outside any phase: [05-plan/outside-phases.md](05-plan/outside-phases.md).

## Stage table

Phase 4 (D167):

| Stage | Status | Closed on |
|-------|--------|-----------|
| 1 Wiki | Closed | 2026-11-16 |
| 2 Technology | Closed | 2026-11-16 |
| 3 Skills | Closed | 2026-11-16 |
| 4 Design system | Closed, not applicable (D195) | 2026-11-16 |
| 5 Plan | Closed | 2026-11-16 |
| 6 Execution | Open | |

Phase 3 (D104):

| Stage | Status | Closed on |
|-------|--------|-----------|
| 1 Wiki | Closed | 2026-11-13 |
| 2 Technology | Closed | 2026-11-13 |
| 3 Skills | Closed | 2026-11-13 |
| 4 Design system | Closed, not applicable (D116) | 2026-11-13 |
| 5 Plan | Closed | 2026-11-13 |
| 6 Execution | Closed | 2026-11-13 |

Phase 2 (D63):

| Stage | Status | Closed on |
|-------|--------|-----------|
| 1 Wiki | Closed | 2026-11-13 |
| 2 Technology | Closed | 2026-11-13 |
| 3 Skills | Closed | 2026-11-13 |
| 4 Design system | Closed, not applicable (D74) | 2026-11-13 |
| 5 Plan | Closed | 2026-11-13 |
| 6 Execution | Closed | 2026-11-13 |

Phase 1, kept as a record:

| Stage | Status | Closed on |
|-------|--------|-----------|
| 1 Wiki | Closed | 2026-11-13 |
| 2 Technology | Closed | 2026-11-13 |
| 3 Skills | Closed | 2026-11-13 |
| 4 Design system | Closed, not applicable (D45) | 2026-11-13 |
| 5 Plan | Closed | 2026-11-13 |
| 6 Execution | Closed | 2026-11-13 |

## Pages

| Page | Content | Code it governs |
|------|---------|-----------------|
| [decisions.md](decisions.md) | Numbered decisions with the owner's words | |
| [01-product/overview.md](01-product/overview.md) | What the playbook is and is not | |
| [01-product/form.md](01-product/form.md) | Proposed principles for structure and storage, from the agent's side | |
| [01-product/rules.md](01-product/rules.md) | Where each working rule comes from and which decision accepted it; the text is in `plugins/playbook-agents/rules.md` and, for six of them, in the contract of `playbook-wiki` | `plugins/playbook-agents/rules.md`, `plugins/playbook-wiki/contract.md` |
| [01-product/skill-set.md](01-product/skill-set.md) | Which job each skill does, and who owns it | `plugins/playbook-wiki/skills/`, `plugins/playbook-agents/skills/` |
| [01-product/style-guide.md](01-product/style-guide.md) | Format of the rules file and the skills, and the size limits | `plugins/playbook-agents/skills/write-skill/references/style-guide.md`, `scripts/verify.sh` |
| [01-product/phase-2.md](01-product/phase-2.md) | The product definition for phase 2: what is decided, what each topic still lacks | |
| [01-product/phase-3.md](01-product/phase-3.md) | The product definition for phase 3, support for opencode 2.x: what is decided, proposed, and open | |
| [01-product/phase-4.md](01-product/phase-4.md) | The product definition for phase 4, a shared core separate from each person's agent system: what is decided, proposed, and open | |
| [01-product/wiki-maintenance.md](01-product/wiki-maintenance.md) | How a project's wiki stays small and current, and how a changed definition reaches the next session: what was measured, the changes proposed, and the order of the work | `plugins/playbook-wiki/skills/doctor/`, `plugins/playbook-wiki/check-wiki.sh`, `plugins/playbook-wiki/skills/prepare-project/references/1-wiki.md` |
| [01-product/wiki-format-3.md](01-product/wiki-format-3.md) | A proposal for the next format of a project's wiki: the page table says which code each page governs, the page is read before the code is changed, the code left on an old definition is listed, and the check enforces it | `plugins/playbook-wiki/skills/doctor/references/format-3.md` |
| [01-product/glossary.md](01-product/glossary.md) | Vocabulary, with Spanish | |
| [01-product/open-questions.md](01-product/open-questions.md) | Questions that block closing this stage | |
| [03-technology/installation.md](03-technology/installation.md) | How the product is installed in Claude Code: the routes evaluated and the one chosen | `.claude-plugin/`, `plugins/playbook/.claude-plugin/`, `plugins/playbook-wiki/.claude-plugin/`, `plugins/playbook-agents/.claude-plugin/` |
| [03-technology/skill-evaluation.md](03-technology/skill-evaluation.md) | How a skill is verified and evaluated: what Claude Code provides and the use chosen | `plugins/playbook-wiki/evals/`, `plugins/playbook-agents/evals/` |
| [03-technology/architecture.md](03-technology/architecture.md) | The architecture: the product as it is and what phase 2 changes, with risks, trade-offs, and discarded alternatives | `plugins/playbook-agents/agents/`, `plugins/playbook-wiki/hooks/`, `plugins/playbook-agents/hooks/`, `plugins/playbook-agents/models.conf`, `scripts/set-models.sh` |
| [03-technology/phase-2.md](03-technology/phase-2.md) | What phase 2 needs from its technology and what is chosen for each need (stage 2 of phase 2) | |
| [04-skills/working-skills.md](04-skills/working-skills.md) | The skills the agent uses to build this product (stage 3) | |
| [03-technology/phase-3.md](03-technology/phase-3.md) | What phase 3 needs from its technology, needs N7 to N15, and what is chosen for each (stage 2 of phase 3) | |
| [03-technology/phase-4.md](03-technology/phase-4.md) | What phase 4 needs from its technology, needs N16 to N27, and what is chosen for each (stage 2 of phase 4) | `plugins/playbook-wiki/format.md`, `plugins/playbook-wiki/merge-step.sh`, `plugins/playbook-wiki/hooks/merge-step-hook.sh` |
| [03-technology/architecture-phase-4.md](03-technology/architecture-phase-4.md) | The architecture of phase 4: three plugins, the start command with its wizard, and the files of a work, with risks, trade-offs, and how it can evolve | |
| [03-technology/architecture-phase-3.md](03-technology/architecture-phase-3.md) | The architecture of phase 3: how the product works in opencode next to Claude Code, with risks, trade-offs, and discarded alternatives. Kept as a record: phase 4 removed what it describes (D191) | |
| [05-plan/plan.md](05-plan/plan.md) | The work plan for phase 1, in units (stage 5) | |
| [05-plan/plan-phase-2.md](05-plan/plan-phase-2.md) | The work plan for phase 2: units U11 to U19 (stage 5 of phase 2) | |
| [05-plan/plan-phase-3.md](05-plan/plan-phase-3.md) | The work plan for phase 3: units U20 to U27 (stage 5 of phase 3) | |
| [05-plan/plan-phase-4.md](05-plan/plan-phase-4.md) | The work plan for phase 4: units U28 to U41 (stage 5 of phase 4) | |
| [05-plan/outside-phases.md](05-plan/outside-phases.md) | Work done outside any phase after phase 2: two changes to `prepare-project`, with what was run for each | |
