# Spec of the work session-cost

Status: Accepted (session-cost-3), changed by session-cost-4.

## What and why (session-cost-1)

A session's cost grows with the context each request carries. Three `/usage` sessions of the owner, on projects using the playbook with Opus 5.5 medium, measured on 2026-11-22:

| Context per request (cache read / requests) | Opus cost | Requests | Cost per request |
|---------------------------------------------|-----------|----------|------------------|
| about 138k | $8.54 | 123 | $0.069 |
| about 229k | $27.98 | 325 | $0.086 |
| about 408k | $28.46 | 144 | $0.198 |

The cache hit rate was 98-99% in all three, and each one's single miss came from idling past the cache lifetime. Haiku cost under two cents in each, and the work a subagent did on Sonnet cost $0.27 to $0.61. Each session stayed open about 12 hours for 20 to 57 minutes of API time: one session for many tasks.

The playbook already writes the handoff between steps: the spec and its units. It cuts the session at those points, so each step starts with a small context, and builds on a cheaper model chosen at the start of the session.

Claude Code's documentation, read on 2026-11-22:

- costs.md: "Use `/clear` to start fresh when switching to unrelated work"; "When you want a fresh start instead of continuity, `/clear` costs nothing."
- costs.md: "Sonnet handles most coding tasks well and costs less than Opus. Reserve Opus for complex architectural decisions or multi-step reasoning."
- costs.md: "your first message after a break longer than the cache lifetime misses the cache and reprocesses your full context."
- prompt-caching.md: "Each model has its own cache. Switching with `/model` means the next request reads the entire conversation history with no cache hits, even though the content is identical."
- prompt-caching.md: "Pick your model and effort level at the top of a session, then save `/compact` for natural breaks between tasks. The fewer changes you make mid-task, the higher your cache hit rate."

## What changes

1. `define`, after the owner accepts the spec, recommends in one line: `/clear`, `/model sonnet`, then build the first unit by name (session-cost-1).
2. `close`, after a unit is marked done, recommends `/clear` and names the next unit (session-cost-1).
3. `rules.md` gains one line: when the owner stops mid-unit to continue later, write in the unit's row of `spec.md` what is done and the next step, commit it, and recommend a new session over `--resume` (session-cost-2). `rules.md` stays near 50 lines (basics-21).
4. The plugin's README says why, in a few lines quoting the documentation above: the context per request is what costs; choose the model at the start of a session, not mid-way; a fresh session beats resuming an old one.
5. `define` sizes every unit to fit one short session, each with its own check, so the `/clear` after a unit falls where the spec holds the handoff (session-cost-4).
6. `product.md` states the build step on the model chosen at the start of a session, citing session-cost-1, at close.

## Out of scope

- Hooks that enforce `/clear` or a model: the playbook recommends, the owner decides.
- The subagents' models: Haiku and the subagents are not where the cost is.
- A status line or any measurement tool: `/usage` already shows the cache and the cost.

## Check

- `sh tests/check-wiki_test.sh`, `sh tests/hooks_test.sh`, `sh plugins/playbook/scripts/check-wiki.sh docs/playbook`, `shellcheck`, and `claude plugin validate .` pass.
- A live run of `define` in a throwaway repository, with `--plugin-dir plugins/playbook`, ends its acceptance with the `/clear` and `/model sonnet` line.
- After release, the owner's next sessions show in `/usage` a lower context per request than the 138k to 408k above.

## Units

One unit: the six changes above, in one pull request.
