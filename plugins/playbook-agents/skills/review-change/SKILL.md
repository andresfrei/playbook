---
name: review-change
description: Review a change for defects before it is committed or merged, such as the last commit, a diff, staged or uncommitted work, or what was just pushed ("is anything broken?"). Returns only findings, each with a failing case.
context: fork
agent: playbook-agents:review
---

## When to use

- The owner or the main agent asks for a review of a change: a diff, a commit or commit range, a branch, or the working tree.

Do not use it to review for unnecessary complexity (use `keep-minimal`), to review a design, or to explain what code does.

## Rules

- You are a reader that has not seen the conversation. Work only from the request and the repository.
- Read only. Never edit, create, or delete a file. Run only commands that read.
- One read, one report. Do not ask questions, and do not apply fixes.
- Report only a defect that makes the change wrong, and only one you can show:
  - behaviour that differs from what the change is meant to do;
  - behaviour that differs from what the project's wiki says is Decided for the part the change touches;
  - a path the change touches that the wiki lists as changed when next touched, and that the change leaves on the old definition;
  - an edge case that fails: empty, missing, boundary, or repeated input, or a failure path;
  - data loss or corruption;
  - a security problem: unchecked input, exposed secret, missing permission check;
  - changed behaviour with no test that would fail if it broke.
- Leave out style, naming, formatting, preference, and anything you cannot show with a concrete case.
- A defect that was already there before the change is not a finding. Say so in one line under "Not checked".

## Steps

1. Find the change:
   - Use the diff, range, branch, or files the request names.
   - When the request names none, review the uncommitted changes (`git diff HEAD`, plus untracked files). When there are none, review the last commit. State which one you reviewed.
2. Read the change, then the code around it that it calls or is called by. Read the tests that cover it. When the repository has `docs/wiki/`, find in the page table of its `README.md` the pages that govern the paths the change touches, and read them.
3. State in one sentence what the change is meant to do, from the request or the commit message. When nothing says, infer it from the diff and mark it as inferred.
4. For each rule above, look for a defect. Keep a candidate only when you can name the input and the wrong result.
5. Drop every candidate you cannot show. Order the rest from most severe to least.

## Output

- Start with the change you reviewed, in one line.
- Findings, most severe first. Each one holds:
  - the file and line;
  - what is wrong;
  - a concrete case that fails: the input and the wrong result;
  - the fix, in one line.
- When there are no findings, say "No findings." plainly.
- End with "Not checked": what you did not read, run, or could not show.
