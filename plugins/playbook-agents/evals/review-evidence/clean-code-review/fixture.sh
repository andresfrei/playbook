#!/bin/bash
# The seeded diff "clean": a real commit of this repository, 82ae054, with no seeded defect.
set -eu
here=$(cd "$(dirname "$0")" && pwd)
exec bash "$here/../seeds/build.sh" "$here/../seeds/clean" e09c6b0 \
  "fix(doctor): keep the copy of the marker beside it, not in TMPDIR" "$@"
