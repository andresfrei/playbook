# Measurements of the work ask-before-irreversible

## Does a hook's `ask` show a prompt in every mode?

Measured on 2026-11-19 with Claude Code 2.1.329, by the owner, in a scratch repository whose `origin` was a local bare repository. The repository's `.claude/settings.json` held a `PreToolUse` hook on `Bash` that returned `permissionDecision` `ask` for any `git ... push` and logged the permission mode and the agent, and the permission rule `ask` `Bash(git reset *)`.

| Mode | Request | Prompt shown | Reason shown |
|------|---------|--------------|--------------|
| `bypassPermissions` | `git -C . push origin HEAD` | Yes | The hook's reason, "Hook PreToolUse:Bash requires confirmation for this command" |
| `bypassPermissions` | `git status --short && git reset --hard HEAD && git status --short` | Yes | "Rule Bash(git reset *) from shared project settings says to ask" |
| `bypassPermissions` | A background `general-purpose` subagent running `git push origin HEAD 2>&1` | Yes, in the main session, marked "from the general-purpose agent" | The hook's reason |

The hook's log confirmed the mode as `bypassPermissions` and the agent as `main` and then `general-purpose`.

What this shows: in the most permissive mode, a hook's `ask` and an `ask` rule both show the prompt, also inside a chained command and for a subagent in the background. The hook matched the form `git -C <dir> push`.

Not measured: `acceptEdits` and `auto`. The documentation says auto mode still shows the prompts a hook forces.
