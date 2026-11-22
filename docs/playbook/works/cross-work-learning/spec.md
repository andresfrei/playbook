# Spec of the work cross-work-learning

Status: Accepted (cross-work-learning-7).

Learned: 2026-11-22

Delivery: one branch and one pull request per work (delivery-versioning-2).

## What and why (cross-work-learning-1)

Each project accumulates its decisions in `docs/playbook/works/*/decisions.md`, with the owner's words. The learning step of `close` looks only at the work being closed, so nothing sees what repeats across works: the same answer given in two works, the same correction, the same procedure done by hand. In this repository, the close stages decided again in each work became the delegation delegation-16 only by hand.

The 4.x construction of learning, a record of findings by levels, `evidence-rules.md`, and the agent `classify`, was weight added for compatibility (basics-4, basics-14). This work keeps no new record, levels, or statistics: it reads what the works already hold. The errors are read from signals already written: a decision marked "Replaced by", the owner's corrections in "Their words", and the reviewer's findings recorded in a work.

Claude Code's documentation, read on 2026-11-22:

- skills.md: "Create a skill when you keep pasting the same instructions, checklist, or multi-step procedure into chat, or when a section of CLAUDE.md has grown into a procedure rather than a fact."
- memory.md: "Keep it to facts Claude should hold in every session: build commands, conventions, project layout, "always do X" rules." and "If an entry is a multi-step procedure or only matters for one part of the codebase, move it to a skill or a path-scoped rule instead."
- sub-agents.md: "Use one when a side task would flood your main conversation with search results, logs, or file contents you won't reference again: the subagent does that work in its own context and returns only the summary." and "**Control costs** by routing tasks to faster, lower-cost models like Haiku".

## What changes

1. A skill `audit-learning` of the plugin, of its own by one job, one skill (cross-work-learning-2, cross-work-learning-6).
2. **What it reads** (cross-work-learning-3). A work is pending while its `spec.md` has no line `Learned: <date>`; a work with no `spec.md`, in the format before `basics`, is history, never pending, and only searched (cross-work-learning-14). A run reads each pending work's `decisions.md` in full, and searches the works already learned from, with `git grep`, only for the subjects the pending ones touch. No list of candidates seen once is kept. The reading runs in a subagent, which returns the repetitions found with their IDs and quotes; the main session asks the owner, since a subagent "doesn't see your conversation history" (skills.md).
3. **The criterion** (cross-work-learning-5). The same thing in two different works:

   | What repeats | What it proposes |
   |--------------|------------------|
   | The same answer to the same question | A delegation in the project's `CLAUDE.md` (R6) |
   | The same correction by the owner | A rule in `CLAUDE.md`, or in `.claude/rules/` with `paths:` for one part of the code |
   | The same procedure of several steps | A skill, written with `skill-creator` |
   | A repeated task with long output, or one a cheaper model can do | An agent |
   | The same subject replaced twice | No tool: a warning for `define` that the subject is unstable |

   When a piece already covers it, it proposes adjusting that piece, not a new one. A project's piece stays in the project; a general one goes to the playbook (R16).
4. **How it proposes.** One proposal at a time, citing the IDs of both works and their quotes, with a recommendation; a new piece is medium (R18), so each is asked. It writes each one the owner accepts, records the answer as a decision of the open work or of `docs/playbook/works/audit-<date>/decisions.md`, and writes `Learned: <date>` in each pending work's `spec.md`, whether or not anything was proposed.
5. **When it runs** (cross-work-learning-4). `close`, when a whole work closes, offers it in one line and runs it on the owner's yes; the owner may also run `/playbook:audit-learning`.
6. The README and `product.md` name the skill with the same name, next to `audit-wiki` and `audit-tools`.

## Out of scope

- A record of errors apart from the works, or of candidates seen once (cross-work-learning-3).
- Changing the learning step of `close` within one work.
- Writing a proposed skill or agent without the owner's yes.
- Making `check-wiki.sh` require the line `Learned:`.

## Check

- `check-wiki.sh`, the tests, `shellcheck`, and `claude plugin validate .` pass.
- In a throwaway repository with two closed works whose decisions give the same answer to the same question, `claude -p --plugin-dir plugins/playbook "/playbook:audit-learning"` proposes one delegation citing both IDs, and writes `Learned:` in both specs. A run after it, with no new work, reads nothing and says so.
- The first run on this repository reads every work in a subagent and the owner answers its proposals.

## Units

| Unit | What | Check | State |
|------|------|-------|-------|
| 1 | Changes 1 to 6 | The first two checks above | Done |
| 2 | The first run on this repository, driven by the owner | The third check above | Done |
