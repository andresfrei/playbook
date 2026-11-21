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

## Construction (decided by the agent under basics-5; the owner accepts it)

Each choice cites Claude Code's documentation, read verbatim on 2026-11-21. BP = best-practices.md, MEM = memory.md, SA = sub-agents.md, PR = plugins-reference.md, CO = costs.md. "Opinion" marks what the docs do not settle.

### The product

One plugin, `playbook`, for Claude Code only (basics-3). Opinion: the docs are silent on splitting, and a dependency is "another plugin that your plugin relies on"; no user takes half of it.

| Piece | Ideas | What it is | Justification |
|-------|-------|------------|---------------|
| `rules.md`, loaded by a SessionStart hook | 2, 4, 8 | The contract and the rules merged, under 200 lines. Delegated decisions are lines here, such as "do not ask about X" | MEM: "target under 200 lines"; BP: "Only write down what Claude can't find by reading the repo". A plugin cannot ship a CLAUDE.md; a hook's `additionalContext` "passes a string from your hook into Claude's context window" |
| Skill `define` | 1, 2, 3 | Names the type of change in one line, then runs its steps (basics-6): Define, the interview until the spec can be written; Technology, each need with a technology checked in its current documentation, as in v1.0.0; Skills, for each new technology a skill installed, written, or not needed; Design, for a new project with an interface. Writes the spec and the decisions; the owner accepts the spec once. A complex work's spec holds its units | BP: "Interview me until you could write the spec, then write it to SPEC.md"; "a written definition of done"; "Decisions that aren't in the repo"; "A more capable model knows more about engineering, but not how your team…"; CO: "Use plan mode for complex tasks" |
| A small wiki | 2, 3 | Flat, one page per step of `define`, holding only what the code does not: `README.md` (the product, for whom, the open work, the list of pages), `product.md` (what it does and the decided rules, each citing its decision), `technology.md` (each technology with why, version, and the link checked), `skills.md` (technology to skill), `design.md` (only with an interface), and per work `spec.md` and `decisions.md` (ID, date, decision, who, their words). No page maps code paths | BP: "Decisions that aren't in the repo"; "Describe your architecture and file layout … Claude reads the repo itself" |
| Skill `close` | 5, 11 | Checks the build against the spec, has the reviewer read a risky change, and proposes one concrete line for each mistake seen twice or each finding Claude should have known, into `CLAUDE.md`, `.claude/rules/` with `paths:`, or a skill's gotchas; the owner accepts or not | MEM: "Add to it when: Claude makes the same mistake a second time; A code review catches something Claude should have known"; "move it to a skill or a path-scoped rule" |
| Agent `reviewer` | 6 | `tools: Read, Grep, Glob`; reads the change against the spec, correctness only | BP: "Getting a reviewer that hasn't seen how the code was written"; "report gaps that affect correctness and skip style" |
| Skill `release` | 11 | Version, tag, release; `disable-model-invocation: true` | BP gives this skill as its example |
| Hook before delivery | 8 | Asks before push, pull request, merge, release | BP: "your 'never' rules belong in deny rules or hooks"; a plugin ships hooks, not permission rules |
| Check of the wiki, run by `define` and `close` and on commit | 9 | Links resolve, decision IDs are unique, every decision has the decider's words | BP: "Give Claude a check to run" |
| `Explore.md`, copied by the user | 7, 12 | A user agent named `Explore`, `model: haiku`, read-only tools; the README says to copy it to `~/.claude/agents/`. Writing stays in the main session, on the model chosen with `/model` (basics-7) | SA: "A user or project subagent named `Explore` overrides the built-in and keeps its own `model` field, so define one with `model: haiku`"; a plugin agent is namespaced and does not override it; BP: "Haiku is a good fit for subagents doing simple jobs"; "Sonnet costs less on routine work" |
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
| `protect` and its script | 8 | A section of the README with the deny rules | BP: deny rules for `.env` in `.claude/settings.json` |
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
| U2 | Builds the plugin `playbook`: `rules.md`, the session-start hook, the hook before delivery, the check on commit, `userConfig`, the agent `reviewer`, and `Explore.md` | `claude plugin validate plugins/playbook`; a new session loads the rules | Not started |
| U3 | Writes the skills `define`, `close`, and `release` | `claude plugin validate`; each skill run once on a small case | Not started |
| U4 | Removes `playbook-wiki`, `playbook-agents`, Codex, and the scripts and evaluations they need; rewrites the README and `CLAUDE.md` | `claude plugin validate .`; nothing names a removed path | Not started |
| U5 | Releases 5.0.0, after the owner's yes | The tag and the release on GitHub | Not started |
