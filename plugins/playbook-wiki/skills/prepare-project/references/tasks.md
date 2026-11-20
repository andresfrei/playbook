# Tasks at the close of a work

Record the tasks the agent carried out, and propose a dedicated agent for one that repeats (task-agents-3, -4, -5, -6, -8, -10, -11, -12, -18).

## When

At the close of a work, when the sibling plugin `playbook-agents` is installed. Skip silently otherwise.

## Steps

1. Locate `tasks.sh` using the client's working-agent instructions. If the agents plugin is unavailable, skip the rest of this file silently. Run subsequent commands from the project root with the quoted absolute script path. If `add` or `set-agent` fails, show its message and stop this procedure.
2. Record the tasks. Read the git log since the previous work's close, so steps done after it show, such as the previous work's release (task-agents-18). The previous close is the last merge of a pull request, or the last squashed commit ending in `(#N)`, that is not a release; with none, the whole log:

   ```sh
   base=$(git log --format='%H %s' -E --grep='^Merge pull request|\(#[0-9]+\)$' | grep -iv release | head -n 1 | cut -d' ' -f1); git log --format='%h %s' ${base:+$base..}HEAD
   ```

   From that log, the plan, and what was done, list the tasks the agent carried out that it would carry out again in another work, such as `release`, `close-stage`, `record-decision`. For each:
   - name it in kebab-case; when `docs/wiki/tasks.md` already holds the same task, reuse its name;
   - write its steps in one line;
   - run `sh <script> add <task> <work> '<steps>' docs/wiki`, with the steps in single quotes and each `'` in them written as `'\''`, so the shell runs nothing in them.

   Run `sh <script> check docs/wiki`, and show the owner the names recorded.
3. Run `sh <script> count docs/wiki`. Each line "ready: <task>: N works, last DATE" is a task ready. With no such line, skip the rest of this file.
4. Choose the model and effort for each ready task using the client's working-agent instructions (task-agents-5). Keep decisions, design, and steps touching R14 or R20 in the main session. If every step stays there, skip the proposal.
5. Propose one task at a time. Ask the owner as the skill says, even when a delegation of kind `other` is in force; write no agent file before the owner answers. Give:
   - its steps and the works that hold it;
   - the model and the effort;
   - the steps that stay in the main session, such as the tag, the push, or the release notes;
   - the project-local profile path from the client's working-agent instructions (task-agents-6).
6. On a yes:
   - create the profile in the format from the client's working-agent instructions. Include only the delegated steps and end by naming the steps left to the main session;
   - after verifying that the project contains the approved profile, run `sh <script> set-agent <task> <task> docs/wiki`, then `sh <script> check docs/wiki`. A failed write or unresolved name collision leaves the task pending;
   - record a decision of kind `other` in the work's `decisions.md`; its shared page is "none";
   - when the task would serve every project, tell the owner it can go up to the playbook, as a proposal the owner carries.
7. On a no, run `sh <script> set-agent <task> declined docs/wiki` and `sh <script> check docs/wiki`, and record a decision of kind `other`, so the task is not proposed again.
