# Plan of the work ask-before-irreversible

The units that build [architecture.md](architecture.md), in order.

## Progress

| Unit | Status | Evidence | Done on | Owner's words |
|------|--------|----------|---------|---------------|
| ask-before-irreversible-U1 | Done | `sh scripts/verify_test.sh` and `sh scripts/verify.sh` pass with gawk and with mawk, shellcheck clean; the new cases ask on the delivery forms, also after shell keywords and wrappers (`for`, `if !`, `!`, `{`, `time`, `env`, `sudo`, `nohup`, `command`, `exec`), on the `gh` aliases `new`, with `-o` options before `-c`, and inside `sh -c`, `bash -c`, and `eval`, and on unreadable input; they stay silent on 13 other commands. Each case failed with its behaviour broken. The heredoc gap is accepted in [architecture.md](architecture.md). Reviewed: six findings, fixed. With the plugin loaded from this worktree by `--plugin-dir`, `claude -p` in `bypassPermissions` and in `acceptEdits` was stopped before `git -C . push origin HEAD` with the reason of ask-before-irreversible-21, and nothing was pushed; the prompt in an interactive session was measured in [measurements.md](measurements.md) | 2026-11-20 | |
| ask-before-irreversible-U2 | Done | `sh scripts/verify_test.sh` (all cases pass) and `sh scripts/verify.sh` pass, shellcheck clean; 41 new cases of `protect.sh` also pass with gawk and with mawk: `scan` finds each name of N4, skips `.git` and `node_modules`, does not list `README.md` or `keyboard.txt`, and reports a name with a double quote; `apply` creates a missing file with valid JSON, adds the rules and sets the booleans of ask-before-irreversible-15, adds nothing twice, replaces an existing true or false, keeps other keys, exits 3 leaving the file byte-identical on a non-object or a path part of another type (also when a later item is the one that fails), and exits 2 on an unknown item. Each case failed with its behaviour broken (a `.git` skip, a pattern, the dedupe, the boolean replace, the exit 3, the unknown item, writing before all items succeeded). Reviewed: seven findings, fixed, each with new cases (75 cases of `protect.sh` in all, passing with gawk and with mawk): a symlinked `.env` is listed; wildcard names are refused by `apply` (exit 2) and reported by `scan`; the walker rejects text that is not JSON (exit 3); a symlinked settings file is refused (exit 4); the mode survives a rewrite; keys with a slash or an escape exit 3; the `..` guard and a failed write (exit 4) are tested | 2026-11-20 | |
| ask-before-irreversible-U3 | Not started | | | |

## Units

| ID | Unit | What it delivers | When it ends | Accepted by |
|----|------|------------------|--------------|-------------|
| ask-before-irreversible-U1 | The delivery hook | The tokenizer of `hook-lib.sh` as a function `commit_dir` and the new hook share; `ask-before-delivery.sh`; its `PreToolUse` entry on `Bash` in `hooks.json` (N1, N2) | `scripts/verify_test.sh` passes cases that ask on: `git push`, `git -C <dir> push`, `cd x && git push`, an environment variable before it, `--tags`, `--delete`, `gh pr create`, `gh pr merge`, `gh release create`, `edit`, and `delete`, each inside `sh -c`, `bash -c`, and `eval`, and an input it cannot read; and that stay silent on `git commit -m "push"`, `echo git push`, `git log`, `gh pr view`, `gh release list`. Each new case seen to fail with its behaviour broken; the commit hook's cases still pass. With the plugin loaded from this worktree, the owner sees the prompt for a push in `bypassPermissions` and in `acceptEdits` | Evidence |
| ask-before-irreversible-U2 | The protect script | `protect.sh scan` and `protect.sh apply <settings file> <items>` (N4, N5) | `verify_test.sh` passes cases: `scan` finds each name of N4 and skips `.git` and `node_modules`; `apply` creates a missing file, adds to the arrays and sets the booleans of ask-before-irreversible-15, adds nothing twice, changes no other key, and stops on a file that is not a JSON object, leaving it unchanged. Each new case seen to fail with its behaviour broken | Evidence |
| ask-before-irreversible-U3 | The protect command | The skill `protect` (`disable-model-invocation: true`): runs `scan`, shows the items with the warning of `allowUnsandboxedCommands`, asks which and where, runs `apply`, shows what it wrote (N3) | `verify.sh` passes (L2, L4 unchanged); a real run in a scratch repository writes the chosen rules, and Claude Code then asks before `git reset --hard` and refuses `cat .env` | Judgement: the flow the person sees |

## How the work is delivered

Decided (ask-before-irreversible-19), as in the works before it (seed-evidence-10), from this repository's history and its only long-lived branch, `main`, which is production:

- Tested by the checks of each unit and the real runs of U1 and U3.
- The units are built in order on this work's branch, `feat/ask-before-irreversible`.
- It reaches `main` by one pull request, which the owner merges (R14).

## Left out

- Other actions that cannot be undone beyond those of ask-before-irreversible-2 and -15.
- Running `protect` in the owner's other repositories: each is run by the owner, in that repository, after the release.
- The version: at the close; it adds a hook and a command and breaks nothing, a MINOR by TD22.
