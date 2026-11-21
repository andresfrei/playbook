# Spec of the work basics

Each idea of the playbook, the problem it solves, and its simplest construction. Each item is Decided, Proposed, or Open.

## The ideas (basics-1)

1. Definitions before code, in stages: nothing is built without knowing what.
2. The owner decides, recorded in their words: the agent does not invent.
3. The wiki is the source of truth: any agent picks the work up without the conversation.
4. Delegated decisions: the agent does not ask the obvious.
5. Learning from repeated mistakes (evidence): the same mistake does not come back.
6. A review by fresh eyes: what the writer does not see is caught.
7. Delegating work to agents: context and time are saved.
8. The owner controls what cannot be undone (push, pull request, merge, release, secrets).
9. The wiki stays valid by itself (check, migrate): it does not break silently.
10. Recurring tasks become agents: the same thing is not explained again.
11. A version per work: users know what changed.
12. Each person chooses each agent's model: cost to taste.
13. Units in parallel: the work ends sooner.
14. A decision repeated becomes a rule: the owner is not asked the same thing twice (basics-10).
15. Only what someone would ask about is a decision, and the entry to them loads every session (basics-11).
16. The wiki stays coherent with itself and with the code; each contradiction is the owner's to resolve, and one seen again becomes a rule (basics-12).
17. Each action has a weight, light, medium, or heavy, that says whether the owner is asked; when unsure, medium (basics-13).
18. Using the playbook is all or nothing: `audit` turns a project's existing knowledge into the playbook's wiki and rules, guided by the owner, and the project's rules win over the plugin's (basics-15).

## Construction (decided by the agent under basics-5; the owner accepts it)

Each choice cites Claude Code's documentation, read verbatim on 2026-11-21. BP = best-practices.md, MEM = memory.md, SA = sub-agents.md, PR = plugins-reference.md, CO = costs.md. "Opinion" marks what the docs do not settle.

### The product

One plugin, `playbook`, for Claude Code only (basics-3). Opinion: the docs are silent on splitting, and a dependency is "another plugin that your plugin relies on"; no user takes half of it.

