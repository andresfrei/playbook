#!/bin/bash
# The seeded diff "limit": raises the body limit of a skill from 700 to 800 words.
set -eu
here=$(cd "$(dirname "$0")" && pwd)
exec bash "$here/../seeds/build.sh" "$here/../seeds/limit" 753e158 \
  "chore(verify): give a skill's body room for its examples" "$@"
