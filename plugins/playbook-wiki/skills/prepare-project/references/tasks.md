# Tasks at the close of a work

Record the tasks the agent carried out, and propose a dedicated agent for one that repeats (task-agents-3, -4, -5, -6, -8, -10, -11, -12, -18).

## When

At the close of a work, when the sibling plugin `playbook-agents` is installed. Skip silently otherwise.

## Steps

1. Find the script `tasks.sh` of the sibling plugin `playbook-agents`. Run:

   ```sh
   cd "<this skill's folder>" && for p in ../../../playbook-agents/tasks.sh $(ls -d ../../../../playbook-agents/*/tasks.sh 2>/dev/null | awk -F/ '{ print $(NF-1) "\t" $0 }' | sort -t. -k1,1n -k2,2n -k3,3n | tail -n 1 | cut -f2); do [ -f "$p" ] && (cd "$(dirname "$p")" && echo "$(pwd)/tasks.sh"); done | tail -n 1
   ```

   It prints the absolute path found. When it prints nothing, skip the rest of this file, silently. Run every later command from the project's root, with `docs/wiki` as the last argument. When `add` or `set-agent` exits non-zero, show the script's message and skip the rest of this file.
2. Record the tasks. Read the git log since the previous work's close, so steps done after it show, such as the previous work's release (task-agents-18). The previous close is the last merge of a pull request, or the last squashed commit ending in `(#N)`; with none, the whole log:

   ```sh
   base=$(git log -1 --format=%H -E --grep='^Merge pull request|\(#[0-9]+\)$'); git log --format='%h %s' ${base:+$base..}HEAD
   ```

   From that log, the plan, and what was done, list the tasks the agent carried out that it would carry out again in another work, such as `release`, `close-stage`, `record-decision`. For each:
   - name it in kebab-case; when `docs/wiki/tasks.md` already holds the same task, reuse its name;
   - write its steps in one line;
   - run `sh <script> add <task> <work> '<steps>' docs/wiki`, with the steps in single quotes and each `'` in them written as `'\''`, so the shell runs nothing in them.

   Run `sh <script> check docs/wiki`, and show the owner the names recorded.
3. Run `sh <script> count docs/wiki`. Each line "ready: <task>: N works, last DATE" is a task ready. With no such line, skip the rest of this file.
4. Judge the weight of each task ready from its steps (task-agents-5):
   - mechanical steps with fixed commands: `haiku`, effort `low`;
   - steps that write text or judge a small change: `sonnet`, effort `medium`;
   - steps that decide, design, or touch R14 or R20 stay in the main session.

   A task whose steps all stay is not proposed.
5. Propose one task at a time. Ask the owner as the skill says, even when a delegation of kind `other` is in force; write no agent file before the owner answers. Give:
   - its steps and the works that hold it;
   - the model and the effort;
   - the steps that stay in the main session, such as the tag, the push, or the release notes;
   - that the agent goes in the project's `.claude/agents/`, not in the playbook (task-agents-6).
6. On a yes:
   - write `.claude/agents/<task>.md`: front matter with `name`, a one-line `description` that says when to use it, `tools`, `model`, and `effort`; then, as instructions, only the steps that do not stay in the main session, and a line naming the steps left to the main session, after which the agent stops;
   - run `sh <script> set-agent <task> <task> docs/wiki`, then `sh <script> check docs/wiki`;
   - record a decision of kind `other` in the work's `decisions.md`; its shared page is "none";
   - when the task would serve every project, tell the owner it can go up to the playbook, as a proposal the owner carries.
7. On a no, run `sh <script> set-agent <task> declined docs/wiki` and `sh <script> check docs/wiki`, and record a decision of kind `other`, so the task is not proposed again.