| Piece | Ideas | What it is | Justification |
|-------|-------|------------|---------------|
| `rules.md`, loaded by a SessionStart hook | 2, 4, 8, 15, 17 | The contract and the rules merged, near 50 lines, since the rules and the wiki's README share the 10,000 characters of a hook's output (basics-21). The same hook prints `docs/playbook/README.md` when the project has one (basics-11, basics-16). A change that contradicts a shared page updates the page in the same commit, or the owner is told (basics-12). The three weights of an action, each with concrete examples, and the tie-break, in a block of about six lines (basics-13, basics-14); writing down what the owner already decided is light, stating what is not decided is medium (basics-18); a weight misjudged twice becomes a project line through `close`. MEM: "always do X" rules belong in every session; skills hold "task-specific instructions that don't need to be in context all the time"; BP: "Handing the same task to a subagent doesn't make the answer any better". A delegated decision is a line in the project's `CLAUDE.md`, such as "do not ask about X", since an update overwrites the plugin's files | MEM: "target under 200 lines"; BP: "Only write down what Claude can't find by reading the repo". A plugin cannot ship a CLAUDE.md; a hook's `additionalContext` "passes a string from your hook into Claude's context window" |
| Skill `define` | 1, 2, 3, 14 | Names the type of change in one line, then runs its steps (basics-6): Define, the interview until the spec can be written; Technology, each need with a technology checked in its current documentation, as in v1.0.0; Skills, for each new technology a skill installed, written, or not needed; Design, for a new project with an interface. Writes the spec and the decisions; the owner accepts the spec once. A complex work's spec holds its units. It records a decision only when the owner chose between real options or set a limit Claude could not infer, the code does not say it, and someone in six months would ask why (basics-11). Before asking, it searches the works' `decisions.md` and cites what is already decided (basics-10) | BP: "Interview me until you could write the spec, then write it to SPEC.md"; "a written definition of done"; "Decisions that aren't in the repo"; "A more capable model knows more about engineering, but not how your team…"; CO: "Use plan mode for complex tasks" |
| A small wiki | 2, 3 | Flat, one page per step of `define`, holding only what the code does not: `README.md` (the product, for whom, the open work, the list of pages), `product.md` (what it does and the decided rules, each citing its decision), `technology.md` (each technology with why, version, and the link checked), `skills.md` (technology to skill), `design.md` (only with an interface), and per work `spec.md` and `decisions.md` (ID, date, decision, who, their words). No page maps code paths | BP: "Decisions that aren't in the repo"; "Describe your architecture and file layout … Claude reads the repo itself" |
| Skill `close` | 5, 11, 14, 16 | Checks the build against the spec, has the reviewer read a risky change, and proposes one concrete line for each mistake seen twice or each finding Claude should have known, into `CLAUDE.md`, `.claude/rules/` with `paths:`, or a skill's gotchas; and for each decision of the work that repeats an earlier one, the rule or delegation that replaces asking it (basics-10); it rereads the shared pages it changed against the work's decisions, and suggests `audit` when works closed since the last audit or it found a contradiction (basics-12); the owner accepts or not | MEM: "Add to it when: Claude makes the same mistake a second time; A code review catches something Claude should have known; You type the same correction or clarification into chat that you typed last session"; "move it to a skill or a path-scoped rule" |
| Agent `reviewer` | 6 | `tools: Read, Grep, Glob`; reads the change against the spec, correctness only | BP: "Getting a reviewer that hasn't seen how the code was written"; "report gaps that affect correctness and skip style" |
| Skills `audit-wiki` and `audit-tools` (basics-26) | 9, 16, 18 | Recommended by the SessionStart hook, inside a git repository, while the wiki has no line "Last audit" (basics-18). On its first run it reads the project's existing knowledge, proposes how to order it, builds the wiki in `docs/playbook/` (basics-16), and cleans `CLAUDE.md` and the project's rules; it starts from a clean git tree, and outside git asks for `git init` (basics-15). It records the owner's answers in the open work's `decisions.md`, or in `works/audit-<date>/` when none is open. It changes files only inside the repository and `.claude/settings.local.json`, and reports what it finds outside; ordering the documentation imposes no structure: per file, keep, merge, move to the wiki, or delete (basics-18). Started only by the owner (`disable-model-invocation: true`): runs the check, reads each shared page against the code, and reports each contradiction with the page's quote and the code's; changes nothing until the owner resolves it. `audit-tools`, a skill of its own that the first run of `audit-wiki` also follows, checks the tools the repository has on, plugins, MCP servers, skills, agents, hooks, and other tools' rules, for collisions with the playbook: a tool that keeps decisions outside the wiki, does the job of one of the playbook's skills, contradicts the rules, or asks at the same moments. For each it suggests a way out, and applies the owner's answer with Claude Code's own commands, for that repository only; it reports a server that does not connect, and keeps no list of tools in the wiki. The plugin names no outside tool (basics-24, basics-25). The owner resolves each: the code is right, the wiki is right, or Open; a kind seen again gets a learning line. Writes the last audit in the wiki's README without asking, a light action (basics-12, basics-13) | BP: "Put team procedures in skills"; MEM: `/doctor prompt-audit` reports "files that contradict each other" and "nothing in your files changes until you ask"; MEM: auto memory "is machine-local"; BP: "Connected servers add their tool names and instructions to the context even when you're not using them, so it's worth turning off the ones you don't need"; CO: "Prefer CLI tools when available"; MCP: "Check `.mcp.json` into version control so everyone on your team gets the same MCP tools and services". Opinion: auditing documentation against code is not in the docs |
| Skill `release` | 11 | Version, tag, release; `disable-model-invocation: true` | BP gives this skill as its example |
| Hook before delivery | 8 | Asks before push, pull request, merge, release. It fails toward asking: it asks when it cannot read the command, and a hook that hangs or is killed blocks, by `onFailure` (basics-23). `ask.sh` and `commit-check.sh` check the command themselves, through `lib.sh`, since the `if` filters also let other commands through; `lib.sh` drops the wrappers Claude Code drops before matching a rule, and reads the subcommand, so `timeout 60 git push` asks and `git stash push` does not; it reads the command as a shell does, with its quotes, backslashes, command substitutions, and heredocs, so a quoted folder with spaces, as in `cd 'my app' && git commit`, the form Code Mode sends, is found, and `git commit -m "x; git push"` does not ask; it looks into the command a shell runs, as in `bash -c "git push"`, and through `env`, `sudo`, and `xargs`. It stays best-effort: a command built at run time, such as `eval "$cmd"`, is not read | BP: "your 'never' rules belong in deny rules or hooks"; a plugin ships hooks, not permission rules; hooks.md: "patterns that specify more than the command name run the hook anyway on `$()`, backticks, or `$VAR`"; permissions.md: "Claude Code strips a fixed set of wrappers… `timeout`, `time`, `nice`, `nohup`, and `stdbuf`, plus the shell builtins `command` and `builtin`" |
| Check of the wiki, run by `define` and `close` and on commit | 9 | Links resolve, decision IDs are unique, every decision has the decider's words, no shared page cites a decision marked replaced (basics-12) | BP: "Give Claude a check to run" |
| `Explore.md`, copied by the user | 7, 12 | A user agent named `Explore`, `model: haiku`, read-only as the built-in: no Write or Edit, and Bash kept for searching, held by its instruction (basics-22); the README says to copy it to `~/.claude/agents/`. Writing stays in the main session, on the model chosen with `/model` (basics-7) | SA: "A user or project subagent named `Explore` overrides the built-in and keeps its own `model` field, so define one with `model: haiku`"; a plugin agent is namespaced and does not override it; BP: "Haiku is a good fit for subagents doing simple jobs"; "Sonnet costs less on routine work" |
| `userConfig` | 12 | The language of the replies | PR: "`userConfig` declares values Claude Code prompts the user for when the plugin is enabled" |

