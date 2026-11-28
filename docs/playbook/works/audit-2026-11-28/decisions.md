# Decisions of the audit of 2026-11-28

| ID | Date | Decision | Who decided | Their words |
|----|------|----------|-------------|-------------|
| audit-2026-11-28-1 | 2026-11-28 | The audit's wiki finding is resolved for the code: `docs/playbook/technology.md` line 6 says `jq` is needed "for the reading of the answered dialogs in `audit-learning`" (dialog-learning-6), and `README.md` line 62 said "The `/playbook:permissions` wizard and `/playbook:presets` need `jq` on your PATH." The README now names `/playbook:audit-learning` too. | Andres Frei | Asked which side is right: "El código (Recomendado)" |
| audit-2026-11-28-2 | 2026-11-28 | The audit's setup finding is left as it is: `CLAUDE.md` line 21, "A rare loss in the plugin's files on the owner's machine when two sessions write at the same moment is accepted when the fix would change how they are stored: record it as a decision and the code's comment, do not ask", loads in every session though it applies only to the scripts and hooks that store data. A delegation is a line of `CLAUDE.md` (R6). Chosen over a rule with `paths:`. | Andres Frei | Chose "Dejarla (Recomendado)" |
