# audit-learning

The skill `/playbook:audit-learning` finds what repeats across the project's works and proposes a delegation, a rule, a skill, or an agent for the owner to accept. It also reads the dialogs the owner answered, by type.

## When it runs

- The owner runs `/playbook:audit-learning` or asks for it, or says yes when [close](close.md) offers it after a whole work closes.
- A repetition is the same thing in two different works; once is not enough.

## What it reads

- The works under `docs/playbook/works/` that have a `spec.md` and no line `Learned:`. Audit folders (`audit-<YYYY-MM-DD>`) are left out. Works with no `spec.md` are history, only searched with `git grep`. When no work is pending it says so and goes on to the dialogs.
- A subagent reads the `decisions.md` of each pending work and searches the other works for the same subjects, looking at the owner's words, decisions marked "Replaced by" or "Replaces", and reviewer findings. It returns each subject that appears in two works, with both quotes and any line of `CLAUDE.md`, `.claude/rules/`, or a skill that already covers it.
- Then the answered dialogs, the lines of the [capture](capture.md) hook (dialog-learning-6). Without `jq` or a data folder it says so and reads only the works. On the first run, when the data folder has no marker `imported`, it runs the import and shows its result; the import writes that marker, so it runs once.
- It runs the table script into a temporary folder and splits the questions whose header is not one of the fourteen types into batches of 300; one subagent per batch, all at once, classifies them by reading, never by keywords (dialog-learning-7). The table script runs again with those types and shows the table by type (times asked, share that took the first option, projects), the count of answers in the owner's own words, the departures of this project, and the share of untyped lines among the hook's. The lines stay on the machine; no step copies them into a repository.

## What it writes

- Only what the owner accepts: a line in the project's `CLAUDE.md` for the same answer, a rule for the same correction, a skill (written with `skill-creator`) for the same procedure, an agent for a repeated task with long output. For a subject replaced twice, no tool: a warning for [define](define.md), recorded as a decision. A piece already covering the subject is adjusted instead.
- From the dialogs, one proposal at a time and never by a number alone: a delegation for a type only when its questions are one question asked again and again, the first option was taken almost every time, and git undoes a wrong answer, never for Delivery or Remote; in the project's `CLAUDE.md`, or in `~/.claude/CLAUDE.md` when the same answer repeats across projects. A departure that is a fact the agent did not have becomes a line for the wiki or `CLAUDE.md`; a recommendation that missed more than once, a correction of its rule or skill; an idea outside the options is only counted.
- Each answer, yes or no, as a decision with the owner's words, in the open work's `decisions.md` or in `docs/playbook/works/audit-<date>/decisions.md`.
- The line `Learned: <date>` in each pending work's `spec.md`, under `Status:`, whether or not anything was proposed.
- It runs the [wiki](wiki.md) check and fixes what it lists. It keeps no record of its own: the dialogs file is the hook's, and the skill writes into it only through the import.

## What it asks the owner

- One proposal at a time: the kind, both decision IDs with their quotes, the exact line or the piece's name and job, where it goes, and a recommendation. The table is shown first. A new piece is a medium step, so nothing is written without the owner's yes.

## Connects to

- [close](close.md), which offers it.
- [define](define.md), [rules](rules.md), and [wiki](wiki.md).

Source: [plugins/playbook/skills/audit-learning/SKILL.md](../../plugins/playbook/skills/audit-learning/SKILL.md)