### Left to Claude Code

| Today | Ideas | Replaced by | Justification |
|-------|-------|-------------|---------------|
| Agents `write`, `explore`, `classify`, `wiki-writer` | 7 | The main session; the built-in Explore | BP: "Handing the same task to a subagent doesn't make the answer any better"; "it can end up slower" |
| Evidence: `classify`, `evidence.sh`, levels, consolidation, graduation, index, `seed-evidence` | 5 | The skill `close`, auto memory, `/doctor prompt-audit` | MEM: auto memory "lets Claude learn from your corrections"; the audit finds files that "contradict each other" |
| Parallel units and worktrees | 13 | `/batch` | BP: "splits the work into 5 to 30 units … each unit gets its own worktree" |
| `models.conf`, `set-models.sh`, `agent-models.sh`, `config` | 12 | The `model` field of the reviewer | SA: `model` and `effort` per agent |
| `tasks.sh`, task agents | 10 | A skill, proposed by `close` when a task repeats | BP: "Put team procedures in skills" |
| Kind, Answer, Replaces, the decision index, measured delegations | 4, 9 | Lines in `rules.md` | Opinion; the docs are silent |
| The six stages, their tables and closes | 1 | `define` by the type of change (basics-6), then build with a check, then `close` | BP and CO above |
| Format versions, the marker, `migrate`, the version notice | 9 | A breaking format change ships its own migration step in its release notes | Opinion: with a small, stable format, a marker costs more than it saves |
| Hooks: commit hold, `review-ran`, subagent contract and rules index, merge step | 6, 7 | Nothing | BP: "a hook is for a rule with zero exceptions"; "keep the enforced set small"; SA: "most rules don't need to reach the subagent itself" |
| `keep-minimal` | 6 | R9 in `rules.md` | BP: "only write down what Claude can't find on its own" |
| `write-skill` | — | Claude Code's `skill-creator` | Opinion: it ships with Claude Code where this was checked |
| `write-docs`, `avoid-generic-design` | — | `define`, R12; nothing | BP: "only write down what Claude can't find on its own" |
| `protect` and its script | 8 | A section of the README with deny rules for secrets and ask rules for local destructive commands such as `git reset --hard`, `rm -rf`, and a forced push (basics-13, basics-18) | BP: deny rules for `.env` in `.claude/settings.json`; permission-modes.md: "Deny rules block in every mode", and no mode, `bypassPermissions` included, auto-approves "Tools matched by an explicit ask rule" |
| Codex | — | Nothing | basics-3 |
| R22 (CodeGraph) and R23 (Engram) in `rules.md` | — | Nothing; each user chooses their own MCP servers | BP: connected servers add their instructions "even when you're not using them"; CO: "Prefer CLI tools when available"; MEM: auto memory is built in (basics-7) |
| A required tool to read documentation | 1 | The step Technology says to check the current documentation, with the link and the date, by any tool: `curl`, WebFetch, or Context7; Claude Code's pages verbatim from `llms.txt` (basics-8) | BP: "For systems without a CLI, there's MCP"; every page opens with "Fetch the complete documentation index at: https://code.claude.com/docs/llms.txt"; the docs are silent on Context7 |

