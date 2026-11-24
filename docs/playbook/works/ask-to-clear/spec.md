# Spec of the work ask-to-clear

Status: Accepted (ask-to-clear-3).

Learned: 2026-11-24

Delivery: one branch and one pull request per work (delivery-versioning-2).

## What and why (ask-to-clear-1)

At the moment Claude Code's documentation names for `/clear`, Claude asks the owner whether to close the session there, instead of recommending it in one line that is easy to skip. The owner works in sessions of 150k to 250k tokens of context, and session-cost-1 measured that the cost per request grows with it.

Claude Code's documentation, read on 2026-11-23:

- best-practices.md: "`/clear` between unrelated tasks. It costs nothing, and it means the next task doesn't keep paying for the previous one's history."
- best-practices.md: "a session past about 200K tokens that sits idle is compacted shortly before the cache expires, so after lunch you continue from a summary. If you don't need the history at all, a fresh session still costs less."
- context-window.md: "run `/clear` when switching to unrelated work. Old conversation crowds out the files you need next and costs tokens on every message."
- skills.md: "Most built-in commands instead execute fixed logic directly." Claude cannot run `/clear`; the owner types it.
- tools-reference.md: "Claude uses `AskUserQuestion` to ask you multiple-choice questions when it needs a decision or a clarification."

## What changes

1. `rules.md`: the line of session-cost-2 becomes, in about the same length (ask-to-clear-2): when a task is done and the next is a different one, or the owner stops mid-unit, ask with `AskUserQuestion` whether to close and continue in a clean session; on a yes, write the next step in the README's line "Open work" or in the unit's row of `spec.md`, commit it, and tell the owner to type `/clear` and then "seguí"; on a no, go on. It holds for any task, also outside a work, and in both build modes.
2. `close`, step 4: after a unit is marked done, ask instead of recommending `/clear`; the next unit is already written, so the yes only commits and names it.
3. `define`, step 11: after the spec is accepted, ask instead of recommending; on a yes in `main`, the line still says `/clear`, `/model sonnet`, and the first unit by name (session-cost-1); in `builder`, `/clear` and the first unit with `builder` (build-mode-6).
4. The plugin's README, the paragraph on cost: the playbook asks at those points instead of recommending.
5. `product.md`, at close: the session is cut by the owner's answer at the end of each task, citing ask-to-clear-1.

## Out of scope

- Measuring the context: hooks do not receive its size, and a status line stays out (session-cost-1). The question follows the task, not a number of tokens.
- Running `/clear`, `/compact`, or `/rename` for the owner: built-in commands are not Claude's to run.
- Asking while iterating on the same task: only when what follows is a different one.

## Check

- `sh tests/check-wiki_test.sh`, `sh tests/hooks_test.sh`, `sh plugins/playbook/scripts/check-wiki.sh docs/playbook`, `shellcheck`, and `claude plugin validate .` pass; `hooks_test.sh` still prints the README with the rules within 9000 characters.
- `git grep` finds no mention of session-cost-2's "recommend a new session" outside `docs/playbook/works/`.
- A live run with `--plugin-dir plugins/playbook` in a throwaway repository: a small task finished, then a different one requested, ends the first with the question; in `-p` the dialog may be missing, so the question comes in text (question-dialog-1).

## Units

One unit: the five changes above, in one pull request. Done.
