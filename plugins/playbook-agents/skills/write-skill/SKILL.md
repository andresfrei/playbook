---
name: write-skill
description: Write a new skill, or audit, fix, or shorten an existing one. Produces one SKILL.md in a fixed format and within size limits, with detail in reference files and two evaluation cases.
---

## When to use

- The owner asks for a new skill.
- The owner asks to audit, fix, shorten, or split an existing skill.

Do not use it for rules that apply to every task, for project documentation, or for a prompt that is not a skill.

## Rules

- One job per skill. When a request holds two jobs, propose two skills and ask which to write first.
- No two skills share a job. When an available skill already answers the same requests, propose changing that skill instead of adding one.
- Every skill follows `references/style-guide.md`: its files, format, limits, and writing rules.
- Ask the owner for a missing job or trigger request. Do not invent it.
- Every skill gets the evaluation cases the style guide asks for. A new skill gets its cases of behaviour before its `SKILL.md`.
- In an existing skill, change only what breaks the style guide or what the owner asked for. Keep its job.
- Run a paid evaluation only when the owner asks.

## Gotchas

- A request that asks for two results, such as "writes the changelog and also publishes the release", is two jobs, even under one name such as `release`: propose two skills, ask which to write first, and write nothing until the owner answers.

## Steps

### New skill

1. Read `references/style-guide.md`.
2. Write down the job in one sentence, the requests that must trigger the skill, and one similar request that must not. Ask the owner for whatever is missing.
3. Read the names and descriptions of the available skills. If one has the same job, stop and report it.
4. Collect the project's own material for the job: tasks done, the owner's corrections, and its documents. Ask the owner when there is none.
5. Write the three cases of behaviour from that material.
6. Write `SKILL.md` from the template in the style guide.
7. Move detail that only some tasks need into `references/`, one file per topic. List each file under References with when to read it.
8. Write the two cases of triggering.
9. Do the checks below.

### Existing skill

1. Read `references/style-guide.md` and every file of the skill.
2. Do the checks below and compare the skill with each rule of the style guide. List every finding: the rule, the file and line, and the fix.
3. Audit only: return the findings and stop.
4. Fix each finding with the smallest change. Move text that does not fit into `references/`.
5. Do the checks again.

### Checks

1. Count the body's words and the description's characters with the commands in the style guide. Shorten until both are within the limits.
2. Confirm that every file, command, and tool the skill names exists where the skill runs.
3. When the skill lives in a Claude Code plugin, run `claude plugin validate <plugin path>` and fix what it reports.

## Output

- New skill: the files written, the body's word count, the description's character count, and the evaluation cases.
- Audit: the findings, or "no findings".
- Fix: the findings, the changes made, and both counts before and after.
- Any check that failed or could not run.

## References

- `references/style-guide.md` — the files of a skill, the front matter, the body sections, the limits and how to count them, the writing rules, and the format of evaluation cases. Read it before writing or auditing.
