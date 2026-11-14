# Plan

Stage 5 of the method (D8): the work plan for phase 1 of the product (D30). The owner accepted it (Decided: D46), including the word "unit" for one step of the plan (see the [glossary](../01-product/glossary.md)).

The ten units are done and phase 1 is closed (D61). What was left out is under "Deferred".

## Progress

| Unit | Status | Evidence |
|------|--------|----------|
| U1 | Done 2026-11-13 | D48; [../01-product/style-guide.md](../01-product/style-guide.md) |
| U2 | Done 2026-11-13 (D49) | Commit `465db4c`. `claude plugin validate` passes on the marketplace and the plugin; `scripts/verify.sh` exits 0; its eight test cases pass, one per limit; `shellcheck` reports nothing |
| U3 | Done 2026-11-13 (D49) | Commit `283844f`. 305 words against the limit of 500; the hook's command prints the file unchanged; the 17 rules matched the wiki's text word for word before D50 removed that copy |
| U4 | Done 2026-11-13 (D54, D55) | `claude plugin marketplace add <clone>` and `claude plugin install playbook@playbook --scope user` both succeeded. `claude plugin list` shows it enabled, at user scope, read from the clone's `plugin/` folder. A new session in an empty folder, with no flags, reported the rules block once and quoted R3 word for word |
| U5 | Done 2026-11-13 (D56, D58) | Skill `write-skill`: body 492 words, description 182 characters. `scripts/verify.sh` passes at 337 words loaded at session start. Both evaluation cases pass: `claude plugin eval plugin --tag write-skill --max-cost-usd 2 --no-publish`, exit 0, 12 runs, 1.50 USD |
| U6 | Done 2026-11-13 (D56, D58) | Skill `prepare-project`: body 633 words, description 197 characters, one reference file per stage (178 to 666 words). Both cases pass, 3 of 3 runs each, 0.83 USD |
| U7 | Done 2026-11-13 (D56, D58) | Skill `write-docs`: body 584 words, description 197 characters, no reference file. Both cases pass, 3 of 3 runs each, 0.44 USD |
| U8 | Done 2026-11-13 (D56, D58) | Skill `keep-minimal`: body 612 words, description 202 characters, no reference file. Both cases pass, 3 of 3 runs each, 0.43 USD |
| U9 | Done 2026-11-13 (D56, D58) | Skill `avoid-generic-design`: body 485 words, description 226 characters, one reference file (588 words). Both cases pass, 3 of 3 runs each, 0.66 USD. An earlier run failed only because two runs hit the account's usage limit (0.31 USD) |
| U10 | Done 2026-11-13 for what could be done; the rest is Deferred (D59, D60, D61) | Inventory in ../02-current-state/removal-map.md (kept in the private archive). Eleven skills moved to the archive folder; a new session no longer lists them. The unit's ending condition, one skill per job, is not met: `skill-creator`, `skill-improver`, `cognitive-doc-design`, and `anti-generic-design` stay installed next to the product's skills. Deferred: the skills installed by the overlay (a piece of work in that repository) and by gentle-ai, with the registry hook (phase 2) |

## How every unit works

- A unit delivers one thing and ends on a condition that can be observed (F8).
- The owner reviews each unit when it ends, before the next one starts (R10).
- A unit is one or more commits on a feature branch. Push and merge are the owner's decisions (R14).
- From U5 on, a unit is built in its own git worktree under `~/dev/playbook-worktrees/`, and tested there with `claude --plugin-dir`. The clone stays on `main`, because the installed plugin is read from it (TD5).
- Execution uses gentle-ai's ODD (D16) and the working skills of D43.

## Units

