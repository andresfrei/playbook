# Design of plugin-directory

Stage 4. The product has no screens; its one visual piece is the icon of each submitted plugin (plugin-directory-3). Tokens and patterns do not apply: there is no interface to build.

## Identity

| Part | Choice | Status |
|------|--------|--------|
| Shape | A square of 512 px with rounded corners, an open book in the middle; the book is the wiki | Decided (plugin-directory-7) |
| `playbook-wiki` | A check mark on the right page: the wiki and its check | Decided (plugin-directory-7) |
| `playbook-agents` | Three joined dots on the right page: the agents that work on the wiki | Decided (plugin-directory-7) |
| Colours | Ink `#1E2B3A` for the ground and the lines of text; paper `#F4EDE1` and `#E8DFCF` for the pages; one accent, `#D9643A`, for the sign of each plugin | Decided (plugin-directory-7) |

The two SVGs and their PNGs are drawn in stage 6, at `.claude-plugin/icon.svg` and `.claude-plugin/icon.png` of each plugin. Stage 6 copies them from the sources below, which the owner approved on 2026-11-17, and turns each into a 512 px PNG with ImageMagick: `convert -background none icon.svg icon.png`.

## `playbook-wiki`

```svg
<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512">
<rect width="512" height="512" rx="112" fill="#1E2B3A"/>
<path d="M256 176 C210 146 150 140 96 148 L96 372 C150 364 210 370 256 400 Z" fill="#F4EDE1"/>
<path d="M256 176 C302 146 362 140 416 148 L416 372 C362 364 302 370 256 400 Z" fill="#E8DFCF"/>
<g stroke="#1E2B3A" stroke-opacity="0.35" stroke-width="14" stroke-linecap="round">
<line x1="132" y1="214" x2="222" y2="222"/><line x1="132" y1="258" x2="222" y2="266"/><line x1="132" y1="302" x2="198" y2="308"/></g>
<polyline points="298,272 334,308 390,232" fill="none" stroke="#D9643A" stroke-width="30" stroke-linecap="round" stroke-linejoin="round"/>
</svg>
```

## `playbook-agents`

```svg
<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512">
<rect width="512" height="512" rx="112" fill="#1E2B3A"/>
<path d="M256 176 C210 146 150 140 96 148 L96 372 C150 364 210 370 256 400 Z" fill="#F4EDE1"/>
<path d="M256 176 C302 146 362 140 416 148 L416 372 C362 364 302 370 256 400 Z" fill="#E8DFCF"/>
<g stroke="#1E2B3A" stroke-opacity="0.35" stroke-width="14" stroke-linecap="round">
<line x1="132" y1="214" x2="222" y2="222"/><line x1="132" y1="258" x2="222" y2="266"/><line x1="132" y1="302" x2="198" y2="308"/></g>
<g stroke="#D9643A" stroke-width="12" stroke-linecap="round"><line x1="336" y1="226" x2="302" y2="304"/><line x1="336" y1="226" x2="378" y2="304"/><line x1="302" y1="304" x2="378" y2="304"/></g>
<g fill="#D9643A"><circle cx="336" cy="226" r="22"/><circle cx="302" cy="304" r="22"/><circle cx="378" cy="304" r="22"/></g>
</svg>
```
