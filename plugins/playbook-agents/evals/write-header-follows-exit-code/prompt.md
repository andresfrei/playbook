---
tags: [write-behaviour]
plugins: ["../.."]
max_turns: 30
allowed_tools: [Read, Glob, Grep, Write, Edit, Bash, Agent]
---

Start the playbook-agents:write agent for this. Path it may change: scripts/check-todo.sh. Task: make check-todo.sh exit 2 with a message when the file given as $1 does not exist. Check to run: sh scripts/check-todo.sh README.md; echo $?.
