# The first run of audit

The first run adopts the project: it turns the knowledge the project already holds into the playbook's wiki and rules. The owner guides and decides each medium step; you do the work.

## Before you start

1. Run `git rev-parse --is-inside-work-tree`. Outside git, stop and ask the owner to run `git init`: without git, the run cannot be undone.
2. Run `git status --porcelain`. When it lists anything, stop and ask the owner to commit or stash it, so that all the run changes is one diff.

## Steps

1. **Inventory.** List what the project knows. For a wide repository, use a search agent, so the files do not fill the conversation.
   - Inside the repository: the README files; `docs/`, a 4.x wiki in `docs/wiki/` among them; `CLAUDE.md`, nested ones too; `AGENTS.md`; `.claude/rules/` and `.claude/skills/`; records of decisions, such as `docs/adr/`; other tools' rules or memory, such as `.cursor/rules/`, `.clinerules`, or `memory-bank/`.
   - Outside it: `~/.claude/CLAUDE.md` and the auto memory index, to report only; the plugins on at any scope, from `claude plugin list`, for step 5.
2. **Propose the order.** Show one table: each file, what it holds, and what to do with it: keep, merge into another, move into the wiki (and to which page), or delete. Documentation for the software's users stays where it is. Ask the owner one topic at a time.
3. **Build `docs/playbook/`.**
   - `README.md`: the product in two lines, the owner, the open work, and the pages.
   - `product.md`, `technology.md`, `skills.md`, and `design.md` when the project has an interface. Each statement cites its decision, or is marked Open when nobody knows why. Write only what the code does not say: what the code or its configuration shows, such as the test runner or the indentation, stays out.
   - A reason the project already wrote, such as a record of a decision or a section of a README, is shown to the owner to confirm. On a yes it becomes a decision that quotes the owner and names its source; without an answer, the statement keeps its reason and is marked Open.
   - Move the works of a 4.x wiki unchanged into `docs/playbook/works/`, so their IDs and the owner's words stay.
   - Record the owner's new answers in `docs/playbook/works/audit-<date>/decisions.md`, with five columns, `| ID | Date | Decision | Who decided | Their words |`, and IDs `audit-<date>-<n>`.
4. **Clean the rules.** For `CLAUDE.md`, `AGENTS.md`, and `.claude/rules/`, show per file what you would cut and apply it on the owner's yes:
   - cut what Claude can derive from the code, such as layouts, dependency lists, and architecture overviews;
   - move each reason into the wiki;
   - keep pitfalls and "always do X" rules;
   - remove pointers to an old wiki, since each session now starts with `docs/playbook/README.md`.

   Where a project rule contradicts the playbook's rules, ask which stands. The project's wins unless the owner changes it.
5. **Turn off what competes.** What competes is another memory, a plugin or server that saves and recalls the project's knowledge, such as engram or claude-mem; another wiki or spec workflow; or a skill that does the job of `define`, `close`, `audit`, or `release`. For each, at any scope, the user's included, propose turning it off for this repository only:
   - a plugin: `claude plugin disable <name>@<marketplace> --scope local`;
   - a skill: `"<name>": "off"` under `skillOverrides` in `.claude/settings.local.json`.

   Files outside the repository, such as `~/.claude/CLAUDE.md` or the auto memory, are only reported: change nothing there.
6. Delete what the owner chose to delete, such as an old wiki whose content moved. Run `sh "${CLAUDE_PLUGIN_ROOT}/scripts/check-wiki.sh" docs/playbook` and fix what it lists.

Then go on with step 1 of `SKILL.md`: the audit of the new wiki against the code.
