# Report of the work decision-review

Five `explore` agents on haiku, as the owner chose, classed the 241 decisions of `docs/wiki/decisions.md` on 2026-11-20 against the code, the shared pages, and Claude Code 2.1.330's documentation. The main session read the evidence of every finding kept below. A decision classed Valid was not read again: a wrong Valid would go unseen.

## Count

| Range | Valid | Replaced, not marked | Outdated | Doubtful |
|-------|-------|----------------------|----------|----------|
| D1–D55 | 35 | 16 | 2 | 2 |
| D56–D110 | 35 | 20 | 0 | 0 |
| D111–D160 | 40 | 8 | 2 | 0 |
| D161–D208 | 37 | 8 | 3 | 0 |
| TD1–TD33 | 11 | 17 | 4 | 1 |
| Total | 158 | 69 | 11 | 3 |

## What the 83 findings are

`plugins/playbook-wiki/format.md`, line 36: the `decisions.md` of a wiki from before format 4 "is history: it stays as it is, nothing is added to that `decisions.md`, and the check does not read it". Since then, a decision is a row of a work's `decisions.md`, and the definition in force is written in a shared page that cites it. So D# and TD# rows are not marked when a later decision replaces them, by design. Checked samples: the limits 270 and 370 of D199 are in `01-product/style-guide.md` by delegation-2; the check at commit of D140 is in `03-technology/architecture.md` by the work `wiki-check-on-commit`; Codex, against D27 and D191, by codex-support-1; the fourth agent, against TD8, by repeated-corrections-30; the `llm` graders, against TD4, in `03-technology/skill-evaluation.md`.

Of the 83, 79 are history replaced as designed. Four rows need the owner.

## Rows for the owner

| Row | What | Evidence | Recommendation |
|-----|------|----------|----------------|
| decision-review-R1 | The entry points still say `decisions.md` wins | `CLAUDE.md`, line 5: "Inside it, `docs/wiki/decisions.md` wins"; `docs/wiki/README.md`, line 3, the same, and line 9: Decided means "numbered in decisions.md". Both contradict `format.md`, line 36. This is what makes the 79 rows look wrong | Rewrite both: the definitions in force are in the shared pages, each citing its decision; a work's `decisions.md` records each decision; `docs/wiki/decisions.md` is the history before format 4 |
| decision-review-R2 | The wiki's README waits for a version already released | `docs/wiki/README.md`, line 67: "Phase 4 raises it to `2.0.0` (TD32)"; the tag `v2.0.0` exists and the manifests say 3.7.2 | Remove the line from what waits for the owner |
| decision-review-R3 | A shared page keeps phase 4's old layout | `docs/wiki/01-product/phase-4.md`, line 24: the core is published "in a folder of its own apart from `plugin/`"; TD26 publishes it as the plugin `plugins/playbook-wiki/` | Rewrite the line after TD26 |
| decision-review-R4 | The release tag differs from Claude Code's current advice | TD22: each release is tagged `v<version>`. https://code.claude.com/docs/en/plugins/dependencies.md, "Create a release tag": "Tag each release as `<plugin-name>--v<version>`", which a version range in `dependencies` resolves. `playbook-agents` depends on `playbook-wiki` with no range | Keep `v<version>`: the three plugins share one version and no range is used. Revisit if a range is ever needed |

## Left as history

The three Doubtful rows: D32 asks whether two ideas of phase 2 were built; D40 whether `codex/install.py` is a command-line tool of the product's own, which codex-support-1 settled by adding Codex; TD24 whether a work needs all four files, which `format.md` settles. None changes what is in force.
