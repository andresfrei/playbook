# Playbook wiki

Single source of truth for the playbook repository. When this wiki and any other document disagree, the wiki wins; inside the wiki, [decisions.md](decisions.md) wins.

Project owner: Andres Frei.

Every statement is one of:

- **Decided** — accepted by the owner, numbered in [decisions.md](decisions.md).
- **Proposed** — a recommendation waiting for the owner's answer.
- **Open** — a question listed in [01-product/open-questions.md](01-product/open-questions.md).

## Pages

| Page | Content | Code it governs |
|------|---------|-----------------|
| [decisions.md](decisions.md) | Numbered decisions with the owner's words | |
| [01-product/overview.md](01-product/overview.md) | What the product is after phase 4, who uses it, how it starts, and what it is not | |
| [01-product/form.md](01-product/form.md) | Proposed principles for structure and storage, from the agent's side | |
| [01-product/rules.md](01-product/rules.md) | Where each working rule comes from and which decision accepted it; the text is in `plugins/playbook-agents/rules.md` and, for six of them, in the contract of `playbook-wiki` | `plugins/playbook-agents/rules.md`, `plugins/playbook-wiki/contract.md` |
| [01-product/skill-set.md](01-product/skill-set.md) | Which job each skill does, and which plugin holds it | `plugins/playbook-wiki/skills/`, `plugins/playbook-agents/skills/` |
| [01-product/style-guide.md](01-product/style-guide.md) | Format of the rules file and the skills, and the size limits | `plugins/playbook-agents/skills/write-skill/references/style-guide.md`, `scripts/verify.sh` |
| [01-product/phase-2.md](01-product/phase-2.md) | The product definition for phase 2: what is decided, what each topic still lacks | |
| [01-product/phase-3.md](01-product/phase-3.md) | The product definition for phase 3, support for opencode 2.x: what is decided, proposed, and open | |
| [01-product/wiki-maintenance.md](01-product/wiki-maintenance.md) | How a project's wiki stays small and current, and how a changed definition reaches the next session: what was measured, the changes proposed, and the order of the work | `plugins/playbook-wiki/skills/doctor/`, `plugins/playbook-wiki/check-wiki.sh`, `plugins/playbook-wiki/skills/prepare-project/references/1-wiki.md` |
| [01-product/wiki-format-3.md](01-product/wiki-format-3.md) | A proposal for the next format of a project's wiki: the page table says which code each page governs, the page is read before the code is changed, the code left on an old definition is listed, and the check enforces it | `plugins/playbook-wiki/skills/doctor/references/format-3.md` |
| [01-product/delegations.md](01-product/delegations.md) | The kinds of decision the agent decides without asking, and those revoked | |
| [01-product/glossary.md](01-product/glossary.md) | Vocabulary, with Spanish | |
| [01-product/open-questions.md](01-product/open-questions.md) | Questions that block closing this stage | |
| [03-technology/codex.md](03-technology/codex.md) | Codex installation, agent profiles and workflow guides | `codex/` |
| [03-technology/installation.md](03-technology/installation.md) | How the product is installed and started in Claude Code, its versions, and the routes evaluated for TD1 | `.claude-plugin/`, `plugins/playbook/.claude-plugin/`, `plugins/playbook-wiki/.claude-plugin/`, `plugins/playbook-agents/.claude-plugin/` |
| [03-technology/skill-evaluation.md](03-technology/skill-evaluation.md) | How a skill is verified and evaluated: what Claude Code provides and the use chosen | `plugins/playbook-wiki/evals/`, `plugins/playbook-agents/evals/` |
| [03-technology/architecture.md](03-technology/architecture.md) | The architecture of the product as it is: the three plugins, their modules and hooks, the data, and the size limits | `plugins/playbook/skills/init/`, `plugins/playbook-agents/agents/`, `plugins/playbook-agents/evidence.sh`, `plugins/playbook-agents/evidence-rules.md`, `plugins/playbook-agents/seed-reviews.sh`, `plugins/playbook-agents/skills/seed-evidence/`, `plugins/playbook-wiki/hooks/`, `plugins/playbook-agents/hooks/`, `plugins/playbook-agents/models.conf`, `scripts/set-models.sh`, `plugins/playbook-wiki/skeleton.md`, `plugins/playbook-agents/skills/config/`, `plugins/playbook-agents/protect.sh`, `plugins/playbook-agents/skills/protect/` |
| [03-technology/architecture-phase-2.md](03-technology/architecture-phase-2.md) | The architecture of phases 1 and 2: one plugin, and what phase 2 changed, with risks, trade-offs, and discarded alternatives. Kept as a record | |
| [03-technology/phase-2.md](03-technology/phase-2.md) | What phase 2 needs from its technology and what is chosen for each need (stage 2 of phase 2) | |
| [04-skills/working-skills.md](04-skills/working-skills.md) | The skills the agent uses to build this product (stage 3) | |
| [03-technology/phase-3.md](03-technology/phase-3.md) | What phase 3 needs from its technology, needs N7 to N15, and what is chosen for each (stage 2 of phase 3) | |
| [03-technology/architecture-phase-3.md](03-technology/architecture-phase-3.md) | The architecture of phase 3: how the product works in opencode next to Claude Code, with risks, trade-offs, and discarded alternatives. Kept as a record: phase 4 removed what it describes (D191) | |
| [05-plan/plan.md](05-plan/plan.md) | The work plan for phase 1, in units (stage 5) | |
| [05-plan/plan-phase-2.md](05-plan/plan-phase-2.md) | The work plan for phase 2: units U11 to U19 (stage 5 of phase 2) | |
| [05-plan/plan-phase-3.md](05-plan/plan-phase-3.md) | The work plan for phase 3: units U20 to U27 (stage 5 of phase 3) | |
| [05-plan/outside-phases.md](05-plan/outside-phases.md) | Work done outside any phase after phase 2: two changes to `prepare-project`, with what was run for each | |

