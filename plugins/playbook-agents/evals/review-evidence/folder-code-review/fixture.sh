#!/bin/bash
# The seeded diff "folder": adds a check on the name of a skill, with no test.
set -eu
here=$(cd "$(dirname "$0")" && pwd)
exec bash "$here/../seeds/build.sh" "$here/../seeds/folder" 753e158 \
  "feat(verify): fail a skill whose name is not the name of its folder" "$@"
