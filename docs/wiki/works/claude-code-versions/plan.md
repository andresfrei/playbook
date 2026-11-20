# Plan of the work claude-code-versions

## Progress

| Unit | Status | Evidence | Done on | Owner's words |
|------|--------|----------|---------|---------------|
| claude-code-versions-U1 | Done | A new headless session in the worktree lists `evaluate-cli-releases` (control: a made-up name, and the main checkout without the skill, both answer no); with the record at 2.1.330 the commands stop as equal; at 2.1.324, a number Claude Code skipped, they stop as missing; at 2.1.325 they keep 2.1.326 to 2.1.330, 973 lines; body 402 words of 700, description 198 characters of 250; `check-wiki` passes | 2026-11-20 | |
| claude-code-versions-U2 | Not started | | | |

## Units

| ID | Unit | Delivers | Changes | Ends when | Waits for | Accepted by |
|----|------|----------|---------|-----------|-----------|-------------|
| claude-code-versions-U1 | The skill and the record | The skill of [architecture.md](architecture.md), written with `write-skill`, and the record page with 2.1.325 as the last version evaluated, so the first run covers 2.1.326 to 2.1.330 | `.claude/skills/evaluate-cli-releases/SKILL.md`, its two evaluation cases, `docs/wiki/03-technology/claude-code-versions.md`, the page table of `docs/wiki/README.md` | The skill is listed in a new session; with the record equal to the installed version it stops and changes nothing; with a record not found in the changelog it stops and changes nothing; `check-wiki` passes | none | Evidence |
| claude-code-versions-U2 | The first evaluation | The report for 2.1.326 to 2.1.330, the owner's answers, and the record moved to 2.1.330 | `docs/wiki/03-technology/claude-code-versions.md` | Every row of the report has the owner's answer; the record says 2.1.330; `check-wiki` passes | U1 | Judgement: the owner judges whether the report is useful |

## Batches

| Batch | Units | Shared |
|-------|-------|--------|
| 1 | claude-code-versions-U1 | no |
| 2 | claude-code-versions-U2 | no |

- Most `write` agents at once: 0. Both units are built in the main session: U1 follows `write-skill`, U2 needs the owner's answers.
- Worktree preparation: none.

## How the work is delivered

Decided (claude-code-versions-10), as readme-redesign-13: each unit is a commit on `feat/claude-code-versions`; one pull request to `main`, which the owner merges.

## Left out

- Doing what the report proposes: each accepted proposal is a work or a fix of its own (claude-code-versions-5).
- Moving the skill up to `playbook-agents` (claude-code-versions-2).
