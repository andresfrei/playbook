# playbook

A set of working rules and skills for AI coding agents (Claude Code), valid for every project. It is one person's set, shared as it is: use it, copy it, or adapt it under the [MIT License](LICENSE). Issues and pull requests are welcome; see [CONTRIBUTING.md](CONTRIBUTING.md).

In this repository, "the owner" means the person whose set this is. Project-specific rules live in each project, not here.

It is a Claude Code plugin. Every session loads:

| Part | Content |
|------|---------|
| Rules | `plugins/playbook-agents/rules.md`, 18 short rules. A hook prints them at session start. The other six rules of the set are in `plugins/playbook-wiki/contract.md`, which `playbook-wiki` prints at session start |
| Skills | Six, loaded on demand: `prepare-project`, `write-skill`, `write-docs`, `keep-minimal`, `avoid-generic-design`, `review-change`. The `SKILL.md` of each, under `plugins/playbook-wiki/skills/` and `plugins/playbook-agents/skills/`, says which requests load it and what it does. A seventh, `doctor`, runs only when the owner starts it (`/playbook-wiki:doctor` in Claude Code): it repairs a project's wiki after the format of a wiki changed. At session start a hook says so in one line when a project's wiki has no file `docs/wiki/.format` or the file is behind |
| Agents | Three, for delegated work: `explore`, `write`, `review`. The model and the effort of each are in `plugins/playbook-agents/models.conf` |

**Status:** "Where work stands" in [docs/wiki/README.md](docs/wiki/README.md) says what is finished, what is open, and what comes next.

## Needs

The plugin does not install these tools. Install each one in Claude Code yourself. The decisions are in [docs/wiki/decisions.md](docs/wiki/decisions.md).

| Tool | Used for | Decision |
|------|----------|----------|
| Engram | Memory across sessions. Rule R23 says what belongs in it | D25, D28 |
| CodeGraph | Questions about code structure. Rule R22 says when to use it | D25, D28 |
| `context7` | An MCP server the agent reaches when it needs the official documentation of a library or a version. No rule or skill names it | D90, D97 |

## Install

### With an agent

Paste this prompt into a Claude Code session. The agent runs the commands below and asks before changing a file of yours.

```text
Install the playbook plugin for Claude Code from https://github.com/andresfrei/playbook.
Run `claude plugin marketplace add andresfrei/playbook`, then
`claude plugin install playbook@playbook --scope user`, then `claude plugin list`,
and confirm that playbook@playbook is enabled and show its version.
Change no other setting. Then read the "Needs" section of the repository's README.md
and tell me which of Engram, CodeGraph, and context7 I am missing. Do not install
them unless I ask.
```

### From GitHub, in Claude Code

```sh
claude plugin marketplace add andresfrei/playbook
claude plugin install playbook@playbook --scope user
```

Claude Code installs a copy of the latest release. Automatic updates are off by default for this marketplace, so update by hand when a new release is out:

```sh
claude plugin update playbook@playbook
```

Inside a session, `/plugin marketplace update playbook` does the same. A release reaches you only when its version changes; the releases and their tags are on GitHub. How versions are made is in [CONTRIBUTING.md](CONTRIBUTING.md#releases).

### From a local clone, in Claude Code

To change the plugin, or to load every commit as it is made:

```sh
claude plugin marketplace add /path/to/this/clone
claude plugin install playbook@playbook --scope user
```

The plugin is read in place from the clone: a change to the files under `plugins/` applies to the next session, or to an open one after `/reload-plugins`, with no reinstall. Whatever is checked out in the clone is what every session loads. The source for this behaviour is in [docs/wiki/03-technology/installation.md](docs/wiki/03-technology/installation.md).

### Remove it from Claude Code

```sh
claude plugin uninstall playbook@playbook
claude plugin marketplace remove playbook
```

## Layout

| Path | Content |
|------|---------|
| `docs/wiki/` | What is decided, what is open, and the plan |
| `CLAUDE.md` | Instructions for an agent that works in this repository |
| `.github/` | `CODEOWNERS`, and the templates for issues and pull requests |
| `LICENSE`, `CONTRIBUTING.md`, `SECURITY.md` | The licence, how to contribute, how to report a vulnerability |
| `.claude-plugin/marketplace.json` | Makes this repository a Claude Code marketplace |
| `plugins/` | The three plugins. `playbook-wiki` holds the wiki skills, the hook that compares a wiki's format, and their evaluation cases; `playbook-agents` holds the rules file, the other skills, the agents, `models.conf`, and their evaluation cases; `playbook` holds only its manifest for now |
| `scripts/` | Checks for whoever maintains the plugin, and the script that sets the agents' models |

## Checks

```sh
sh scripts/verify.sh             # manifests, format, size limits, and agent models
sh scripts/verify_test.sh        # tests of the scripts
shellcheck scripts/*.sh
```

To change the model or the effort of an agent, edit its line in `plugins/playbook-agents/models.conf`, then run:

```sh
sh scripts/set-models.sh
```

The script writes the values into `plugins/playbook-agents/agents/*.md`. Do not edit the `model` or `effort` lines in `plugins/playbook-agents/agents/*.md` by hand: `verify.sh` fails when they differ from `plugins/playbook-agents/models.conf`.

Evaluation cases call the model and are billed to your account, so run them by hand, before a change to a skill is accepted:

```sh
# one skill
claude plugin eval plugins/playbook-agents --tag write-skill --ablation none --max-cost-usd 1 --no-publish
# the whole suite, one plugin at a time
claude plugin eval plugins/playbook-wiki --ablation none --max-cost-usd 2 --no-publish -j 3
claude plugin eval plugins/playbook-agents --ablation none --max-cost-usd 3 --no-publish -j 3
```

`--no-publish` keeps the report on this machine. Each skill has two cases under `plugins/playbook-wiki/evals/` or `plugins/playbook-agents/evals/`: one request that must load it and one that must not. `prepare-project` has a third, for a request that starts a new phase.

`verify.sh` needs the `claude` command. The limits it enforces are in [docs/wiki/01-product/style-guide.md](docs/wiki/01-product/style-guide.md).

Start at [docs/wiki/README.md](docs/wiki/README.md). The wiki is the source of truth for what this repository is, what is decided, and what is still open.
