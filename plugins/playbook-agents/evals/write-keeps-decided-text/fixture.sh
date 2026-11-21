#!/bin/bash
set -eu
c=commit
git init -q -b main .
git config user.email eval@example.com
git config user.name "Andres Frei"
mkdir -p docs/wiki hooks
cat > docs/wiki/README.md <<'MD'
# Wiki

| Page | Content | Code it governs |
|------|---------|-----------------|
| [hooks.md](hooks.md) | The guard hook and its prompt | `hooks/` |
MD
cat > docs/wiki/hooks.md <<'MD'
# Hooks

The guard hook asks before any irreversible action. Its prompt text is: "Ask the owner before push, pull requests, and merges." (hooks-3, decided by Andres Frei, who chose "That text, nothing more").
MD
cat > hooks/guard.sh <<'SH'
#!/bin/sh
# Prints the prompt of the guard hook.
echo "Ask the owner before push, pull requests, and merges."
SH
git add -A
git $c -q -m "feat: scaffold"
