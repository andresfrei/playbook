# Measurements of seed-evidence

The past reviews in the Claude Code transcripts on the owner's machine, read on 2026-11-19 by a script, with no model. Only counts are written here: the other projects are private.

## Method

The script reads every transcript under `~/.claude/projects/` and keeps the final report of each call to an agent named `review`: the tool result of a call in the foreground, and the result of the task notification of a call in the background, matched by its tool call. The notice that a review in the background started is left out, the fault of the earlier extraction. A report's date is that of its call.

## Result

| Project | Reviews | Last 7 days | Last 30 days | "No findings." |
|---------|---------|-------------|--------------|----------------|
| A | 43 | 33 | 35 | 2 |
| playbook | 35 | 27 | 27 | 2 |
| B | 26 | 23 | 23 | 1 |
| C | 12 | 10 | 10 | 0 |
| D | 5 | 4 | 4 | 0 |
| E | 2 | 1 | 1 | 0 |

129 reviews in all, besides 6 from scratch folders; 23 have no date. Nearly all are of the last 7 days, and nearly all have findings.

## Reading

- The history is short: what a repository can seed is a few weeks of reviews, so finding a window by age matters less than expected.
- Few reviews per repository: one run of `classify` per review costs little, at most a few dozen runs for the largest.
- Recalled, not checked: Claude Code removes transcripts older than its `cleanupPeriodDays` setting, 30 days by default; this would explain the short history.
