# Technology of review-evidence

What the work needs from its technology, from [definition.md](definition.md), and what is proposed for each need. Stage 2. No new dependency: the work uses `claude plugin eval`, as [../../03-technology/skill-evaluation.md](../../03-technology/skill-evaluation.md) describes, and `jq` for the transcripts.

## What was checked

On 2026-11-17:

- `claude --version`: 2.1.327. `jq`, `bwrap`, and `socat` are installed (`command -v`), so a case may grant `Bash` under the sandbox.
- [Review locally with /code-review](https://code.claude.com/docs/en/code-review-local.md): `/code-review` is a bundled skill; it takes an effort level, `low` to `max`, and a target such as a range of commits (`abc1234^..abc1234`); in a `-p` run it runs in the foreground and reports its findings as text in the reply; it follows `CLAUDE.md`; it counts against the plan's usage or the API bill like the rest of the session.
- `claude --help`: `--bare` reads only `ANTHROPIC_API_KEY` or an `apiKeyHelper` as its Anthropic login, so it does not run on the owner's plan, which has no API key (review-evidence-10). `--max-budget-usd` is described as a "maximum dollar amount to spend on API calls" in a `--print` run.
- [Environment variables](https://code.claude.com/docs/en/env-vars.md): `CLAUDE_CONFIG_DIR` overrides the configuration folder, where "all settings, session history, and plugins are stored"; `CLAUDE_CODE_OAUTH_TOKEN` is an OAuth token for a claude.ai login. [Authentication](https://code.claude.com/docs/en/authentication.md): `claude setup-token` opens the browser login and prints a one-year token, saved nowhere.
- Recorded in phase 2 for TD12, on Claude Code 2.1.323: with `CLAUDE_CONFIG_DIR` set to another folder, a session in a project under the home folder still loads `~/.claude/CLAUDE.md`, because Claude Code reads `.claude/CLAUDE.md` in every parent folder of the project; `claudeMdExcludes` in settings, also through `--settings`, removes it; skills, agents, hooks, and MCP servers did not leak. What a session loads shows in the `init` event of `claude -p --output-format stream-json --verbose`. Not run again on 2.1.327.
- [Plugin evaluations](https://code.claude.com/docs/en/plugin-evals.md): a case's `context.scaffold_script` runs as the owner, outside the sandbox, before the agent starts, only with `--scaffold`, with 120 seconds and a minimal environment; "no `.claude/` directory, `CLAUDE.md`, or `.mcp.json` loads from above the workspace or inside it"; `--ablation none` runs one arm; `--max-cost-usd` is a ceiling on the list-price estimate, checked before each run starts.
- The transcripts of this repository's sessions are JSON Lines files; `jq` lists each tool call by name from `.message.content[] | select(.type=="tool_use")`, which shows the calls of `Agent`, `Skill`, and `Bash` (read on one transcript).

## Needs already met

The technology of the earlier works stays as it is; it is not decided again:

| # | Need | Choice | Source |
|---|------|--------|--------|
| N1 | Three runs per case | `--runs 3` | skill-triggering-6, review-evidence-3 |
| N2 | A record of each run, and its traces | `--json <file>` and `--keep-temp` | skill-triggering-6, skill-adherence-3 |
| N3 | The model of `review` | `opus` with effort `high`, from `plugins/playbook-agents/models.conf` | skill-best-practices-6 |

## New needs

| # | Need | Choice | Status |
|---|------|----------|--------|
| N4 | Where the reviewers run on the same diff | `review-change` and `/code-review` alone: `claude plugin eval`, one case per reviewer and diff, `--ablation none`; no `CLAUDE.md` loads there (review-evidence-7). `/code-review` with the rule of review-evidence-8: `claude -p` inside a clone of the case's diff, so its `CLAUDE.md` loads, with `CLAUDE_CONFIG_DIR` set to a new empty folder, so none of the owner's plugins, hooks, global `CLAUDE.md`, or memory loads, and `CLAUDE_CODE_OAUTH_TOKEN` from `claude setup-token`, on the owner's plan (review-evidence-10) | Decided (review-evidence-7, -10) |
| N5 | A real diff of this repository with a seeded defect | The case's `fixture.sh` clones this repository at a fixed commit, applies a seeded patch kept in the case's folder, and commits it, so both reviewers review `HEAD~1..HEAD` | Decided (review-evidence-11) |
| N6 | Each reviewer runs on purpose, not by triggering | The prompt names the reviewer: `/code-review high HEAD~1..HEAD`, alone or with the rule, and a request for `review-change` on `HEAD~1..HEAD`. Whether `review` runs when it should is measured apart, by N9 | Decided (review-evidence-11) |
| N7 | The defects seeded | Six diffs, one defect each, one per class of the rules of `review-change`: wrong behaviour, a statement that contradicts a Decided one of the wiki, a failing edge case, data loss, a security problem, changed behaviour with no test; and one clean diff, for findings that are not real. In the shell scripts and skill texts of this repository | Decided (review-evidence-11) |
| N8 | Recall and precision | The same reading for the three reviewers, so they compare: an agent reads each kept reply against the diff and the list of seeded defects, and records each seeded defect found or missed, and each other finding real or not, with the line that shows it; the owner reviews the table in the measurement page. No `llm` grader: it would score the cases of `claude plugin eval` and not the runs with the rule, and a judge is not stable | Decided (review-evidence-11) |
| N9 | The count for R20 | A local reading with `jq` of the transcripts: each `git commit` run by `Bash`, and whether an `Agent` call with `review` or a `Skill` call of `review-change` came before it in the session. Each committed change is classed risky or not by R20's list, reading its diff with `git show`. Only the counts reach the wiki (review-evidence-4) | Decided (review-evidence-11) |
| N10 | The ceiling of the paid run | One trial of one diff, one run per reviewer, gives the cost of a run; the ceiling is that cost times the cases times three, and the owner approves it before the full run (review-evidence-5) | Decided (review-evidence-11) |

## Architecture

The work adds cases, a script for the runs of `claude -p` with the rule, and measurement pages. Measuring the wrapper needs no wrapper: what reviews in it is `/code-review` with the rule in `CLAUDE.md` (review-evidence-8). The wrapper and the rule are built only if the measurement justifies them (review-evidence-2).

| Path | What is added | Need |
|------|---------------|------|
| `plugins/playbook-agents/evals/review-evidence-*/` | Fourteen cases: seven diffs, each reviewed by `review-change` and by `/code-review`, with a `fixture.sh` and a seeded patch | N4 to N7 |
| `plugins/playbook-agents/evals/review-evidence-rule.sh` | Builds each diff of the cases with its `fixture.sh`, writes the rule into the clone's `CLAUDE.md`, and runs `/code-review` three times in `claude -p` with an empty `CLAUDE_CONFIG_DIR` | N4 |
| `docs/wiki/works/review-evidence/measurements.md` | Recall and precision of each reviewer, and the count for R20 | N8, N9 |

Risks:

- A seeded defect is easier or harder than a real one. Reduced by seeding in real files of this repository, in the classes the validator says it finds.
- `/code-review` reviews without `CLAUDE.md` in the sandbox, which it reads in real use. Reduced by recording it as a limit of the comparison; in this repository `CLAUDE.md` only points to the wiki.
- Reading the replies is a judgement. Reduced by writing, for each verdict, the line of the reply and of the diff that shows it, and by the owner's review of the table.
- Classing a commit risky is a judgement. Reduced by writing, for each commit classed, the item of R20's list it falls under.

Trade-offs:

- A new configuration folder gives up the owner's settings in the runs with the rule, as `claude plugin eval` does; the token stays out of the repository.
- Isolation in `claude plugin eval` gives up the real session: the owner's settings, hooks, and `CLAUDE.md`. In return each run is repeatable and its cost is capped.
- Naming the reviewer in the prompt gives up measuring triggering here; N9 measures it from real use.
- Reading every reply costs the owner's review, and gives up an automatic score that a later run could repeat.

Discarded:

- `claude -p` with the owner's configuration, in a worktree of the repository: it loads the owner's plugins, hooks, memory, and global `CLAUDE.md`, so a run is not repeatable.
- `claude -p --bare`: it needs `ANTHROPIC_API_KEY`, which the owner does not have (review-evidence-10).
- Measuring the two reviewers alone and deciding the wrapper from that: the rule of the wrapper would stay unmeasured.
- CodeRabbit as the second reviewer: it needs a GitHub App installed and a manual trigger on a repository under 10 stars, and its runs cannot be repeated on the same diff ([research.md](research.md)).

## Not verified

- That a case's prompt can call `/code-review` and a plugin's skill by name inside `claude plugin eval`: the documentation does not say. The trial of N10 checks it.
- That an empty `CLAUDE_CONFIG_DIR` with `CLAUDE_CODE_OAUTH_TOKEN` loads nothing of the owner's. The clone lives outside the home folder, under `TMPDIR`, so no parent `.claude/CLAUDE.md` of the owner's applies; the trial of N10 reads the `init` event of `--output-format stream-json --verbose` to check it.
- That `--max-budget-usd` caps a run on a plan: the help speaks of API calls. Without it, the ceiling is the number of runs and the owner's order for each.
- That `fixture.sh` can find this repository from its own path: the documentation names only `PATH`, `HOME`, and `TMPDIR` in its environment. The trial of N10 checks it.