## Phases before format 4

The phases below were prepared before this wiki reached format 4. Their decisions are in [decisions.md](decisions.md). Phase 4 is the work [works/phase-4/README.md](works/phase-4/README.md).

Finished:

- Phase 3, support for opencode 2.x (D128), which phase 4 removes (D191): [05-plan/plan-phase-3.md](05-plan/plan-phase-3.md).
- Phase 2, replacing gentle-ai (D28, D98): [05-plan/plan-phase-2.md](05-plan/plan-phase-2.md).
- Phase 1 (D61): [05-plan/plan.md](05-plan/plan.md).
- Work done outside any phase: [05-plan/outside-phases.md](05-plan/outside-phases.md).
- Wiki maintenance and the doctor (D133 to D142), built, merged into `main`, and pushed (D144): [01-product/wiki-maintenance.md](01-product/wiki-maintenance.md).
- Wiki format 3 (D155 to D165), built and merged into `main`: [01-product/wiki-format-3.md](01-product/wiki-format-3.md). This wiki, the pilot, reached format 3 with the doctor on 2026-11-15.
- The repository is public since 2026-11-14 (D145 to D152): https://github.com/andresfrei/playbook. Every pull request needs the owner's approval. The full earlier history, with the pages about the owner's installation, is in the private `andresfrei/playbook-archive`.

Waiting for the owner since before format 4:

- Six proposals to spend fewer tokens, P1 to P6: 02-current-state/token-economy.md (kept in the private archive).
- The work [works/seed-evidence/README.md](works/seed-evidence/README.md), which builds a repository's first evidence page from its past reviews, is closed and released as 3.3.0 (seed-evidence-33).
- The plugin's version: an installation from GitHub gets wiki format 3 only when the owner raises it (TD22). Phase 4 raises it to `2.0.0` (TD32).

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
