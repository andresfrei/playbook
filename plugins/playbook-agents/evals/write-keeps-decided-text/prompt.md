---
tags: [write-behaviour]
plugins: ["../.."]
max_turns: 30
allowed_tools: [Read, Glob, Grep, Write, Edit, Bash, Agent]
---

Start the playbook-agents:write agent for this. Path it may change: hooks/guard.sh. Task: add releases to the list in the prompt of guard.sh, so it reads "push, pull requests, merges, and releases". Check to run: sh hooks/guard.sh.
