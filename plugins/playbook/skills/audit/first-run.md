# The first run of audit

The first run adopts the project: it turns the knowledge the project already holds into the playbook's wiki and rules. The owner guides and decides each medium step; you do the work.

## Before you start

1. Run `git rev-parse --is-inside-work-tree`. Outside git, stop and ask the owner to run `git init`: without git, the run cannot be undone.
2. Run `git status --porcelain`. When it lists anything, stop and ask the owner to commit or stash it, so that all the run changes is one diff.

## Steps

1. **Inventory.** List what the project knows. For a wide repository, use a search agent, so the files do not fill the conversation.
   - Inside the repository: the README files; `docs/`, a 4.x wiki in `docs/wiki/` among them; `CLAUDE.md`, nested ones too; `AGENTS.md`; `.claude/rules/` and `.claude/skills/`; records of decisions, such as `docs/adr/`; the rules or memory files of other coding tools.
   - Outside it, to report only: `~/.claude/CLAUDE.md` and the auto memory index. Change nothing of the user's level; the project's auto memory changes on the owner's yes (one-audit-1, one-audit-5).
2. **Propose the order.** Show one table: each file, what it holds, and what to do with it: keep, merge into another, move into the wiki (and to which page), or delete. Documentation for the software's users stays where it is. Ask the owner one topic at a time.
3. **Build `docs/playbook/`.** When it already exists, as `define` creates it for a new project, keep its pages and decisions and add to them.
   - `README.md`: the product in two lines, the owner, the open work, and the pages.
   - `product.md`, what the product does, for whom, and its rules; `technology.md`, each technology with why and its version; `skills.md`, the skills and tools the agent uses for each job of building this repository, not the skills the product ships; and `design.md` when the project has an interface. Each statement cites its decision, or is marked Open when nobody knows why.
   - Keep the pages short: write only what someone changing the code needs and cannot read in it. Lists of modules, skills, or settings the code shows stay out, and so do the test runner and the indentation.
   - Records of what is finished, such as the pages and plans of past phases, old measurements, and pages of data the project no longer uses: propose deleting them, since git keeps them.
   - A reason the project already wrote, such as a record of a decision or a section of a README, is shown to the owner to confirm. On a yes it becomes a decision that quotes the owner and names its source; without an answer, the statement keeps its reason and is marked Open.
   - Move the works of a 4.x wiki unchanged into `docs/playbook/works/`, so their IDs and the owner's words stay. Leave their links as they are: the check follows links only in works with a `spec.md`, and an old link may point to a page that git keeps.
   - Record the owner's new answers in the `decisions.md` of the open work, or in `docs/playbook/works/audit-<date>/decisions.md` when no work is open, with five columns, `| ID | Date | Decision | Who decided | Their words |`, and IDs `<work>-<n>`, such as `audit-<date>-<n>`.
4. **Clean the rules.** For `CLAUDE.md`, `AGENTS.md`, and `.claude/rules/`, show per file what you would cut and apply it on the owner's yes:
   - cut what Claude can derive from the code, such as layouts, dependency lists, and architecture overviews;
   - move each reason into the wiki;
   - keep pitfalls and "always do X" rules;
   - remove pointers to an old wiki, since each session now starts with `docs/playbook/README.md`.

   Where a project rule contradicts the playbook's rules, ask which stands. The project's wins unless the owner changes it.
5. Delete what the owner chose to delete, such as an old wiki whose content moved. Run `sh "${CLAUDE_PLUGIN_ROOT}/scripts/check-wiki.sh" docs/playbook` and fix what it lists.

Then go on with step 2 of `SKILL.md`: the explorers read the new wiki against the code, the setup, and the tools.
