# Playbook wiki

Single source of truth for the playbook repository. When this wiki and any other document disagree, the wiki wins. Inside it, the definitions in force are in the shared pages, each citing its decision; each work records its decisions in its own `decisions.md`; [works/history/decisions.md](works/history/decisions.md) is the history from before format 4 (decision-review-9).

Project owner: Andres Frei.

Every statement is one of:

- **Decided** — accepted by the owner, a row of a work's `decisions.md`, or a `D#` or `TD#` of the history in [works/history/decisions.md](works/history/decisions.md).
- **Proposed** — a recommendation waiting for the owner's answer.
- **Open** — a question listed in [01-product/open-questions.md](01-product/open-questions.md).

## Pages

| Page | Content | Code it governs |
|------|---------|-----------------|
| [works/history/decisions.md](works/history/decisions.md) | The decisions from before format 4, `D#` and `TD#`, with the owner's words: history, replaced since by decisions of works without being marked | |
| [01-product/overview.md](01-product/overview.md) | What the product is after phase 4, who uses it, how it starts, and what it is not | |
| [01-product/form.md](01-product/form.md) | Proposed principles for structure and storage, from the agent's side | |
| [01-product/rules.md](01-product/rules.md) | Where each working rule comes from and which decision accepted it; the text is in `plugins/playbook-agents/rules.md` and, for six of them, in the contract of `playbook-wiki` | `plugins/playbook-agents/rules.md`, `plugins/playbook-wiki/contract.md` |
| [01-product/skill-set.md](01-product/skill-set.md) | Which job each skill does, and which plugin holds it | `plugins/playbook-wiki/skills/`, `plugins/playbook-agents/skills/` |
| [01-product/style-guide.md](01-product/style-guide.md) | Format of the rules file and the skills, and the size limits | `plugins/playbook-agents/skills/write-skill/references/style-guide.md`, `scripts/verify.sh` |
| [01-product/phase-2.md](01-product/phase-2.md) | The product definition for phase 2: what is decided, what each topic still lacks | |
| [01-product/phase-3.md](01-product/phase-3.md) | The product definition for phase 3, support for opencode 2.x: what is decided, proposed, and open | |
| [01-product/wiki-maintenance.md](01-product/wiki-maintenance.md) | How a project's wiki stays small and current, and how a changed definition reaches the next session: what was measured, the changes proposed, and the order of the work | `plugins/playbook-wiki/skills/migrate/`, `plugins/playbook-wiki/check-wiki.sh`, `plugins/playbook-wiki/skills/prepare-project/references/1-wiki.md` |
| [01-product/wiki-format-3.md](01-product/wiki-format-3.md) | A proposal for the next format of a project's wiki: the page table says which code each page governs, the page is read before the code is changed, the code left on an old definition is listed, and the check enforces it | |
| [01-product/delegations.md](01-product/delegations.md) | The kinds of decision the agent decides without asking, and those revoked | |
| [01-product/readme.md](01-product/readme.md) | The repository's README: its order, its assets, and the demo console | `README.md`, `docs/how-it-works.md`, `docs/assets/` |
| [01-product/glossary.md](01-product/glossary.md) | Vocabulary, with Spanish | |
| [01-product/open-questions.md](01-product/open-questions.md) | Questions that block closing this stage | |
| [03-technology/codex.md](03-technology/codex.md) | Codex installation, agent profiles and workflow guides | `codex/` |
| [03-technology/installation.md](03-technology/installation.md) | How the product is installed and started in Claude Code, its versions, and the routes evaluated for TD1 | `.claude-plugin/`, `plugins/playbook/.claude-plugin/`, `plugins/playbook-wiki/.claude-plugin/`, `plugins/playbook-agents/.claude-plugin/` |
| [03-technology/claude-code-versions.md](03-technology/claude-code-versions.md) | The Claude Code version this repository was last evaluated against, its evaluations, and the proposals left for later | `.claude/skills/evaluate-cli-releases/` |
| [03-technology/skill-evaluation.md](03-technology/skill-evaluation.md) | How a skill is verified and evaluated: what Claude Code provides and the use chosen | `plugins/playbook-wiki/evals/`, `plugins/playbook-agents/evals/` |
| [03-technology/architecture.md](03-technology/architecture.md) | The architecture of the product as it is: the three plugins, their modules and hooks, the data, and the size limits | `plugins/playbook/skills/init/`, `plugins/playbook-agents/agents/`, `plugins/playbook-agents/evidence.sh`, `plugins/playbook-agents/tasks.sh`, `plugins/playbook-agents/evidence-rules.md`, `plugins/playbook-agents/seed-reviews.sh`, `plugins/playbook-agents/skills/seed-evidence/`, `plugins/playbook-wiki/hooks/`, `plugins/playbook-agents/hooks/`, `plugins/playbook-agents/models.conf`, `scripts/set-models.sh`, `plugins/playbook-wiki/skeleton.md`, `plugins/playbook-agents/skills/config/`, `plugins/playbook-agents/protect.sh`, `plugins/playbook-agents/skills/protect/`, `plugins/playbook-wiki/skills/prepare-project/references/` |
| [03-technology/architecture-phase-2.md](03-technology/architecture-phase-2.md) | The architecture of phases 1 and 2: one plugin, and what phase 2 changed, with risks, trade-offs, and discarded alternatives. Kept as a record | |
| [03-technology/phase-2.md](03-technology/phase-2.md) | What phase 2 needs from its technology and what is chosen for each need (stage 2 of phase 2) | |
| [04-skills/working-skills.md](04-skills/working-skills.md) | The skills the agent uses to build this product (stage 3) | |
| [03-technology/phase-3.md](03-technology/phase-3.md) | What phase 3 needs from its technology, needs N7 to N15, and what is chosen for each (stage 2 of phase 3) | |
| [03-technology/architecture-phase-3.md](03-technology/architecture-phase-3.md) | The architecture of phase 3: how the product works in opencode next to Claude Code, with risks, trade-offs, and discarded alternatives. Kept as a record: phase 4 removed what it describes (D191) | |
| [05-plan/plan.md](05-plan/plan.md) | The work plan for phase 1, in units (stage 5) | |
| [05-plan/plan-phase-2.md](05-plan/plan-phase-2.md) | The work plan for phase 2: units U11 to U19 (stage 5 of phase 2) | |
| [05-plan/plan-phase-3.md](05-plan/plan-phase-3.md) | The work plan for phase 3: units U20 to U27 (stage 5 of phase 3) | |
| [05-plan/phases-before-format-4.md](05-plan/phases-before-format-4.md) | The phases prepared before format 4 and the work waiting for the owner since then: their stage tables and where each is recorded | |
| [05-plan/outside-phases.md](05-plan/outside-phases.md) | Work done outside any phase after phase 2: two changes to `prepare-project`, with what was run for each | |
