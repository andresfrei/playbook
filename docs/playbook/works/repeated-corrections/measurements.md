# Measurements of repeated-corrections

How often the findings of the agent `review` repeat, from a sample of the Claude Code transcripts on the owner's machine, read on 2026-11-19. Only types and counts are written here: this repository is public, and the reports of the other projects are private.

## Method

- A script read every transcript under `~/.claude/projects/` and kept the reports of calls to an agent named `review`: 232 distinct reports, from six projects of the owner.
- A sample of 60, in proportion to each project and spread over dates, was read by one agent. It wrote each defect a report states as one record: a type, a general lesson, the step, and whether the lesson depends on the project.
- 29 of the 60 held only the notice that a review in the background had started, not its result, and 3 were short follow-ups: the script read the start of background reviews, not their end. 31 real reviews remain; 26 found at least one defect, 93 in all.

## Result

| Measure | Value |
|---------|-------|
| Findings | 93, in 25 types |
| Types with 3 findings or more, in 2 projects or more | 15, holding 79 findings (85%) |
| Findings whose lesson holds for any project | 85 (91%) |
| Findings at the step of building a unit | 88 (95%) |

The types that repeat, with their findings and projects:

| Type | Findings | Projects |
|------|----------|----------|
| missing-test | 8 | 5 |
| state-model-gap | 8 | 3 |
| doc-out-of-sync-with-code | 8 | 4 |
| unhandled-error-path | 6 | 4 |
| shell-pitfall | 6 | 2 |
| test-passes-when-broken | 5 | 3 |
| contradicts-decision | 5 | 3 |
| race-condition | 4 | 4 |
| existing-data-not-handled | 4 | 2 |
| access-control-gap | 4 | 2 |
| external-tool-semantics-assumed | 4 | 2 |
| input-case-mishandled | 4 | 3 |
| rule-enforced-on-one-path-only | 3 | 2 |
| unintended-regression | 3 | 3 |
| misleading-message | 3 | 3 |

The three types about tests together hold 15 findings in five projects, the strongest pattern.

## Limits

- 26 reports with defects; three projects give 80% of the findings.
- Some types border on each other, such as missing-test and test-passes-when-broken; joining them would make them repeat more.
- The share of general lessons is high partly because every lesson was written in general terms; many still name a technology, such as SQL or shell.
- The step is inferred: a review sees changes already built, so "build" dominates partly for that reason.
- Before a measurement that seeds the mechanism, the script must read the results of background reviews, not their start.

## Reading

Findings repeat: most of them fall in types seen in several projects. The work goes on (repeated-corrections-1).
