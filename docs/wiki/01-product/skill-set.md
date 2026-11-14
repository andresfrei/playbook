# Skill set

Which job each skill does and who owns it in each phase (D30). One job, one skill (F3). The split is Decided (D6 for phase 1, D28 for phase 2), and so are the phase 1 rows (D33).

## Phase 1 — the product improves these

gentle-ai's instructions do not call these by name, so the product can own them now without leaving two skills for one job.

| Job | Product skill | Starting material |
|-----|---------------|-------------------|
| Prepare a project before code, new or already started | One skill, one reference file per stage | `project-groundwork` and its known defects, the four ideas of D19, the method for a started project (D35) |
| Write and audit skills | One skill with the style guide | `skill-creator`, `skill-improver` |
| Write documentation | One skill | `cognitive-doc-design` |
| Keep an implementation minimal, and review for excess | One skill | `minimal-correct-implementation`, `overengineering-review` |
| Avoid generic visual design | One skill | `anti-generic-design` |

The product also carries the rules, in `plugin/rules.md` (D50), outside the blocks gentle-ai generates.

## Phase 1 — gentle-ai keeps these

| Job | Provided by | Known problem, recorded for phase 2 |
|-----|-------------|--------------------------------------|
| Execute a task | gentle-ai's ODD | About 12,000 words always loaded; delegation rules written twice |
| Review a change | gentle-ai's review lifecycle, `judgment-day` | Its detail loads in every session |
| Plan commits | `work-unit-commits` | Repeats the global instructions |
| Split large pull requests | `chained-pr` | Treats 400 lines as a hard gate, against D14 |
| Open a pull request | `branch-pr` | Encodes rules of the Gentle AI repository |
| Index skills | `skill-registry` | Broken reference paths |
| Write review comments | `comment-writer` | Not audited |

The owner's differences with these go in the rules until phase 2.

## Phase 2 — the product takes over

Every job in the second table except indexing skills, which is discarded (D52), with its own methodology layer (D28). gentle-ai is the source of concepts, not a structure to copy, and its full set of tools is not a requirement (D31). Executing a task is done by short rules in `plugin/rules.md`, not by a skill (D65). Reviewing a change is one plain skill, `review-change`, which runs in a separate context on the `review` agent (D66, TD10), and commits stay as rules R13 and R15 (D66). Splitting large pull requests is dropped (D66). Opening a pull request and writing review comments get no skill until a project needs one (D67). The full table is in [phase-2.md](phase-2.md).

## Outside a phase

| Job | Product skill | Why it is a skill of its own |
|-----|---------------|------------------------------|
| Repair a project's wiki after the format of a wiki changed | `doctor`, which only the owner starts (D139, D141) | No other skill does this job (F3). Its description is not loaded at session start, so it costs no words there. The design is in [wiki-maintenance.md](wiki-maintenance.md) |

## Never in the product

- Memory and the map of the code: Engram and CodeGraph (D25). The product states only when to use each and what belongs in memory (F11).
- The SDD project-start family (D12, D18), skills for one project (D13), and the video skills (D17).
- Skills that encode the gentle-ai repository's own rules: `rdd-defect-workflow`, `gentle-ai-bench`, `systemic-issue-triage`, `issue-creation`.
- `gadu-orchestrate` and the GADU agent (the owner's personal content, D29), `knowledge-ingestion` (memory tooling), and `go-testing` (a technology skill, added per project in stage 3): D37. See ../02-current-state/unplaced-skills.md (kept in the private archive).
