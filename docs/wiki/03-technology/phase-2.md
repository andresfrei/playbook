# Technology for phase 2

What phase 2 needs from its technology, and what is chosen for each need. Stage 2 of phase 2. Every need has a decision (TD6 to TD11) or is met by Claude Code as it is. The shape that results is in [architecture-phase-2.md](architecture-phase-2.md).

Phase 2 keeps the technology of phase 1 (TD1 to TD5): a Claude Code plugin read from this repository, plain shell for verification, and Claude Code's own evaluation command. This page covers only what changes.

## Needs

Taken from [../01-product/phase-2.md](../01-product/phase-2.md).

| # | Need | From | Status |
|---|------|------|--------|
| N1 | A separate environment on the same machine where Claude Code loads the product, Engram, and CodeGraph, and nothing of gentle-ai or the overlay | D69 | Decided: a second configuration directory (TD6) whose settings exclude `~/.claude/CLAUDE.md` (TD12) |
| N2 | A way to state the model, and the effort, of a delegated job | D57, D66 | Decided: three agents in the plugin, `explore` on Haiku, `write` on Sonnet, `review` on Opus (TD7, TD8), with the values set in one file (TD11) |
| N3 | A way to remove gentle-ai from Claude Code that it does not undo by itself | D69 | Decided: gentle-ai's own `uninstall`, rehearsed on a copy first (TD9). What it removes is not known until the rehearsal |
| N4 | Engram and CodeGraph working without the two sections of gentle-ai that tell the agent how to use them | D28, D66 | Partly checked: both tools send their own instructions to the session through their MCP servers, seen in the session of 2026-11-13. Whether those are enough is confirmed in the trial environment (TD6) |
| N5 | A place for the persona that does not depend on gentle-ai | D70 | Met by Claude Code as it is: a file in `~/.claude/output-styles`, chosen with the `outputStyle` setting. No decision needed beyond D70 |
| N6 | A way for the review skill to read a change without filling the main conversation | D66 | Decided: the review skill runs with `context: fork` on the `review` agent (TD10) |

## Checked in Claude Code's documentation

Checked on 2026-11-13 by a research agent that read the pages below. The flags were also seen in `claude --help` on this machine. Quotes are from the documentation.

### N1 — a separate environment

