# Phase 2: replacing gentle-ai

Phase 2 makes the product do every job gentle-ai does today for the owner, so that gentle-ai can be removed from the owner's Claude Code (D28, D30). It is prepared with the product's own method, through the six stages again (D63).

This page is the product definition for phase 2. Status: accepted by the owner when stage 1 of phase 2 was closed (D71). No question about phase 2 is Open.

## Decided

- The product has its own methodology layer and does not depend on gentle-ai. It depends only on Engram and CodeGraph. It owns every job, including execution, commits, and pull requests (D28).
- gentle-ai is taken as a concept, not as a structure to copy. Only the tools that earn their place are kept (D31).
- The product is adapted to Claude Code with Anthropic's models. Other tools are considered only when the product is ready, and only if needed (D57).
- Two concepts are kept: the effort is scaled to the task, and the model is chosen per task (D57).
- The skill registry is left out (D52).
- Phase 2 solves four problems, and each is a criterion for what stays (D64): weight (used in real work, and short), control (written and understood by the owner), cost (each job states its effort and model), and method (one workflow, the product's).
- The workflow for everyday work is a few always-loaded lines in `plugin/rules.md` plus skills that load on demand for the jobs not done in every request (D65).
- The product writes no skill for pull requests, review comments, or issues until a project needs one (D67).
- The overlay is retired from the owner's Claude Code as a whole; its repository is not changed (D68).
- The machine moves in two steps: a trial without gentle-ai in a separate environment, then the switch of the main installation with a backup (D69).
- The persona is the owner's own file, outside the product (D70).
- The owner is the only user for now ("la idea de playbook es optimizar mi herramienta de trabajo para mi y mi uso, al menos en la etapa de hoy").

## Topics

How much the decisions above cover of each topic a product definition needs.

| Topic | Coverage | What is missing |
|-------|----------|-----------------|
| The problem, and who has it | Covered | D64 |
| Who uses it | Covered | |
| Main flows | Covered | Where the workflow lives (D65) and which concepts it holds (D66). The text of each rule is written in stage 6 |
| What it must do | Covered | The concepts (D66). No skill for pull requests, review comments, or issues (D67) |
| What it must not do | Covered | The five concepts dropped by D66 |
| Qualities | Covered | Lower cost (D57), and the size limits of the [style guide](style-guide.md): 500 words for the rules file and 800 for everything loaded at session start (D48) |
| Limits | Covered | Claude Code, Anthropic's models, Engram, CodeGraph |
| Outside systems | Covered | Engram and CodeGraph stay (D28). The overlay is retired from Claude Code (D68) |
| Volume | Not applicable (D71) | One user, one machine |
| Who runs and maintains it | Covered | The owner |
| How the machine moves | Covered | A trial in a separate environment, then the switch with a backup (D69). The mechanism is decided in stage 2 |
| Rules, states, vocabulary | Covered | Phase, stage, and unit are in the [glossary](glossary.md) |

## Concepts

What each concept of the inventory (kept in the private archive) becomes, by the four criteria of D64. Decided as one table (D66); the persona by D70.

| # | Concept | Decision | Reason |
|---|---------|----------|--------|
| 1 | Change authorization | Keep, as one rule | Short, and it prevents an unrequested change |
| 2 | Task size | Keep, shorter | It is "effort scaled to the task" (D57) |
| 3 | High-risk list | Keep, shorter | It decides when a second reader is worth its cost |
| 4 | Feature document | Drop | The plan's unit in the wiki is the document; the copy in Engram is the same fact twice |
| 5 | Test first | Keep R11 as it is | Already the owner's rule |
| 6 | Delegation rules | Keep, shorter, with the model named per job | D57; used in phase 1 |
| 7 | Edit surfaces | Keep, as one line of the delegation rule | Needed only when two agents write at once |
| 8 | Commits by unit | Keep R13 and R15 as they are | Already the owner's rules |
| 9 | Chained pull requests | Drop | Not used; no remote |
| 10 | Review with receipts | Drop, and write one plain review skill | Turned off by the owner; about half of the longest section |
| 11 | Defect report to gentle-ai | Drop | Has no meaning without gentle-ai |
| 12 | Blocking questions kept whole | Drop | R3 and the question dialog cover it |
| 13 | Language of artifacts | Keep R1 as it is | Already the owner's rule |
| 14 | Skill registry | Out | D52 |
| 15 | CodeGraph first | Keep, as one rule | The product depends on CodeGraph (D28) |
| 16 | Engram protocol | Keep, as one rule on what belongs in memory | Engram's plugin brings its own protocol (tooling.md (kept in the private archive)) |
| 17 | Remote authorization | Keep, as one rule | Short, and it prevents an action that cannot be undone |
| 18 | Working rules | Keep R3, R4, R13 as they are | Already the owner's rules |
| 19 | Persona | Kept as the owner's own file, outside the product (D70) | The output style is the owner's taste, not a method |

## What is missing

What separates this definition from what exists today (gentle-ai-layer.md (kept in the private archive)). Each line becomes work in the plan of stage 5.

- Eight new short rules in `plugin/rules.md` (D66). The file is 305 words today and its limit is 500, so the eight share about 195 words.
- The rule on delegation names a model per job (D57). Which model for which job is not defined yet; it is decided in stage 2.
- One plain review skill (D66).
- A rule in `prepare-project` for a new phase (Q37).
- A separate environment where the product runs without gentle-ai (D69). How it is made is decided in stage 2.
- The switch of the main installation, with a backup: the five sections gentle-ai writes in `~/.claude/CLAUDE.md`, its 5 hook commands, its skills and agents, and the skills D61 deferred (D69).
- The retirement of the overlay from Claude Code: 8 hook commands, the `longterm-mem` server, and its skills (D68).
- The persona saved as the owner's own file before gentle-ai is removed (D70).

Not verified, and needed before the switch: what `gentle-ai sync` puts back, and whether Engram and CodeGraph keep working once gentle-ai's sections are gone, since two of those sections tell the agent how to use them.

## Open

Nothing. Q37 was answered by D79.
