# ask

The hook `ask` makes Claude Code ask the owner before a delivery action (rule R14).

## When it runs

- At `PreToolUse` of a Bash command, when the command matches one of the filters of `hooks.json`: `git push`, `gh pr create`, `gh pr merge`, `gh release create`, `gh release edit`, `gh release delete`, `gh release upload`, and the forms with options between the words, such as `git -C dir push`. The hook is set to block when it fails.
- The filters are best-effort: Claude Code also runs the hook for a command holding `$()`, backticks, or a variable. So the hook reads the command itself and asks only when it really pushes, creates or merges a pull request, or creates, edits, deletes, or uploads to a release. It looks through wrappers such as `timeout` and `sudo`, and into a command a shell runs.

## What it reads

- The hook's input: the Bash command.

## What it writes

- Nothing to disk. For a delivery command it answers with the decision "ask" and a reason saying that push, pull requests, merges, and releases are the owner's decisions. When it cannot read the command, it asks too, with a reason saying so. For any other command it prints nothing.

## What it asks the owner

- To confirm the push, the pull request, the merge, or the release. Nothing else.

## Connects to

- [rules](rules.md), where R14 states the rule.
- [release](release.md) and [close](close.md), which end with commands this hook asks about.
- [commit-check](commit-check.md), the other `PreToolUse` hook.
- [permissions](permissions.md), for rules that ask on a forced push as well.

Source: [plugins/playbook/hooks/ask.sh](../../plugins/playbook/hooks/ask.sh), with helpers in [lib.sh](../../plugins/playbook/hooks/lib.sh), wired in [hooks.json](../../plugins/playbook/hooks/hooks.json)