| Way | What it does | Meets N1? |
|-----|--------------|-----------|
| `CLAUDE_CONFIG_DIR` | "Override the configuration directory (default: `~/.claude`). All settings, session history, and plugins are stored under this path." Every `~/.claude` path and `.claude.json` move under it, and "Each directory has its own settings, session history, and claude.ai login or API key." ([env-vars](https://code.claude.com/docs/en/env-vars.md), [claude-directory](https://code.claude.com/docs/en/claude-directory.md), [authentication](https://code.claude.com/docs/en/authentication.md)) | Yes, with one addition seen on 2026-11-13 when unit U15 was built: a session in a project under the home directory still reads `~/.claude/CLAUDE.md`, as a `.claude/CLAUDE.md` of a parent directory, until the `claudeMdExcludes` setting names it (TD12). It needs its own login and its own installation of the plugin, Engram, and CodeGraph |
| `--bare` with `--plugin-dir` | Skips "hooks, skills, custom commands, subagents, installed plugins, MCP servers, auto memory, and CLAUDE.md", and still loads a plugin given by flag. It never reads the claude.ai login, so it needs an API key ([cli-reference](https://code.claude.com/docs/en/cli-reference.md), [headless](https://code.claude.com/docs/en/headless.md)) | No. The hooks of a plugin loaded by flag do not run, and the product loads its rules with a `SessionStart` hook (`plugin/hooks/hooks.json`) |
| `--safe-mode` | Disables CLAUDE.md, skills, plugins, hooks, MCP servers, agents, and output styles together | No. It cannot keep the plugin |
| `--setting-sources` | "Comma-separated list of setting sources to load." | Not known. Its effect on CLAUDE.md, skills, and agents is not documented |

Not from the documentation: a second operating-system user also gives a separate environment, with a separate home directory.

### N2 — model and effort of a delegated job

- A subagent definition takes `model` ("`sonnet`, `opus`, `haiku`, `fable`, a full model ID such as `claude-opus-5-5`, or `inherit`") and `effort` ("`low`, `medium`, `high`, `xhigh`, `max`") in its front matter ([sub-agents](https://code.claude.com/docs/en/sub-agents.md)).
- Order of precedence, same page: the `model` parameter of the call, then the definition's `model`, then the `CLAUDE_CODE_SUBAGENT_MODEL` variable, then the main conversation's model.
- A skill's front matter takes `model`, `effort`, `context: fork` ("run in a forked subagent context"), and `agent` ([skills](https://code.claude.com/docs/en/skills.md)).
- A plugin can ship subagent definitions: "Each Markdown file under `agents/` defines one" ([plugin components](https://code.claude.com/docs/en/plugins/components.md)).

### One file for every model and effort

The owner asked on 2026-11-13: "podemos hacer un arcivo de configuracion de modelos y esfuerzos?". Checked the same day in the documentation:

- Claude Code has no setting that maps a model or an effort to a named subagent or skill. `modelOverrides` maps model IDs to a provider's IDs, and `CLAUDE_CODE_SUBAGENT_MODEL` is one default for all subagents ([settings reference](https://code.claude.com/docs/en/settings-reference.md), [env-vars](https://code.claude.com/docs/en/env-vars.md)).
- The front matter of an agent or a skill takes no variable. Substitution applies to "the skill's markdown content", not to `model` or `effort` ([skills](https://code.claude.com/docs/en/skills.md), [plugin manifest](https://code.claude.com/docs/en/plugins/manifest-reference.md)).
- A plugin lists its agents only as Markdown files: "Agent `.md` files. Directories aren't accepted". It cannot define them as data in its manifest.
- The `--agents` flag of the command line takes subagents as JSON, with `model` and `effort`. It applies only to a session started with that flag ([sub-agents](https://code.claude.com/docs/en/sub-agents.md)).

Decided: the first of the two ways below (TD11). A single file is possible in two ways, neither built into the plugin format: a file of the product's own from which a script writes the front matter of each agent file, or a JSON file passed with `--agents` when Claude Code is started.

### Models and prices

From the model table of the `claude-api` skill bundled with Claude Code 2.1.323, which says "cached: 2026-11-03". It was not fetched live on 2026-11-13.

| Model | Alias in an agent file | Input, $ per million tokens | Output, $ per million tokens |
|-------|------------------------|-----------------------------|------------------------------|
| Claude Fable 5.2 | `fable` | 8.00 | 40.00 |
| Claude Opus 5.5 | `opus` | 4.00 | 20.00 |
| Claude Sonnet 5.5 | `sonnet` | 2.00 | 10.00 |
| Claude Haiku 5.5 | `haiku` | 0.10 | 0.50 |

- These are the prices of the API. The owner signs in with a claude.ai subscription, so they do not appear on a bill; they show how much of the usage limit each model spends compared with the others.
- The same source says the default effort is `medium` on Opus 5.5 and Haiku 5.5 and `high` on Sonnet 5.5, and recommends starting at `medium` on Sonnet 5.5 for coding with tools and `low` for subagents or simple tasks.
- Not verified: that each alias resolves to the model of this table in the installed Claude Code.

### N5 — the persona

- A user's own output style is a Markdown file in `~/.claude/output-styles`, chosen with the `outputStyle` key of a settings file ([output-styles](https://code.claude.com/docs/en/output-styles.md)). The page does not mark output styles as deprecated.
- A plugin can also ship one, in `output-styles/<name>.md`. D70 keeps it outside the product.

### N6 — the review skill

- `context: fork` in a skill's front matter runs it in a subagent, with the skill's own `model` and `effort`, so the reading stays out of the main conversation.

### Always-loaded text

- "Claude Code doesn't load a `CLAUDE.md` at the plugin root." A `SessionStart` hook is the documented way for a plugin to add text to every session, which is what TD1 already does.

### Not verified

- The key under which `~/.claude.json` stores the user's MCP servers. They are added with `claude mcp add ... --scope user` ([mcp](https://code.claude.com/docs/en/mcp.md)).
- Whether a skill's `model` wins over the `model` of the subagent named in its `agent` field.

## Checked on this machine

- **gentle-ai has its own removal command.** `gentle-ai uninstall` takes `-agent`, `-component`, and `-all` ("Remove Gentle AI managed files from this machine"). Read from `gentle-ai uninstall --help`, version 4.4.0, on 2026-11-13. It was not run. Not verified: which files it removes, and whether it removes the hooks and the five sections of `~/.claude/CLAUDE.md`.
- **gentle-ai puts the registry hook back** on every sync or install when it is missing (../02-current-state/removal-map.md (kept in the private archive)).
