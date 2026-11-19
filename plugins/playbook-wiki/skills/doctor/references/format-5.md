# Format 5 — the kind and the answer of each decision

What changed in the format of a wiki, and how a wiki at format 4 reaches format 5.

## What changed

- The table of a work's `decisions.md` has two more columns at the end, after "Shared page": Kind, what the decision was about, and Answer, how the owner answered. They let the check count, for each kind, how often the owner accepted what was recommended, and propose a delegation.
- A decision taken under a delegation says `agent, by <delegation>` in "Who decided".
- The shared page `01-product/delegations.md` lists the delegations in force. It is created with the first delegation, not by this migration.

The format is `../../../format.md`. Read the section "A work's `decisions.md`" before step 1: it holds the lists of kinds and answers.

## Steps

1. List every `docs/wiki/works/<work>/decisions.md`. Never touch `docs/wiki/decisions.md`, the history before format 4.
2. In each table of decisions, add the headers `Kind` and `Answer` after `Shared page`, and two cells at the end of every row.
3. Fill the two cells of each row, reading only that row: the decision and the words of whoever decided.
   - Kind: the one of the list that the decision is about. A stage closed is `close-stage`; a work opened is `open-work`; a version is `version`; a merge or a push is `merge-push`.
   - Answer: `as recommended` when the words only accept, such as "si", "acepto", or an option marked recommended; `changed` when they accept and add or change something, such as "si, pero ..."; `rejected` when they say no; `delegated` when "Who decided" names a delegation.
   - Write each value as plain text, without backticks, with ` (estimated)` at its end, such as close-stage (estimated).
   - When the row does not show the value, leave the cell empty. An empty cell is better than a guess: the count skips it.
4. Change nothing else in a row: not its identifier, its text, its words, or its shared page.
5. Show the owner, for each work, how many rows got each kind and each answer, and how many cells were left empty, before writing. Apply what the owner accepts, as the skill's rules say.
6. Continue with the last step of the skill. The check refuses a value outside the lists.
