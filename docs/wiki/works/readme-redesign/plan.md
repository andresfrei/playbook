# Plan of the work readme-redesign

The units that build the README of [definition.md](definition.md), with the design of [design.md](design.md).

## Progress

| Unit | Status | Evidence | Done on | Owner's words |
|------|--------|----------|---------|---------------|
| readme-redesign-U1 | Done | All 50 non-empty lines of the current README, from the plugin flowchart to the end of the session diagram, are in `docs/how-it-works.md`, with "What happens during a session" raised to a section; 2 Mermaid blocks; its one relative link, `../README.md`, resolves | 2026-11-20 | |
| readme-redesign-U2 | Done | `sh docs/assets/render-demo.sh` writes `docs/assets/demo.webp`, 1200 × 600 px, 43,666 bytes; the image shows rate-limit-Q1 with its recommendation, the answer "yes, 100 per minute", and the row rate-limit-1 with its words, in IBM Plex Mono and the brand's colours | 2026-11-20 | "si, esta bien" |
| readme-redesign-U3 | Built | Every relative link and image resolves; the anchors `#claude-code-prompt` and `#codex-cli-prompt`, linked from `docs/claude-code.md` and `codex/README.md`, are kept; the four install commands match `docs/claude-code.md` and `codex/README.md`; `avoid-generic-design` found no generic pattern; 833 words, down from 1284. Rendering on GitHub waits for the owner | | |

## Units

| ID | Unit | Delivers | Changes | Ends when | Waits for | Accepted by |
|----|------|----------|---------|-----------|-----------|-------------|
| readme-redesign-U1 | How it works | `docs/how-it-works.md`: the six steps of "How a change moves through Playbook" and the two diagrams of the current README, unchanged in substance (readme-redesign-2) | `docs/how-it-works.md` | Each paragraph and both diagrams of the current README's sections are in the page; every relative link in it resolves | none | Evidence |
| readme-redesign-U2 | The demo image | `docs/assets/demo.html`, the console of [design.md](design.md) with its dialogue, and `docs/assets/demo.webp` rendered from it by `docs/assets/render-demo.sh` (readme-redesign-18) | `docs/assets/demo.html`, `docs/assets/render-demo.sh`, `docs/assets/demo.webp` | `sh docs/assets/render-demo.sh` writes the WebP; it is 1200 px wide and at most 500 KB; it shows the question, the answer, and the decision row | none | Judgement: the demo people see |
| readme-redesign-U3 | The README | The root `README.md` in the order of [definition.md](definition.md): banner, badges (readme-redesign-4), demo, problem, stages, learning, plugins, install with prompts in `<details>` and commands by hand, including `python3 codex/install.py --check` (readme-redesign-5), documentation with GitHub releases (readme-redesign-6), contributing, license | `README.md`, `docs/assets/playbook-banner.png`, `docs/assets/playbook-logo.svg`, `docs/assets/playbook-banner.svg` (removed) | Every relative link and image resolves; the install commands match `.claude-plugin/` and `codex/README.md`; `avoid-generic-design` reports no generic pattern left unanswered; the pushed branch renders on GitHub in light and dark themes | readme-redesign-U1, readme-redesign-U2 | Judgement: the README's text |

U3 links to the page U1 writes and shows the image U2 renders, so it waits for both.

## Batches

| Batch | Units | Shared |
|-------|-------|--------|
| 1 | readme-redesign-U1, readme-redesign-U2 | no |
| 2 | readme-redesign-U3 | no |

- Most `write` agents at once: 1. The units are small; they are built one at a time in this worktree.
- Worktree preparation: none. Rendering U2 uses a headless Chromium and ffmpeg, both already on the owner's machine.

## How the work is delivered

Decided (readme-redesign-13):

- Tested nowhere apart: the checks of each unit, and GitHub's rendering of the pushed branch before the merge.
- One pull request for the whole work, from `docs/readme-redesign` to `main`, which the owner merges (R14); the units are commits on that branch.
- Branch names: `<type>/<work>`, as the repository already does.

## Left out

- The plugin icons (readme-redesign-11).
- The plugin READMEs and the client guides, which keep their text.
- A link to the landing's news section, added when it exists (readme-redesign-6).
