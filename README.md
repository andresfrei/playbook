# playbook

A set of working rules and skills for AI coding agents (Claude Code and opencode), valid for every project. It is one person's set, shared as it is: use it, copy it, or adapt it under the [MIT License](LICENSE). Issues and pull requests are welcome; see [CONTRIBUTING.md](CONTRIBUTING.md).

In this repository, "the owner" means the person whose set this is. Project-specific rules live in each project, not here.

It is a Claude Code plugin, and opencode 2.x reads the same files through its own configuration. Every session of either tool loads:

| Part | Content |
|------|---------|
| Rules | `plugin/rules.md`, 24 short rules. In Claude Code a hook prints them at session start; opencode reads the file as an instructions entry |
| Skills | Six, loaded on demand: `prepare-project`, `write-skill`, `write-docs`, `keep-minimal`, `avoid-generic-design`, `review-change`. The `SKILL.md` of each, under `plugin/skills/`, says which requests load it and what it does. A seventh, `doctor`, runs only when the owner starts it (`/playbook:doctor` in Claude Code): it repairs a project's wiki after the format of a wiki changed. At session start a hook says so in one line when a project's wiki has no file `docs/wiki/.format` or the file is behind |
| Agents | Three, for delegated work: `explore`, `write`, `review`. The model and the effort of each, for both tools, are in `plugin/models.conf` |

**Status:** "Where work stands" in [docs/wiki/README.md](docs/wiki/README.md) says what is finished, what is open, and what comes next.

## Needs

Neither the plugin nor the installer for opencode installs these tools. Install each one in Claude Code yourself, and connect it to opencode with the commands below the table. The decisions are in [docs/wiki/decisions.md](docs/wiki/decisions.md).

| Tool | Used for | Decision |
|------|----------|----------|
| Engram | Memory across sessions. Rule R23 says what belongs in it | D25, D28 |
| CodeGraph | Questions about code structure. Rule R22 says when to use it | D25, D28 |
| `context7` | An MCP server the agent reaches when it needs the official documentation of a library or a version. No rule or skill names it | D90, D97 |

In opencode, add each one to the global configuration with opencode's own command, then list them to see that the three are connected. These are the commands run on opencode 2.3.0 on 2026-11-13 (TD20):

```sh
opencode mcp add --global engram -- engram mcp --tools=agent
opencode mcp add --global codegraph -- codegraph serve --mcp
opencode mcp add --global context7 -- npx -y --package=@upstash/context7-mcp@2.2.5 -- context7-mcp
opencode mcp list
```

opencode starts each server by its command name, so `engram`, `codegraph`, and `npx` must be on the `PATH` of opencode's background service. In opencode Engram does not print the earlier sessions at session start, as its plugin does in Claude Code; the agent asks for them with Engram's tools.

## Install

From a local clone, with Claude Code's own commands:

```sh
claude plugin marketplace add /path/to/this/clone
claude plugin install playbook@playbook --scope user
```

The plugin is read in place from the clone: a change to the files under `plugin/` applies to the next session, or to an open one after `/reload-plugins`, with no reinstall. Whatever is checked out in the clone is what every session loads. The source for this behaviour is in [docs/wiki/03-technology/installation.md](docs/wiki/03-technology/installation.md).

To remove it:

```sh
claude plugin uninstall playbook@playbook
claude plugin marketplace remove playbook
```

## Install in opencode 2.x

opencode has no plugin for this. It reads the rules and the skills in place from the clone, through two entries of its global configuration file, and the agents through a link. Tried on opencode 2.3.0; versions 1.x are not supported. The reasons are in [docs/wiki/03-technology/architecture-phase-3.md](docs/wiki/03-technology/architecture-phase-3.md).

With the script, from the clone:

```sh
sh scripts/install-opencode.sh
opencode reload
```

The script writes `~/.config/opencode/opencode.json` only when opencode has no configuration file yet. When one exists, it changes nothing in it and prints the two entries for you to add. It stops, changing nothing, when `~/.config/opencode/agents` already exists and does not lead to the folder of step 2. It says "Installed" only for a file it wrote; for a file you edited, the check below is what confirms it.

When the `XDG_CONFIG_HOME` variable is set, opencode's configuration folder is `$XDG_CONFIG_HOME/opencode`, not `~/.config/opencode`. The script follows the variable; by hand, use that folder in the steps below.

