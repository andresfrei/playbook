# Phase 3: support for opencode 2.x

Phase 3 makes the product work in opencode 2.x, a second AI coding tool, next to Claude Code (D104). It is prepared with the product's own method, through the six stages again.

This page is the product definition for phase 3. Status: accepted by the owner when stage 1 of phase 3 was closed (D112). Phase 3 is finished (D128). No question about phase 3 is Open. The owner's brief was one sentence, "ahora necesitamos darle soporte a opencode 2.x"; the rest was asked as questions Q43 to Q49 and answered by D105 to D111.

## Decided

- The product gets a third phase, support for opencode 2.x, and it goes through the six stages (D104).
- The problem: the owner needs opencode to use models of other providers, at a lower cost, for part of the work. It is not a replacement for Claude Code when it is unavailable, and not a step towards sharing the product (D105).
- What must work in opencode: the same three parts as in Claude Code and nothing more. The rules in every session, the six skills on demand, and the three agents, each with its model. A part that opencode cannot do is reported in stage 2 with alternatives (D106).
- The provider: opencode works with a subscription of OpenAI. The model of each agent is chosen in stage 2 among the models it gives (D107).
- One source: each rule and skill is written once and used by both tools. A file for one tool exists only where the two differ (D108).
- The four size limits of D48 hold for an opencode session, measured on what opencode loads (D109).
- Engram, CodeGraph, and `context7` are connected to opencode in this phase, each as a unit on the owner's machine that waits for the owner's authorization (D110).
- The 23 skills in `~/.agents/skills/` that are not the product's: stage 2 checks whether opencode 2.x reads that folder; if it does, they are deleted with no copy, in a unit that waits for the owner to ask for it (D111).
- "opencode 2.x" means version 2.3.0, the one installed, and later 2.x versions. Versions 1.x are not supported (D112).
- Claude Code keeps working exactly as it does now. Phase 3 adds a target and takes nothing away (D112).
- What earlier decisions already fix, and phase 3 does not reopen:
  - Skills use the standard `SKILL.md` format with nothing exclusive to one tool, so another tool is added as one more installer target (D11).
  - This repository is the only source, with no hand-copied files, and the product is not a workflow engine, a CLI, or a framework (D40).
  - One job, one skill (D6).
  - The owner is the only user for now (D52).

## Topics

How much the brief and the earlier decisions cover of each topic a product definition needs.

| Topic | Coverage | What is missing |
|-------|----------|-----------------|
| The problem, and who has it | Covered | D105 |
| Who uses it | Covered | The owner (D52) |
| Main flows | Covered | The same as in Claude Code: rules at session start, a skill when the task calls for it, an agent for a delegated job (D106) |
| What it must do | Covered | D106 |
| What it must not do | Covered | Not a CLI or a framework (D40). No second copy of a rule or a skill (D108). Nothing is taken away from Claude Code, and opencode 1.x is not supported (D112) |
| Qualities | Covered | Lower cost (D105) and the size limits of the [style guide](style-guide.md), in both tools (D109) |
| Limits | Covered | opencode 2.x with a subscription of OpenAI (D107). Not verified: that opencode 2.x accepts that subscription, and its models and limits; checked in stage 2 |
| Outside systems | Covered | Engram, CodeGraph, and `context7`, connected to opencode (D110). OpenAI, through the subscription (D107) |
| Volume | Not applicable (D112) | One user, one machine |
| Who runs and maintains it | Covered | The owner |
| Rules, states, vocabulary | Covered | Phase, stage, and unit are in the [glossary](glossary.md) |

## What exists today

- The product, as built in phases 1 and 2: one rules file, six skills, three agents with their model and effort, and the checks. It is installed in Claude Code only. Its parts and how they load are in [../03-technology/architecture-phase-2.md](../03-technology/architecture-phase-2.md).
- opencode 2.3.0 on the owner's machine, with an empty configuration and no provider: ../02-current-state/opencode-on-the-machine.md (kept in the private archive).

## What separates the two

Four parts of the product are tied to Claude Code today. For each one, how opencode does the same job is a technology question for stage 2; what is listed here is only that the tie exists, read from the repository on 2026-11-13.

| Part | How it works in Claude Code | Evidence |
|------|-----------------------------|----------|
| The rules in every session | A `SessionStart` hook of the plugin prints `plugin/rules.md` (TD1) | `plugin/hooks/hooks.json` |
| The agents and their models | Three files with `model` and `effort` in their front matter, naming Anthropic's models, written from `plugin/models.conf` (TD7, TD8, TD11) | `plugin/agents/*.md`, `scripts/set-models.sh` |
| The review skill | It runs in a separate context through `context: fork` and names the `review` agent (TD10) | `plugin/skills/review-change/SKILL.md` |
| Installation and checks | A Claude Code plugin from a marketplace; `scripts/verify.sh` runs `claude plugin validate`, and the evaluations run with Claude Code (TD1, TD4) | `.claude-plugin/marketplace.json`, `scripts/verify.sh`, `plugin/evals/` |

The six skills and the text of the rules are plain Markdown and are expected to need little or no change (D11). That expectation is not verified.

Two rules name tools that opencode does not have connected today: R22 (CodeGraph) and R23 (Engram). Connecting them is part of this phase (D110).
