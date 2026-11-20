# Plan of the work ask-before-irreversible

The units that build [architecture.md](architecture.md), in order.

## Progress

| Unit | Status | Evidence | Done on | Owner's words |
|------|--------|----------|---------|---------------|
| ask-before-irreversible-U1 | Not started | | | |
| ask-before-irreversible-U2 | Not started | | | |
| ask-before-irreversible-U3 | Not started | | | |

## Units

| ID | Unit | What it delivers | When it ends | Accepted by |
|----|------|------------------|--------------|-------------|
| ask-before-irreversible-U1 | The delivery hook | The tokenizer of `hook-lib.sh` as a function `commit_dir` and the new hook share; `ask-before-delivery.sh`; its `PreToolUse` entry on `Bash` in `hooks.json` (N1, N2) | `scripts/verify_test.sh` passes cases that ask on: `git push`, `git -C <dir> push`, `cd x && git push`, an environment variable before it, `--tags`, `--delete`, `gh pr create`, `gh pr merge`, `gh release create`, `edit`, and `delete`, each inside `sh -c`, `bash -c`, and `eval`, and an input it cannot read; and that stay silent on `git commit -m "push"`, `echo git push`, `git log`, `gh pr view`, `gh release list`. Each new case seen to fail with its behaviour broken; the commit hook's cases still pass. With the plugin loaded from this worktree, the owner sees the prompt for a push in `bypassPermissions` and in `acceptEdits` | Evidence |
| ask-before-irreversible-U2 | The protect script | `protect.sh scan` and `protect.sh apply <settings file> <items>` (N4, N5) | `verify_test.sh` passes cases: `scan` finds each name of N4 and skips `.git` and `node_modules`; `apply` creates a missing file, adds to the arrays and sets the booleans of ask-before-irreversible-15, adds nothing twice, changes no other key, and stops on a file that is not a JSON object, leaving it unchanged. Each new case seen to fail with its behaviour broken | Evidence |
| ask-before-irreversible-U3 | The protect command | The skill `protect` (`disable-model-invocation: true`): runs `scan`, shows the items with the warning of `allowUnsandboxedCommands`, asks which and where, runs `apply`, shows what it wrote (N3) | `verify.sh` passes (L2, L4 unchanged); a real run in a scratch repository writes the chosen rules, and Claude Code then asks before `git reset --hard` and refuses `cat .env` | Judgement: the flow the person sees |

## How the work is delivered

Proposed, as in the works before it (seed-evidence-10), from this repository's history and its only long-lived branch, `main`, which is production:

- Tested by the checks of each unit and the real runs of U1 and U3.
- The units are built in order on this work's branch, `feat/ask-before-irreversible`.
- It reaches `main` by one pull request, which the owner merges (R14).

## Left out

- Other actions that cannot be undone beyond those of ask-before-irreversible-2 and -15.
- Running `protect` in the owner's other repositories: each is run by the owner, in that repository, after the release.
- The version: at the close; it adds a hook and a command and breaks nothing, a MINOR by TD22.
