# Architecture of phase 3

How the product works in opencode 2.x next to Claude Code. It describes only what phase 3 adds; the product as it is, with its modules and how they load in Claude Code, is in [architecture-phase-2.md](architecture-phase-2.md) and does not change (D112). The decisions behind this page are TD13 to TD20, and the evidence for each is in [phase-3.md](phase-3.md).

Every statement here is Decided. The owner accepted this page when stage 2 of phase 3 was closed (D114), with the points listed under "Not verified".

## The problem

The owner wants to do part of the work in opencode 2.x with OpenAI's models, at a lower cost (D105, D107). The same rules, skills, and agents must work there (D106), written once for both tools (D108). opencode loads none of them from a Claude Code plugin, and its agent files use a different format.

## Requirements that shape it

| Requirement | Source |
|-------------|--------|
| The rules in every session, the six skills on demand, and the three agents with their models | D106 |
| One text for each rule, skill, and agent; a file for one tool only where the tools differ | D108 |
| This repository is the only source; no hand-copied file | D40 |
| The four size limits hold in opencode | D109 |
| Claude Code keeps working exactly as it does now | D112 |
| Only opencode 2.x; version 2.3.0 is the one tried | D112 |
| One user, one machine | D52, D112 |

Assumption: the clone of this repository stays at one path on the machine. The opencode installation points to that path three times.

## The shape

opencode reads the product in place from the clone, through its own configuration. Nothing is copied to opencode's folders and no plugin of opencode is written.

```text
~/.config/opencode/opencode.json
  instructions: [<clone>/plugin/rules.md]     -> the rules, in every session (TD13)
  skills:       [<clone>/plugin/skills]       -> the six skills (TD14)
  mcp.servers:  engram, codegraph, context7   -> the three servers (TD20)
~/.config/opencode/agents  -> link to <clone>/opencode/agents   (TD15)
```

The main session is not an agent of the product. It runs on opencode's default agent, `build`, with the rules above, and its model is the `model` key of the same file, `openai/gpt-6.1-sol`, written by the owner and not by the installer (TD21, decided after this page was accepted).

It fits the requirements because the two shared parts, the rules and the skills, are plain Markdown that both tools read as they are, and the one part the tools read differently, the agent files, is generated from one text.

## Modules

What phase 3 adds or changes. The other modules are in [architecture-phase-2.md](architecture-phase-2.md).

| Module | Path | Responsible for | Does not | Used by | State |
|--------|------|-----------------|----------|---------|-------|
| Rules | `plugin/rules.md` | Unchanged. The same file is the rules in both tools | Name a tool | opencode, through the `instructions` key (TD13) | Exists: 492 words on 2026-11-13 (`wc -w`) |
| Skills | `plugin/skills/<name>/` | Unchanged, except one rule added to `review-change` (TD17) | Hold a second copy for opencode | opencode, through the `skills` key (TD14). A skill is named by its folder there, such as `prepare-project` | Exists; one line to add |
| Agent texts | `plugin/agents/<name>.md` | Being the one text of each agent: its description and its body. They stay Claude Code agent files | Hold opencode's values | Claude Code, directly; the script below, as the source | Exists, unchanged |
| Model configuration | `plugin/models.conf` | Being the one place for the model and effort of each agent, for both tools (TD11, TD15). Each line gets two more columns, the opencode model and its variant (D114) | Run at session time | `scripts/set-models.sh` | Exists; columns to add |
| Generator | `scripts/set-models.sh` | Writing the model and effort into the Claude Code agent files, as it does now, and writing the opencode agent files (TD15) | Install anything | The owner, after changing `models.conf`; `scripts/verify.sh`, with `--check` | Exists; to extend |
| opencode agent files | `opencode/agents/<name>.md`, at the root of the repository and outside `plugin/` so that Claude Code does not load them (D114) | Being what opencode reads for each agent: `description`, `mode: subagent`, `model`, `permissions`, and the body | Get edited by hand; they are generated and committed | opencode, through the link | New |
| Installer | `scripts/install-opencode.sh` (D114) | Doing the installation steps: the two entries and the link (TD18). It writes `opencode.json` only when the file does not exist; otherwise it prints the entries to add and changes nothing in that file (D114) | Add MCP servers, sign in, or delete anything | A person, once | New |
| Installation steps | `README.md` of the repository | Saying the same steps for a person to do by hand (TD18) | | A person | To add |
| Checks | `scripts/verify.sh` | A part for opencode (TD19): generated files match their source and hold only allowed fields; the limits hold; when opencode is installed, it lists the six skills and the three agents with their models, and the rules path resolves | Call a model | The agent, on every change | Exists; to extend |

### The generated agent file

For each agent the generator takes the description and the body from `plugin/agents/<name>.md` and the model and variant from `plugin/models.conf`.

| Agent | Model in opencode (TD16) | Permissions |
|-------|--------------------------|-------------|
| `explore` | `openai/gpt-6-luna#medium` | `edit` denied |
| `write` | `openai/gpt-6.1-sol#medium` | None denied |
| `review` | `openai/gpt-6.1-sol#high` | `edit` denied |

