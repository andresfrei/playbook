# Spec of the work audit-decided

Status: Accepted (audit-decided-3); U2 added (audit-decided-4).

Delivery: one branch and one pull request per work (delivery-versioning-2).

## What and why (audit-decided-1)

The audit asks again what the owner already resolved. In the second audit of 2026-11-24, the tools part brought back Moshi and Persona and the setup part the on-demand proposal for `CLAUDE.md`, all three left by the owner that morning; and two findings were dropped because a rule already settles them. Rules R6 and R7 already say to search the decisions before asking and to record a choice someone would ask about again; a "leave it" answer was not recorded, so there was nothing to find.

## What changes

In the skill `audit`:

1. **Gotchas of the parts.** The setup part says these are not findings: a `[[link]]` of a memory file that matches no file (memory allows it), and an instruction of the project's `CLAUDE.md` that differs from a rule of the plugin when it is a delegation, as R6 says, since the project's rules win.
2. **A "leave it" is a decision.** In step 5, when the owner leaves a finding as it is, record it as a decision, as the parts already record a split of jobs: in the open work's `decisions.md`, or in `docs/playbook/works/audit-<date>/decisions.md` when none is open. The decision quotes the finding with its file, as the explorer gave it.
3. **Cross with what is decided.** In step 3, for each finding, search `docs/playbook/works/*/decisions.md` for a decision that already resolves it. When its quote is the same, the finding stays in the one table (one-audit-6) with "Already decided: <ID>" and is not asked. When the quote changed, it is a new finding.

In the skills `close` and `release` (audit-decided-4): a proposal of a version names the number it gives next to its kind, such as "PATCH: 5.5.1" from 5.5.0.

In the project's `CLAUDE.md`, under Conventions (audit-decided-2): "A work of the plugin changes only the plugin; findings about this repository's own setup (its memory, its audit answers) are resolved apart, by running the plugin, never as a unit of the work." The first draft of this spec mixed both, recording by hand the findings left on 2026-11-24.

## Out of scope

- Recording by hand the findings left on 2026-11-24 (audit-decided-2).
- The explorers: they stay as they are and do not read the decisions; the main session crosses (one-audit-6).
- An expiry of a "leave it": it comes back only when its quote changes.
- The wiki part: a contradiction left Open is already marked Open on its page and not reported.

## Check

- `sh tests/check-wiki_test.sh`, `sh tests/hooks_test.sh`, `sh tests/startup-context_test.sh`, `check-wiki.sh docs/playbook`, `shellcheck`, and `claude plugin validate .` pass.
- Live, in this repository, after the merge and `/reload-plugins`: a first `/playbook:audit` does not report the memory links nor the delivery delegation; it asks about Moshi, Persona, and the `CLAUDE.md` proposal, and records each "leave it" with its quote in `docs/playbook/works/audit-<date>/decisions.md`. A second `/playbook:audit` shows those three as "Already decided" with their IDs and asks nothing about them.

## Units

| Unit | Result | Check | State |
|------|--------|-------|-------|
| U1 | The three changes in `audit`, and the line of `CLAUDE.md` | The check above, but for the live part, which runs after the merge | Done; live check pending after the merge |
| U2 | `close` and `release` name the number next to the kind of version proposed | The check above | Done |
