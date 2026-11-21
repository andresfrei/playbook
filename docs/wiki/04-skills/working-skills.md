# Working skills

Stage 3 of the method (D8): the skills the agent needs to build this product with the technology chosen in stage 2 (TD1–TD4). These are not the product's own skills, which are listed in [../01-product/skill-set.md](../01-product/skill-set.md) and written in stage 6. The owner accepted the list (Decided: D43).

## The list

Nothing new is installed. Every entry is already on the owner's machine.

| Job in this repository | What the agent uses | Note |
|------------------------|---------------------|------|
| Write and audit a skill file | `skill-creator` and `skill-improver`, for their style guide only | Their style guide sets the format and the size limits. The parts of `skill-creator` about the Gentle AI repository (its paths, `AGENTS.md` registration) are ignored. The style guide exists as two copies, one in each skill |
| Write the plugin files: manifests, the hook, evaluation cases | No skill. The current Claude Code documentation, read through the `claude-code-guide` agent, and `claude plugin validate` | No installed skill covers the plugin format. A new skill is Deferred: it is written only if the same documentation lookups repeat during stage 6 |
| Write shell scripts | No skill. `shellcheck`, already installed on this machine, checks them | It is a tool for whoever maintains the product. Installing the plugin does not need it (TD2) |
| Write the wiki and other documentation | `cognitive-doc-design` | |
| Keep each change minimal | `minimal-correct-implementation` | |
| Execute, commit, review | gentle-ai's ODD, `work-unit-commits`, and its review lifecycle | Unchanged in phase 1 (D16, D33) |

## Order that follows from this list

The product's own skill for writing and auditing skills is one of the five of D33. Writing it first lets the other four be written with it, instead of with the installed `skill-creator`. Whether to do so is a matter for the plan (stage 5).

## Measured

On 2026-11-13: `skill-creator` 574 words, `skill-improver` 434, `cognitive-doc-design` 372, `minimal-correct-implementation` 724. `shellcheck` is present on the owner's machine.

## Phase 2

Stage 3 of phase 2: the skills the agent needs to build what [../03-technology/architecture-phase-2.md](../03-technology/architecture-phase-2.md) adds, with the technology of TD6 to TD11. The owner accepted the list (D73).

Nothing is installed or written for this stage. The product's own skills, built in phase 1, replace the installed ones of the list above.

| Job in this repository | Technology | What the agent uses | Where it lives | When |
|------------------------|------------|---------------------|----------------|------|
| Write the review skill, and change `prepare-project` (Q37) | Skill files | `playbook:write-skill`, with its style guide and the two evaluation cases it asks for | `plugin/skills/write-skill/` | Each time a skill file is written or changed |
| Write the eight rules | The rules file | No skill. The format and the limits of [../01-product/style-guide.md](../01-product/style-guide.md), enforced by `scripts/verify.sh` | This repository | Each change to `plugin/rules.md` |
| Write the three agent files | Subagent definitions (TD7, TD8) | No skill. The current Claude Code documentation, read through the `claude-code-guide` agent, and `claude plugin validate` | Claude Code | When the agents are written. A skill for the plugin format stays Deferred, as in phase 1 |
| Write the model configuration and its script | Plain shell (TD2, TD11) | No skill. `shellcheck` checks the script | The owner's machine: `shellcheck` 0.11.0, seen with `command -v shellcheck` on 2026-11-13 | Each change to a script |
| Make the trial environment, rehearse the uninstall | `CLAUDE_CONFIG_DIR` (TD6), `gentle-ai uninstall` (TD9) | No skill. The documentation quoted in [../03-technology/phase-2.md](../03-technology/phase-2.md) and each command's own help | Claude Code, gentle-ai | Once each |
| Write the wiki and other documentation | Markdown | `playbook:write-docs` | `plugin/skills/write-docs/` | Each page written or changed |
| Keep each change minimal | Any | `playbook:keep-minimal` | `plugin/skills/keep-minimal/` | Each change to code |
| Prepare and track the work | The six stages | `playbook:prepare-project` | `plugin/skills/prepare-project/` | Each stage and each unit |
| Execute and commit | The session's instructions | gentle-ai's workflow, still loaded in the main installation until the switch (D69). Inside the trial environment, the product's own rules | `~/.claude/CLAUDE.md` | Until the switch |

