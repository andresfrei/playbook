---
name: audit-wiki
description: Audit the project's wiki against itself and against the code, on the owner's request; on its first run, adopt the project by building the playbook's wiki and rules from the knowledge it already holds. Reports each contradiction with both quotes for the owner to resolve.
---

## When to use

- The owner runs `/playbook:audit-wiki` or asks for an audit, or says yes when you offer one: when the session start recommends it, before a release, or when `close` suggests it (agent-runs-skills-1).

## Rules

- Change nothing tied to a contradiction until the owner resolves it. Fix what the check lists when it is light, such as a broken link, and write the line "Last audit" without asking.
- Report only contradictions: a statement of a shared page that the code, another page, or a newer decision says otherwise. Skip style and wording.
- Quote both sides with file and line. Say when a side is inferred rather than read.
- Ask one question at a time, with a recommendation, then stop and wait.

## Steps

0. When `docs/playbook/README.md` is missing, or has no line that starts with `Last audit:`, this is the first run: read [first-run.md](first-run.md) and do its steps first.
1. Run `sh "${CLAUDE_PLUGIN_ROOT}/scripts/check-wiki.sh" docs/playbook`. Fix what is light, such as a broken link, and list the rest.
2. For each shared page (`docs/playbook/*.md`), read each statement and check it against the code: versions against the manifests, rules of the product against the behaviour, technology against the dependencies. Check it also against the other pages and the newest decision on the same subject.
3. **Definitions.** Check that the wiki defines each item below, in `docs/playbook/README.md`, `product.md`, `technology.md`, or the line `Checks` of the project's `CLAUDE.md`. Report each item missing with a proposal to define it, one at a time; the owner may leave it Open, marked Open on its page, and then it is not reported again (delivery-versioning-1, -3, session-cost-7):
   - the product and its owner;
   - the technology and its versions;
   - how a change is checked;
   - the versioning policy: the line `Versioning:` of `technology.md`;
   - the default way of delivery: the line `Delivery default:` of `technology.md`.

   An item stays on this list only while a skill of the playbook reads it.
4. Show a table: the page's quote, the other side's quote, and your recommendation.
5. Ask the owner to resolve each contradiction, one at a time:
   - The code is right: record the owner's answer as a decision, in the open work's `decisions.md` or, when none is open, in `docs/playbook/works/audit-<date>/decisions.md`. In the same edit, update the page, write "Replaced by <ID>" at the start of the old decision's cell, and move the page's citation to the new ID.
   - The wiki is right: the code has a bug; propose the fix, to be built as any change.
   - Not known: mark the statement Open on the page.
6. When a kind of contradiction was found before, such as a version bumped without `technology.md`, propose the line that prevents it, as `close` does in its learning step.
7. Write in `docs/playbook/README.md` one line that starts with `Last audit:`, as `Last audit: <date>, after work <last closed work>. Contradictions: <found>, <resolved>.`, replacing the previous one, without asking. Run the check again.
8. On the first run, read `${CLAUDE_PLUGIN_ROOT}/skills/audit-tools/SKILL.md` and do its steps, so that the adoption leaves the tools in order too.

## Output

- The check's result, the table of contradictions, the definitions missing, how the owner resolved each, the lines proposed, and the line "Last audit".
