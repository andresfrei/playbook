# Technology of the work readme-redesign

What the new README needs from its technology, and what is chosen for each need. Checked on 2026-11-20.

## Needs

| Need | From | Technology | Status |
|------|------|------------|--------|
| N1. Render the README and `docs/how-it-works.md` | readme-redesign-2 | GitHub's Markdown, with Mermaid for the two diagrams, already used by the current README | In use |
| N2. Show the latest release and the license | readme-redesign-4 | shields.io badges, images loaded by the reader's browser | Decided (readme-redesign-4) |
| N3. Show the demo as a designed console in a static WebP image | readme-redesign-18 | `docs/assets/demo.html`, rendered to PNG by a headless Chromium (the one Playwright keeps in its cache, or one named by `CHROME`) and encoded to WebP by ffmpeg with libwebp, both already on the machine | Decided (readme-redesign-18) |

## N3: the demo image

The demo was first an animated GIF recorded with VHS (readme-redesign-3, -8). The first recording showed Claude Code's header, its notices, and a dialogue that varies from run to run; the owner judged it "horrible" and chose a designed console (readme-redesign-18). The VHS candidates are kept here as a record:

| Candidate | Why it was dropped |
|-----------|--------------------|
| VHS v0.12.1 recording a real session | The result depends on the model's answer and on Claude Code's notices and header; it needs a login in an isolated configuration |
| asciinema with agg | Same dependence on a real session, and nothing to re-run |

The image needs no session, no login, and no tokens: the dialogue is text in `docs/assets/demo.html`, and `sh docs/assets/render-demo.sh` writes `docs/assets/demo.webp`. GitHub shows WebP images in Markdown (recalled, checked when the README renders on the pushed branch).

## Architecture

Not applicable: the work changes two documents and adds static assets. The files it adds are listed in the plan.
