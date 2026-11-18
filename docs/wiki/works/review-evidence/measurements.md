# Measurements of review-evidence

What each unit of [plan.md](plan.md) measured, with how it was measured and its limits.

## review-evidence-U1: the count for R20

Measured on 2026-11-17 from the Claude Code transcripts of this repository's sessions on the owner's machine, 101 JSON Lines files with those of their subagents, read locally (review-evidence-4). Only counts, commit hashes, and commit subjects from `git log` are written here; no transcript text.

### How

1. Every tool call was listed in time order per session: a `Bash` call whose command runs `git commit`, an `Agent` call whose agent's name holds `review`, and a `Skill` call whose skill's name holds `review`.
2. Each commit command was matched to a commit of this repository by its subject, against `git log --all`. A commit counts as reviewed when a review call came after the previous commit of the same session and before it.
3. Each matched commit was classed by the paths it changes (`git show --name-only`), against R20's list in `plugins/playbook-agents/rules.md`:
   - **delivery**: it changes a plugin manifest under `.claude-plugin/`;
   - **interface others use, script or hook**: it changes a shipped script, hook, or configuration under `plugins/`, outside `evals/`;
   - **interface others use, text**: it changes a shipped skill, agent, rule, or contract text under `plugins/`, outside `evals/`;
   - not risky: anything else, such as the wiki, the cases under `evals/`, or `scripts/`.

### Result

| | Commits | Reviewed |
|---|---|---|
| Commits of this repository found in the transcripts | 108 | 13 |
| Risky by R20 | 37 | 10 |
| Delivery: a manifest | 11 | 3 |
| Interface others use: a shipped script or hook | 8 | 5 |
| Interface others use: a shipped skill, agent, rule, or contract text | 18 | 2 |
| Not risky | 71 | 3 |

27 of the 37 risky commits had no call of `review` before them. Every review found was the agent `review`, as `playbook-agents:review` or, before version 2, `playbook:review`; no call of the skill `review-change` was found.

By review-evidence-3, a change to the validator is justified when `review` did not run on a change R20 calls risky. This count shows it did not, in 27 commits, if the owner accepts the classing below.

### Risky commits

