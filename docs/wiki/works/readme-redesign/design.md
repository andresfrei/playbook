# Design of the work readme-redesign

The README carries the brand designed for the landing in the neuralmind repository: one logo for Playbook everywhere, carried here by a work of this repository (neuralmind playbook-product-14). This page says what the README takes from it. The plugin icons move to the new logo in a later work (readme-redesign-11).

## Identity

- Logo: "Manual con franjas", the open pixel book with its edge drawn as three stripes (neuralmind playbook-product-34). Copied from `public/brand/playbook/` of the neuralmind repository to `docs/assets/playbook-logo.svg`.
- Banner: the landing's social image, `og.png`, copied to `docs/assets/playbook-banner.png`: logo, wordmark, "Your coding agent, with a method.", and the three stripes. A PNG, so GitHub shows the wordmark in Bricolage Grotesque without loading a font.
- Voice: the landing's copy, in English, adapted to Markdown.

## The demo console

A static image of one terminal window (readme-redesign-18), 1200 px wide, drawn in HTML:

| Token | Value | In the console |
|-------|-------|----------------|
| `ink` | `#0e1116` | Window background, as the banner |
| `on-ink` | `#e9ecef` | Text |
| `muted` (dark) | `#8f98a3` | Secondary text and the window's title |
| `accent` | `#ff5a1f` | The prompt `❯` and the agent's `●` |
| `pb-amber` | `#ffb020` | Identifiers, such as `rate-limit-1` |
| `pb-paper` | `#f2ebdd` | The answer the owner types |

- Font: IBM Plex Mono, the landing's mono, loaded from Google Fonts when the image is rendered.
- The window: rounded corners, a title bar with three dots and "acme-api", and the logo's three stripes along its foot.
- The dialogue: the owner asks to continue the work `rate-limit`; the agent asks `rate-limit-Q1` with its recommendation; the owner answers; the agent records `rate-limit-1` with the owner's words.

## Patterns

- Header: banner linking to the landing, then the two badges and the site link on one line.
- Each section: a short heading, one or two sentences, then a list or a table. No section is longer than one screen.
- Long blocks, such as the install prompts, are collapsed in `<details>` (readme-redesign-5).
