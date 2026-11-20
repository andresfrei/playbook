# Definition of the new README

The root `README.md` is the first page a developer sees on GitHub. The current one explains the method in full, with internal vocabulary (work, stage, delegation, evidence level) and two diagrams, before the reader knows why to care. The landing at https://playbook.neuralmind.lat/ already tells the story in a shorter order; the README follows it (readme-redesign-2).

## Who reads it

- A developer who arrives from the landing, a post, or a search, and decides in a few seconds whether Playbook is worth installing.
- A user who wants to install or update it, and needs the commands.
- A contributor, who needs the way into the wiki and the contributing guide.

## Structure

In this order (readme-redesign-2):

1. The banner, linking to the landing; two shields.io badges, the latest release and the license (readme-redesign-4); the site link.
2. What Playbook is, in one line, and for whom.
3. A demo: a designed console as a static WebP image, the agent asking one question and recording the decision (readme-redesign-18).
4. The problem, in three points: decisions vanish in the chat, every session starts from zero, the same mistakes come back.
5. How it works: the six stages, one line each.
6. It learns: review finds a defect, classify stores it as evidence, three hits on one kind, a rule every agent follows.
7. The three plugins, in a short table linking to their guides.
8. Install: the prompts for Claude Code and Codex CLI, each collapsed in a `<details>` block (D154), then "Or by hand": the two Claude Code commands and the Codex installer from a clone (readme-redesign-5).
9. Documentation: a link to `docs/how-it-works.md`, the client guides, the project wiki, and GitHub releases for what is new in each version (readme-redesign-6).
10. Contributing and license.

## What it keeps

- An opening for an outside reader (D150).
- The install prompts, one per client (D154).
- English, as every document of the repository (R12).
- The brand of the landing: the banner and logo come from the neuralmind repository, `public/brand/playbook/`, copied to `docs/assets/`.

## What moves

- "How a change moves through Playbook", its six steps, and the two diagrams move to `docs/how-it-works.md`, unchanged in substance.
- "Explore this repository" shrinks to the documentation links of section 9.

## What it must not do

- Use the method's internal vocabulary before section 9 without saying what it means.
- Repeat what the plugin guides already explain.

## Coverage of the topics

| Topic | Coverage |
|-------|----------|
| The problem, and who has it | Covered: "Who reads it" and the problem section |
| Users and what each does | Covered: "Who reads it" |
| Main flows | Covered: discover, install, contribute |
| What it must do | Covered: "Structure" |
| What it must not do | Covered |
| Qualities | Covered: it renders on GitHub in light and dark themes, without external fonts |
| Limits | Covered: D150, D154, R12 |
| Outside systems | Covered: shields.io for the badges (readme-redesign-4) |
| Volume, operation | Not applicable: one page, kept by the owner at each release |
| Vocabulary | Covered: the glossary, `01-product/glossary.md` |