| Commit | Subject | R20 item | Reviewed before |
|--------|---------|----------|-----------------|
| `82ae054` | fix(doctor): keep the copy of the marker beside it, not in TMPDIR | interface others use (shipped script or hook) | yes, `playbook-agents:review` |
| `302bdbf` | fix(skills): align prepare-project, write-docs, init, and the two scripts with the style guide | interface others use (shipped script or hook) | yes, `playbook-agents:review` |
| `8d99c3e` | feat(playbook-wiki): add the contract and its hooks | interface others use (shipped script or hook) | yes, `playbook:review` |
| `46d2c28` | feat(playbook-wiki): check the works of a wiki | interface others use (shipped script or hook) | yes, `playbook:review` |
| `d5af090` | feat(playbook-wiki): bring a wiki to format 4 with the doctor | interface others use (shipped script or hook) | yes, `playbook:review` |
| `d7a5481` | feat(playbook-wiki): check the wiki before an agent commits a change to it | interface others use (shipped script or hook) | no |
| `8c62c54` | feat(playbook): compare the skills that are not the product's in /playbook:init | interface others use (shipped script or hook) | no |
| `94829da` | feat(playbook-wiki): show the decisions to compare before a merge | interface others use (shipped script or hook) | no |
| `b177b3c` | docs: describe version 2 and how to start it, and set 2.0.0 | delivery (manifest) | yes, `playbook:review` |
| `a00124c` | feat!: split the plugin into playbook, playbook-wiki, and playbook-agents | delivery (manifest) | yes, `playbook:review` |
| `c368900` | feat(playbook): add /playbook:init to turn the product on | delivery (manifest) | yes, `playbook:review` |
| `8e62c5d` | chore(release): 2.2.1 | delivery (manifest) | no |
| `14d3718` | chore(release): 2.1.0 | delivery (manifest) | no |
| `03ac4e5` | feat(playbook-wiki,playbook-agents): add the directory icons | delivery (manifest) | no |
| `e548a31` | docs(playbook-wiki,playbook-agents): add a README and the licence to each plugin | delivery (manifest) | no |
| `f6c9022` | chore(release): 2.2.0 | delivery (manifest) | no |
| `4b9c5f4` | chore(release): 2.2.2 | delivery (manifest) | no |
| `5fe0ac8` | feat: first public release of the playbook | delivery (manifest) | no |
| `fef053d` | feat: declare version 1.0.0 and document how releases are made | delivery (manifest) | no |
| `8a5d136` | fix(playbook-agents): align keep-minimal, review-change, and avoid-generic-design with the style guide | interface others use (shipped skill, agent, or rule text) | yes, `playbook-agents:review` |
| `4c26efc` | feat(playbook-wiki): accept a unit by its evidence or by the owner's judgement | interface others use (shipped skill, agent, or rule text) | yes, `playbook:review` |
| `9cd9c1a` | fix(skills): name the requests that missed review-change and keep-minimal | interface others use (shipped skill, agent, or rule text) | no |
| `8862bfc` | fix(prepare-project): add a gotcha for a closing line that asks two things | interface others use (shipped skill, agent, or rule text) | no |
| `fae1512` | fix(review-change): ask the session to show the report unchanged | interface others use (shipped skill, agent, or rule text) | no |
| `beb21ba` | feat(playbook-wiki): recommend a version when a work closes | interface others use (shipped skill, agent, or rule text) | no |
| `428758e` | feat(playbook-wiki): the doctor trims a moved state section that is too long | interface others use (shipped skill, agent, or rule text) | no |
| `f06dba1` | feat(playbook-agents): adopt the best practices for skills in write-skill and its style guide | interface others use (shipped skill, agent, or rule text) | no |
| `72ababd` | test(playbook-agents): add the cases of behaviour of write-skill | interface others use (shipped skill, agent, or rule text) | no |
| `cc1e19f` | test(playbook-agents): run the cases of write-skill with playbook-wiki, and add its first gotcha | interface others use (shipped skill, agent, or rule text) | no |
| `a3e6638` | fix(init): record a choice about a project skill only in the open work | interface others use (shipped skill, agent, or rule text) | no |
| `bb4e7d0` | test(skills): run the cases with their scaffold, and drop graders that expect the wiki before the first answer | interface others use (shipped skill, agent, or rule text) | no |
| `d058c9e` | docs(write-skill): record what the second run of U6 taught about cases of behaviour | interface others use (shipped skill, agent, or rule text) | no |
| `82f6f40` | test(skills): fix the cases of behaviour after the second run, and two skill faults they found | interface others use (shipped skill, agent, or rule text) | no |
| `531ffb4` | feat(review-change): place the intent sentence and drop passing cases from the report | interface others use (shipped skill, agent, or rule text) | no |
| `dfd4b7f` | fix(prepare-project): take the gotcha's example from a domain no case uses | interface others use (shipped skill, agent, or rule text) | no |
| `4580d35` | feat(playbook-wiki): define format 4 of a wiki in format.md | interface others use (shipped skill, agent, or rule text) | no |
| `b6ca3b6` | feat(playbook-wiki): prepare a project one work at a time | interface others use (shipped skill, agent, or rule text) | no |

### Limits

- 257 commit commands were found; 143 did not match a commit of this repository: commits in the temporary repositories of tests and fixtures, such as "feat: invoicing app"; commands whose message could not be read; text that only mentions `git commit`; and commits of the history before 2026-11-14, kept in the private `andresfrei/playbook-archive`. The count covers the 108 that matched.
- A review in another session than the commit, or a `/code-review` typed by the owner, is not a tool call of the session and is not counted.
- A review that came before a commit may have read another change than that commit.
- Classing by path is a judgement: whether a change to a skill's text is "an interface others use" is for the owner to accept.

