# Architecture of phase 2

How the product is built today and what phase 2 changes in it. Phase 2 replaces gentle-ai in the owner's Claude Code ([../01-product/phase-2.md](../01-product/phase-2.md)). The owner accepted this page when stage 2 of phase 2 was closed (D72); each statement names the decision it rests on.

Kept as a record: it describes the one plugin of phases 1 and 2, with its paths under `plugin/` and its limits of 500 and 800 words. D72 names it by its earlier name, `architecture.md`. The product as it is now is in [architecture.md](architecture.md).

## The problem

The owner's Claude Code loads two layers of instructions at once: the product, and gentle-ai with the overlay. gentle-ai's layer is 13,512 words in every session, belongs to someone else, never chooses a model by job, and brings a workflow that collides with the product's (D64, measured in ../02-current-state/gentle-ai-layer.md (kept in the private archive)). Phase 2 makes the product do those jobs so that the other layer can be removed.

## Requirements that shape it

| Requirement | Source |
|-------------|--------|
| A concept stays only if it is used in real work and fits in a few lines | D64 |
| The rules file stays under 500 words, and everything loaded at session start under 800 | D48, [../01-product/style-guide.md](../01-product/style-guide.md) |
| Each delegated job states its model and effort | D57, D64 |
| One workflow, the product's | D64 |
| Adapted to Claude Code and Anthropic's models; no other tool for now | D57 |
| The only outside tools are Engram and CodeGraph | D28 |
| A person who installs the plugin installs nothing else | TD2 |

Assumption: Engram and CodeGraph work from the instructions their own MCP servers send to the session, without the two sections gentle-ai writes about them. Both servers sent instructions in the session of 2026-11-13. Whether that is enough is confirmed in the trial environment.

## The shape

One Claude Code plugin, read in place from this repository (TD1). Three kinds of content, split by when each one loads:

| Loads | Content | Why there |
|-------|---------|-----------|
| In every session | The rules file | A rule that applies to every request cannot depend on a skill being triggered (D65) |
| When a job needs it | Skills | The detail of a job not done in every request costs nothing until then (D65) |
| When work is delegated | Agents | A subagent definition is where Claude Code lets a model and an effort be fixed (TD7). Their values come from one file (TD11) |

## Modules

Today means present in the repository on 2026-11-13, checked by listing it.

| Module | Path | Responsible for | Does not | Used by | State |
|--------|------|-----------------|----------|---------|-------|
| Rules | `plugin/rules.md` | The rules that apply in every project. Phase 2 adds eight short ones (D66) | Hold the detail of a job, or anything over 500 words | The `SessionStart` hook prints it into each session | Today: R1 to R17, 305 words |
| Hook | `plugin/hooks/hooks.json` | Printing the rules file at session start | Anything else; it is one `cat` command | Claude Code | Today, unchanged |
| Skills | `plugin/skills/<name>/` | One job each (R17): `prepare-project`, `write-skill`, `write-docs`, `keep-minimal`, `avoid-generic-design` | Run in every request | Claude Code loads one when a request matches its description | Today: five. Phase 2 adds a review skill (D66) and a rule for a new phase in `prepare-project` (Q37) |
| Agents | `plugin/agents/` | Fixing the model and effort of a delegated job: `explore`, `write`, `review` (TD8) | Decide when to delegate; the rules do | The main agent, by the delegation rule; the review skill | New in phase 2 |
| Model configuration | `plugin/models.conf` and a shell script | Being the one place where the model and effort of each agent are set (TD11). The script writes them into the agent files | Run at session time; Claude Code never reads this file | The owner, to change a model; `scripts/verify.sh`, to fail when an agent file differs | New in phase 2 |
| Evaluation cases | `plugin/evals/` | Two cases per skill: one where it must load, one where it must not | Run by themselves | `claude plugin eval` (TD4) | Today: ten cases |
| Checks | `scripts/verify.sh` | Failing a change that breaks the format or a size limit | Judge the quality of a skill | The agent, on every change | Today |
| Marketplace | `.claude-plugin/marketplace.json` | Letting Claude Code install the plugin from this repository | | Claude Code | Today, unchanged |
| Wiki | `docs/wiki/` | The definitions and decisions of the product | Load into any session by itself | The agent, through the project's `CLAUDE.md` | Today |

### How a review runs

1. The main agent, or the owner, asks for a review of a change.
2. The review skill starts in a separate context (`context: fork`) on the `review` agent, which is Claude Opus 5.5 at high effort (TD8, TD10).
3. The agent reads the change there and returns only its findings to the main conversation.

The reviewer starts without the conversation, so the request must say what to review.

## The main data

The product holds no data of its own. State lives in three places, each with one role (../02-current-state/tooling.md (kept in the private archive), D36):

- The repository of each project: its wiki and its code.
- Engram: what was learned across sessions.
- CodeGraph: the map of the code, rebuilt from the code.

Phase 2 removes two stores: the feature documents in `odd/tasks/` with their copy in Engram (D66), and the overlay's `longterm-mem` (D68).

## Outside systems

