# Skill set

Which job each skill does, and which plugin holds it. One job, one skill (D6, F3). The split between the plugins is TD30.

## The skills

| Job | Skill | Plugin | Loads |
|-----|-------|--------|-------|
| Start the product in a repository, or change what is on: what to use, where, the skills that do the same job, and a wiki where none exists | `init`, the command `/playbook:init` (D184, D193, TD31, setup-commands-1, setup-commands-5, setup-commands-6) | `playbook` | Only when the person types it (setup-commands-9) |
| Add only a wiki's skeleton to a repository that has none, with no work | `init`, the command `/playbook-wiki:init` (setup-commands-1, setup-commands-2) | `playbook-wiki` | Only when the person types it (setup-commands-9) |
| Prepare a project or a work before code, through the six stages | `prepare-project` (D203) | `playbook-wiki` | When a request matches its description |
| Bring a project's wiki to the present format | `doctor` (D141, D207) | `playbook-wiki` | Only when the person types `/playbook-wiki:doctor` |
| Write documentation, and record a changed definition | `write-docs` | `playbook-wiki` | When a request matches its description |
| Set the model and the effort of the agents `explore`, `write`, and `review`, for one repository or every project, in Claude Code only | `config`, the command `/playbook-agents:config` (setup-commands-1, setup-commands-4, setup-commands-7) | `playbook-agents` | Only when the person types it (setup-commands-9) |
| Keep an implementation minimal, and review a change for excess | `keep-minimal` | `playbook-agents` | When a request matches its description |
| Review a change for defects, in a separate context on the `review` agent | `review-change` (D66, TD10) | `playbook-agents` | When a request matches its description |
| Write and audit skills | `write-skill` | `playbook-agents` | When a request matches its description |
| Avoid generic visual design | `avoid-generic-design` | `playbook-agents` | When a request matches its description |

When `prepare-project` closes a work in a project that has a version tag in git, it recommends whether the work needs a new version and which one, by the project's own rule or else Semantic Versioning, and asks; on a yes it records the version and lists the release steps, and makes the release only when asked (version-on-close-1, version-on-close-2, version-on-close-3, version-on-close-5).

A person with `playbook-wiki` alone gets its four skills and none of `playbook-agents` (D182). `review-change` names its agent as `playbook-agents:review`.

Jobs with no skill: executing a task and committing are rules of `playbook-agents` (D65, D66); splitting large pull requests is dropped (D66); opening a pull request and writing review comments get a skill only when a project needs one (D67); indexing skills is discarded (D52).

## Never in the product

- Memory and the map of the code: Engram and CodeGraph (D25). The product states only when to use each and what belongs in memory (F11).
- The SDD project-start family (D12, D18), skills for one project (D13), and the video skills (D17).
- Skills that encode the gentle-ai repository's own rules: `rdd-defect-workflow`, `gentle-ai-bench`, `systemic-issue-triage`, `issue-creation`.
- `gadu-orchestrate` and the GADU agent (the owner's personal content, D29), `knowledge-ingestion` (memory tooling), and `go-testing` (a technology skill, added per project in stage 3): D37. See ../02-current-state/unplaced-skills.md (kept in the private archive).

## Before phase 4

Kept as a record of how the jobs were split in phases 1 and 2, with the paths of then. D33 decided the rows of phase 1.

### Phase 1 — the product improves these

gentle-ai's instructions do not call these by name, so the product can own them now without leaving two skills for one job.

| Job | Product skill | Starting material |
|-----|---------------|-------------------|
| Prepare a project before code, new or already started | One skill, one reference file per stage | `project-groundwork` and its known defects, the four ideas of D19, the method for a started project (D35) |
| Write and audit skills | One skill with the style guide | `skill-creator`, `skill-improver` |
| Write documentation | One skill | `cognitive-doc-design` |
| Keep an implementation minimal, and review for excess | One skill | `minimal-correct-implementation`, `overengineering-review` |
| Avoid generic visual design | One skill | `anti-generic-design` |

The product also carries the rules, in `plugin/rules.md` (D50), outside the blocks gentle-ai generates.

### Phase 1 — gentle-ai keeps these

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

### Phase 2 — the product takes over

Every job in the second table except indexing skills, which is discarded (D52), with its own methodology layer (D28). gentle-ai is the source of concepts, not a structure to copy, and its full set of tools is not a requirement (D31). Executing a task is done by short rules in `plugin/rules.md`, not by a skill (D65). Reviewing a change is one plain skill, `review-change`, which runs in a separate context on the `review` agent (D66, TD10), and commits stay as rules R13 and R15 (D66). Splitting large pull requests is dropped (D66). Opening a pull request and writing review comments get no skill until a project needs one (D67). The full table is in [phase-2.md](phase-2.md).

### Outside a phase

| Job | Product skill | Why it is a skill of its own |
|-----|---------------|------------------------------|
| Repair a project's wiki after the format of a wiki changed | `doctor`, which only the owner starts (D139, D141) | No other skill does this job (F3). Its description is not loaded at session start, so it costs no words there. The design is in [wiki-maintenance.md](wiki-maintenance.md) |
