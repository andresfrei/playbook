# commit-check

The hook `commit-check` stops a `git commit` when the wiki has changes and its check fails.

## When it runs

- At `PreToolUse` of a Bash command that matches `git commit` or `git * commit` in `hooks.json`, and the command itself commits. Other commands pass.
- It finds the repository from a `cd <dir>` at the start of the command or from `git -C <dir>`, else from the session's folder. A folder it cannot resolve falls back to the session's. The folder may be quoted or hold spaces.
- It does nothing when the repository has no `docs/playbook/`, or when `docs/playbook/` has no changes (including untracked files) since the last commit.

## What it reads

- The hook's input (the command and the session's folder) and the state of `docs/playbook/` in git.
- The result of [wiki](wiki.md)'s check, `check-wiki.sh`, run on the repository's `docs/playbook`.

## What it writes

- Nothing to disk. When the check fails, it denies the commit, with a reason that says the commit is stopped, to repair what is listed, and the check's output. When the check passes, it prints nothing and the commit goes on. On an error of its own it lets the commit through.

## What it asks the owner

- Nothing. It denies, and Claude repairs what the check lists.

## Connects to

- [wiki](wiki.md), whose check it runs.
- [ask](ask.md), the other `PreToolUse` hook.
- [close](close.md) and [define](define.md), which also run the check before a commit.

Source: [plugins/playbook/hooks/commit-check.sh](../../plugins/playbook/hooks/commit-check.sh), with helpers in [lib.sh](../../plugins/playbook/hooks/lib.sh), wired in [hooks.json](../../plugins/playbook/hooks/hooks.json)
