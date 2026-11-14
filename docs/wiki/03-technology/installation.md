# Installation in Claude Code

Evaluation for Q21, made on 2026-11-13 against the current Claude Code documentation and one plugin already installed on the owner's machine. The owner chose route A (Decided: TD1).

## What the installation must do

| Requirement | Source |
|-------------|--------|
| Put the rules document in context in every session, in every project | D34, F1 |
| Make the product's skills available in every project | D33 |
| Keep this repository as the only source, with no hand-copied files | D40 |
| Use no command-line tool of the product's own | D40 |
| Work for the owner now and for invited people later | D29 |
| Claude Code only | D27 |

## What Claude Code provides

| Fact | Evidence |
|------|----------|
| A plugin is a directory with `.claude-plugin/plugin.json` and component folders: `skills/`, `agents/`, `hooks/hooks.json`, and others. | [Create plugins](https://code.claude.com/docs/en/plugins/create.md), [Components](https://code.claude.com/docs/en/plugins/components.md) |
| A plugin cannot contribute a `CLAUDE.md`. Rules that must always be loaded need another mechanism. | Same pages |
| A plugin's `SessionStart` hook can print a file, and its output is added to the context. | [Hooks](https://code.claude.com/docs/en/hooks.md); observed in this session, where Engram's hook output appeared as context |
| Hook output is capped at 10,000 characters. Above that, the agent sees a 2,000-character preview and a file path. | [Hooks](https://code.claude.com/docs/en/hooks.md), read from a summary of a page too long to fetch whole |
| `SessionStart` accepts a `compact` matcher, so the rules can be printed again after the conversation is compacted. | Engram's `hooks.json` on this machine uses it |
| A git repository can be a marketplace, and a plugin can live in a subfolder of that same repository (`"source": "./plugin"`). | [Create a marketplace](https://code.claude.com/docs/en/plugins/create-marketplace.md); Engram is installed this way |
| A marketplace added from a local folder loads its plugin in place. Edits apply at the next session or with `/reload-plugins`, with no version change. | [Plugin loading](https://code.claude.com/docs/en/plugins/loading.md) |
| A private repository is reached with the person's existing git credentials. Claude Code does not ask for them. | [Install plugins](https://code.claude.com/docs/en/plugins/install.md) |
| Automatic update is off by default for private marketplaces. It is turned on per marketplace, or the plugin is updated by hand. | [Plugin loading](https://code.claude.com/docs/en/plugins/loading.md) |
| A plugin's skill is named `<plugin>:<skill>`, so it does not collide with a personal skill of the same name. Both load. | [Skills](https://code.claude.com/docs/en/skills.md) |
| At session start only the name and description of each skill load. The description is cut at 1,536 characters. | [Skills](https://code.claude.com/docs/en/skills.md) |
| An `@path` line in `~/.claude/CLAUDE.md` imports a file into every session. Each person adds that line by hand. | [Memory](https://code.claude.com/docs/en/memory.md) |

## A working example on this machine

Engram is installed as a plugin at user scope. Its repository is the marketplace, the plugin lives in a subfolder (`./plugin/claude-code`), and its `SessionStart` hook writes the memory context seen at the start of every session. The route recommended below is this same pattern.

## Routes compared

| | A. Private marketplace | B. Plugin folder inside `~/.claude/skills/` | C. No plugin |
|---|---|---|---|
| How it is installed | Two Claude Code commands, once per person: add the marketplace, install the plugin | Clone the repository into that folder | Clone, add an `@path` line to `~/.claude/CLAUDE.md`, link each skill folder |
| Always-loaded rules | `SessionStart` hook prints the rules file | Same hook, but the documentation does not state that hooks run for this kind of plugin | The `@path` line |
| Repository layout | The plugin is a subfolder; the wiki stays outside it | The whole repository sits inside the skills folder | Free |
| Update | By hand, or automatic once turned on | `git pull` | `git pull` |
| Turn on and off | Yes | Through the manifest only | No |
| Skill names | Prefixed with the plugin name | Prefixed with the plugin name | Not prefixed; a same-named personal skill collides |
| Same steps for the owner and for invited people | Yes | Yes | Each person edits their own files |
| Verified working | Yes, by Engram on this machine | No | Not for linked skill folders |

## Chosen route (Decided: TD1)

Route A. The plugin lives in a subfolder of this repository, with the five skills and a `SessionStart` hook that prints the rules file. The repository is also the marketplace. The owner adds the marketplace from the local clone, so edits apply without reinstalling; invited people add it by its git address.

What it costs:

- Two Claude Code commands per person, once. They are Claude Code's own commands, so D40 holds.
- The rules file must stay under 10,000 characters. This matches F1 and the hard size limit taken in D32.
- While gentle-ai is in use (phase 1), an old skill and the product's skill for the same job both appear in the skill list, until the old one is removed at its source (D40). This is against F3 for as long as it lasts.
- Updates for invited people are by hand unless they turn automatic update on.

## Not verified

- The exact wording of the `SessionStart` section of the hooks page. It was read from a summary because the page is too long to fetch whole. The behaviour itself is observed on this machine.
- Whether there is a limit on the total size of the skill list.
- Which of two skills with similar descriptions the agent picks when both are listed.
- Whether `gentle-ai sync` or the overlay changes anything under `~/.claude/plugins/`.
