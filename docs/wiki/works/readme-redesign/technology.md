# Technology of the work readme-redesign

What the new README needs from its technology, and what is chosen for each need. Checked on 2026-11-20.

## Needs

| Need | From | Technology | Status |
|------|------|------------|--------|
| N1. Render the README and `docs/how-it-works.md` | readme-redesign-2 | GitHub's Markdown, with Mermaid for the two diagrams, already used by the current README | In use |
| N2. Show the latest release and the license | readme-redesign-4 | shields.io badges, images loaded by the reader's browser | Decided (readme-redesign-4) |
| N3. Record the demo as an animated GIF of a real session, and re-record it when the flow changes | readme-redesign-3 | VHS, from `docs/assets/demo.tape` | Decided (readme-redesign-8) |

## N3: recording the GIF

The demo shows the agent asking one question and recording the decision (readme-redesign-3). The session is a TUI, Claude Code, whose answers vary from run to run.

| Candidate | What it gains | What it gives up |
|-----------|---------------|------------------|
| VHS v0.12.1, charmbracelet, MIT | A `.tape` script in the repository types the prompt, waits for screen text (`Wait+Screen /regex/`), and writes the GIF; re-recording is one command | Needs `vhs` and `ttyd` installed; `ffmpeg` 8.1 is already present. Each recording runs a real session, which spends tokens and can differ |
| asciinema recorder, then agg v1.9.0, GPL-3.0 | Records a session played by hand, with no script | Nothing to re-run: each new GIF is played again by hand. Two tools, agg built with Cargo |
| A screen recorder, then ffmpeg to GIF | No new tool beyond ffmpeg | Pixel video, heavy GIF, and nothing reproducible |

Chosen: VHS (readme-redesign-8). Its tape lives in `docs/assets/demo.tape`, so re-recording is reproducible as readme-redesign-3 asks. The tools are installed only when the owner asks for that step.

Sources: https://github.com/charmbracelet/vhs (release v0.12.1, read 2026-11-20; the year of that release was not shown), https://github.com/asciinema/agg (release v1.9.0, read 2026-11-20).

## Architecture

Not applicable: the work changes two documents and adds static assets. The files it adds are listed in the plan.
