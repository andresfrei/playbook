# audit

The skill `/playbook:audit` audits what sets up Claude in a project. On its first run it adopts the project; afterwards it reports each contradiction, limit passed, and collision for the owner to resolve.

## When it runs

- The owner runs `/playbook:audit` or asks for an audit, or says yes when one is offered: when the session start recommends it ([adopt](adopt.md)), before a release, when [close](close.md) suggests it, or after installing or removing a tool.
- The argument `wiki`, `setup`, or `tools` runs that part alone; with none it runs all three.
- The first run happens when `docs/playbook/README.md` is missing or has no line starting with `Last audit:`. It does the adoption first, in the main session, and then runs all three parts whatever the argument.

## What it reads

- First run: the project's README files, `docs/` (including a 4.x wiki in `docs/wiki/`), `CLAUDE.md`, `AGENTS.md`, `.claude/rules/`, `.claude/skills/`, records of decisions, and other coding tools' rules or memory files. Outside the repository it only reports `~/.claude/CLAUDE.md` and the auto memory index.
- Wiki part: the shared pages of `docs/playbook/` against the code, the other pages, and the newest decision on each subject; it also runs the [wiki](wiki.md) check and looks for the missing definitions (product and owner, technology and versions, how a change is checked, `Versioning:`, `Delivery default:`).
- Setup part: the output of `startup-context.sh`, `claude -p "/skill-doctor"`, and `claude -p "/context"`, and the files they list, against the documentation's limits.
- Tools part: `claude plugin list`, `claude mcp list`, `.mcp.json`, and the skills, agents, and hooks under `.claude/`, for collisions with the playbook.
- Each part is explored by an [auditor](auditor.md) agent; the main session reads every `decisions.md` to cross each finding with decisions already taken.

## What it writes

- First run: `docs/playbook/` (`README.md`, `product.md`, `technology.md`, `skills.md`, `design.md` when there is an interface), the works of a 4.x wiki moved unchanged into `docs/playbook/works/`, a cleaned `CLAUDE.md`, `AGENTS.md`, and `.claude/rules/`, and the files the owner chose to delete. It starts only from a clean git tree inside a git repository.
- A decision for each answer the owner gives, in the open work's `decisions.md` or in `docs/playbook/works/audit-<date>/decisions.md`.
- Light fixes (such as a broken link) and each change the owner says yes to.
- When the wiki part ran, the line `Last audit:` in `docs/playbook/README.md`, without asking.
- It changes nothing at the user's level (such as `~/.claude/CLAUDE.md`) unless the owner asks for it explicitly.

## What it asks the owner

- On the first run, the order for each file (keep, merge, move into the wiki, delete), one topic at a time, and each reason it proposes to record as a decision.
- Then one question per finding, one at a time, after the single table of findings is shown: which side of a contradiction is right, whether to define a missing item or leave it Open, what to do with each collision or limit passed, and whether to hide skills never used.

## Connects to

- [auditor](auditor.md), the agent that explores each part.
- [adopt](adopt.md), the hook that recommends it, and [close](close.md) and [define](define.md), which offer it.
- [wiki](wiki.md), [rules](rules.md), and [audit-learning](audit-learning.md).

Source: [plugins/playbook/skills/audit/SKILL.md](../../plugins/playbook/skills/audit/SKILL.md), [first-run.md](../../plugins/playbook/skills/audit/first-run.md)