Seen while doing stages 1 and 2 of phase 2 with these skills, on 2026-11-13:

- `prepare-project` writes wiki pages by itself and does not say to use `write-docs` for them. The pages of stage 1 were written without it; the architecture page with it. Since 2026-11-13 the skill says to write them with `write-docs` (D87).
- `prepare-project` has no rule for a new phase (Q37).

## Phase 3

Stage 3 of phase 3: the skills the agent needs to build what [../03-technology/architecture-phase-3.md](../03-technology/architecture-phase-3.md) adds, with the technology of TD13 to TD20. The owner accepted the list (D115).

Nothing is installed or written for this stage. Every skill named is the product's own and is already loaded in the owner's Claude Code, seen in the skill list of the session of 2026-11-13.

| Job in this repository | Technology | What the agent uses | Where it lives | When |
|------------------------|------------|---------------------|----------------|------|
| Add one rule to `review-change` (TD17) | Skill files | `playbook:write-skill`, with its style guide | `plugin/skills/write-skill/` | When the skill file is changed |
| Extend `scripts/set-models.sh` and `scripts/verify.sh`, and write `scripts/install-opencode.sh` (TD15, TD18, TD19) | Plain shell (TD2) | No skill needed. `shellcheck` checks each script, and `scripts/verify_test.sh` holds the tests | The owner's machine: `shellcheck` 0.11.0, seen with `shellcheck --version` on 2026-11-13 | Each change to a script |
| Produce the agent files of opencode, write its configuration entries, and connect the three servers (TD13 to TD16, TD20) | opencode 2.x | No skill needed: three small generated files and a few configuration lines, written once. The documentation quoted in [../03-technology/phase-3.md](../03-technology/phase-3.md), and opencode's own `opencode debug agents` and `opencode api` to read what it resolved | opencode 2.3.0 on the owner's machine | When each is built |
| Write the installation steps in the README, and the wiki | Markdown | `playbook:write-docs` | `plugin/skills/write-docs/` | Each page written or changed |
| Keep each change minimal | Any | `playbook:keep-minimal` | `plugin/skills/keep-minimal/` | Each change to code |
| Read a risky change before delivery, such as the installer, which writes on a person's machine | Any | `playbook:review-change`, on the `review` agent (R20) | `plugin/skills/review-change/` | Before a risky change is delivered |
| Prepare and track the work | The six stages | `playbook:prepare-project` | `plugin/skills/prepare-project/` | Each stage and each unit |
| Execute and commit | The session's instructions | The product's own rules | `plugin/rules.md` | Always |

## Phase 4

Stage 3 of phase 4: the skills the agent needs to build what [../03-technology/architecture-phase-4.md](../03-technology/architecture-phase-4.md) describes, with the technology of TD24 and TD26 to TD33. The owner accepted the list (D194).

Nothing is installed or written for this stage. Every skill named is the product's own and is loaded in the owner's Claude Code, seen in the skill list of the session of 2026-11-16.