## review-evidence-U2: the trial

Run on 2026-11-17 with Claude Code 2.1.327, when the owner asked ("listo"), on the seeded diff `dash`: a commit titled as a refactor of `plugins/playbook-wiki/merge-step.sh` that drops the arm `-)` of `case $ref in -) ;; -*) exit 0 ;; esac`, so a ref of `-`, the previous branch, exits with no output. One run of each reviewer:

- The two cases, from `plugins/`: `claude plugin eval . --tag review-evidence --runs 1 --ablation none --scaffold --keep-temp --model opus --allow-tools Bash --max-cost-usd 3 --no-publish --trust-plugin --json <file>`.
- The run with the rule: `bash plugins/playbook-agents/evals/review-evidence/run-rule.sh plugins/playbook-agents/evals/review-evidence/dash-code-review 1 <folder> 2`, with `CLAUDE_CODE_OAUTH_TOKEN` read from the owner's file.

### Cost of one run

List-price estimates reported by each run:

| Reviewer | Cost (USD) | Duration |
|----------|-----------|----------|
| `review-change` (eval) | 0.16 | 32 s |
| `/code-review` alone (eval) | 0.20 | 33 s |
| `/code-review` with the rule (`claude -p`) | 0.27 | 43 s |

Total of the trial: USD 0.64. A first eval run loaded no case and a first run with the rule failed at login; neither cost anything (see below).

### The four points that were not verified

| Point | Answer | Evidence |
|-------|--------|----------|
| A case's prompt can call `/code-review` and a plugin's skill by name | Yes | The traces show the turns of each reviewer marked `forked-command-code-review` and `forked-command-playbook-agents:review-change`. The grader `tool_used: Skill` does not see such a call, since no `Skill` tool runs: it failed with "Skill called 0x" and was removed |
| `fixture.sh` finds this repository from its own path | Yes | Both cases reviewed the seeded commit; `build.sh` finds the repository as `$(dirname "$0")/../../../../..` |
| An empty `CLAUDE_CONFIG_DIR` loads nothing of the owner's | Yes | The `init` event of the run with the rule lists the plugins `cc-plugin-agents-md`, `cc-plugin-telemetry`, `cc-plugin-privacy`, and `cc-plugin-plugin-authoring`, which the eval cases also list, no MCP server, only the built-in agents, and the auto memory under the empty folder; none of the owner's plugins, such as Engram or the playbook, and the clone under `/tmp` |
| `--max-budget-usd` caps a run on a plan | Not shown | The run reports `total_cost_usd` 0.27, under the ceiling of 2, so the cap was never reached. The ceiling of U4 also rests on the number of runs and the owner's order |

### What else the trial showed

- All three reviewers found the seeded defect, with the line, a failing case, and the tests in `scripts/verify_test.sh` that would fail.
- Only `/code-review` with the rule reported that the change contradicts the wiki: `docs/wiki/05-plan/plan-phase-4.md` records "`git merge -` was ignored" as a defect fixed in U35. It read `docs/wiki/README.md` to find the page, as the rule asks.
- `/code-review` alone, in the eval, wrote "Only the repo-root `CLAUDE.md` applies", though no `CLAUDE.md` loads there: it read the file itself.
- Run against `plugins/playbook-agents`, the eval refuses a case that loads `playbook-wiki`, outside that folder; it runs from `plugins/`, and then writes its report to `plugins/evals/results/`, now in `.gitignore`.
- The token file held the marker `[200~` that a terminal adds to a paste; it is removed when the token is read.

### Ceiling proposed for U4

Seven diffs, three runs each, at the costs above: about USD 13. Proposed: `--max-cost-usd 12` for the fourteen cases, and `--max-budget-usd 1` for each of the 21 runs with the rule, about USD 6 expected; together under USD 20. The owner approves it before U4 (review-evidence-5).