| # | Unit | Delivers | Ends when |
|---|------|----------|-----------|
| U1 | Style guide and size limits | One page with the format of a skill and of the rules file, and four limits: the rules file, a skill file, a skill description, and everything loaded at session start | The owner accepts the format and the four numbers, and they are recorded as a decision |
| U2 | Plugin skeleton and verify script | The marketplace manifest, the plugin manifest, the `SessionStart` hook, and one shell script that runs `claude plugin validate` and the limits of U1 | `claude plugin validate` passes; the script exits 0 on the skeleton and non-zero on a file over a limit; `shellcheck` reports nothing |
| U3 | Rules file | R1–R17 as the plugin's rules file | The verify script passes; running the hook's command by hand prints the file unchanged |
| U4 | Install on the owner's machine | The marketplace added from the local clone and the plugin installed for all projects | A new session in another project shows the rules in its context. Starts only when the owner asks for it |
| U5 | Skill: write and audit skills | The skill with the style guide of U1, and its two evaluation cases | See "When a skill unit ends" |
| U6 | Skill: prepare a project | The six stages for a new project and for one already started (D8, D15, D19, D35), without the defects listed in ../02-current-state/audit-findings.md (kept in the private archive) | Same |
| U7 | Skill: write documentation | The skill and its cases | Same |
| U8 | Skill: keep an implementation minimal and review for excess | The skill and its cases | Same |
| U9 | Skill: avoid generic visual design | The skill and its cases | Same |
| U10 | Remove what the product replaces | For each job the product now owns, the older skills for that job removed at the source that installs them (D40, F3), together with the removals of D12, D13, and D18, and the hook that generates the skill registry (D52, D53) | The skill list of a new session shows one skill per job. Each removal needs the owner's authorization, and Q25 answered |

## When a skill unit ends

1. The verify script passes.
2. Its two evaluation cases pass: one request that must trigger the skill and one that must not (TD4).
3. The owner has reviewed it.

U6 to U9 are written with the skill of U5, not with the installed `skill-creator`.

## Why U4 comes early

The owner's stated goal is to apply the playbook globally in Claude Code. Installing right after the rules file exists means the rules are used in real work from then on, and each skill appears as soon as it is finished, because the installation loads from the local clone (TD1). The cost: until U10, the rules load next to gentle-ai's global instructions, which state several of them too.

## Decided inside the units, not here

- The four numbers of U1.
- The cost ceiling for an evaluation run. Measured in U5: two cases at the default three runs per arm cost 1.50 USD, and 0.82 of it went to the arm that runs without the plugin, which cannot pass a trigger case. From U6 on a skill's cases run with `--ablation none --max-cost-usd 1 --no-publish`. `--no-publish` keeps the report on this machine. The whole suite, ten cases with the five skills loaded together, was run once on 2026-11-13 with `claude plugin eval plugin --ablation none --max-cost-usd 4 --no-publish -j 3`: all ten passed, 3 of 3 runs each, 3.25 USD. Evaluation runs for U5 to U9 cost 7.42 USD in total.

## Not in this plan

- Phase 2 (D28): replacing gentle-ai.
- The questions about the owner's machine that U10 does not need: Q10, Q16, Q17, Q20, Q22.
- The final name and the version scheme (Q24, Q30), which wait until someone else installs the product.

## Notes from the units

- U3 was built before the owner reviewed U2, against the order stated above. The owner reviewed and accepted both together (D49). Nothing is installed.
- The text of R1–R17 existed twice after U3. D50 made `plugin/rules.md` the only place; [../01-product/rules.md](../01-product/rules.md) keeps the source and decision of each rule.
- The validator's remaining warnings are deliberate: no version (TD3), and no licence or icon, which only the public plugin directory requires (D29).
- Receipt-driven development is off on this machine, so no native review ran on these commits.
- The hook was tested in a real session on 2026-11-13, at the owner's request and without installing the plugin: `claude --plugin-dir <plugin folder> -p <question>` in an empty folder. With the plugin, the session reported the rules block once and quoted R12 word for word. Without it, the same question got "NONE".
- A resumed session was tested the same way on 2026-11-13: one session started with the plugin, then resumed with `--resume`. The resumed session reported the rules block once, from the first start, and none added by the resume. This is the session's own report of its context, not a reading of the transcript.

- U4 changed two things in `~/.claude/settings.json`: the plugin is enabled, and the marketplace is declared with the clone's path. To undo: `claude plugin uninstall playbook@playbook`, then `claude plugin marketplace remove playbook`. Both commands exist in the installed version; they were not run.
- The plugin is read in place. Tested on 2026-11-13: a marker line added to `plugin/rules.md` in the clone appeared in the next new session, and the file was then restored. So whatever is checked out in the clone is what every session loads, including a unit that is half built on its branch. TD5 answers this with a worktree per unit.
- From U4 on, the rules load next to gentle-ai's global instructions, which state several of them too. This lasts until U10.

