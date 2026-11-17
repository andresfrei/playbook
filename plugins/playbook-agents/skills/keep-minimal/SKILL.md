---
name: keep-minimal
description: Write or change code, or review a change for unnecessary complexity or overengineering. Keeps an implementation the simplest one that solves the current problem, and reports only the excess in a change.
---

## When to use

- You are about to write or change code.
- The owner asks to review a change for unnecessary complexity, excess, or overengineering.

Do not use it to review a change for correctness, security, or reliability, or to explain what code does.

## Rules

- Choose the simplest solution that solves the current problem and can evolve.
- Every piece of a change serves a requirement that exists today. A piece that no current requirement uses is excess:
  - code for a caller, a case, or an option that nobody has asked for;
  - a layer that only passes a call on;
  - a dependency or a pattern that nothing in the current context justifies;
  - a second way to do what the project already does;
  - a change to code that the current problem does not touch.
- Add a dependency or a pattern only when the current context justifies it, and name that justification.
- Simple never means incorrect or untested. A change in behaviour comes with its tests, and tests of the changed behaviour are never excess.
- The project's own rules win over this skill. What a project rule requires is never excess.
- Leave excess out whole; do not build half of it. Report it as Deferred, with the evidence that would justify adding it later.
- A review reports only excess. It is not a correctness, security, or reliability review, and its report says so.

## Steps

### Before writing or changing code

1. State the current problem in one sentence: the behaviour that must exist when the change is done. Ask the owner when it is not clear.
2. Read the project's rules and the code the change touches.
3. List what the change would add: files, functions, types, options, dependencies, and patterns.
4. For each item, name the current requirement that uses it. Remove every item that has none.
5. For each item left, check whether something already there does its job: the project's own code, a dependency the project already has, the language, or the platform. Use that instead.
6. For each dependency or pattern still on the list, write down what in the current context justifies it. Remove it when there is nothing to write.
7. Write the change, with the tests of the behaviour it changes.
8. Read the finished change and remove any excess that got in.

### Review a change for excess

1. Read the change the owner names. Ask which one when it is not clear.
2. State in one sentence the problem the change solves, from the request, the task, or the commit message. Ask the owner when none of them says.
3. Read the project's rules.
4. List what the change adds, as in step 3 above.
5. Test each item against the Rules. Each item that is excess is one finding.
6. Drop every finding that is a defect, a risk, or a matter of style. They belong to other reviews.
7. Return the report.

## Output

- After writing or changing code, add to the summary of the work:
  - each dependency or pattern added, with its justification;
  - a list titled "Deferred": each thing left out, with the evidence that would justify adding it later.
- After a review, return:
  - a first line: "This review reports only excess. It is not a correctness, security, or reliability review.";
  - the problem the change solves, in one sentence;
  - each finding: where it is, what is excess, what simpler thing replaces it, and the evidence that would justify adding it later;
  - "No excess found." when there are no findings.
