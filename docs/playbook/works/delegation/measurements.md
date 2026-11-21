# Measurements of the work delegation

How the owner answered the questions that became recorded decisions. Measured on 2026-11-19 by the agent, reading only.

## Method

- Source: every decision row with the owner's words in nine wikis on the owner's machine: this repository (`docs/wiki/decisions.md` and `docs/wiki/works/*/decisions.md`), and the wikis of radar, unlink, huellitas-id, viba, brand-factory, huellitas-social, genesis, and neuralmind. 1063 rows.
- Each answer is sorted by the owner's words:
  - plain yes: an affirmation with nothing added, such as "si", "acepto", "Sí, cerrarla";
  - recommended: the option marked "(Recomendado)" or "(Recommended)" chosen with nothing added;
  - yes but: an affirmation with an addition or a change, such as "si, pero autorizo a que lo hagas tu";
  - menu option: another option of a dialog;
  - own words: anything else.
- "Accepted as is" is plain yes plus recommended.
- Each row is sorted by kind with keywords of the decision's text: closing a stage or a work, merge or push or commit, accepting a unit or a list, version or release, opening a work, and definition for the rest.

## By kind of question, all nine wikis

| Kind | Rows | Accepted as is |
|------|------|----------------|
| Close a stage or a work | 131 | 83% |
| Merge, push, or commit | 104 | 63% |
| Accept a unit or a list | 63 | 60% |
| Definition | 703 | 50% |
| Version or release | 55 | 49% |

## By project

| Project | Rows | Plain yes | Recommended | Accepted as is | Yes but | Own words |
|---------|------|-----------|-------------|----------------|---------|-----------|
| playbook | 404 | 36% | 12% | 48% | 8% | 20% |
| neuralmind | 27 | 33% | 66% | about 100% | 0% | 0% |
| genesis | 142 | 16% | 56% | 72% | 4% | 23% |
| viba | 79 | 24% | 51% | 75% | 3% | 18% |
| huellitas-id | 216 | 22% | 41% | 63% | 6% | 28% |
| unlink | 92 | 16% | 31% | 47% | 15% | 36% |
| brand-factory | 31 | 35% | 0% | 35% | 3% | 61% |
| radar | 59 | 3% | 18% | 21% | 40% | 35% |

The rest of each row is menu options; huellitas-social, 13 rows, is left out of this table.

In this repository alone, plain yes grew from 28% of the rows in `docs/wiki/decisions.md` to 48% of the rows in the works, after D208 had asked the agent to ask only what written decisions cannot resolve.

## What it shows

- Closing a stage is accepted as is in every wiki: 83%.
- How often a definition is accepted as is depends on the project: about 12% plain yes in this repository, where the owner is the domain, but 72% to 100% in genesis, viba, and neuralmind, and 21% in radar, where 40% of the answers change what was proposed.
- An answer accepted as is does not show that the recommendation was right: it may not have been read, as the owner said before D208, "terminas no leyendo nada y aprobando sin leer".

## Limits

- The kind of question comes from keywords, so some rows are in the wrong kind.
- "Recommended" is only seen where a dialog marked its option; elsewhere a chosen option may also be the one the agent recommended.
- Only questions that became a recorded decision are counted. Questions such as "¿avanzo?" left no row, so the real count of automatic yeses is higher.
