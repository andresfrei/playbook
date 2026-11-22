# Spec of the work agent-runs-skills

Status: Accepted (agent-runs-skills-1).

Learned: 2026-11-22

Delivery: one branch and one pull request per work (delivery-versioning-2).

## What and why (agent-runs-skills-1)

The skills `audit-wiki`, `audit-tools`, and `release` had `disable-model-invocation: true`, so the agent could only tell the owner to type the command. In use, the owner copied `/playbook:audit-wiki:` with a trailing colon and Claude Code answered "Unknown command". The heavy steps those skills lead to already ask through the hooks (R18), and each skill asks the owner inside it: `audit-wiki` changes nothing until each contradiction is resolved, `release` asks to confirm the version.

Claude Code's documentation, read on 2026-11-22 (skills.md):

- "By default, both you and Claude can invoke any skill."
- "`disable-model-invocation: true`: Claude can't invoke the skill on its own. Use this for workflows with side effects or that you want to control timing, like `/commit`, `/deploy`, or `/send-slack-message`."
- "Claude uses skills when relevant, or you can invoke one directly with `/skill-name`."

## What changes

1. The three skills drop `disable-model-invocation: true`; each says when to use it: the owner asks, or says yes to the agent's offer. `release` adds: never because the work looks ready.
2. `define` and `close` offer to run `audit-wiki` and `release` and run them on a yes, instead of telling the owner to type them.
3. `product.md` says the same.

## Out of scope

- The hook `adopt.sh` keeps naming `/playbook:audit-wiki` in its message; the agent offers it from there.
- The hooks that ask before push, pull request, merge, and release.

## Check

- `check-wiki.sh`, the tests, `shellcheck`, and `claude plugin validate .` pass.
- In a throwaway repository with a wiki and no line "Last audit", `claude -p --plugin-dir plugins/playbook "audit the wiki"` runs the skill `audit-wiki` without asking the owner to type it.

## Units

| Unit | What | Check | State |
|------|------|-------|-------|
| 1 | Changes 1 to 3 | The check above | Done |
