---
tags: [write-behaviour]
plugins: ["../.."]
max_turns: 30
allowed_tools: [Read, Glob, Grep, Write, Edit, Bash, Agent]
---

Start the playbook-agents:write agent for this. Paths it may change: scripts/check-version.sh and scripts/check-version_test.sh. Task: make check-version.sh exit 3 with a message when the file given as $1 does not exist, and exit 4 with a message when its content is not three numbers joined by dots (such as 1.2.3). Check to run: sh scripts/check-version_test.sh.
