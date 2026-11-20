# The repository's README

The root `README.md` is the first page a developer sees on GitHub. It follows the story of the landing at https://playbook.neuralmind.lat/ and leaves the detail to other documents (readme-redesign-2).

## Its order

1. The banner, linking to the landing; two shields.io badges, the latest release and the license (readme-redesign-4); the site link.
2. What Playbook is, in one sentence, for an outside reader (D150).
3. The demo console, `docs/assets/demo.webp` (readme-redesign-18).
4. The problem, the six stages, how Playbook learns from repeated mistakes, and the three plugins.
5. Install: one prompt per client, each collapsed in a `<details>` block under the headings "Claude Code prompt" and "Codex CLI prompt", whose anchors `docs/claude-code.md` and `codex/README.md` link to; then the commands by hand (D154, readme-redesign-5).
6. Documentation: `docs/how-it-works.md`, the client guides, GitHub releases for what is new (readme-redesign-6), and the project wiki.
7. Contributing and license.

## Its assets

| File | What it is |
|------|------------|
| `docs/assets/playbook-banner.png` | The banner: the landing's social image, copied from the neuralmind repository's `public/brand/playbook/og.png` |
| `docs/assets/playbook-logo.svg` | The logo "Manual con franjas", from the same folder |
| `docs/assets/demo.html` | The demo console: a terminal window in the brand's colours with a fixed dialogue (readme-redesign-18) |
| `docs/assets/demo.webp` | The demo console rendered, 1200 px wide, by `sh docs/assets/render-demo.sh` with a headless Chromium and ffmpeg |

To change the demo, edit the dialogue in `docs/assets/demo.html` and run `sh docs/assets/render-demo.sh`. It needs the network for the font; without it, it stops and leaves `demo.webp` as it was.

## How it works, in detail

`docs/how-it-works.md` holds how a change moves through Playbook, step by step, and the two diagrams of the plugins and of a session (readme-redesign-2).

## Not here

The plugin icons stay as plugin-directory-7 drew them, until a work of their own moves them to the new logo (readme-redesign-11).
