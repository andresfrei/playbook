# Installation in Claude Code

How the product is installed and started since phase 4. The route is the one TD1 chose, a marketplace in this repository, with three plugins in place of one (TD26).

## How it is installed

1. The person adds this repository as a marketplace: `claude plugin marketplace add andresfrei/playbook`, or the path of a local clone.
2. The person installs the start plugin alone: `claude plugin install playbook@playbook --scope user`. It holds only `/playbook:init`, which loads nothing until the person types it (D184).
3. In a repository, the person runs `/playbook:init`. Its script installs `playbook-wiki`, and `playbook-agents` for the whole product, with the scope chosen: `user` for every project, `local` for this repository (D183, TD27).
4. What it turned on is used from the next session. A session does not see a plugin installed while it runs (tried in U28, [phase-4.md](phase-4.md)).

The answers are kept in four places, none of them a file of the product's own (TD27): which plugins are on, in `enabledPlugins` of the user's `settings.json` or of the repository's `.claude/settings.local.json`, which git ignores; the language, under `pluginConfigs` of the user's `settings.json`, so it holds in every project (TD31); a skill of the person turned off, under `skillOverrides` of the same settings file as the plugins (TD33); and a choice about a skill of the project, only as a decision in the open work: `docs/wiki/04-skills/` changes when that work closes (skill-best-practices-11, which narrows TD33). The script installs `playbook-wiki` by name even with `playbook-agents`, so it is never kept only as a dependency ([phase-4.md](phase-4.md), "What follows from it").

## Versions

Each plugin declares its version in its own `plugin.json`, never in the marketplace entry, and each release commit is tagged `v<version>` (TD22). The tag then gets a release on GitHub, titled `playbook <version>`, with notes on what changed and, for a MAJOR version, how to move from the one before (github-release-1). When a work closes, the agent recommends whether it needs a new version and which one, and asks the owner; the repository's `CLAUDE.md` says so, because every session loads it (github-release-2). Version 2 is phase 4, a MAJOR version because it breaks an installation of version 1: the plugin `playbook` loses its skills, agents, and rules and becomes the start plugin (TD32). A person who had version 1 updates it and runs `/playbook:init` once. Version 2.2.0 is MINOR: it brings the skills in line with the best practices for skills, and breaks no installation (skill-best-practices-15). Version 2.2.1 is PATCH: it fixes skills that did not load and `wiki-format.sh mark` (skill-triggering-17).

At the start of a new session, `playbook-wiki` tells the person and the agent when the marketplace's copy on the machine holds a newer version than the one installed, in one line, every session while they differ (version-check-1, version-check-4, version-check-6). It reads only local files: the installed `plugin.json` under `CLAUDE_PLUGIN_ROOT`, and the copy under `~/.claude/plugins/marketplaces/<marketplace>/`. A marketplace from a local folder loads the plugin in place, so the version that runs is the folder's and no notice is shown (version-check-18). It never updates anything and never connects to a network, so with automatic update off, as for this marketplace, a new version is seen only after the marketplace is refreshed; a check against GitHub, off unless the person turns it on, is for later (version-check-2, version-check-8).

An installation from GitHub gets a commit only when the version changes. A marketplace added from a local clone loads the plugins in place: a change applies to the next session, or to an open one after `/reload-plugins`.

## Anthropic's plugin directory

The product is not listed in Anthropic's plugin directory. The directory accepts command hooks and scripts only from a Verified organization, and both `playbook-wiki` and `playbook-agents` work through them; the owner's organization is not Verified. The listing is a new work once it is (plugin-directory-9). The evidence, the portal's report of 2026-11-17, is in [../works/plugin-directory/definition.md](../works/plugin-directory/definition.md).

Ready for that work:

- Only `playbook-wiki` and `playbook-agents` are submitted, as two submissions; `playbook` is not, because it turns the others on by this repository's marketplace name (plugin-directory-1).
- The installation from this repository's marketplace stays as it is; the directory is a second way in (plugin-directory-2).
- Each of the two holds what the directory reads inside the plugin folder: a `README.md`, `"license": "MIT"` in its `plugin.json`, and its icon, `.claude-plugin/icon.png`, drawn from `.claude-plugin/icon.svg` (plugin-directory-3, plugin-directory-5). The directory takes the icon only at the first submission.

Installing `playbook-agents` from this marketplace also installs `playbook-wiki`, its dependency: checked on 2026-11-17 in [../works/plugin-directory/technology.md](../works/plugin-directory/technology.md).

## The evaluation of 2026-11-13 (TD1)

Kept as a record of how the route was chosen, when the product was one plugin that loaded its rules in every session.

Evaluation for Q21, made on 2026-11-13 against the current Claude Code documentation and one plugin already installed on the owner's machine. The owner chose route A (Decided: TD1).

### What the installation must do

| Requirement | Source |
|-------------|--------|
| Put the rules document in context in every session, in every project | D34, F1 |
| Make the product's skills available in every project | D33 |
| Keep this repository as the only source, with no hand-copied files | D40 |
| Use no command-line tool of the product's own | D40 |
| Work for the owner now and for invited people later | D29 |
| Claude Code only | D27 |

### What Claude Code provides

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

### A working example on this machine

Engram is installed as a plugin at user scope. Its repository is the marketplace, the plugin lives in a subfolder (`./plugin/claude-code`), and its `SessionStart` hook writes the memory context seen at the start of every session. The route recommended below is this same pattern.

### Routes compared

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

### Chosen route (Decided: TD1)

Route A. The plugin lives in a subfolder of this repository, with the five skills and a `SessionStart` hook that prints the rules file. The repository is also the marketplace. The owner adds the marketplace from the local clone, so edits apply without reinstalling; invited people add it by its git address.

What it costs:

- Two Claude Code commands per person, once. They are Claude Code's own commands, so D40 holds.
- The rules file must stay under 10,000 characters. This matches F1 and the hard size limit taken in D32.
- While gentle-ai is in use (phase 1), an old skill and the product's skill for the same job both appear in the skill list, until the old one is removed at its source (D40). This is against F3 for as long as it lasts.
- Updates for invited people are by hand unless they turn automatic update on.

### Not verified

- The exact wording of the `SessionStart` section of the hooks page. It was read from a summary because the page is too long to fetch whole. The behaviour itself is observed on this machine.
- Whether there is a limit on the total size of the skill list.
- Which of two skills with similar descriptions the agent picks when both are listed.
- Whether `gentle-ai sync` or the overlay changes anything under `~/.claude/plugins/`.
