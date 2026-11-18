#!/bin/bash
# The seeded diff "dash": a refactor that drops the meaning of the ref "-".
set -eu
here=$(cd "$(dirname "$0")" && pwd)
exec bash "$here/../seeds/build.sh" "$here/../seeds/dash" 753e158 \
  "refactor(merge-step): simplify the check of refs that start with a dash" "$@"