An agent whose Claude Code `tools` line has neither `Edit` nor `Write` gets one rule that denies the `edit` action in opencode; that action covers opencode's edit, write, and patch tools. Shell commands stay allowed, as `Bash` is in Claude Code, and the body of the agent says to run only commands that read (D114).

The product's `explore` replaces opencode's built-in agent of the same name (tried on 2.3.0, [phase-3.md](phase-3.md), N9).

### How a review runs in opencode

1. The owner, or the main agent under the rule on risky changes, asks for a review of a change.
2. When the agent asked is the one that wrote the change, the rule added to `review-change` tells it to hand the review to the `review` agent (TD17).
3. opencode starts the `review` agent in a child session with a new context, on `gpt-6.1-sol` at high effort. It loads `review-change`, reads the change, and returns its findings.

In Claude Code the review runs as before ([architecture-phase-2.md](architecture-phase-2.md)).

## The main data

One line per agent in `plugin/models.conf`, and one text per rule, skill, and agent. From them come two sets of agent files, one per tool. On the machine, opencode's configuration holds three paths into the clone.

## Outside systems

| System | For | How critical |
|--------|-----|--------------|
| opencode 2.x | Running the sessions | Needed for phase 3; Claude Code does not depend on it |
| OpenAI, through the owner's subscription | The models of the three agents and of the main session (D107) | Needed in opencode. Its limits in opencode are not known |
| Engram, CodeGraph, `context7` | Memory, the map of the code, current documentation (D110, TD20) | Rules R22 and R23 need the first two. In opencode Engram does not print earlier sessions at session start |

## Risks

| Risk | What reduces it |
|------|-----------------|
| opencode skips a missing rules file without an error, so a moved clone leaves sessions with no rules | The check lists what opencode resolved (TD19); it is run after installing and after moving the clone |
| A link is not followed for the global agents folder; it was tried only for a project's folder | It is the first thing tried when the agents are installed. If it fails, the owner is told and the alternatives of N9 are proposed again |
| A model of OpenAI does not load a skill when it should, or does not hand a review to the `review` agent | A manual trial in stage 6 (TD19). There is no automatic evaluation in opencode |
| The check depends on an interface opencode marks as experimental | The part of the check that asks opencode is skipped, with a message, when the interface does not answer; the checks on the files do not depend on it |
| A later 2.x version changes how configuration or agents load | Only 2.3.0 is tried. The check is run after an upgrade of opencode |
| opencode shows skills that are not the product's | The 23 of `~/.agents/skills/` are deleted when the owner asks (D111); the five of `~/.claude/skills/` stay by decision (D113) |

## Trade-offs

| Decision | Gained | Given up |
|----------|--------|----------|
| Configuration keys and no opencode plugin (TD13, TD14) | No code to maintain against opencode's plugin interface | One-command installation and automatic updates |
| Generated agent files (TD15) | One text and one place for the values | A larger script, and generated files committed to the repository |
| A link for the whole agents folder (TD15) | One step, and a new agent needs no new step | Room in that folder for an agent that is not the product's |
| `gpt-6.1-sol` for the reviewer (TD16) | The plan's allowance lasts | The most capable model as second reader |
| A rule in the skill for reviews (TD17) | No file only for opencode | A guarantee by the tool: it depends on the model following the rule |
| No paid evaluation in opencode (TD19) | No runner to build, no allowance spent | Knowing automatically whether each skill loads when it should |
| `opencode mcp add` for the servers (TD20) | One documented way for the three | Engram's memory at session start |

## Discarded

Each is compared with the chosen way in [phase-3.md](phase-3.md).

| Alternative | Reason |
|-------------|--------|
| A plugin of the product for opencode | Code against an interface with no stated stability; it cannot add an agent |
| A link from `~/.config/opencode/AGENTS.md` to the rules | It takes the one global file for the owner's own instructions |
| A link per skill | A manual step for each new skill |
| Agents as entries in the owner's `opencode.json` | The values would live outside the repository |
| Agent files for opencode written by hand | The same text twice (D108) |
| `gpt-6-astra` for the reviewer | It uses the plan's allowance five times faster by its listed price |
| A command of opencode for reviews | A file only for opencode, used only when the owner types it |
| The installers of Engram and CodeGraph | Not verified for version 2 |

## How it can evolve

- Another tool is one more target of the generator and one more set of installation steps, as long as it reads `SKILL.md` folders and a rules file.
- If opencode documents a stable way for a plugin to ship skills and agents, the installation can become one command.
- If the trial shows that skills do not load when they should, evaluations with `opencode run` can be added (the alternative of N13).

## Not verified

- No opencode session was opened and no model was called. Everything tried was read with `opencode debug agents` and `opencode api`, in a temporary folder.
- That opencode follows a link for `~/.config/opencode/agents`.
- That a model in opencode follows the rule of TD17.
- The usage limits of the owner's OpenAI plan in opencode.
- The words opencode itself loads at session start, apart from the product's.
