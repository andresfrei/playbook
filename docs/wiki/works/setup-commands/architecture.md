# Architecture

How the three commands fit the product as it is, described in `03-technology/architecture.md`, and what changes. Becomes part of that page when the work closes. Its Proposed points were accepted with the close of stage 2 (setup-commands-11).

## The problem

A person who installed the playbook cannot add only a wiki to a repository, cannot choose the agents' models without losing the choice at the next update, and gets every question again from a second `/playbook:init` (setup-commands-1).

## Requirements and assumptions

- Only when the person types each command; nothing of another tool is changed (setup-commands-9).
- No new dependency: POSIX `sh`, `sed`, and `awk`, as the product's scripts and hooks already are. (setup-commands-11)
- The person's choices survive an update of the plugins (setup-commands-1).
- Assumed: settings files are written by Claude Code with one key per line, as the scripts that read `skillOverrides` already assume.

## Shape

Each command is a skill typed by the person, with a script that does the reading and the writing, as `/playbook:init` already is (TD31). The model choice reaches the agents through a hook, because Claude Code has no setting for it (setup-commands-10).

## Modules

| Module | Plugin | Responsible for | Does not | Used by |
|--------|--------|-----------------|----------|---------|
| `init` skill and `init.sh` | `playbook` | Reading what is on, the remembered choices, and whether a wiki exists; asking "Keep" or "Change"; turning the plugins on; writing "Keep both" choices; offering `/playbook-wiki:init` (setup-commands-5, setup-commands-6, setup-commands-8) | Write a wiki or a model | The person |
| `init` skill of `playbook-wiki` | `playbook-wiki` | Writing the skeleton: the project's `README.md` with the owner asked, `.format` through `wiki-format.sh mark`, and the two `CLAUDE.md` sentences after asking (setup-commands-2, setup-commands-3) | Open a work, write a decision, touch a wiki that exists | The person; `prepare-project` for a new project; `/playbook:init` on a yes |
| `config` skill and its script | `playbook-agents` | Showing each agent's model and effort and where it comes from; writing the person's choice at the scope chosen (setup-commands-4, setup-commands-9) | Change `models.conf` or an agent file | The person |
| Model hook, `PreToolUse` on `Agent` | `playbook-agents` | Adding the person's `model` and `effort` to a call that names `playbook-agents:explore`, `write`, or `review` (setup-commands-10) | Act on another agent; change a call when nothing is set | Claude Code, on every Agent call |

## Data

One key of the playbook in each settings file, at the two scopes of `/playbook:init`: `.claude/settings.local.json` for this repository and the person's `settings.json` for every project (setup-commands-8, setup-commands-10). Proposed shape:

```json
"playbook": {
  "models": {
    "review": "opus xhigh",
    "explore": "haiku low"
  },
  "keepBoth": ["my-review-skill"]
}
```

- `models`: per agent, an alias and an effort. An agent missing here keeps the value of `models.conf`. The repository's value of one agent wins over the person's.
- `keepBoth`: the names of the person's or another plugin's skills whose pair the person settled with "Keep both". `skillOverrides` keeps holding the skills turned off.

## Outside systems

- Claude Code: the plugin system, its settings files, and the Agent tool's `model` and `effort` parameters. Critical: without them the choice does not reach the agents.

## Risks

| Risk | What reduces it |
|------|-----------------|
| Claude Code drops the unknown key when it rewrites a settings file | The schema allows extra keys; a lost key brings back the defaults and the questions, not an error; the plan includes a trial that saves a permission |
| A future Claude Code changes the Agent input or the `updatedInput` rule | The hook copies every field it receives and adds two; a test runs the hook on a sample input |
| The hook runs on every Agent call | It reads two small files and exits at once for any other agent |
| `CLAUDE_CODE_EFFORT_LEVEL` set by the person overrides the effort | Documented in the command's output |

## Trade-offs

- Hook rather than a copy of the agents: the agents keep their updates and their names; in exchange the model must be an alias.
- Settings files rather than a file of the playbook: one place with `skillOverrides`, already written by `/playbook:init`; in exchange a rewrite by Claude Code may drop the key.

## Discarded

- `CLAUDE_CODE_SUBAGENT_MODEL` and its `_FORCE` form: one model for every subagent.
- `userConfig`: not substituted in an agent's front matter, and user scope only.
- Copies of the agents in `.claude/agents/`: another name, which `review-change` does not call, and no updates.
- Rewriting the agent files in the plugin cache at session start: one cache for every repository, so the two scopes would race.

## How it can evolve

- When Claude Code adds a per-agent model setting, the hook is replaced by writing that setting, and the key moves there.
- The same key can hold other choices of the person later.
