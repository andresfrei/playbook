# Spec of the work skill-usage

Status: Accepted (skill-usage-3)

Delivery: one branch and one pull request per work (delivery-versioning-2).

## What and why (skill-usage-1)

The setup part of `audit` measures what loads at startup by its size (one-audit-3, one-audit-5), but not whether it is used. Claude Code's report `/skill-doctor` gives that: each skill in the listing, its source, its context cost, its uses, and when it was last used. Its documentation: "Every skill in the skill listing adds to your context on every turn, whether or not Claude ever uses it. Run `/skill-doctor` to see what each of your skills costs and how often it gets used" and "In non-interactive mode with `-p`, Claude Code prints it as text" (skills.md, Find unused skills). Run in this repository on 2026-11-24, it flagged 18 skills never used, about 3.6k tokens of listing per turn.

## What changes

In the skill `audit`, the setup part:

1. **The explorer runs the report.** After `startup-context.sh`, it runs `claude -p "/skill-doctor"` in the project, a command that reads. It reports the skills the report flags as loaded but never used, with no threshold of its own (one-audit-3).
2. **One finding per source** (skill-usage-2): one for each source of the report that has skills never used (claude.ai sync, user, project, plugin), with the skills, their context cost, and the report's verdict line as the quote. The level follows the source: a plugin's skills are the plugin's, a project's skills the project's, the rest the user's.
3. **The proposal.** For a skill of the user, the project, or claude.ai sync: hide it from this project's listing with the menu `/skills`, which writes `skillOverrides` to `.claude/settings.local.json`; the state `user-invocable-only` takes it out of the listing and keeps `/name`. For a plugin's skill: `/plugin`, since "Plugin skills are not affected by `skillOverrides`" (skills.md). The main session asks one finding at a time: hide all, pick which, or leave them; a "leave it" is recorded as any other (audit-decided-1).
4. **When the report fails**, such as before Claude Code v2.1.252 or in a session that skips feature flags, the explorer says so and the part goes on.

## Out of scope

- A threshold of uses or of tokens (one-audit-3).
- Changing a skill or a file of the user's level without the owner asking for it explicitly (one-audit-5).
- The report's 7-day token column, which attributes cost to skills that ran, not to the listing.

## Check

- `sh plugins/playbook/scripts/check-wiki.sh docs/playbook` and `claude plugin validate .`.
- Live check: `/playbook:audit setup` in this repository shows the skills never used as one finding per source, each with its cost, and asks one at a time.

## Units

| Unit | What | Check | State |
|------|------|-------|-------|
| U1 | The setup part of `audit` as above, and the line of `product.md` that says what the setup part reads | The checks above | Pending |
