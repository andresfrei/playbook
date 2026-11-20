# Plan of the work readme-redesign

The units that build the README of [definition.md](definition.md), with the design of [design.md](design.md).

## Progress

| Unit | Status | Evidence | Done on | Owner's words |
|------|--------|----------|---------|---------------|
| readme-redesign-U1 | Done | All 50 non-empty lines of the current README, from the plugin flowchart to the end of the session diagram, are in `docs/how-it-works.md`, with "What happens during a session" raised to a section; 2 Mermaid blocks; its one relative link, `../README.md`, resolves | 2026-11-20 | |
| readme-redesign-U2 | Not started | | | |
| readme-redesign-U3 | Not started | | | |

## Units

| ID | Unit | Delivers | Changes | Ends when | Waits for | Accepted by |
|----|------|----------|---------|-----------|-----------|-------------|
| readme-redesign-U1 | How it works | `docs/how-it-works.md`: the six steps of "How a change moves through Playbook" and the two diagrams of the current README, unchanged in substance (readme-redesign-2) | `docs/how-it-works.md` | Each paragraph and both diagrams of the current README's sections are in the page; every relative link in it resolves | none | Evidence |
| readme-redesign-U2 | The demo GIF | `docs/assets/demo.tape` with the tokens of [design.md](design.md), and `docs/assets/demo.gif` recorded from it with VHS: a real Claude Code session in a throwaway project with Playbook, where the agent asks one question and records the decision (readme-redesign-3, -8) | `docs/assets/demo.tape`, `docs/assets/demo.gif` | `vhs docs/assets/demo.tape` writes the GIF; it is 1200 px wide and at most 5 MB; its frames show the question and the decision row | none | Judgement: the demo people see |
| readme-redesign-U3 | The README | The root `README.md` in the order of [definition.md](definition.md): banner, badges (readme-redesign-4), demo, problem, stages, learning, plugins, install with prompts in `<details>` and commands by hand, including `python3 codex/install.py --check` (readme-redesign-5), documentation with GitHub releases (readme-redesign-6), contributing, license | `README.md`, `docs/assets/playbook-banner.png`, `docs/assets/playbook-logo.svg`, `docs/assets/playbook-banner.svg` (removed) | Every relative link and image resolves; the install commands match `.claude-plugin/` and `codex/README.md`; `avoid-generic-design` reports no generic pattern left unanswered; the pushed branch renders on GitHub in light and dark themes | readme-redesign-U1, readme-redesign-U2 | Judgement: the README's text |

U3 links to the page U1 writes and shows the GIF U2 records, so it waits for both.

## Batches

| Batch | Units | Shared |
|-------|-------|--------|
| 1 | readme-redesign-U1, readme-redesign-U2 | no |
| 2 | readme-redesign-U3 | no |

- Most `write` agents at once: 1. The units are small; they are built one at a time in this worktree.
- Worktree preparation: none. Recording U2 needs `vhs` and `ttyd` installed on the owner's machine, only when the owner asks for that step (readme-redesign-8).

## How the work is delivered

Decided (readme-redesign-13):

- Tested nowhere apart: the checks of each unit, and GitHub's rendering of the pushed branch before the merge.
- One pull request for the whole work, from `docs/readme-redesign` to `main`, which the owner merges (R14); the units are commits on that branch.
- Branch names: `<type>/<work>`, as the repository already does.

## Left out

- The plugin icons (readme-redesign-11).
- The plugin READMEs and the client guides, which keep their text.
- A link to the landing's news section, added when it exists (readme-redesign-6).