### Delivery

A new major version, 5.0.0. Built on a branch from `main`, not on `feat/rule-promotion`, whose pull request closes unmerged. In this repository the shared pages are rewritten into the flat pages, short; the pages of past phases, the old plans, `evidence.md`, and `tasks.md` are deleted, since git keeps them; `works/` stays as the record of decisions.

## Units

Each unit is accepted by its check.

| Unit | What it does | Check | Status |
|------|--------------|-------|--------|
| U1 | Rewrites this wiki into the flat pages, deletes the old shared pages, and writes the new check of the wiki in `plugins/playbook/scripts/check-wiki.sh` | `sh plugins/playbook/scripts/check-wiki.sh docs/wiki` passes; `sh tests/check-wiki_test.sh` shows it fails on a broken link, a repeated ID, and a decision with no words | Done |
| U2 | Builds the plugin `playbook`: `rules.md`, the session-start hook, the hook before delivery, the check on commit, `userConfig`, the agent `reviewer`, and `Explore.md` | `claude plugin validate plugins/playbook`; `sh tests/hooks_test.sh`; a live `claude -p --plugin-dir` run loaded the rules, stopped a commit on a broken wiki, and asked before a push | Done |
| U3 | Writes the skills `define`, `close`, and `release` | `claude plugin validate`; each skill run once by `claude -p --plugin-dir` on a small case: `define` named the type and steps, `close` refused a unit with no code, `release` bumped and committed on a branch and left delivery to the owner | Done |
| U4 | Removes `playbook-wiki`, `playbook-agents`, Codex, and the scripts and evaluations they need; rewrites the README and `CLAUDE.md` | `claude plugin validate .`; the tests, the check, and shellcheck pass; outside `works/`, nothing names a removed path but the upgrade steps of the README | Done |
| U5 | Decisions (basics-10, basics-11): the SessionStart hook prints the wiki's README; `define` applies the filter and searches the decisions before asking; `close` proposes a rule or delegation for a repeated decision; a replaced decision gets "Replaced by <ID>" in its Decision cell, with no new column | `sh tests/hooks_test.sh` shows the README printed when present and nothing when absent; a live `claude -p --plugin-dir` run: `define`, asked something already decided in a test wiki, cites the decision instead of asking; `close` on a work that repeats a decision proposes the line | Done |
| U6 | Coherence (basics-12): the check on replaced decisions, the line in `rules.md`, the step and the suggestion in `close`, the skill `audit`, the last-audit line, the README's advice | `sh tests/check-wiki_test.sh` shows a failure on a page citing a replaced decision; `claude plugin validate`; a live `claude -p --plugin-dir` run of `audit` on a test project whose page contradicts its code reports both quotes and changes no file | Done |
| U7 | Weights (basics-13) and the review of U5 and U6: the weights with examples and the tie-break in `rules.md`, which stays near 50 lines (basics-14); `audit` writes "Last audit" without asking; `define`, `close`, and `audit` ask nothing light; `define` writes "Replaces <ID>" in the new decision and `close` marks the old one and moves the page's citation in the same edit; the README's limit counts the whole hook output; the README's ask rules for local destructive commands (basics-18) | `sh tests/check-wiki_test.sh` and `sh tests/hooks_test.sh`, with a case for a README that fits alone but not with the rules; `claude plugin validate`; a live run of `close` on a work with a replaced decision commits without the check failing | Done |
| U8 | Adoption (basics-15 to basics-18): the folder `docs/playbook/` in every skill, hook, and check; the SessionStart recommendation inside a git repository; the first run of `audit`; `define` sends an existing project with no wiki to `audit`; the precedence line in `rules.md`; the README's install section with the three scopes | The tests and `claude plugin validate`; a live run of `audit` on a throwaway project with a README, a `CLAUDE.md`, and an old `docs/wiki/` builds the new wiki and leaves one diff | Done |
| U9 | A trial of `audit` (basics-19, basics-20): a detached worktree of `main` at 4.0.0, with the plugin installed at user scope; the owner runs `/playbook:audit` | Its `docs/playbook/` compared with the `docs/wiki/` U1 built by hand (commit 89cf79f): what each holds that the other lacks; the cost, the time, and each time the owner had to step in, recorded in this spec; the fixes to `audit` made and tested | Done |
| U10 | The audit of this repository, with the fixes of U9, with the plugin installed | The wiki ordered in `docs/playbook/`; the check passes; nothing names `docs/wiki/` but the upgrade steps | Done |
| U11 | Releases 5.0.0, after the owner's yes | The tag and the release on GitHub | Not started |

