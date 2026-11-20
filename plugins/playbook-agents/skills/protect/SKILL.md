---
name: protect
description: Protect this repository: keep Claude Code from reading its secret files, ask before deletes and history resets, and turn on the sandbox. Finds the secret files, offers each protection, and writes the person's choice to a settings file.
disable-model-invocation: true
---

## When to use

- The person types `/playbook-agents:protect` inside a repository, the first time or after the repository changed.

Do not use it to ask before a push, a pull request, a merge, or a release: the plugin's hook already asks before those.

## Rules

- Read and write only through the script. Never edit a settings file by hand.
- Never read, print, or search the content of a secret file. Its name is enough.
- Write nothing the person did not choose. Ask only what the person's message does not already say.
- Offer `no-unsandboxed` only together with its warning, as an item apart from `sandbox`.

In what follows `<script>` is `${CLAUDE_PLUGIN_ROOT}/protect.sh`. Run it from the repository's root.

## Steps

1. Run `sh "<script>" scan`. Each line it prints is a secret file. Show a name it reports on standard error as not offered, since a rule cannot name it exactly. When the script fails, show its message and stop.
2. On Linux, run `command -v bwrap` and `command -v socat`. When one is missing, say that the sandbox needs it and will not run until it is installed.
3. Show the items, each with what it does:
   - `secret:<path>`, one per file found: Claude Code cannot read it with its file tools, and commands in the sandbox cannot read it.
   - `deletes`: Claude Code asks before `rm -r`, `rm -rf`, `git reset --hard`, `git branch -D`, and `git clean`.
   - `sandbox`: commands run in the sandbox, which limits the files and the network they reach.
   - `no-unsandboxed`: without it, a command that fails inside the sandbox can run again outside it, and in `bypassPermissions` mode without asking. With it, that command fails, and some tools may stop working until the sandbox allows what they need.
4. Ask, with AskUserQuestion when available, the recommended option first:
   - Which items. Recommend every `secret:`, `deletes`, and `sandbox`. Stop when the person chooses none.
   - Where: `.claude/settings.json` (recommended: shared through git, so it protects everyone who works here) or `.claude/settings.local.json` (only this person, kept out of git).
5. Run `sh "<script>" apply <file> <item>...` with the chosen file and items. When it fails, show its message and what its exit code means, and stop:
   - 2: an item or a path was refused.
   - 3: the file is not a valid JSON object; nothing was written. Fix the file and run the command again.
   - 4: the file could not be written, or it is a symbolic link; nothing was written.

## Output

- Each line `apply` printed: what was added, set, or already there, and the file written.
- When `secret:` items were written: the rules stop Claude Code's file tools and the commands it recognises, such as `cat`; the sandbox stops the rest of the commands only when `sandbox` is on.
- When the file is `.claude/settings.json`: it is ready to commit, so the rules reach everyone who works here.
- Run `/playbook-agents:protect` again when new secret files appear.
