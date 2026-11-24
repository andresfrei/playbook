# Decisions of the work skill-usage

| ID | Date | Decision | Who decided | Their words |
|----|------|----------|-------------|-------------|
| skill-usage-1 | 2026-11-24 | Open the work `skill-usage`. The setup part of `audit` runs `claude -p "/skill-doctor"` in its explorer and reports the skills loaded but never used, with their context cost, so the audit measures the user's skills by their real use and not only by their listing (one-audit-5). Found when the owner ran `/skill-doctor` after the third audit of 2026-11-24: 18 skills never used, about 3.6k tokens of listing per turn. | Andres Frei | "skill doctor deveria ser parte de la auditoria de playbook corriendo en un subagente para obtener esa info valiosa"; then "sí, definamos el work" |
| skill-usage-2 | 2026-11-24 | The skills never used are one finding per source of the report (claude.ai sync, user, project, plugin), as `/skill-doctor` groups its own verdict, not one finding per skill. For each, the owner hides all, picks which, or leaves them. | Andres Frei | Chose "Un hallazgo por origen (Recomendado)" |
| skill-usage-3 | 2026-11-24 | The owner accepts the spec of `skill-usage`: one unit, U1, the setup part of `audit` runs `/skill-doctor` and reports the skills never used, one finding per source. | Andres Frei | Chose "Sí, aceptado (Recomendado)" |
