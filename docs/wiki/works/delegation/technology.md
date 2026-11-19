# Technology of delegation

What the work needs from its technology, from [definition.md](definition.md). Stage 2. No new dependency: shell and awk, as the check already uses (TD2), and text in the skills and the contract.

## Needs and choices

| # | Need | Choice | Status |
|---|------|--------|--------|
| N1 | Record the kind of each question and how the owner answered it (delegation-8) | Two columns added at the end of a work's `decisions.md`, after "Shared page": Kind and Answer. Kept at the end so the check still reads the shared page in the sixth column | Decided (delegation-11) |
| N2 | A short fixed list of kinds (delegation-8) | `definition`, `technology`, `plan`, `open-work`, `close-stage`, `close-work`, `commit`, `merge-push`, `version`, `other`. From the kinds of [measurements.md](measurements.md), with merge and push apart from commit, since delegation-5 never delegates them | Decided (delegation-11) |
| N3 | The answers (delegation-8) | `as recommended`, `changed`, `rejected`, `delegated`. A value the doctor estimated ends in ` (estimated)`; a cell left empty when unsure is allowed, and the measurement skips it (delegation-9) | Decided (delegation-11) |
| N4 | Measure at the close of a work (delegation-6) | A new mode of the check, `sh check-wiki.sh --delegations [wiki]`, built on the reader that `--decisions` already uses. It counts, for each kind, the rows of every work's `decisions.md` and prints one line for each kind that qualifies, with its numbers; nothing when none does | Decided (delegation-11) |
| N5 | The delegations in force, readable after their work closes (delegation-7) | A shared page `01-product/delegations.md`: one row per delegation in force, with its kind and the decision that made it. Written when a work that records a delegation closes, like any shared page | Decided (delegation-11) |
| N6 | The agent knows the delegations before it asks | `prepare-project` reads `01-product/delegations.md`, when it exists, before asking a question of a delegated kind; within one, it acts, records the row with "Who decided" as `agent, by <delegation>`, and tells the owner in one line (delegation-3) | Decided (delegation-11) |
| N7 | The step at the close (delegation-6) | One item in the close of a work in `prepare-project/references/6-execution.md`, beside the version: run `--delegations` and propose what it prints | Decided (delegation-11) |
| N8 | Format 5 and the migration (delegation-8, delegation-9) | `format.md` gets the two columns; the check's `present_format` becomes 5 and checks the values of N2 and N3 in rows that have them; the doctor gets `references/format-5.md`: add the two columns to every work's `decisions.md` and fill earlier rows as delegation-9 says | Decided (delegation-11) |
| N9 | The contract with the new R6 and R10 (delegation-3, delegation-4) | `plugins/playbook-wiki/contract.md`, and L1 and L4 raised in `scripts/verify.sh` and `01-product/style-guide.md` (delegation-2) | Decided by those decisions |

## Architecture

The problem: every decision is a question asked each time, and nothing measures which questions the owner answers with an automatic yes ([measurements.md](measurements.md)).

The shape: record the kind and the answer when a decision is made, count them with the check that already reads the decisions, and keep the delegations in force in one shared page the agent reads before asking.

| Module | Changes | Does not |
|--------|---------|----------|
| `plugins/playbook-wiki/contract.md` | R6 and R10 (N9) | Hold the list of kinds or the threshold |
| `plugins/playbook-wiki/format.md` | Format 5: the columns Kind and Answer, and the page `01-product/delegations.md` (N1 to N3, N5) | |
| `plugins/playbook-wiki/check-wiki.sh` | Format 5; the values of the two columns; the mode `--delegations` (N4, N8) | Decide or record a delegation; call a model |
| `plugins/playbook-wiki/skills/doctor/` | `references/format-5.md` (N8) | Change a row's other cells; touch `docs/wiki/decisions.md`, the history before format 4 |
| `plugins/playbook-wiki/skills/prepare-project/` | Records Kind and Answer with each decision; reads the delegations before asking; the step at the close (N6, N7) | Record a delegation the owner did not give |
| `scripts/verify.sh`, `01-product/style-guide.md` | L1 270 and L4 370 (N9) | |

Data: a row of a work's `decisions.md` gains Kind and Answer. `01-product/delegations.md` lists the delegations in force, each citing its decision; a decision that revokes one removes its row.

Risks:

- A version that raises the format sends every project with a wiki to the doctor. Reduced by the notice at the start of a session, and by a migration that only adds columns.
- The agent records Kind or Answer wrong. Reduced by a fixed list the check enforces; a wrong value only shifts a count that the owner reads before deciding.
- A delegation outlives the trust that made it. Reduced by delegation-7: a "yes but" or a "no" makes the agent propose revoking it.

Trade-offs: a mode of the check, not a script of its own, keeps one reader of the decisions and one file to maintain, and makes the check a little longer.

Discarded:

- Classifying the rows at each close with keywords, as [measurements.md](measurements.md) did: approximate forever (delegation-8).
- An outside classifier, Jev or a model on a homelab: a dependency and data leaving the session (delegation-9).
- The columns placed before "Shared page": the check and every existing row read the shared page in the sixth column.

Evolution: the threshold of delegation-6 can become a setting of a project; risk levels with more than one person can use the same Kind column.