By hand, the same three steps:

1. In `~/.config/opencode/opencode.json`, add the absolute path of the rules file to `instructions` and of the skills folder to `skills`:

   ```json
   {
     "$schema": "https://opencode.ai/config.json",
     "instructions": ["/path/to/this/clone/plugin/rules.md"],
     "skills": ["/path/to/this/clone/plugin/skills"]
   }
   ```

2. Link opencode's global agents folder to the generated agent files:

   ```sh
   ln -s /path/to/this/clone/opencode/agents ~/.config/opencode/agents
   ```

3. Run `opencode reload`.

Then check what opencode loads. The command calls no model:

```sh
sh scripts/verify.sh --opencode
```

opencode skips an `instructions` entry whose file is missing, with no error. Run that check again after moving the clone or upgrading opencode.

In opencode a skill is named by its folder, such as `prepare-project`, and the three agents run on the OpenAI models named in `plugin/models.conf`, so opencode must be signed in with OpenAI (`opencode auth login openai`).

The installer does not set the model of the main session, which runs on opencode's default agent, `build`. With nothing configured, opencode 2.3.0 reported a free model, `opencode/iceman-free`, as its default. To choose the model, add a `model` entry to `opencode.json`, or pick one in a session with `/models` (TD21):

```json
"model": "openai/gpt-6.1-sol"
```

That entry holds a provider and a model only, so it does not set the effort.

opencode also loads the skills it finds in `~/.claude/skills/` and `~/.agents/skills/`, which are not this product's. To hide one in opencode without deleting it, add a rule with its name to `permissions` in `opencode.json` (D126):

```json
"permissions": [
  { "action": "skill", "resource": "skill-creator", "effect": "deny" }
]
```

After any change to `opencode.json`, run `opencode reload`.

To remove the product, delete the two entries from `opencode.json` and the link `~/.config/opencode/agents`.

## Layout

| Path | Content |
|------|---------|
| `docs/wiki/` | What is decided, what is open, and the plan |
| `CLAUDE.md` | Instructions for an agent that works in this repository |
| `.github/` | `CODEOWNERS`, and the templates for issues and pull requests |
| `LICENSE`, `CONTRIBUTING.md`, `SECURITY.md` | The licence, how to contribute, how to report a vulnerability |
| `.claude-plugin/marketplace.json` | Makes this repository a Claude Code marketplace |
| `plugin/` | The plugin: the rules file, the hooks that print it and that compare a wiki's format, the skills, the agents, `models.conf`, and the evaluation cases |
| `opencode/agents/` | The agent files opencode reads. Generated by `scripts/set-models.sh`; never edited by hand |
| `scripts/` | Checks for whoever maintains the plugin, the script that sets the agents' models, and the installer for opencode |

## Checks

```sh
sh scripts/verify.sh             # manifests, format, size limits, and agent models
sh scripts/verify.sh --opencode  # the same, and what opencode loads from this clone
sh scripts/verify_test.sh        # tests of the three scripts
shellcheck scripts/*.sh
```

To change the model or the effort of an agent, edit its line in `plugin/models.conf`, then run:

```sh
sh scripts/set-models.sh
```

The script writes the Claude Code values into `plugin/agents/*.md` and generates `opencode/agents/*.md` whole, from the description and the text of each `plugin/agents/<name>.md`. Do not edit the `model` or `effort` lines in `plugin/agents/*.md` by hand, nor any file in `opencode/agents/`: `verify.sh` fails when they differ from `plugin/models.conf`.

Evaluation cases call the model and are billed to your account, so run them by hand, before a change to a skill is accepted:

```sh
# one skill
claude plugin eval plugin --tag write-skill --ablation none --max-cost-usd 1 --no-publish
# the whole suite
claude plugin eval plugin --ablation none --max-cost-usd 4 --no-publish -j 3
```

`--no-publish` keeps the report on this machine. Each skill has two cases under `plugin/evals/`: one request that must load it and one that must not. `prepare-project` has a third, for a request that starts a new phase.

`verify.sh` needs the `claude` command. The limits it enforces are in [docs/wiki/01-product/style-guide.md](docs/wiki/01-product/style-guide.md).

Start at [docs/wiki/README.md](docs/wiki/README.md). The wiki is the source of truth for what this repository is, what is decided, and what is still open.
