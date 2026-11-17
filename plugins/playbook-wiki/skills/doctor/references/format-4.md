# Format 4 — works, and a project's `README.md` with no state

What changed in the format of a wiki, and how a wiki at format 3 reaches format 4.

## What changed

- Each piece of work that one branch carries is a work, with its own folder under `docs/wiki/works/<name>/`: its state, its stage table, its decisions, questions, and plan.
- The project's `README.md` names the project's owner and holds no state: no "Where work stands" section and no stage table of an open phase.
- Decisions written from now on are rows of a work's `decisions.md`, such as `auth-1`. The rows already in `docs/wiki/decisions.md` stay, with their identifiers, and nothing is added to that file. The check does not read it.
- `docs/wiki/.unchecked-decisions` is no longer used. `wiki-format.sh mark` deletes it.

The format is `../../../format.md`. Read its sections "The project's `README.md`" and "A work" before step 1.

## Steps

1. Ask the owner who the project's owner is.
2. Find the open phase: a stage table of `docs/wiki/README.md` with a stage that is neither Closed nor Closed (not applicable). When there is one, ask the owner for the name of the work it becomes, lowercase letters, digits, and hyphens, and who leads it. Recommend the phase's own name, such as `phase-4`, and the project's owner.
3. Show the owner every move of the steps below before making any, as the skill's rules say.
4. Write the project's owner in `docs/wiki/README.md`, after the first section, as `Project owner: <name>.`
5. When there is an open phase, it becomes a work:
   - Create `docs/wiki/works/<name>/README.md` as the format says: what the work is for, who leads it, "Status: Open", then move there the "Where work stands" section and the phase's stage table.
   - A link that moves with the text is relative to `docs/wiki/`, and the work's folder is two levels below it: put `../../` in front of each relative link you move, so that it still resolves. This, and the next item, are the only changes to the moved text.
   - When the moved "Where work stands" holds more than 250 words, or says what is finished, take out what does not belong in it. Delete a sentence that another page of the wiki already holds, and link to that page. Move what is finished to the page of the phase's plan, and link to it. Never open a new section in the work's `README.md` to hold it.
   - In its table of pages, link the pages of that phase where they are. Do not move them.
   - Its earlier decisions keep their `D#`. Say in the work's `README.md` that its decisions up to the last `D#` are in `../../decisions.md`, and that new ones are `<name>-1` onwards in its own `decisions.md`.
6. Move the stage tables of closed phases under a heading `## Phases before format 4` at the end of `docs/wiki/README.md`. When no phase is open, move the "Where work stands" section there too, as `### Where work stands`: a heading of level 2 ends the section.
7. Continue with the last step of the skill. The check refuses the wiki while `README.md` names no owner, or holds a state section or a stage table outside `## Phases before format 4`.
