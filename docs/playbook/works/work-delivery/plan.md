# Plan of work-delivery

Stage 5. It builds what [definition.md](definition.md) and [technology.md](technology.md) decide.

## Progress

| Unit | Status | Evidence | Done on | Owner's words |
|------|--------|----------|---------|---------------|
| work-delivery-U1 | Done | Step 5 of `plugins/playbook-wiki/skills/prepare-project/references/5-plan.md` rewritten, with "Project already started" and the closing condition; the file has 55 lines and 772 words. Run on 2026-11-18: `bash scripts/verify.sh` printed "verify passed: playbook-wiki loads 337 words at session start, limit 350; playbook-agents loads 615, limit 620"; `sh scripts/verify_test.sh` printed "all cases passed"; `claude plugin validate plugins/playbook-wiki` passed; the check of the wiki passed | 2026-11-19 | Asked "¿Aceptás U1 con este texto?"; answered "si" |
| work-delivery-U2 | Done | Step 2 and the close of step 6 of `plugins/playbook-wiki/skills/prepare-project/references/6-execution.md` changed: each unit is delivered as the delivery decisions say; the work goes to where it is tested and waits for the owner's check, whose fixes are units of the same work; "before it is merged" became "before its last merge". Run on 2026-11-19: `bash scripts/verify.sh` passed with the same counts as U1; `sh scripts/verify_test.sh` printed "all cases passed"; `claude plugin validate plugins/playbook-wiki` passed; the check of the wiki passed | 2026-11-19 | Asked "¿Aceptás U2 con este texto?"; answered "si" |
| work-delivery-U3 | Done | Two cases in `plugins/playbook-wiki/evals/`: `prepare-project-delivery-names-risk` and `prepare-project-delivery-asks-where-tested`, each with `skill-loaded.md`; `shellcheck` passed on both fixtures, and each built its repository. The agent `review` read U1 to U3 on 2026-11-19 and found five faults, all fixed: both graders failed a correct first reply that asks one question; stage 6 wrote the shared pages after a merge to a shared test branch, so the check of the test place moved after them; "still recommend a work branch" became "a way that keeps that branch whole"; the no-merge grader matched `git merge-base`; the cases lacked `skill-loaded.md`. After the fixes, on 2026-11-19: `bash scripts/verify.sh` passed, `sh scripts/verify_test.sh` printed "all cases passed", `claude plugin validate plugins/playbook-wiki` passed, the check of the wiki passed. The paid run was not made | 2026-11-19 | |

## Units

| ID | Unit | Delivers | Ends when | Accepted by |
|----|------|----------|-----------|-------------|
| work-delivery-U1 | The delivery step of stage 5 | Step 5 of `plugins/playbook-wiki/skills/prepare-project/references/5-plan.md` rewritten as the delivery step: the project's own skill and git as sources (work-delivery-2, -6), where the work is tested (work-delivery-8), the production branch confirmed, the three ways of integrating with their cost (work-delivery-5), the risk warning (work-delivery-6), and the default branch names (work-delivery-3). "Project already started" and the closing condition follow | `bash scripts/verify.sh` exits 0, `sh scripts/verify_test.sh` prints "all cases passed", and the check of the wiki passes | Judgement: it is the text of a definition |
| work-delivery-U2 | The delivery and the close in stage 6 | Step 2 of `plugins/playbook-wiki/skills/prepare-project/references/6-execution.md` delivers each unit as the delivery decision says; the close of the work waits for the owner's check where the work is tested, and its fixes are units of the same work (work-delivery-8) | The same checks as U1 | Judgement: it is the text of a definition |
| work-delivery-U3 | Two evaluation cases | Two cases in `plugins/playbook-wiki/evals/`: a started repository whose history merges each unit into its test branch, where the agent recommends a work branch and names the risk; a new project with only `main`, where the agent asks where the work is tested before recommending (work-delivery-10). The agent `review` reads U1 to U3 (R20) | `bash scripts/verify.sh` exits 0 with the cases, and the review's findings are fixed or answered. The paid run of the cases happens only when the owner asks (skill-triggering-3) | Evidence |

## How a unit is delivered

Decided (work-delivery-14): the units are built in order, one at a time, on this work's branch, `feat/work-delivery`. No unit is built in parallel: U2 and U3 read the text of U1. The work is tested nowhere apart, only by the checks of each unit and the evaluation cases. It reaches `main` by one pull request, which the owner merges (R14).

## Left out

- A rule about delivery in `plugins/playbook-agents/rules.md` (work-delivery-9).
- Changing `plugins/playbook-wiki/format.md`, which already says a work is one branch.
- The version of the plugins: when the work closes, the repository's `CLAUDE.md` asks for it (github-release-2).
