#!/bin/bash
set -eu
git init -q -b main .
git config user.email eval@example.com
git config user.name Eval
# Builds a repository whose last commit adds average(), which returns NaN for
# an empty list. The working tree is clean.
mkdir -p src test
cat > src/stats.js <<'JS'
export function sum(numbers) {
  return numbers.reduce((a, b) => a + b, 0);
}
JS
git add -A
git commit -q -m "feat: sum"

cat > src/stats.js <<'JS'
export function sum(numbers) {
  return numbers.reduce((a, b) => a + b, 0);
}

export function average(numbers) {
  return sum(numbers) / numbers.length;
}
JS
cat > test/stats.test.js <<'JS'
import test from "node:test";
import assert from "node:assert/strict";
import { average } from "../src/stats.js";

test("average of 1, 2, 3 is 2", () => {
  assert.equal(average([1, 2, 3]), 2);
});
JS
git add -A
git commit -q -m "feat: add average"
