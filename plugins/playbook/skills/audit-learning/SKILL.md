---
name: audit-learning
description: Find what repeats across the project's works, such as the same answer, the same correction, or the same procedure in two works, and propose a delegation, a rule, a skill, or an agent for the owner to accept. On the owner's request, or offered by close when a whole work closes.
---

## When to use

- The owner runs `/playbook:audit-learning` or asks for it, or says yes when `close` offers it after a whole work closes (cross-work-learning-4).

## Rules

- Propose; the owner decides. Write no piece, rule, or delegation without the owner's yes: a new piece is medium (R18).
- Keep no record of its own: no list of candidates, levels, or counts. What was learned is the line `Learned: <date>` in each work's `spec.md` (cross-work-learning-3).
- A repetition is the same thing in two different works; once is not enough (cross-work-learning-5).
- Ask one question at a time, with a recommendation, then stop and wait. Ask it with `AskUserQuestion` when available, one question per dialog, recommended option first; ask in text a question that has no options to offer.

## Steps

1. List the works under `docs/playbook/works/` that have a `spec.md`, leaving out `audit-*`. A work is pending while its `spec.md` has no line `Learned:`. A work with no `spec.md`, in the older format, and `history/` are history: never pending, only searched with `git grep` (cross-work-learning-14). When none is pending, say so in one line and stop.
2. Run a subagent to read, so the files stay out of the conversation; it does not see the conversation, so give it everything below. Brief:
   - Read in full the `decisions.md` of each pending work: list their paths.
   - Note the subjects they touch, then search the other works for them with `git grep -n -i "<subject>" -- docs/playbook/works`, reading only the lines it finds.
   - Signals: the owner's words in the column "Their words", a decision whose cell starts with "Replaced by" or "Replaces", and the reviewer's findings recorded in a work.
   - Return each subject that appears in two different works, at least one of them pending, as: the kind (the same answer to the same question, the same correction, the same procedure of several steps, a repeated task with long output or one a cheaper model can do, the same subject replaced twice), the two IDs, the quote of each, and any line of `CLAUDE.md`, `.claude/rules/`, or a skill that already covers it. Nothing else.
3. Check each repetition it returns against the quoted lines, and drop any whose quotes do not say the same thing. For each one left, choose the proposal:

   | What repeats | What to propose |
   |--------------|-----------------|
   | The same answer to the same question | A delegation, one line in the project's `CLAUDE.md` (R6) |
   | The same correction by the owner | A rule in `CLAUDE.md`, or in `.claude/rules/<topic>.md` with `paths:` when it holds for one part of the code |
   | The same procedure of several steps | A skill, written with `skill-creator` |
   | A repeated task with long output, or one a cheaper model can do | An agent |
   | The same subject replaced twice | No tool: a warning for `define`, recorded as a decision, that the subject is unstable |

   When a piece already covers it, propose adjusting that piece instead of a new one. A piece that holds for this project only stays in the project; one that holds for any project goes to the playbook (R16).
4. Show one proposal at a time: the kind, both IDs with their quotes, the exact line or the piece's name and job, where it goes, and your recommendation. Stop and wait.
5. Write each proposal the owner accepts; for a skill or an agent, write it with the owner on the yes. Record each answer, yes or no, as a decision with the owner's words: in the open work's `decisions.md`, or in `docs/playbook/works/audit-<date>/decisions.md` when none is open.
6. Write `Learned: <date>` in each pending work's `spec.md`, under the line `Status:`, or under the title when it has none, whether or not anything was proposed. Run `sh "${CLAUDE_PLUGIN_ROOT}/scripts/check-wiki.sh" docs/playbook` and fix what it lists.

## Output

- The works read, each repetition with its IDs, the owner's answer, what was written and in which file, and the works marked `Learned:`.