| Job in this repository | Technology | What the agent uses | Where it lives | When |
|------------------------|------------|---------------------|----------------|------|
| Change `prepare-project` and `doctor` (renamed `migrate`, decision-index-5), rename the agent that `review-change` names, and write the start skill (TD30, TD31) | Skill files | `playbook:write-skill`, with its style guide and the two evaluation cases it asks for | `plugin/skills/write-skill/` | Each time a skill file is written or changed |
| Write the three manifests, the marketplace entries, the dependency, the `userConfig` option, and the hooks (TD26, TD28, TD29, TD31) | Claude Code plugins | No skill needed. The documentation quoted in [../03-technology/phase-4.md](../03-technology/phase-4.md), read again through the `claude-code-guide` agent when a detail is missing, and `claude plugin validate`. A skill for the plugin format stays Deferred, as in phases 1 to 3 | Claude Code 2.1.325 on the owner's machine | When each file is written |
| Write the wizard's script and the script of the step at the merge, and change the check and `scripts/verify.sh` (TD24, TD27, TD28) | Plain shell (TD2) | No skill needed. `shellcheck` checks each script, and `scripts/verify_test.sh` holds the tests | The owner's machine: `shellcheck` 0.11.0, seen with `shellcheck --version` on 2026-11-16 | Each change to a script |
| Try how Claude Code's scopes and hooks behave, which [../03-technology/phase-4.md](../03-technology/phase-4.md) lists as not verified | Claude Code's plugin commands | No skill needed. Each command's own help, and a trial that the owner authorizes before it runs on the owner's machine | Claude Code 2.1.325 | Before anything is built on a behaviour that was not tried |
| Take out what phase 3 built for opencode (D191) | Files of this repository | No skill needed | This repository | Once |
| Write the contract and the wiki | Markdown | `playbook:write-docs` | `plugin/skills/write-docs/` | Each page written or changed |
| Keep each change minimal | Any | `playbook:keep-minimal` | `plugin/skills/keep-minimal/` | Each change to code |
| Read a risky change before delivery: the wizard's script, which changes a person's settings, the hooks, and the check | Any | `playbook:review-change`, on the `review` agent (R20) | `plugin/skills/review-change/` | Before a risky change is delivered |
| Prepare and track the work | The six stages | `playbook:prepare-project` | `plugin/skills/prepare-project/` | Each stage and each unit |
| Execute and commit | The session's instructions | The product's own rules | `plugin/rules.md` | Always |

## Setup commands

Stage 3 of the work `setup-commands`: the skills used to build `/playbook-wiki:init`, `/playbook-agents:config`, the model hook, and the changes to `/playbook:init`. The owner accepted the list (setup-commands-12). Nothing is installed or written for it.

| Job in this repository | What the agent uses | When |
|------------------------|---------------------|------|
| Write the three skills and change `prepare-project` | `playbook-agents:write-skill` | Each skill file written or changed |
| Write the scripts and the hook in POSIX `sh`, `sed`, and `awk` | `playbook-agents:keep-minimal`, `shellcheck`, `scripts/verify_test.sh` | Each change to a script |
| Check Claude Code's hooks, settings, and Agent tool | No skill needed: the sources of [../works/setup-commands/technology.md](../works/setup-commands/technology.md), and the `claude-code-guide` agent | When a behaviour is not documented there |
| Read the hook and each script that writes a person's settings | `playbook-agents:review-change`, on the `review` agent (R20) | Before each such unit is delivered |
| Write the wiki and the plugins' `README.md` | `playbook-wiki:write-docs` | At the close |

## Work delivery

Stage 3 of the work `work-delivery`: the skills used to change stages 5 and 6 of `prepare-project` and write two evaluation cases. The owner accepted the list (work-delivery-12). Nothing is installed or written for it.

| Job in this repository | What the agent uses | When |
|------------------------|---------------------|------|
| Change `5-plan.md` and `6-execution.md`, and write the two cases | `playbook-agents:write-skill` | Each file written or changed |
| Keep the step to what was decided | `playbook-agents:keep-minimal` | Each change to the step |
| Read the change to `prepare-project`, which other projects use | `playbook-agents:review-change`, on the `review` agent (R20) | Before delivery |
| Write the wiki | `playbook-wiki:write-docs` | At the close |

## Delegation

Stage 3 of the work `delegation`: the skills used to change the contract, the format, the check, the doctor, and `prepare-project`. The owner accepted the list (delegation-13). Nothing is installed or written for it.

| Job in this repository | What the agent uses | When |
|------------------------|---------------------|------|
| Write `prepare-project`'s `references/delegation.md` and the doctor's `references/format-5.md` (deleted: `migrate` keeps no reference for an older format, decision-index-10) | `playbook-agents:write-skill` | Each file written or changed |
| Keep the change to what was decided | `playbook-agents:keep-minimal` | Each change |
| Change `check-wiki.sh` and its tests | No skill needed: `shellcheck` and `scripts/verify_test.sh` | Each change to the check |
| Read the contract, the format, the check, and the skills, which every project uses | `playbook-agents:review-change`, on the `review` agent (R20) | Before each unit is delivered |
| Write the wiki | `playbook-wiki:write-docs` | At the close |