| System | For | How critical |
|--------|-----|--------------|
| Claude Code | Runs everything: the plugin, the hook, the skills, the agents | Total. The product is built for it (D57) |
| Anthropic's models | Haiku, Sonnet, and Opus for the three agents; the owner's choice for the main session | Total |
| Engram | Memory across sessions | The work continues without it; recall is lost |
| CodeGraph | Questions about the structure of a codebase | The work continues with file search |

## How the machine moves

| Step | What | Decision |
|------|------|----------|
| 1 | A second configuration directory, opened through `CLAUDE_CONFIG_DIR`, with its own login and only the plugin, Engram, and CodeGraph. Its settings exclude `~/.claude/CLAUDE.md` | TD6, TD12 |
| 2 | Real work in one project inside it, while `~/.claude` stays untouched | D69 |
| 3 | `gentle-ai uninstall` rehearsed on a copy of `~/.claude`, to list what it removes and what it leaves | TD9 |
| 4 | The switch of `~/.claude`, with a backup: gentle-ai removed, the overlay retired, the persona saved as the owner's own output style | D68, D69, D70 |

## Risks

| Risk | What reduces it |
|------|-----------------|
| Eight new rules do not fit in the 195 words left | `scripts/verify.sh` fails over the limit; a rule that does not fit moves to a skill or is dropped by a decision |
| What loads at session start passes 800 words. `scripts/verify.sh` reported 475 on 2026-11-13, so the eight rules, the description of the review skill, and the descriptions of the three agents share 325 | The same script fails over the limit. Whether it counts agent descriptions is not verified; it is extended when the agents are added |
| Haiku misses something while exploring | The main agent checks one item of the map before acting on it; the model of `explore` is one line to change (TD11) |
| `gentle-ai uninstall` removes more than gentle-ai's files, or less | The rehearsal on a copy (TD9), and the backup before the switch (D69) |
| gentle-ai puts back what was removed | Known for the registry hook (../02-current-state/removal-map.md (kept in the private archive)); after the uninstall the command no longer runs. Checked in the rehearsal |
| Engram or CodeGraph work worse without gentle-ai's sections | Seen first in the trial environment, before the main installation changes |
| A model alias such as `haiku` points to another model after an update of Claude Code | The agent files can name the full model ID instead; decided when it happens |

## Trade-offs

| Decision | Gained | Given up |
|----------|--------|----------|
| Short rules instead of a full workflow (D65) | About 13,000 fewer words in every session | The detailed procedures for rare cases |
| Agents with a fixed model (TD7, TD8) | The cost of a job is known and the same every time | The main agent cannot raise the model for a hard case without a decision |
| One file for models and efforts, written into the agent files by a script (TD11) | One place to see and change every model | One more script, and a step to run after changing the file |
| A second configuration directory (TD6) | The main installation is untouched during the trial | A second login, and a session history split in two |
| gentle-ai's own uninstall (TD9) | It knows what it installed | Trust in a command not yet seen running |
| A review in a separate context (TD10) | The reviewer did not write the change, and the reading stays out of the main conversation | The reviewer has no context beyond what the request gives |
| No skill for pull requests, comments, or issues (D67) | Three skills not written or maintained | Those jobs run on Claude Code's default behaviour |

## Discarded

| Alternative | Reason |
|-------------|--------|
| `--bare` with `--plugin-dir` for the trial | It does not run a plugin's hooks, so the rules would not load, and it needs an API key ([phase-2.md](phase-2.md)) |
| A second operating-system user | More isolation than the trial needs |
| A rule that passes the model on each delegation | Depends on the agent remembering it, and spends words of the rules file (TD7) |
| One default model for everything delegated | Does not tell an exploration from a risky review (TD7) |
| A JSON file of agents passed with `--agents` at start | The agents would exist only in a session started that way, and would leave the plugin (TD11) |
| Removing gentle-ai by hand only | Easy to miss something installed outside `~/.claude` (TD9) |
| Keeping the overlay and trimming it | Its hooks would still run on every message (D68) |

## How it can evolve

- Another tool than Claude Code: only when the product is ready, and only if needed (D57). The rules file is plain text and would carry over; the hook, the agents, and the skill front matter are Claude Code's.
- A skill for pull requests, review comments, or issues: added by its own decision when a project needs it (D67).
- A new model: a change to one line of the model configuration, by a decision (TD8, TD11).
- Sharing the product with another person: blocked by the questions on naming, versions, and the personal pages in [../01-product/open-questions.md](../01-product/open-questions.md).

## Not verified

- That the alias `sonnet` resolves to the model named here when the `write` agent runs. `haiku` was seen to resolve to `claude-haiku-5-5` in U11 and `opus` to `claude-opus-5-5` in U13 ([../05-plan/plan-phase-2.md](../05-plan/plan-phase-2.md)).
- Whether a skill's own `model` field would win over the model of the agent it names. The review skill sets no model of its own for that reason.
- That a plugin's `agents/` folder is read when the plugin is installed from the local marketplace. It was seen to be read with `claude --plugin-dir` in U11.
