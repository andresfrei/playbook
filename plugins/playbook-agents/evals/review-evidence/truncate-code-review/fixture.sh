#!/bin/bash
# The seeded diff "truncate": writes each agent file through a redirection onto itself.
set -eu
here=$(cd "$(dirname "$0")" && pwd)
exec bash "$here/../seeds/build.sh" "$here/../seeds/truncate" 753e158 \
  "refactor(set-models): write an agent file in place, without a temporary file" "$@"
