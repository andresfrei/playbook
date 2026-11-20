---
name: evaluate-cli-releases
description: Evaluate Claude Code, what is new in its latest versions, or whether a new release helps this repository. Reads the changelog since the last version evaluated and proposes what to optimize or check.
---

## When to use

- The owner asks to evaluate Claude Code, or what its new versions change for this repository.

Do not use it to update Claude Code, to answer how a Claude Code feature works, or for this repository's own versions.

## Rules

- Change no file but `docs/wiki/03-technology/claude-code-versions.md`. Each proposal the owner accepts becomes a work or a fix of its own (claude-code-versions-5).
- Read the changelog verbatim with `curl`; never with WebFetch, which paraphrases it.
- Move the record only when the owner has answered every proposal (claude-code-versions-4).
- Ask one proposal at a time, with a recommendation.

## Gotchas

- Claude Code skips version numbers, such as 2.1.324: compare the recorded version with the changelog's headings, never by counting.
- `awk` prints the whole changelog when the recorded heading is missing: check that the heading exists first.

## Steps

1. Read the record, `docs/wiki/03-technology/claude-code-versions.md`: the line `Last version evaluated: X.Y.Z`.
2. Run `claude --version`. When it prints the recorded version, say there is nothing new and stop.
3. Fetch and cut the changelog. Do not change these commands:

   ```sh
   f=$(mktemp) && curl -fsSL https://raw.githubusercontent.com/anthropics/claude-code/main/CHANGELOG.md -o "$f"
   grep -qx "## <recorded>" "$f" || echo "missing"
   awk -v from="<recorded>" '/^## /{ if ($2 == from) exit } { print }' "$f" > "$f.new"
   ```

   When `curl` fails or the heading is missing, say so, leave the record as it is, and stop.
4. Give `explore` the file `$f.new` and these paths: `plugins/*/hooks/`, `plugins/*/.claude-plugin/`, `.claude-plugin/marketplace.json`, `plugins/*/agents/`, `plugins/*/skills/`, `plugins/*/commands/`, `.claude/`, `codex/`, `docs/wiki/03-technology/`. Ask for one row per changelog entry that touches one of them: version, change, the file it touches, and a proposal, optimize or check, with one line of why. Entries that touch nothing are left out.
5. Verify each row by reading the file it names. Drop a row whose file does not use what the entry changes.
6. Show the table, newest version first, and the versions read, such as "2.1.326 to 2.1.330".
7. Ask each proposal: do it, leave it for later, or drop it.
8. Write the record: set `Last version evaluated` to the newest version read, add a row to Evaluations, and add each proposal left for later to Pending. Remove from Pending what the owner answered. Run `sh plugins/playbook-wiki/check-wiki.sh docs/wiki`.

## Output

- The table of proposals, the range read, and the owner's answers.
- The record moved, or the reason it was not.
