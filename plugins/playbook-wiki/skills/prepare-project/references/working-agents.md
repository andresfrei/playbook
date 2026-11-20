# Working agents in Claude Code

## Locate a script

Replace `<script>` with the script's name, such as `evidence.sh` or `tasks.sh`, and run:

```sh
s=<script>; (cd "<this skill's folder>" && for p in ../../../playbook-agents/"$s" $(ls -d ../../../../playbook-agents/*/"$s" 2>/dev/null | awk -F/ '{ print $(NF-1) "\t" $0 }' | sort -t. -k1,1n -k2,2n -k3,3n | tail -n 1 | cut -f2); do [ -f "$p" ] && (cd "$(dirname "$p")" && echo "$(pwd)/$s"); done | tail -n 1)
```

It prints the script's absolute path: from a marketplace kept in a folder, or from the highest version of an installed cache, compared as numbers, so 3.10.0 is above 3.9.0. When it prints nothing, `playbook-agents` is missing. It runs in a subshell, so the working folder stays the project's root.

## Review findings

The review agent delegates classification to `playbook-agents:classify`. Keep one copy of the evidence on the work branch.

## Recurring tasks

Use `haiku` with low effort for mechanical commands and `sonnet` with medium effort for writing or judging small changes. For an approved task, create `.claude/agents/<task>.md`. Its front matter holds `name`, a one-line `description` saying when to use it, `tools`, `model`, and `effort`. Put the instructions in the Markdown body.
