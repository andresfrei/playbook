# playbook

A Claude Code plugin that helps you build software fast: it defines each change with you before code, records your decisions in your words, and learns from its own mistakes.

```sh
claude plugin marketplace add andresfrei/playbook
claude plugin install playbook@playbook
```

| Piece | What it does |
|-------|--------------|
| `/playbook:define` | Interviews you until the change's spec can be written, with only the steps its type needs |
| `/playbook:close` | Checks the build against the spec, has `reviewer` read a risky change, and proposes one line for each repeated mistake |
| `/playbook:release` | Sets the version, commits, and drafts the notes; you push and publish |
| `reviewer` | A read-only agent that checks a change against its spec, for correctness only |
| Rules | Loaded at session start, under 50 lines |
| Hooks | Ask before push, pull request, merge, and release; run the wiki check on commit |

For cheaper searches, copy `extras/Explore.md` to `~/.claude/agents/`: it runs Claude Code's Explore on `haiku`.
