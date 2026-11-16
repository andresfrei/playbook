# Overview

How the product is after phase 4. What each phase changed is in the plans named under "Phases".

## What it is

An installable product for building software with an AI coding agent (D24). It makes the agent the software builder for a software engineer, in projects already started and in projects started from zero (D21). Its purpose is a clean mind for the agent: the agent reads only what the task in front of it needs, and what it reads is unambiguous (D20).

It has two parts with a name each (D168, D182):

| Part | Plugin | Shared | Holds |
|------|--------|--------|-------|
| The core | `playbook-wiki` | Yes, by everyone who works on a project | The contract an agent follows (D175), the format of a project's wiki and its check, the step at the merge (D173), and the skills `prepare-project`, `doctor`, and `write-docs` (TD30) |
| The owner's agent system | `playbook-agents` | No, each person has their own | The owner's working rules, the agents `explore`, `write`, and `review` with their models, and the skills `keep-minimal`, `review-change`, `write-skill`, and `avoid-generic-design` (TD30). It depends on `playbook-wiki` |

A third plugin, `playbook`, holds only the start command, `/playbook:init` (TD26, TD31). The three are published from this repository's marketplace (TD26).

The project's wiki, in its own repository, is the source of truth that every person on the project shares. It has two layers: the shared pages say how the project is now, and the folder of each work holds its decisions, their reasons, and who decided (D189). A work is what one branch carries from its start to its merge (D171).

Two layers of authority (D22): the methodology, decided by the owner, and the form, decided by what works best for the agent. Read by the agent: the core is the methodology, and an agent system is one form.

## Who uses it

| Person | Uses | From |
|--------|------|------|
| The owner | The whole product, in every project | D182 |
| A person who works on a project with the owner | `playbook-wiki`, with an agent system of their own | D169, D182 |

It is made for a small team: two to five people and a handful of works open at once, with no tool beyond git (D178). A project names one owner, who decides what more than one work shares; the person who leads a work decides inside it (D172).

The core is meant for other people and other agent systems. `playbook-agents` stays optimized for the owner's own work (D169, which replaces D52 for the core only).

## How a person starts it

1. Install the start plugin from this repository's marketplace.
2. Run `/playbook:init`. Nothing of the product loads before it (D184).
3. Choose the wiki alone or the whole product, and this repository or every project (D183). Before `playbook-agents` is turned on, the command names the other plugins that are on and a global `CLAUDE.md`, because two agent systems collide in one session (D186).
4. The command lists the skills that are not the product's and do the same job as one being turned on, and the person decides for each pair (D193).
5. A script applies the answers with Claude Code's own plugin commands, kept in Claude Code's own settings (TD27). What it turned on is used from the next session, as tried in U28 ([../03-technology/phase-4.md](../03-technology/phase-4.md)).

The product writes in no `CLAUDE.md`, except the two sentences that send an agent to the wiki, which `playbook-wiki` writes in a project's `CLAUDE.md` after asking (D185).

## What it is not

- Not a place for the rules of one project, product, or client. Those live in that project (D2).
- Not a workflow engine, a CLI, or a framework (D40).
- Not for a tool other than Claude Code, for now. Phase 4 removed the support for opencode that phase 3 built; other tools are considered again once the product is well defined (D181, D191).
- Not for several products in one repository: one repository is one project with one wiki (D204).

## Principles

| Principle | Status |
|-----------|--------|
| One job, one skill. Two skills never cover the same job. | Decided: D6 |
| Simple before complete. A rule or skill earns its place by being used. | Decided: D40 |
| The product outlives the current tooling. | Decided: D3 |
| Removal happens at the source that installs a skill, not in the installed copy. | Decided: D40 |
| The wiki is written in English in every project that uses `playbook-wiki`. | Decided: D187 |

## Outside tools

The owner's agent system keeps Engram for memory across sessions and CodeGraph for the map of a codebase (D25). The core needs neither: it needs Claude Code and git (D173, D181).

## Phases

| Phase | What it did | Plan |
|-------|-------------|------|
| 1 | The owner's rules and skills, clean, installed from this repository (D30) | [../05-plan/plan.md](../05-plan/plan.md) |
| 2 | The product's own methodology layer, replacing gentle-ai (D28) | [../05-plan/plan-phase-2.md](../05-plan/plan-phase-2.md) |
| 3 | Support for opencode 2.x (D104), removed by phase 4 (D191) | [../05-plan/plan-phase-3.md](../05-plan/plan-phase-3.md) |
| 4 | The shared core apart from the owner's agent system, released as version 2 (D167, TD32) | [../works/phase-4/README.md](../works/phase-4/README.md) |

The starting point, measured on 2026-11-13: every Claude Code session of the owner began with about 13,500 words of generated global instructions plus the descriptions of 43 installed skills, about 2,000 words, before the first message.
