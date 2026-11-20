# Design of the work readme-redesign

The README carries the brand designed for the landing in the neuralmind repository: one logo for Playbook everywhere, carried here by a work of this repository (neuralmind playbook-product-14). This page says what the README takes from it. The plugin icons move to the new logo in a later work (readme-redesign-11).

## Identity

- Logo: "Manual con franjas", the open pixel book with its edge drawn as three stripes (neuralmind playbook-product-34). Copied from `public/brand/playbook/` of the neuralmind repository to `docs/assets/playbook-logo.svg`.
- Banner: the landing's social image, `og.png`, copied to `docs/assets/playbook-banner.png`: logo, wordmark, "Your coding agent, with a method.", and the three stripes. A PNG, so GitHub shows the wordmark in Bricolage Grotesque without loading a font.
- Voice: the landing's copy, in English, adapted to Markdown.

## Tokens, for the demo GIF

The VHS tape sets the terminal to the brand's colours:

| Token | Value | In the GIF |
|-------|-------|------------|
| `ink` | `#0e1116` | Terminal background, as the banner |
| `on-ink` | `#e9ecef` | Text |
| `accent` | `#ff5a1f` | Cursor and selection |
| `pb-amber` | `#ffb020` | Yellow of the terminal palette |
| `pb-paper` | `#f2ebdd` | Bright white of the terminal palette |

Font: IBM Plex Mono, the landing's mono, when installed on the machine that records; otherwise VHS's default monospace. Width 1200 px, the banner's, so both align on GitHub.

## Patterns

- Header: banner linking to the landing, then the two badges and the site link on one line.
- Each section: a short heading, one or two sentences, then a list or a table. No section is longer than one screen.
- Long blocks, such as the install prompts, are collapsed in `<details>` (readme-redesign-5).
