---
name: audit-learning
description: Find what repeats across the project's works, such as the same answer, the same correction, or the same procedure in two works, and read the dialogs the owner answered, by type, with the answers that departed from the recommendation; propose a delegation, a rule, a skill, or an agent for the owner to accept. On the owner's request, or offered by close when a whole work closes.
---

## When to use

- The owner runs `/playbook:audit-learning` or asks for it, or says yes when `close` offers it after a whole work closes (cross-work-learning-4).

## Rules

- Propose; the owner decides. Write no piece, rule, or delegation without the owner's yes: a new piece is medium (R18).
- Keep no record of its own: no list of candidates, levels, or counts. What was learned from the works is the line `Learned: <date>` in each work's `spec.md` (cross-work-learning-3). The answered dialogs are the capture hook's file in the plugin's data folder, not the skill's: the skill writes nothing into it except through the import (dialog-learning-2).
- A repetition in the works is the same thing in two different works; once is not enough (cross-work-learning-5). This does not apply to the dialogs, which repeat inside one work and across projects (dialog-learning-6).
- The lines of the dialogs hold the text of questions and answers of every project: they stay on the machine, and no step copies them into a repository (dialog-learning-6).
- Ask one question at a time, with a recommendation, then stop and wait. Ask it with `AskUserQuestion` when available, one question per dialog, recommended option first; ask in text a question that has no options to offer. Its `header` is the question's type, one of these words copied as they are in any language: Session, Accept, Delivery, Load, Record, Finding, Remote, Setup, Product, Technical, Design, Scope, Problem, Clarify; the question and its options stay in the owner's language.

## Steps

1. List the works under `docs/playbook/works/` that have a `spec.md`, leaving out only the folders of an audit, named `audit-<YYYY-MM-DD>` such as `audit-2026-11-24` (audit-decided-5); a work whose name starts with `audit-` but is not a date, such as `audit-decided`, is a work like any other. A work is pending while its `spec.md` has no line `Learned:`. A work with no `spec.md`, in the older format, and `history/` are history: never pending, only searched with `git grep` (cross-work-learning-14). When none is pending, say so in one line and go on to step 7.
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

7. Read the answered dialogs (dialog-learning-6). Without `jq` or with no `${CLAUDE_PLUGIN_DATA}`, say so in one line and finish with the works only. First run: when `${CLAUDE_PLUGIN_DATA}/dialogs.jsonl` is missing or holds no line with `"origin":"import"`, run `CLAUDE_PLUGIN_DATA="${CLAUDE_PLUGIN_DATA}" sh "${CLAUDE_PLUGIN_ROOT}/scripts/import-dialogs.sh"` and show its one-line result; when it fails (no transcripts, a format with no dialog), show its message and go on. Otherwise do not import: a second run imports nothing.
8. Run a subagent for the table; it does not see the conversation, so give it everything below. Brief:
   - Run `CLAUDE_PLUGIN_DATA="${CLAUDE_PLUGIN_DATA}" sh "${CLAUDE_PLUGIN_ROOT}/scripts/dialog-table.sh" "$PWD"` and keep its output; the variable is written out because Claude Code substitutes it in this text but does not export it to Bash (plugins-reference.md).
   - When the output has the section "Untyped questions", classify each JSON line there into one of these fourteen words, by what the question asks: Session (close here and go on in a clean session, or go on to the next step), Accept (a spec, a plan, a unit, a close), Delivery (commit, push, pull request, version, release), Load (split a unit, build in parallel, the order of units), Record (write down a rule, a delegation, a memory, a name), Finding (what to do with a finding of an audit or a review), Remote (another machine, credentials, access), Setup (Claude's permissions, skills, plugins, agents), Product (what the product does), Technical (a technology or a mechanism), Design (the visual part), Scope (what is in and what is out), Problem (an obstacle while building), Clarify (a fact only the owner knows). Write them as JSON lines `{"id":...,"question":...,"type":...}` into a file in a temporary folder (`mktemp -d`), run the same command again with `"$PWD"` and that file as the second argument, and keep the new output.
   - Return the final output verbatim, plus the share of untyped lines among the lines the hook wrote (those with no `"origin"`), counted with `jq`: it is the sign whether the header rule holds. Nothing else. Copy no line or text into a repository (dialog-learning-6).
9. Show the table to the owner, with the count of own-words answers, as the sign that questions came before the picture was shared, and the untyped share of the hook's lines.
10. Propose from the table and the departures, one at a time, under the rules above (dialog-learning-6). No number decides (cross-work-learning-10); show the counts with each one.
   - A delegation for a type, only when its questions are one question asked again and again, the first option was taken almost every time, and git undoes a wrong answer (light, R18). Never for Delivery or Remote, which a hook asks anyway (R14, R24). Where: the project's `CLAUDE.md` when it holds for this project, `~/.claude/CLAUDE.md` when the same answer repeats across the owner's projects (dialog-learning-4).
   - A departure that is a fact the agent did not have: a line for the project's wiki or its `CLAUDE.md`.
   - A recommendation that missed more than once on the same question: a correction of the rule or the skill that makes it.
   - An idea of the owner outside the options: nothing to write, only counted.
11. Write each proposal the owner accepts, and record each answer, yes or no, as step 5 does. Run `sh "${CLAUDE_PLUGIN_ROOT}/scripts/check-wiki.sh" docs/playbook` again when something was written in the wiki.

## Output

- The works read, each repetition with its IDs, the owner's answer, what was written and in which file, and the works marked `Learned:`.
- The table of the answered dialogs shown, and each proposal from them with the owner's answer and what was written.
