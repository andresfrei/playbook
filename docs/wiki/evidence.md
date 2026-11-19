# Evidence

## Kinds

| Kind | Level | Rule | Applies when | Source | Scope |
|------|-------|------|--------------|--------|-------|
| identifier-form-unrecognised | 1 | Accept every identifier form that any producer of the data writes | Code that matches or dedupes identifiers written by more than one flow | seed-evidence-U1 2026-11-19 17:21 | general |
| delimiter-matched-too-early | 1 | Close a quoted span at the last closing delimiter inside its enclosing unit, not at the first | Code that extracts text between tags or delimiters that the text itself may quote | seed-evidence-U1 2026-11-19 17:21 | general |
| scope-climbs-to-enclosing-context | 1 | Check that a tool's answer is rooted at the given folder, not at an enclosing one | Code that asks git or another tool about a folder that may sit inside a larger one | seed-evidence-U1 2026-11-19 17:21 | general |
| identifier-not-unique | 1 | Build an identifier from every distinguishing part and never give undated or missing parts a shared default | Code that derives an identifier used to count or dedupe | seed-evidence-U1 2026-11-19 17:21 | general |
| escape-unaware-trim | 1 | Before removing an escape sequence, check that its escape character is not itself escaped | Code that trims or splits text holding backslash escapes | seed-evidence-U1 2026-11-19 17:21 | general |
| test-passes-when-broken | 1 | Prove a test fails when the behaviour it covers is removed | A test is written or kept for a behaviour | seed-evidence-U1 2026-11-19 17:21 | general |
| exact-match-on-drifting-value | 1 | Match a value another step writes later against the range it can fall in, not against one exact value | Code that compares a value taken at one moment with a value written at a later moment | seed-evidence-U1 re-review 2026-11-19 17:57 | general |

## Evidence

| Kind | Level | Review | Date | Finding |
|------|-------|--------|------|---------|
| identifier-form-unrecognised | 1 | seed-evidence-U1 2026-11-19 17:21 | 2026-11-19 | Reviews classified by the live flow use the form "<unit> YYYY-MM-DD HH:MM", but the script only recognised "YYYY-MM-DD HH:MM:SS", so they were not marked as seeded and would be counted twice |
| delimiter-matched-too-early | 1 | seed-evidence-U1 2026-11-19 17:21 | 2026-11-19 | A report text was cut at the first closing result tag inside it instead of the last one before the end of its notification, so findings after a quoted tag were lost |
| scope-climbs-to-enclosing-context | 1 | seed-evidence-U1 2026-11-19 17:21 | 2026-11-19 | git worktree list climbs to an enclosing repository, so a plain folder inside a git repository read that repository's transcripts |
| identifier-not-unique | 1 | seed-evidence-U1 2026-11-19 17:21 | 2026-11-19 | Identifiers dropped fractional seconds and gave every undated call the same value, so two different reviews could share an identifier and one was dropped |
| escape-unaware-trim | 1 | seed-evidence-U1 2026-11-19 17:21 | 2026-11-19 | The trailing trim stripped an escaped newline without checking whether its backslash was itself escaped, damaging the last characters of a report |
| test-passes-when-broken | 1 | seed-evidence-U1 2026-11-19 17:21 | 2026-11-19 | Tests still passed when the behaviour was removed: a root reached through a symlink |
| test-passes-when-broken | 1 | seed-evidence-U1 2026-11-19 17:21 | 2026-11-19 | Tests still passed when the behaviour was removed: a date taken from a later copy of a call |
| test-passes-when-broken | 1 | seed-evidence-U1 2026-11-19 17:21 | 2026-11-19 | Tests still passed when the behaviour was removed: show with no transcript folder |
| exact-match-on-drifting-value | 1 | seed-evidence-U1 re-review 2026-11-19 17:57 | 2026-11-19 | A review classified live was marked as already seeded only when the stored minute equalled the minute of the call, but the reviewer writes the minute later, so the review was seeded a second time |
| delimiter-matched-too-early | 1 | seed-evidence-U1 re-review 2026-11-19 17:57 | 2026-11-19 | A report was ended at the first closing notification tag, so a report quoting that tag was cut or dropped; the end must be the tag that closes the enclosing string |
| identifier-not-unique | 1 | seed-evidence-U1 re-review 2026-11-19 17:57 | 2026-11-19 | The suffix that separates undated reviews depends on the order of transcript files, so a new review in an earlier file changes the identifiers already seeded and one is seeded again |
