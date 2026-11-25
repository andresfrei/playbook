# Spec of the work permissions-wizard

Status: Accepted (permissions-wizard-6)

Learned: 2026-11-25

Delivery: one branch and one pull request per work (delivery-versioning-2).

## What and why

The owner wants to choose, in one guided place, what Claude may do in a project and what it asks first, and whether Claude Code adds its attribution to commits and pull requests (permissions-wizard-1). Today those are set by hand in Claude Code's settings files, and the playbook only lists a few suggested rules in `docs/reference/permissions.md`.

## What it does

A skill `permissions`, run as `/playbook:permissions` or offered once by `audit` when it adopts a project (permissions-wizard-4), asks the owner about four settings of Claude Code (permissions-wizard-2), one question at a time, each with a recommendation:

1. **Attribution.** Whether Claude Code adds its line to commits, and to pull requests, each apart: `attribution` in `~/.claude/settings.json`; `commit` and `pr` set to `""` when both are off, which every version reads (permissions-wizard-7).
2. **Allow.** Narrow rules for the project's own commands, proposed from its files (`package.json`, `Makefile`, test scripts) and the checks of its `CLAUDE.md`; never bare `Bash` or `Bash(*)`.
3. **Ask.** Rules before commands that destroy work: `git reset --hard`, `git clean`, `rm -rf`, and a forced push.
4. **Deny.** Rules that keep Claude from reading or editing the project's secrets: `.env` files, keys, and a `secrets/` folder.

Before each question it shows what the file already holds, so it proposes only what is missing. Rules go to the project's `.claude/settings.json`, attribution to `~/.claude/settings.json`; before writing, it shows each line and the file it goes to (permissions-wizard-3).

A script `plugins/playbook/scripts/settings-write.sh` does the writing (permissions-wizard-5): it adds rules to `allow`, `ask`, or `deny` without duplicating them, sets `attribution`, keeps every other key, never removes a rule, writes atomically, and refuses a file that is not a JSON object or is a symlink. Without `jq`, it says so and writes nothing.

## Out of scope

- Removing or editing rules already there; the owner does that by hand.
- `defaultMode` and other settings besides the four.
- Playbot's `bot-permissions` and its bot files (permissions-wizard-1).

## Check

- `sh tests/settings-write_test.sh` passes offline: rules added once, other keys kept, nothing removed, `attribution` set, a broken JSON or symlink refused unchanged, a missing `jq` refused.
- The checks of `CLAUDE.md`, with `reference_test.sh` finding the skill's page.
- A live check in a throwaway repository: `/playbook:permissions` proposes allow rules from its `package.json`, writes the accepted ones to `.claude/settings.json`, and a second run proposes nothing new.

## Units

| Unit | What | Check | State |
|------|------|-------|-------|
| 1 | `settings-write.sh` and its test | `sh tests/settings-write_test.sh`; `shellcheck` on both | Done |
| 2 | The skill `permissions`, its page in `docs/reference/` (from `permissions.md`), and the README tables | `sh tests/reference_test.sh`; `claude plugin validate .`; the live check | Done |
| 3 | `audit` offers the wizard once when it adopts a project | Live check: adopting a throwaway repository offers it; a second audit does not | Done |
