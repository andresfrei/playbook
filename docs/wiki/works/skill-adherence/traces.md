# What the traces of skill-triggering show

Read on 2026-11-17 from the traces that `claude plugin eval --keep-temp` left in `/tmp/claude-eval-*`, found through the `--json` reports of skill-triggering's measurements (skill-adherence-3). Nothing was run again. The traces live in `/tmp` and a reboot deletes them; what matters is quoted here.

## skill-triggering-Q6: `prepare-project` asks more than one thing

Case `prepare-project-new-project-stage-one`, U5, the three runs with the plugin. The owner's brief is a booking app for a dental clinic. The skill loaded in each run.

| Run | Grader `one-question` | How the last answer ends |
|-----|-----------------------|--------------------------|
| 1 | failed | Two numbered questions: whether to create `CLAUDE.md`, then "how many dentists does the clinic have, and should each time slot belong to a dentist?" |
| 2 | passed | "How many dentists and chairs does the clinic have, and do treatments differ in length?" |
| 3 | failed | The same question as run 2, after asking the owner to run `wiki-format.sh mark` or to allow writes in the sandbox |

What they show:

- The question in the three runs is the example of the skill's gotcha, almost word for word: "How many dentists are there, and do treatments differ in length?". The gotcha was written from the trace of this same case in U2, so the example the skill gives of what not to do is the question the case calls for, and the agent asks it.
- The judge passed run 2, whose question asks two things, and failed run 3 with the same question. The grader does not separate one question that asks two things from two questions.
- In the three runs `Bash` could not write the project's folder in the sandbox of the run, though `Write` could. `wiki-format.sh mark` failed, and each answer asked the owner for something else besides the question: run the script, or change the sandbox.

## skill-triggering-Q7: the report of `review-change` changes before it reaches the owner

Case `review-change-clean-commit`, U6, the three runs with the plugin. The commit has no defect. The skill loaded in each run and ran in its fork.

What the forked agent returned, in the three runs:

- It says "No findings." in 3 of 3. The measurement of U6 read otherwise.
- Before it, a section "What the change is meant to do". Step 3 of the skill asks for that sentence; its Output does not say where it goes.
- After it, a list of the cases checked, which the Output does not ask for.
- "Not checked" in 3 of 3, which names input with no rule, such as `chunk(null, 2)`, as something it cannot show.

What the session wrote last, in the three runs:

- It rewrote the report each time: "found no defects" in 2 of 3, "no findings" in 1, with its own sections, advice such as adding a `test` script, and a closing line such as "Pushing and opening it are your call". The description's "show its report unchanged" did not hold in any run.
- The fork's result reaches the session as a tool result, "Skill … completed (forked execution). Result: …", and the session writes its own message after it. Whether Claude Code can pass that result to the owner as it is was not checked.
- The judge of `no-padding` failed 3 of 3 runs, also the one whose last message says "no findings". It counts the remarks under "Not checked" about input with no rule as findings, which the Output asks the report to name.

## skill-triggering-Q5: a small task done without the skill

Case `keep-minimal-triggers`, U5, the three runs with the plugin. The request holds the whole change in its text: an interface, a class, a factory, an option, and a package, to show a price in one place.

- In the two runs that did not load the skill, the agent called no tool and answered at once. It named each of the five parts as excess and gave the one line the task needs, as the skill asks.
- In the run that loaded it, the answer followed the skill's Output, and said it read only the description and not the diff.
- The case is a case of triggering, so it still counts whether the skill loads (skill-adherence-2). Its request needs no file, which the agent treats as a small task.
