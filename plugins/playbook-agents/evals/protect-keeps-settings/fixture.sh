#!/bin/bash
# Builds a repository whose local settings already allow a command.
set -eu
git init -q -b main .
git config user.email eval@example.com
git config user.name "Laura Gómez"
mkdir -p .claude
cat > .claude/settings.local.json <<'JSON'
{
  "permissions": {
    "allow": ["Bash(npm test)"]
  }
}
JSON
printf '.claude/settings.local.json\n' > .gitignore
printf 'export const app = {};\n' > app.js
git add -A
git commit -q -m "feat: app"
