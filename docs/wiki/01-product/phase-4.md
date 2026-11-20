# Phase 4: a shared core

Phase 4 splits the product into a shared core and each person's agent system, so that more than one person can work on the same project (D167, D168). It is prepared with the product's own method, through the six stages again.

This page is the product definition for phase 4. Status: accepted by the owner when stage 1 of phase 4 was closed, on 2026-11-16 (D180). D181 to D191 were decided later the same day, in stage 2, and D193 in stage 3; they are written here. The terms core, agent system, and work are in the [glossary](glossary.md). The rules named `R#` are in `plugin/rules.md`.

## Decided

- The product gets a fourth phase, and it goes through the six stages (D167).
- The product splits in two (D168):

  | Part | Shared | Lives in | Holds |
  |------|--------|----------|-------|
  | Core | Yes, by everyone who works on a project | The project's repository holds the wiki as the source of truth, the works in progress, and the decisions with their reasons. The plugin `playbook-wiki` holds the minimal contract an agent follows and the check (TD26, which changes this part of D168) | Everything a person needs to work on the project with others |
  | Agent system | No, each person has their own | Each person's machine | Whatever that person uses to work with an AI coding agent, built on the core. The owner's is `playbook-agents` (D182) |

- The core is meant for other people and for agent systems other than the playbook's. The playbook's own rules, skills, and agents stay optimized for the owner (D169, which changes D52 and part of D105 for the core only).
- In the core, a decision is identified by the short name of its work and a counter of that work, such as `auth-3`. Each work keeps its decisions in a file of its own (D170). The alternatives discarded are under "Identifiers considered".
- A work is what one branch carries from its start to its merge: a phase with its six stages, or a smaller change outside phases. Several works are open at once, each with its name, its decisions, and its state. Phases are no longer one after another, and the stage table belongs to its work (D171).
- A project names one owner in its `README.md`. The person who leads a work decides inside that work. A decision that changes a definition other works share goes to the project's owner (D172).
- Before a work is merged, the person who merges reads the decisions it brings against the definitions other works share. A contradiction is settled by a new decision that names both and says which holds and why. The contract requires this step. The core assumes git only, not a forge such as GitHub (D173).
- Questions and units get the same identifier as decisions: the work's name and a counter of their own, kept in that work's files, with a letter that tells them apart, such as `auth-Q2` and `auth-U1` (D174).
- The minimal contract of the core holds the rules about deciding: definitions before code (R5), who decides and the three statuses (R6, as D172 changes it), the owner's words verbatim (R7), saying when a request differs from what is Decided (R8), delivering in stages (R10), and documentation any agent understands (R12). It also holds reading the wiki before changing code, and the step at the merge (D173). Every other rule stays in each person's agent system or in the project's own rules (D175).
- The core is published from this repository as the plugin `playbook-wiki`, in `plugins/playbook-wiki/` (D176, TD26, decision-review-12).
- Decisions written before the core keep their identifiers and are never renumbered. The new identifiers start with the wiki format that brings them, so a wiki holds both: the earlier file with `D#` and the files of each work (D177). Read by the agent: the same holds for earlier questions and units.
- The core is made for a small team: two to five people and a handful of works open at once, with no tool beyond git. What a larger team needs is decided when that team exists (D178).
- A decision's row records who decided. Each work says where it stands in a file of its own, in place of one "Where work stands" section for the whole project. The playbook's plugin is one agent system built on the core, like any other. The owner maintains the definition of the core (D179).
- Phase 4 is built for Claude Code only, for now (D181). Support for opencode, which phase 3 built, is removed in this phase, and other tools are considered again once the product is well defined (D191).
- The two parts have a name each: `playbook-wiki`, the core, and `playbook-agents`, the owner's agent system. The owner uses both; another person may use `playbook-wiki` alone (D182).
- The product is installed for every project of a person or for one repository. Each person chooses, for each repository, the whole product or `playbook-wiki` alone (D183).
- Starting the product is deliberate. Once installed, Claude Code uses nothing of it until the person runs the start command. That command opens a wizard made with Claude Code's own question dialog, and a script applies the answers (D184). How it is done is in [../03-technology/phase-4.md](../03-technology/phase-4.md).
- The start plugin writes in no `CLAUDE.md`, the person's or the project's. What a person chose is only which plugins are on. The one text the product writes in a project's `CLAUDE.md` stays the two sentences that send an agent to the wiki, written by `playbook-wiki` when it creates the wiki, after asking (D185).
- Before it turns `playbook-agents` on, the wizard tells the person which other plugins are on and whether a global `CLAUDE.md` exists, because two agent systems collide in one session. It changes nothing of another tool (D186).
- At the start, the product looks for skills that are not its own: the project's, the person's, and other plugins'. A script lists them; the agent points out the ones that do the same job as a skill being turned on; the person decides for each: turn their own off, keep both, or leave the plugin off. It runs for `playbook-wiki` as well as for `playbook-agents` (D193, which changes that part of D186).
- The wiki is written in English in every project that uses `playbook-wiki`. It is a rule of the core, not of one person's agent system (D187). The owner's reason: agents work better in English and cost a little less.
- A branch is a work, with a folder under `works/`, from its first decision, question, or plan. Before that it is only a branch and needs no folder (D188).
- A wiki has two layers. The shared pages say how the project is now, and are what an agent reads to understand it. The folders of the works are the history: the decisions, their reasons, and who decided. Before a work is merged, what it defined is written in the shared pages, which cite the decision (D189).
- A later change to something a closed work defined is a new work with a new name. A closed work is never reopened (D190).
- What earlier decisions already fix, and phase 4 does not reopen:
  - The product is not a workflow engine, a CLI, or a framework (D40).
  - The product has two layers: the methodology, decided by the owner, and the form, decided by what works best for the agent (D22). Read by the agent: the core is the methodology, and an agent system is one form.