## Version check

Stage 3 of the work `version-check`: the skills used to build the notices at the start of a session. The owner accepted the list (version-check-11). Nothing is installed or written for it.

| Job in this repository | What the agent uses | When |
|------------------------|---------------------|------|
| Write `hooks/version-check.sh`, change `wiki-format.sh`, and their tests | No skill needed: `shellcheck`, `scripts/verify_test.sh`, and `scripts/verify.sh` | Each change |
| Keep the change to what was decided | `playbook-agents:keep-minimal` | Each change |
| Read the hooks, which every project with `playbook-wiki` runs | `playbook-agents:review-change`, on the `review` agent (R20) | Before each unit is delivered |
| Check Claude Code's hooks and plugin files | No skill needed: the sources of [../works/version-check/technology.md](../works/version-check/technology.md), and the `claude-code-guide` agent | When a behaviour is not documented there |
| Write the wiki and the README of `playbook-wiki` | `playbook-wiki:write-docs` | At the close |

## Learned rules

How the agents keep in mind what repeated findings of `review` taught (repeated-corrections-1). It is not a skill: the criteria live in the instructions of the agent `classify`, since a skill hidden from the session cannot be preloaded and a visible one passes the limit L4 of `playbook-agents` (repeated-corrections-27). The modules are in [../03-technology/architecture.md](../03-technology/architecture.md).

- What is learned is a thing to keep in mind at its step, not a rule loaded always. When a kind keeps repeating with its rule written, a check is proposed where the mistake can be found mechanically (repeated-corrections-3).
- The first source is the findings of `review`, each with its failing case. Memory and lint come later (repeated-corrections-2). `write` and `review` run the cycle first; the stages of a work and the commits wait (repeated-corrections-14).
- The cycle of each step (repeated-corrections-9): before building, the subagent gets the rules that bear on what it does; on a failure, the evidence is stored under its kind in the index, or under a new kind; on accumulation, the rule is rebuilt one level up.
- The evidence page is `docs/wiki/evidence.md` of each project: a table of kinds and a table of evidence, which `evidence.sh` checks and counts (repeated-corrections-15, repeated-corrections-19). The agent `classify` keeps the rows and a script counts, never the model (repeated-corrections-6, repeated-corrections-10).
- A kind names the mistake, not the place, and the central test decides both the kind and the level: would the rule of this kind have prevented this finding? Kinds are never renamed (repeated-corrections-11).
- The level is only a statistic: how many consolidations a record went through. A kind with no rule is at level 1. A finding that the rule of level k did not prevent is recorded at level k (repeated-corrections-5, repeated-corrections-11).
- The threshold is 3 distinct reviews of the same kind and level. One review that lists a mistake several times counts once. The 3 is a value of `evidence.sh`, adjusted with data once the mechanism runs (repeated-corrections-12).
- Only an index of the rules of level 2 and up is given to `write` and `review` at their start, one line per kind with when it applies; the subagent reads the full rule of the kinds that match its task, and judges (repeated-corrections-18, seed-evidence-31).
- A repository's page can be started from its past reviews with the skill `seed-evidence`, which only the person starts and which is not in the limit L4 (seed-evidence-2, seed-evidence-5). The 15 general rules of level 2 are in `evidence-rules.md` (seed-evidence-32).
- Consolidation happens at the close of a work: N records at level k become one rule at level k+1 that covers them, and the level-k records are deleted, git keeping them. The agent proposes it to the owner, or makes it when the owner delegated the kind `consolidate` (repeated-corrections-5, repeated-corrections-13, repeated-corrections-28). The step is the file `references/evidence.md` of `prepare-project`.
- A rule is the project's when understanding it needs the project's business, and general otherwise. A general rule is proposed to the owner to go up to `plugins/playbook-agents/evidence-rules.md`, which every project reads (repeated-corrections-15, repeated-corrections-20).

## Decision index

Stage 3 of the work `decision-index`: `playbook-agents:write-skill` writes the renamed skill `migrate` and no other skill is needed (decision-index-8). `migrate` runs in the agent `wiki-writer` (decision-index-12) and keeps no reference for an older format (decision-index-10).
