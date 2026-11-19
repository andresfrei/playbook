# Plan of version-check

Stage 5. It builds what [definition.md](definition.md) and [technology.md](technology.md) decide. Accepted (version-check-14).

## Progress

| Unit | Status | Evidence | Done on | Owner's words |
|------|--------|----------|---------|---------------|
| version-check-U1 | Not started | | | |
| version-check-U2 | Not started | | | |

## Units

| ID | Unit | Delivers | Ends when | Accepted by |
|----|------|----------|-----------|-------------|
| version-check-U1 | The version notice | `plugins/playbook-wiki/hooks/version-check.sh`: the installed version from `CLAUDE_PLUGIN_ROOT`, the available one from the marketplace's local copy, compared, and printed as one JSON object with `systemMessage` and `additionalContext`; registered under SessionStart with the matcher `startup` in `hooks.json`; the hook's row in the README of `playbook-wiki` (N1 to N3, N6, N7) | `scripts/verify_test.sh` passes with a case for an older, equal, newer, and unknown version, a missing copy, a marketplace from a Git source and one from a folder, and a run that prints nothing on failure; `shellcheck` and `bash scripts/verify.sh` pass; the agent `review` read it | Evidence |
| version-check-U2 | The format notice for the person | `wiki-format.sh`: the case of a wiki at a newer format than the plugin, and the hook's output as JSON for the person and the agent, under the matcher `startup` (N4 to N6) | `scripts/verify_test.sh` passes with a case for a wiki behind, equal, ahead, and with no marker, each checking the JSON; `shellcheck` and `bash scripts/verify.sh` pass; the agent `review` read it | Evidence |

U2 follows U1, since both change the SessionStart entries of `hooks.json`.

## How the work is delivered

Decided (version-check-14), from this repository's history (`git log --merges --first-parent main`: each work reaches `main` by one pull request from its own branch, as `feat/delegation` in #28) and its only long-lived branch, `main`, which is production:

- Tested nowhere apart: the tests of each unit, which build the plugins folder of Claude Code with fake files.
- The units are built in order, one at a time, on this work's branch.
- The branch is renamed from `docs/version-check` to `feat/version-check`, since the work now changes code; it has not been pushed.
- It reaches `main` by one pull request, which the owner merges (R14).

## Left out

- The first real notice of a new version: the hook exists only from the version that ships it. A person on 3.0.0 or earlier is not told about it; the version notice first shows when a later version is available to a person who has this one. The format notice reaches the person from this version on.
- Whether SessionStart runs again on `/reload-plugins`: not documented; the notice shows at the next session either way.
- The check against GitHub (version-check-8, Later).
- The version: when the work closes, `CLAUDE.md` asks for it (github-release-2). It adds a hook and breaks nothing, a MINOR by TD22.
