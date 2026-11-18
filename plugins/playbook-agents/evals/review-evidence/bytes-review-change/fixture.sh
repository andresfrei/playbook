#!/bin/bash
# The seeded diff "bytes": counts the characters of a description with wc -c.
set -eu
here=$(cd "$(dirname "$0")" && pwd)
exec bash "$here/../seeds/build.sh" "$here/../seeds/bytes" 753e158 \
  "fix(verify): count a description's characters the same way on every platform" "$@"
