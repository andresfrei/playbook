# Architecture of the work ask-before-irreversible

## The problem

R14 says push, pull requests, merges, and releases are the owner's decisions, but nothing stops an agent from running them. The rest of rule 3 of the guide, secrets and deletions, depends on each repository. A plugin cannot ship permission rules, so the first part is a hook and the second a command that writes the repository's own settings (ask-before-irreversible-1, -7).

## Requirements and assumptions

- Ask before every action of R14, in every mode, also for subagents, every time (ask-before-irreversible-2 to -5).
- Propose, per repository and chosen item by item, rules for secrets, deletions, and the sandbox, written where the person says (ask-before-irreversible-8 to -10).
- Assumption, measured in `bypassPermissions` only: a hook's `ask` and an `ask` rule show the prompt in every mode ([measurements.md](measurements.md)).

## Shape

Two independent pieces of `playbook-agents`, in POSIX `sh` and `awk` like its other scripts, with no new dependency.

## Modules

| Module | Path | Responsible for | Does not |
|--------|------|-----------------|----------|
| Tokenizer | `plugins/playbook-agents/hooks/hook-lib.sh` | Splits a Bash command into segments and tokens, outside quoted text; today inside `commit_dir`, made a function that `commit_dir` and the new hook call (ask-before-irreversible-12) | Decide anything |
| Delivery hook | `plugins/playbook-agents/hooks/ask-before-delivery.sh` | Returns `permissionDecision` `ask`, with R14 as the reason, when a segment is `git ... push`, `gh pr create`, `gh pr merge`, or `gh release create|edit|delete`, following `cd`, `git -C`, global options, and environment variables, and the text of `sh -c`, `bash -c`, and `eval` once; returns `ask` when it cannot read its input; prints nothing otherwise (ask-before-irreversible-12) | Deny, allow, or remember an earlier answer (ask-before-irreversible-4) |
| Registration | `plugins/playbook-agents/hooks/hooks.json` | A `PreToolUse` entry on `Bash` with no `if` (ask-before-irreversible-13) | |
| Protect script | `plugins/playbook-agents/protect.sh` | `scan`: lists the secret files found by name, skipping `.git` and `node_modules`. `apply <settings file> <items>`: adds the chosen rules to that file with `json_add`, creating it when missing and changing no other key (ask-before-irreversible-14, -15) | Read the content of a secret file. Remove a rule |
| Protect command | `plugins/playbook-agents/skills/protect/` | `/playbook-agents:protect`, started only by the person: runs `scan`, shows each item of ask-before-irreversible-15 with the warning of `allowUnsandboxedCommands`, asks which, asks where to write, runs `apply`, and shows what it wrote (ask-before-irreversible-8, -9, -10) | Write without the person's choice |

## Data

The settings file of the repository, `.claude/settings.json` or `.claude/settings.local.json`: the arrays `permissions.deny`, `permissions.ask`, and `sandbox.filesystem.denyRead`, and the booleans `sandbox.enabled` and `sandbox.allowUnsandboxedCommands`. Adding the same rule twice changes nothing.

## Outside systems

- Claude Code: runs the hook and applies the settings. Critical.
- git and `gh`: the commands the hook recognizes; neither is called.

## Risks

| Risk | What reduces it |
|------|-----------------|
| A form of push the tokenizer misses, such as a script that pushes inside | The sandbox and the rules of `protect`; the gap is stated, as the guide states it for rules |
| A prompt on a command that does not push | Tokens, not text: a word inside a commit message is not a command |
| A broken settings file after `apply` | `json_add` writes to a temporary file and stops on a file that is not a JSON object |
| `acceptEdits` and `auto` not measured | The documentation says auto mode still shows a hook's prompts; measured again in stage 6 |
| The sandbox missing its dependencies runs commands without it | `protect` says when `bwrap` or `socat` is missing |

## Trade-offs

- `ask` every time costs one click per delivery action, and never trusts the agent's reading of a "yes" (ask-before-irreversible-4).
- No `if` on the hook costs a short script run on every Bash call, and leaves no form unmeasured (ask-before-irreversible-13).

## Discarded alternatives

- Permission rules shipped by the plugin: a plugin cannot ship them.
- A rule `Bash(git push *)`: does not match `git -C <dir> push`.
- A regular expression over the command's text: asks on a commit message that says "push" (ask-before-irreversible-12).
- `deny` instead of `ask`: R14 makes these actions the owner's, not forbidden (ask-before-irreversible-3).

## How it can evolve

More actions join the hook's list, such as `gh api` calls that write; `protect` learns more names of secret files; a later work may refuse in a mode measured to show no prompt.