## For the owner's review of U5 to U9

Each skill was written by a separate agent from the decisions in this wiki. Where no decision covered a point, the agent wrote the minimum and reported it. The owner accepted these points as written (D58), except the first one of `prepare-project`, which was changed: the skill now asks with the `AskUserQuestion` tool when it is available. A point that fails in real use is corrected by a later decision.

| Skill | Point the owner has not decided |
|-------|----------------------------------|
| `write-skill` | It says "Run a paid evaluation only when the owner asks", derived from TD4 |
| `write-skill` | An audit of an existing skill does not report missing evaluation cases; only a new skill gets them |
| `write-skill` | When a skill is not in a Claude Code plugin, its two requests go in the report to the owner |
| `prepare-project` | It names no question tool; it keeps the wording of R3, because D11 allowed nothing exclusive to one tool. D57 now allows naming Claude Code's question dialog |
| `prepare-project` | Stage 4 says to propose the visual identity, but not how or where it is shown |
| `prepare-project` | The owner's closing of a stage is what opens the next one. This follows D41 to D47, not a numbered decision |
| `prepare-project` | Wiki folder names (`01-product` to `06-plan`, with `05-design-system`) and unit statuses (Not started, Built, Done) come from this repository's practice |
| `prepare-project` | Stages 3 and 4 hold the minimum: a skill per decided technology; identity, tokens, and patterns |
| `prepare-project` | It also loads when the owner asks to continue or close a stage of a wiki that has a stage table |
| `write-docs` | Status marks (Decided, Proposed, Open) apply only where a document records what was chosen, and evidence only next to claims a reader may need to check |
| `write-docs` | One topic per page, an opening sentence, tables for comparisons, and a last "Not verified" section come from this wiki's pages, not from a decision |
| `write-docs` | Whether wiki pages written during project preparation use this skill or `prepare-project` is not decided |
| `keep-minimal` | Its description starts with "Write or change code", so it loads on most coding tasks. This matches the job as decided, but how often it loads was not measured |
| `keep-minimal` | The five kinds of excess it lists are the agent's reading of R9 and D40 |
| `keep-minimal` | A review returns a report only; whether it may also change the code is not decided |
| `keep-minimal` | "Deferred" items go in the work summary, not in a file |
| `avoid-generic-design` | The catalogue holds only the four patterns named in the job; whether it grows is open |
| `avoid-generic-design` | In a review it changes nothing; with a project design system it skips the catalogue |
| `avoid-generic-design` | It cites R8 and R9 by number, so renumbering the rules file would leave them stale |
| All five | Until U10, an older skill with the same job stays installed next to each. An evaluation run loads only the plugin, so it does not measure that overlap |

## Deferred

Left out of phase 1 by D61. The lists and the evidence are in ../02-current-state/removal-map.md (kept in the private archive).

| What | Why it could not be done | Where it goes |
|------|--------------------------|---------------|
| Removing `skill-creator`, `skill-improver`, `cognitive-doc-design`, and the hook that generates the skill registry | gentle-ai installs them and has no way to leave one out; a sync puts them back | Phase 2, with the move away from gentle-ai (Q22) |
| Removing the skills the overlay installs at their source | It is a refactor of another repository, whose deploy pushes to its remote. Seven were archived on the installed copies instead (D62); `anti-generic-design`, `gadu-operator`, and `chat-thread-analyzer` stay installed | The decision about the overlay's future (Q10) |
| Placing the three Genesis skills in the Genesis repository | It is work in that repository (D60) | Outside this plan |

## Not verified

- Whether `gentle-ai sync` can leave a skill out. U10 depends on it for the skills gentle-ai installs.
- Whether the rules are printed again after a conversation is compacted. The hook has no matcher, so it should run on every kind of session start; only a new session and a resumed one were tested.

## What the phase left

- Eighteen older skills were moved to `~/.claude/skills-archive/2026-11-13/` (D59, D60, D62).
