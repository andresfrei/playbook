# Technology

What the three commands need from their technology, what was checked, and what is proposed. Becomes part of `03-technology/` when the work closes. The project already uses POSIX `sh`, `sed`, and `awk` for its scripts and hooks, with no `jq` or Python (TD31, the scripts under `plugins/`); nothing below adds a dependency.

## Needs

| Need | From |
|------|------|
| N1. A model and an effort chosen by the person reach each agent of `playbook-agents`, for one repository or for every project, the repository's winning, and survive an update of the plugin | setup-commands-1, setup-commands-4 |
| N2. A place, at the scope chosen, where `/playbook:init` remembers a "Keep both" choice | setup-commands-8 |
| N3. `/playbook:init` knows what is on and whether the repository has a wiki before it asks | setup-commands-5, setup-commands-6 |
| N4. `/playbook-wiki:init` writes the skeleton, and `prepare-project` calls it | setup-commands-2, setup-commands-3 |

## What Claude Code offers for N1

Checked on 2026-11-18 in the documentation, by an agent that read it, and by trial on Claude Code 2.1.327.

- No setting and no environment variable sets the model or the effort of one agent. Source: https://code.claude.com/docs/en/sub-agents.md
- A subagent's model is, first match: the `model` parameter of the Agent call, the agent's `model` front matter, `CLAUDE_CODE_SUBAGENT_MODEL`, the session's model. The parameter takes an alias only: `haiku`, `sonnet`, `opus`, `fable`. Same source.
- `CLAUDE_CODE_SUBAGENT_MODEL_FORCE=1` forces one model on every subagent: not per agent. Same source.
- A plugin's `userConfig` is substituted in hooks, MCP, and the body of skills and agents, not in an agent's front matter, and is stored at user scope only. Source: https://code.claude.com/docs/en/plugins/manifest-reference
- An agent with the same name in `.claude/agents/` wins over a plugin's, but plugin agents are named `playbook-agents:review` and a file there cannot hold a `:`, so it would be another agent that `review-change` does not call, and a copy gets no update of the plugin. Same source as above.
- The Agent call takes an `effort` parameter since 2.1.292; it overrides the agent's `effort` front matter, and `CLAUDE_CODE_EFFORT_LEVEL` overrides both. Source: https://code.claude.com/docs/en/sub-agents.md, checked 2026-11-18.
- A `PreToolUse` hook's `updatedInput` "Replaces the entire input object, so include unchanged fields alongside modified ones." The hook's table of the Agent input lists `model` and not `effort`. Source: https://code.claude.com/docs/en/hooks.md, checked 2026-11-18.
- The JSON schema of the settings files, https://json.schemastore.org/claude-code-settings.json, sets `additionalProperties: true` at the top level, read 2026-11-18. Whether Claude Code keeps an unknown key when it rewrites a settings file is not documented.

Trial, in the scratchpad, with a `PreToolUse` hook on `Agent` that returns `updatedInput` with a `model`:

1. A `general-purpose` call asked for `opus`; the hook set `haiku`; the subagent ran on `claude-haiku-5-5`, by its own answer and by the session's `modelUsage`.
2. A `playbook-agents:explore` call, whose front matter says `haiku`; the hook set `sonnet` and `effort: low`; the subagent ran on `claude-sonnet-5-5`. The effort was accepted without error; its effect was not observed.

## Chosen and proposed

- **N1.** Decided (setup-commands-10): a `PreToolUse` hook of `playbook-agents` on `Agent`. When the call names one of the three agents and the person set a value for it, the hook adds `model` and `effort` to the call. With no value set, it changes nothing and the front matter written from `models.conf` stays the default (TD11). It replaces nothing of TD11: `models.conf` keeps the defaults; the person's choice sits above them.
- **N1 and N2, storage.** Decided (setup-commands-10): one key of the playbook in Claude Code's settings files, where `/playbook:init` already writes `skillOverrides`: `.claude/settings.local.json` for this repository, kept out of git, and the person's `settings.json` for every project. The hook reads the repository's file first. Trial: an unknown key in `.claude/settings.local.json` gave no error and was left as written by a session. The settings schema allows extra top-level keys. Not verified: that Claude Code keeps the key when it rewrites the file itself, such as when a permission is saved.
- **N3.** Accepted (setup-commands-11): `init.sh scan` also prints the values of that key and whether `docs/wiki/README.md` exists. No new technology.
- **N4.** Accepted (setup-commands-11): A skill `init` in `playbook-wiki`, typed only, that runs `wiki-format.sh mark`, as `prepare-project` does today. No new technology.

## Limits of the proposal

- The model must be an alias: a full `claude-` id or `inherit`, which `models.conf` accepts, cannot be set by the person.
- It acts only on calls through the Agent tool.
- A person who sets `CLAUDE_CODE_EFFORT_LEVEL` overrides the effort the hook sets.
- A value set by the person wins over a model Claude itself names in the call.
