# Decisions of the work agent-runs-skills

| ID | Date | Decision | Who decided | Their words |
|----|------|----------|-------------|-------------|
| agent-runs-skills-1 | 2026-11-22 | Replaces "Started only by the owner (`disable-model-invocation: true`)" of basics-26 and the row of `release` in the spec of basics. The skills `audit-wiki`, `audit-tools`, and `release` drop `disable-model-invocation: true`: the agent offers each in one line where the playbook recommends it (the session start, `define`, `close`) and runs it on the owner's yes. Push, pull request, merge, and release still ask through the hooks. | Andres Frei | Asked "¿Lo tomamos como un cambio de la definición, sacando la marca de los tres skills para que el agente los proponga y los corra con tu confirmación?": "si" |
