# Technology of the work ask-before-irreversible

What the work needs from its technology, from [definition.md](definition.md). Documentation read on 2026-11-19: code.claude.com/docs/en/hooks, /permissions, /permission-modes, /sandboxing, /settings. Claude Code 2.1.329.

## Needs

| ID | Need | From | Proposed answer | Status |
|----|------|------|-----------------|--------|
| N1 | Recognize, in a Bash command, each action of R14, in every form: chained with `&&`, `;`, or `|`, after `cd`, with `git -C <dir>` or other global options, and with environment variables before it, and not a word inside a quoted text such as a commit message | ask-before-irreversible-2, -5 | A hook script of `playbook-agents` in POSIX `sh` and `awk`, as its other hooks, that splits the command into segments with the tokenizer of `hook-lib.sh` (now inside `commit_dir`, made a function both hooks use) and asks when a segment is `git ... push`, `gh pr create`, `gh pr merge`, or `gh release create|edit|delete`. It also reads the text of `sh -c`, `bash -c`, and `eval` once. When it cannot read its input, it asks (ask-before-irreversible-12) | Decided |
| N2 | Run the hook on every Bash call of the session and of its subagents, in every mode | ask-before-irreversible-3, -5 | A `PreToolUse` entry on `Bash` in `plugins/playbook-agents/hooks/hooks.json`, with no `if`: a hook's `ask` shows the prompt in `bypassPermissions` and for a subagent ([measurements.md](measurements.md)) (ask-before-irreversible-13) | Decided |
| N3 | The command `/playbook-agents:protect` | ask-before-irreversible-8 | A skill of `playbook-agents` with `disable-model-invocation: true`, so only the person starts it, and a script `protect.sh` in `sh` and `awk` that lists the secret files found and adds the chosen rules to the settings file, with the `json_add` of `plugins/playbook/skills/init/scripts/init.sh` (ask-before-irreversible-14) | Decided |
| N4 | Find the secret files of a repository | ask-before-irreversible-9 | `find` from the repository's root, skipping `.git` and `node_modules`, for names such as `.env`, `.env.*`, `*.pem`, `*.key`, `id_rsa*`, `*credentials*`, `*.p12`, and `secrets.*`; files git tracks included (ask-before-irreversible-14) | Decided |
| N5 | The rules written | ask-before-irreversible-9, -10 | For each secret file chosen: `permissions.deny` `Read(<path>)` and `sandbox.filesystem.denyRead` with the same path, because a `Read` rule stops the file tools and only the Bash commands Claude Code recognizes, such as `cat`. For deleting and resetting: `permissions.ask` `Bash(rm -r *)`, `Bash(rm -rf *)`, `Bash(git reset --hard *)`, `Bash(git branch -D *)`, `Bash(git clean *)`. For the sandbox: `sandbox.enabled` `true`, and as a separate item with its warning `sandbox.allowUnsandboxedCommands` `false` (ask-before-irreversible-15) | Decided |

## Facts that shape the answers

- A `Read` deny rule applies to the file tools and, in a Bash command Claude Code can analyze, to file commands it recognizes, such as `cat`, `head`, `tail`, `sed`, and `tee`. It does not apply to `grep -r` or to a script that opens files itself.
- `sandbox.filesystem.denyRead` blocks reading inside the sandbox, for shell commands only; it does not stop the Read tool.
- The sandbox is off by default. On Linux it needs `bubblewrap` and `socat`; when they are missing, commands run without the sandbox unless `sandbox.failIfUnavailable` is `true`. Both are installed on the owner's machine.
- In `bypassPermissions` mode, a command that fails in the sandbox is retried outside it without a prompt, unless `sandbox.allowUnsandboxedCommands` is `false`.
- Project settings apply the sandbox; `/sandbox` saves to `.claude/settings.local.json`. List settings merge across files.
- Read rule paths: `//path` is absolute, `/path` is relative to the settings file's project, `./path` and a bare name are relative to the current directory, and `Read(.env)` equals `Read(**/.env)`. Sandbox paths differ: `/path` is absolute.
