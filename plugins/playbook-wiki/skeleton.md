# The skeleton of a wiki

The steps that write a wiki's skeleton in a repository that has none (setup-commands-2, setup-commands-3). `/playbook-wiki:init` and `prepare-project`, for a new project, both do them. `<plugin>` is the folder of `playbook-wiki`, two levels above the folder of the skill that reads this file. Run each command from the project's root.

Ask one question at a time, with a recommendation, using AskUserQuestion when available. Ask only what the person's message does not already say.

1. Ask who the project's owner is, the person who decides what every work shares. Recommend the `user.name` of git, the person running the command. Accept another name.
2. Propose what the project is, in one or two sentences, from the repository's `README.md` and code when they exist, and ask the person to confirm or correct it.
3. Write `docs/wiki/README.md`, the format of `<plugin>/format.md`, "The project's `README.md`", with a table of pages that has only its header:

   ```markdown
   # <Project name>

   <What the project is.> This wiki wins over any other document; inside it, a decision wins over the rest.

   Project owner: <name>.

   Every statement is one of:

   - **Decided**: accepted by the owner, a row of a work's `decisions.md`.
   - **Proposed**: a recommendation waiting for the owner's answer.
   - **Open**: a question in a work's `questions.md`.

   ## Pages

   | Page | Content | Code it governs |
   |------|---------|-----------------|
   ```

4. Run `sh <plugin>/skills/doctor/scripts/wiki-format.sh mark docs/wiki`. It writes `docs/wiki/.format`; never write that file by hand. When it fails, show its message, repair the `README.md`, and run it again.
5. Ask whether to add to the project's `CLAUDE.md` the two sentences of the format, "The project's instruction file". On a yes, create the file when missing; in a file that exists, add the two sentences and change nothing else.
