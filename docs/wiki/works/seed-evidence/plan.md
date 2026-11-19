# Plan of the work seed-evidence

The units that build [architecture.md](architecture.md), in order.

## Progress

| Unit | Status | Evidence | Done on | Owner's words |
|------|--------|----------|---------|---------------|
| seed-evidence-U1 | Not started | | | |
| seed-evidence-U2 | Not started | | | |

## Units

| ID | Unit | What it delivers | When it ends | Accepted by |
|----|------|------------------|--------------|-------------|
| seed-evidence-U1 | The reader of transcripts | `seed-reviews.sh` in `playbook-agents`: `list <repo> [page]`, numbered reviews with date, time, and findings or "No findings.", marking those already on the page; `show <repo> N`, the text of review N and its identifier. It finds the folders of the repository and its worktrees under `$CLAUDE_CONFIG_DIR/projects/` or `~/.claude/projects/` (N1, N2) | `scripts/verify_test.sh` passes cases on lines shaped as real transcripts: a review in the foreground; one in the background, its start notice left out; "No findings."; escaped quotes and newlines in the text; a review already on the page marked; a worktree's folder found; another repository's folder not found; no folder, an empty list and a message. Each new case seen to fail with its behaviour broken. Run on the owner's transcripts, `list` agrees with [measurements.md](measurements.md) | Evidence |
| seed-evidence-U2 | The command | The skill `seed-evidence` (`disable-model-invocation: true`): runs `list`, shows the preview with the count of runs, asks, starts `classify` once per chosen review in order with `show`'s text, the tree root, and the identifier, and ends with `evidence.sh count` (N3) | `verify.sh` passes (L2, L4 unchanged); a real run in this repository's worktree seeds its page from its own past reviews, and the page passes `evidence.sh check` | Judgement: the flow the person sees |

## How the work is delivered

Decided (seed-evidence-10), as in the works before it (repeated-corrections-25), from this repository's history and its only long-lived branch, `main`, which is production:

- Tested by the checks of each unit and the real run of U2.
- The units are built in order on this work's branch, renamed `feat/seed-evidence`.
- It reaches `main` by one pull request, which the owner merges (R14).

## Left out

- Codex transcripts.
- Seeding the owner's other repositories: each is run by the owner, in that repository, after the release.
- The version: at the close; it adds a command and a script and breaks nothing, a MINOR by TD22.
