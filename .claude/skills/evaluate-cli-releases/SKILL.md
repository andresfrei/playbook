---
name: evaluate-cli-releases
description: Evaluate Claude Code, what is new in its latest versions, or whether a new release helps this repository. Reads the changelog since the last version evaluated and proposes what to optimize or check.
---

## When to use

- The owner asks to evaluate Claude Code, or what its new versions change for this repository.

Do not use it to update Claude Code, to answer how a Claude Code feature works, or for this repository's own versions.

## Rules

- Change no file but the section "Claude Code versions" of `docs/wiki/technology.md`. Each proposal the owner accepts becomes a work or a fix of its own (claude-code-versions-5).
- Read the changelog verbatim with `curl`; never with WebFetch, which paraphrases it.
- Move the record only when the owner has answered every proposal (claude-code-versions-4).
- Ask one proposal at a time, with a recommendation.

## Gotchas

- Claude Code skips version numbers, such as 2.1.324: compare the recorded version with the changelog's headings, never by counting.
- `awk` prints the whole changelog when the recorded heading is missing, and a shell variable does not survive between calls: run step 3 as one call and print the file it writes.

## Steps

1. Read the record, the section "Claude Code versions" of `docs/wiki/technology.md`: the line `Last version evaluated: X.Y.Z`, and the rows under Pending.
2. Run `claude --version`. When it prints the recorded version and Pending is empty, say there is nothing new and stop.
3. Cut the changelog from the version after the record up to the installed one. Run this as one call, with the two versions filled in, and do not change it:

   ```sh
   rec=<recorded>; inst=<installed>; f="${TMPDIR:-/tmp}/cli-changelog.md"
   curl -fsSL https://raw.githubusercontent.com/anthropics/claude-code/main/CHANGELOG.md -o "$f" || { echo "fetch failed"; exit 1; }
   grep -qx "## $rec" "$f" || { echo "recorded $rec missing"; exit 1; }
   grep -qx "## $inst" "$f" || { echo "installed $inst missing"; exit 1; }
   awk -v from="$rec" -v to="$inst" '/^## /{ if ($2 == from) exit; if ($2 == to) on = 1 } on' "$f" > "$f.new"
   grep "^## " "$f.new"; echo "$f.new"
   ```

   When it prints an error, or no `## ` line when the record is behind, say why, leave the record as it is, and stop.
4. When the cut holds more than 10 versions, keep the 10 oldest and say the range left for the next run.
5. Give the Explore agent the cut file and these paths: `plugins/*/hooks/`, `plugins/*/.claude-plugin/`, `.claude-plugin/marketplace.json`, `plugins/*/agents/`, `plugins/*/skills/`, `plugins/*/commands/`, `.claude/`, `codex/`, `docs/wiki/03-technology/`. Ask for one row per changelog entry that touches one of them: version, change, the file it touches, a proposal, optimize or check, and one line of why. Entries that touch nothing are left out.
6. Verify each row by reading the file it names. A row whose file does not use what the entry changes, or that the change already favours, becomes "nothing", with one line of why.
7. Show the table, newest version first: the rows to optimize or check, then the rows that became nothing, and the range read, such as "2.1.326 to 2.1.330".
8. Ask, one at a time, each optimize or check row and each Pending row: do it, leave it for later, or drop it.
9. Write the record: set `Last version evaluated` to the newest version read; add a row to Evaluations, whose Where each went names, for each proposal, the work or fix it became, "pending", or "dropped"; add the proposals left for later to Pending, and remove the Pending rows answered. Run `sh plugins/playbook-wiki/check-wiki.sh docs/wiki`.

## Output

- The table of proposals, the range read, and the owner's answers.
- The record moved, or the reason it was not.
