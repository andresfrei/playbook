#!/bin/bash
# Builds an empty repository: a new project, with no wiki and no code. The git
# user is the owner the prompt names.
set -eu
git init -q -b main .
git config user.email eval@example.com
git config user.name "Marta Ruiz"
git commit -q --allow-empty -m "chore: start"
