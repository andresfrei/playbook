# Architecture of the work seed-evidence

## The problem

A repository with past reviews starts with an empty evidence page. The reviews are in the person's Claude Code transcripts; this work turns them into evidence with one command, the person choosing what goes in.

## Requirements and assumptions

- A command only the person starts, inside the repository (seed-evidence-2).
- A preview with date and findings of each review, every review with findings chosen by default (seed-evidence-3, -4).
- One run of `classify` per review, in order, the count shown first (seed-evidence-5).
- POSIX `sh` and `awk` (seed-evidence-7).
- Assumed: transcripts are JSON lines, one event per line, as on 2026-11-19; their shape is not a documented interface.

## The shape

```text
/playbook-agents:seed-evidence
  └─ seed-reviews.sh list <repo>   → numbered reviews: date, findings or "No findings."
  └─ the person chooses            → default: every review with findings
  └─ seed-reviews.sh show <repo> N → the text of review N
  └─ classify, once per review     → rows in <repo>/docs/wiki/evidence.md
```

## Modules

| Module | Responsible for | Does not | Used by |
|--------|-----------------|----------|---------|
| `seed-reviews.sh` (`playbook-agents`) | Finds the transcript folders of the repository and its worktrees; lists its reviews; prints one review's text and identifier | Write any file; call a model | The command |
| The skill `seed-evidence` (`playbook-agents`, `disable-model-invocation: true`) | Runs the script, shows the preview and the count of runs, asks, starts `classify` per review in order, reports the `count` at the end | Classify itself; consolidate | The person |
| `classify` (from repeated-corrections) | Stores one review's findings | Change | The command |

## Main data

A review: the transcript it came from, its call's identifier, its date, and its report. The identifier given to `classify` is the date and time of the call, so a review seeded twice is stored under the same identifier and counted once.

## Outside systems

The transcripts of Claude Code under `~/.claude/projects/` or `$CLAUDE_CONFIG_DIR/projects/`: not a documented format, kept for about 30 days (recalled). Critical: if their shape changes, the list comes back empty.

## Risks

| Risk | What reduces it |
|------|-----------------|
| The transcript shape changes | Tests on lines of the real shape; an empty list says so instead of seeding nothing silently |
| A review seeded twice | The identifier is the call's date and time; the preview marks reviews already in the page |
| A review resumed after its session restarted: its notice of the end carries no call identifier, so it is not listed | Known limit, seen on 2026-11-19; its findings, when stored live, are on the page already |
| A stale finding | The person leaves it out in the preview |
| Private text reaches a public repository | The page is in the repository where the command runs; `classify` writes one general line per finding |

## Trade-offs

- `sh` and `awk` over a JSON parser: no dependency, at the cost of a fragile reader.
- One run per review: `classify` unchanged, at the cost of more runs.

## Discarded alternatives

- `python3`: a dependency missing on some machines (seed-evidence-7).
- Classifying in the main agent: the criteria live in `classify` (repeated-corrections-27).

## How it can evolve

Codex transcripts, when `classify` exists there; a seed for memory or lint, when those become sources.