## Trial of audit (U9)

Run on 2026-11-21 in the detached worktree `../playbook-audit-trial` at `e13cc28` (4.0.0), with the plugin installed at user scope from this worktree. Its diff is left uncommitted there.

What it built: `docs/playbook/` with `README.md`, `product.md`, `technology.md`, `skills.md`, `design.md`, about 7,600 words, against about 1,150 in the four pages U1 wrote by hand (89cf79f). The 26 works moved unchanged. Seven decisions, audit-2026-11-21-1 to -7. One contradiction was found and fixed in the code: R23 still sent learning to Engram after the owner removed it.

What each holds that the other lacks:

- The trial kept the current 4.0.0 definitions nearly whole: the glossary, where each rule R1–R24 comes from, the delegations, F1–F12, the Codex integration, the README's design. U1 describes the 5.0.0 product being rebuilt, so it holds none of these, and they no longer apply to it.
- U1 deleted the pages of past phases, `evidence.md`, and `tasks.md`, since git keeps them (line 71 of this spec). The trial moved the phase pages to `works/history/pages/` and rewrote about 200 links of old works, because `first-run.md` named neither choice.
- U1's `skills.md` holds the skills the agent uses to build the repository, as `define` means it. The trial put the product's own skill set there, which `define` would not.

Cost and time, from `/usage` of the session, which also holds this comparison and the fixes: $4.53 estimated, 10 min 17 s of API time, 34 min 27 s of wall time, 78 requests, 99% of input from cache, almost all on `claude-opus-5-5`. The live test of the fix ran apart, under a ceiling of $2.

Each time the owner stepped in: one answer per topic, six in the first run (the phase pages, `tasks.md` and `evidence.md`, `product.md`, `technology.md`, `CLAUDE.md`, the competing plugin) and one for the contradiction. Each was a "si" but the competing plugin: the owner asked to uninstall Engram from the machine instead of turning it off for the repository, which was done on that request.

Fixes to `audit`, in `first-run.md`: what each page holds, with `skills.md` as the skills for building the repository; the pages kept short, with no list the code shows; records of finished work proposed for deletion; the links of old works left as they are. Tested by a live `claude -p '/playbook:audit'` on a throwaway project with a 4.x wiki: it proposed deleting the plan of a closed phase, moved the working skills to `skills.md`, and dropped a table of modules.

## Audit of this repository (U10)

Run on 2026-11-21 in this worktree, in a new session with the plugin installed at user scope, after the fixes of U9. It took 13 minutes and 30 requests, on `claude-fable-5-2`, with no tool call refused or failed.

What it did: moved `docs/wiki/` to `docs/playbook/`, 190 files unchanged; fixed the paths in `CLAUDE.md`, `CONTRIBUTING.md`, the root `README.md`, and the project skill `evaluate-cli-releases`; cut from `CLAUDE.md` the pointer to the wiki, which the hook now loads. Nothing outside `docs/playbook/works/` names `docs/wiki/` but the upgrade steps of the root `README.md` and `first-run.md`.

Contradictions: 6 found, 6 resolved. Four by decisions already recorded, written without asking: `product.md` and `skills.md` did not name `audit`, this spec named the old path of the hook, and `CONTRIBUTING.md` asked for the client. Two by the owner: the size of `rules.md` (basics-21) and the tools of `Explore.md` (basics-22).

Each time the owner stepped in: four answers, three "si" and one question on the size of `rules.md`, answered with the cap of a hook's output. One line was accepted for `CLAUDE.md`, for a contradiction seen in U9 and again here: a decision removes something and text that names it stays.

Read afterwards by the session that built the work: the tests, `shellcheck`, `claude plugin validate`, and the check pass; the session-start hook prints the rules and the README in 5,959 characters, and no longer recommends the audit here.
