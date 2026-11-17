# Plan of plugin-directory

Stage 5. It builds what [definition.md](definition.md), [technology.md](technology.md), and [design.md](design.md) decide.

## Progress

| Unit | Status | Evidence | Done on | Owner's words |
|------|--------|----------|---------|---------------|
| plugin-directory-U1 | Done 2026-11-17, accepted by its evidence | `plugins/playbook-wiki/.claude-plugin/icon.svg` and `plugins/playbook-agents/.claude-plugin/icon.svg` copied from the sources of [design.md](design.md), and each turned into `icon.png` with `convert -background none icon.svg icon.png` (ImageMagick 6.9.12). Run on 2026-11-17: `identify` printed 512x512, 24507 and 26466 bytes; the pixels of each PNG equal those of the draft the owner approved (plugin-directory-7), compared with `cmp`; `claude plugin validate` printed "These checks found nothing to report" for both, with no `ICON_MISSING`; `bash scripts/verify.sh` passed | 2026-11-17 | |
| plugin-directory-U2 | Done 2026-11-17, accepted by the owner's judgement | `plugins/playbook-wiki/README.md` and `plugins/playbook-agents/README.md`, written with `write-docs`: what each holds, a table of each hook with what it reads and does, checked against each script's header and output lines, three example prompts, the install, support, and the licence; `"license": "MIT"` added to both `plugin.json`. No network call in either folder: `grep -E 'curl\|wget\|https?://\|nc \|ssh '` over their scripts and JSON found nothing. Run on 2026-11-17: the READMEs hold 489 and 370 words outside code blocks; `claude plugin validate` printed "These checks found nothing to report" for both, and no longer says it took the README or the licence from the repository's root; `bash scripts/verify.sh` passed; `sh scripts/verify_test.sh` printed "all cases passed" | 2026-11-17 | Asked "¿Aceptás la U2 con estos dos READMEs?"; answered "me parece bien" |
| plugin-directory-U3 | Not started | | | |

## Units

| ID | Unit | Delivers | Ends when | Accepted by |
|----|------|----------|-----------|-------------|
| plugin-directory-U1 | The icons | `.claude-plugin/icon.svg` and `.claude-plugin/icon.png` in `plugins/playbook-wiki/` and `plugins/playbook-agents/`, from the sources of [design.md](design.md) (N6) | Each PNG is 512 by 512 px and under 2 MB, and `claude plugin validate` no longer prints `ICON_MISSING` for either plugin | Evidence: the owner approved the design (plugin-directory-7) |
| plugin-directory-U2 | The README and the licence of each plugin | A `README.md` in each of the two plugin folders, written with `write-docs`: what the plugin is for, what each hook reads, prints, and stops, that nothing leaves the machine, three example prompts, support through the repository's issues, and, for `playbook-agents`, that it needs `playbook-wiki`; `"license": "MIT"` in each `plugin.json` (N1, N2, N7) | `claude plugin validate` passes with no directory warning for either plugin and no longer takes the README or the licence from the repository's root; `bash scripts/verify.sh` exits 0 | Judgement: the reviewer and the people who install read this text |
| plugin-directory-U3 | The portal's Validate | The owner runs Validate in https://claude.ai/directory/manage for each plugin, with this work's branch as the branch; each blocking finding is corrected on the branch (N4) | The portal reports no blocking finding for either plugin | Judgement: only the owner can run the portal and read its report |

U1 and U2 do not depend on each other. U3 needs both, and needs the branch pushed.

## How a unit is delivered

Accepted by the owner (plugin-directory-8), read from how this repository delivers (TD5, D196): the three units are built on this work's branch, `feat/plugin-directory`, one after the other and not in parallel. The branch is pushed before U3, so the portal can read it. The work reaches `main` by one pull request, which the owner merges (R14). No unit changes a script or a hook, so none is risky in the sense of R20.

## Left out

- The submission itself. The directory follows the default branch, so the owner submits each plugin in the portal after this work is merged, and after the release the version recommendation of the closing step leads to.
- Checking, after the listing, that installing `playbook-agents` from the directory brings `playbook-wiki` (N2). It waits for Anthropic's review, which has no date.
- `playbook`, which is not submitted (plugin-directory-1).
- Aligning `write-skill` and its style guide with Anthropic's and agentskills.io's best practices for skills, compared on 2026-11-17: a later work, which the owner asked to note.
