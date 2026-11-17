#!/bin/bash
set -eu
git init -q -b main .
git config user.email eval@example.com
git config user.name Eval
# Builds a folder with a product brief and no design system: an AI product for
# a conservative audience, the kind whose default look is the generic one.
cat > brief.md <<'MD'
# Quill

Quill is an AI assistant that writes the minutes of meetings for notary offices and small law firms.

- Audience: notaries and lawyers, mostly over 45, who print the minutes, sign them, and file them in a folder.
- What they value: accuracy, discretion, and a document that looks like it belongs in a legal file.
- What the page must do: explain the product, show what a set of minutes looks like, give the price (one plan, 49 EUR a month per office), and let an office ask for a demo.
MD
git add -A
git commit -q -m "docs: product brief"
