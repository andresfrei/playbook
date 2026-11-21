---
name: audit
description: Audit the project's wiki against itself and against the code, on the owner's request. Runs the wiki check, reads each shared page against the code, and reports each contradiction with both quotes for the owner to resolve.
disable-model-invocation: true
---

## When to use

- The owner runs `/playbook:audit`, such as before a release or when `close` suggests it.

## Rules

- Change no file until the owner resolves the contradiction it belongs to.
- Report only contradictions: a statement of a shared page that the code, another page, or a newer decision says otherwise. Skip style and wording.
- Quote both sides with file and line. Say when a side is inferred rather than read.
- Ask one question at a time, with a recommendation, then stop and wait.

## Steps

1. Run `sh "${CLAUDE_PLUGIN_ROOT}/scripts/check-wiki.sh" docs/wiki` and list what it reports.
2. For each shared page (`docs/wiki/*.md`), read each statement and check it against the code: versions against the manifests, rules of the product against the behaviour, technology against the dependencies. Check it also against the other pages and the newest decision on the same subject.
3. Show a table: the page's quote, the other side's quote, and your recommendation.
4. Ask the owner to resolve each contradiction, one at a time:
   - The code is right: update the page, record the owner's answer as a decision, and write "Replaced by <ID>" at the start of the old decision's cell.
   - The wiki is right: the code has a bug; propose the fix, to be built as any change.
   - Not known: mark the statement Open on the page.
5. When a kind of contradiction was found before, such as a version bumped without `technology.md`, propose the line that prevents it, as `close` does in its learning step.
6. Write in `docs/wiki/README.md` one line: `Last audit: <date>, after work <last closed work>. Contradictions: <found>, <resolved>.`, replacing the previous one. Run the check again.

## Output

- The check's result, the table of contradictions, how the owner resolved each, the lines proposed, and the line "Last audit".