Read by the agent, not said by the owner: this wiki keeps its present format until the core is built in stage 6, so the decisions of phase 4 are numbered `D#` as well.

## Proposed

- The Spanish word for a work is "trabajo colaborativo", because the [glossary](glossary.md) gives "trabajo" to Job.

## Open

No question about phase 4 is Open. Phase 4 opened Q53 to Q60 on 2026-11-16, and D171 to D178 answered them.

## Identifiers considered

The problem: two branches that each record a decision give it the same number, and the clash shows only when they are merged.

| Identifier | Example | Result |
|------------|---------|--------|
| A hash | `a3f9c1` | Discarded. It never clashes, but it loses the order between decisions, cannot be said aloud, and a hash of the text changes when the text is corrected. The owner raised it: "capaz que necesitemos un hash en vez de un número correlativo" |
| A prefix per person and that person's counter | `AF-12` | Discarded. It fails when one person works in two branches, or runs two agents at once. The owner's objection: "se están trabajando en dos funcionalidades distintas, en dos ramas distintas, y después cuando se unen se tomaron dos decisiones con la mismo número" |
| The work's name and that work's counter | `auth-3` | Chosen (D170). Two branches are two works, so their names differ. Inside one branch the history is one line, so a counter does not clash |

Two people in the same branch are not covered by the identifier: git refuses the second push until that person takes the first one's commits, so the clash shows at once.

No identifier detects two decisions that contradict each other under different names. A step at the merge covers that (D173).

## Topics

How much the owner's words and the earlier decisions cover of each topic a product definition needs.

| Topic | Coverage | What is missing |
|-------|----------|-----------------|
| The problem, and who has it | Covered | More than one person works on a project, and the wiki is written for one (D168). The evidence is under "What separates the two" |
| Who uses it | Covered | The owner, with the whole product, and the people who work with the owner, with `playbook-wiki` and an agent system of their own (D168, D169, D182, D183). Who decides: D172 |
| Main flows | Covered | Installing and starting the product (D183, D184). Starting a work, deciding inside it (D171, D172), and merging it (D173) |
| What it must do | Covered | D168, D170, D174, and the contract (D175) |
| What it must not do | Covered | It loads nothing until the person starts it (D184). `playbook-wiki` holds nothing of `playbook-agents` (D182). No tool other than Claude Code, for now (D181). Not a CLI or a framework (D40) |
| Qualities | Covered | Two works never write the same file (D170, D179). Each decision records who decided (D179) |
| Limits | Covered | Claude Code only, for now (D181). The wiki lives in the project's repository (D168) and needs git only (D173, D178) |
| Outside systems | Covered | git only, not a forge (D173) |
| Volume | Covered | Two to five people and a handful of works at once (D178) |
| Who runs and maintains it | Covered | It is published from this repository (D176), and the owner maintains its definition (D179) |
| Rules, states, vocabulary | Covered | Core, agent system, and work are in the [glossary](glossary.md) (D168, D171). The Spanish word for work: Proposed |

## What exists today

Read from the repository on 2026-11-16.

- The content of a wiki is Markdown in the project's `docs/wiki/`. No agent tool is needed to read it.
- The definition of that content lives inside the playbook's plugin, so a person who does not install the plugin does not get it:

  | Piece | Where | Tied to an agent tool |
  |-------|-------|-----------------------|
  | The format | `plugin/skills/prepare-project/references/1-wiki.md`, `plugin/skills/doctor/references/format-3.md` | Only by its place, inside a skill |
  | The check | `plugin/skills/prepare-project/scripts/check-wiki.sh` | Only by its place. It is a shell script that names no agent tool: `grep -i "claude\|opencode\|engram\|codegraph\|skill\|agent"` finds nothing in it |
  | The notice and the migration | `plugin/skills/doctor/`, `plugin/hooks/hooks.json` | Yes. The hook reads `CLAUDE_PROJECT_DIR` |
  | The rules | `plugin/rules.md` | Yes. A hook of the plugin prints them at the start of a session |

- The agents that write code are told to read the wiki: `plugin/agents/write.md` and `opencode/agents/write.md`.

## What separates the two

Six places where the format assumes that one person writes the wiki.

| Assumption | Where it is stated | With two branches |
|------------|--------------------|-------------------|
| One counter for the whole project, for decisions, questions, and units | `plugin/skills/prepare-project/references/1-wiki.md`, "Continue the numbers of decisions, questions, and units" | Both branches use the same identifier |
| `decisions.md` is one table | The same file, under "`decisions.md`" | A merge conflict. Tested on 2026-11-16 with git 2.43.0: two branches that each add a row at the end of one table give `CONFLICT (content)` |
| The check skips the first rows of `decisions.md` by count | `plugin/skills/prepare-project/scripts/check-wiki.sh`, which reads `.unchecked-decisions` | The count belongs to one file, and D170 gives each work its own |
| "Where work stands" is one section, opened by the number of the last decision | `plugin/skills/prepare-project/references/1-wiki.md`, under "Where work stands" | Both branches rewrite the same lines |
| One owner decides | R6 in `plugin/rules.md`, and Owner in the [glossary](glossary.md) | Nothing says who decides. D172 defines it; the rule still states the old definition |
| A phase starts only when the six stages before it are closed | `plugin/skills/prepare-project/references/1-wiki.md`, under "A new phase" | Two people cannot each prepare a work. D171 changes this definition; the file still states the old one |

## Not verified

- That two branches rewriting "Where work stands" give a merge conflict. It was not tested; the test above was run on `decisions.md` only.
- That a person with an agent system other than `playbook-agents` can work with `playbook-wiki` alone. None was tried.
