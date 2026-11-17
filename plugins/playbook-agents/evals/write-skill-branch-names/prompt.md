---
tags: [write-skill-behaviour]
max_turns: 25
allowed_tools: [Read, Glob, Grep, Skill, Write]
---

Armame una skill en skills/branch-names/ para que el agente revise los nombres de las ramas de git. Tienen que empezar con feat/, fix/ o chore/, seguir en minúsculas con guiones, como feat/user-roles. Se tiene que activar cuando pido "revisá el nombre de esta rama" o "¿está bien esta rama?", y no cuando pido crear una rama. Errores que vimos: "Feature/login", "fix_bug", "feat/UserRoles".
