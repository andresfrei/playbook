# Architecture of the work decision-index

## The problem

An agent cannot tell which decisions hold without reading all of them, and `playbook-wiki` carries rules for every older format it ever had (decision-index-1, -2).

## Requirements

- A work's `decisions.md` gains the column Replaces; the check fails on an identifier it names that does not exist (decision-index-4).
- The index is printed by the check, never written (decision-index-4).
- Only the current format, 6, is read and written; an older wiki is migrated first (decision-index-2).
- The skill `doctor` becomes `migrate` (decision-index-5). Released as 4.0.0 (decision-index-3).

## Modules

| Module | Changes | Does not |
|--------|---------|----------|
| `plugins/playbook-wiki/format.md` | Format 6: the column Replaces; the work `history` keeps the identifiers `D#`, `TD#`, `Q#`, `U#` it had; every rule for an older format is removed | Describe older formats |
| `plugins/playbook-wiki/check-wiki.sh` | Checks Replaces; `--decisions --in-force [shared page]` prints the decisions that name a shared page and that no later decision replaces; the branches for older formats are removed | Write any file |
| Skill `migrate`, formerly `doctor` | An agent reads the current `format.md` and the wiki, rewrites the wiki to format 6, and runs the check until it passes (decision-index-10): it adds Replaces, filled from the prose where a row names what it replaces and marked `(estimated)`, and turns `docs/wiki/decisions.md` into `works/history/decisions.md` | Keep a reference or a script for any older format; leave the wiki between formats |
| `wiki-format.sh` and the session-start hook | Name `/playbook-wiki:migrate` in the notice | |
| `prepare-project`, `write-docs`, `init` | Stop on a wiki below format 6 and point to `migrate` | Read the older wiki |
| Codex copy, `codex/` | Follows the same files and names | |
| This repository's wiki | Migrated to format 6 with `migrate`; the history's Replaces come from the review of 2026-11-20 | |

## Risks

- The migration fills Replaces wrongly: each filled value is marked `(estimated)`, and the owner reads them before the merge.
- A rename leaves `doctor` named somewhere: the unit's check greps the plugins, `codex/`, and the tests for it.

## Trade-offs

- Breaking compatibility keeps the check small and one format to test; an older wiki pays one migration.
- A migration costs the tokens of an agent reading the format and the wiki, once per wiki; no code is kept for older formats (decision-index-10).

## Discarded

- A written index file: it goes stale.
- Decisions in files by area: parallel works would edit the same file (decision-review-10).
