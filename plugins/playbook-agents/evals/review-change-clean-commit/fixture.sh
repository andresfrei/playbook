#!/bin/bash
set -eu
git init -q -b main .
git config user.email eval@example.com
git config user.name Eval
# Builds a repository whose last commit adds a correct, tested chunk() with
# short names that invite style comments.
mkdir -p src test
printf '{ "name": "list-tools", "version": "1.0.0", "type": "module" }\n' > package.json
git add -A
git commit -q -m "chore: package"

cat > src/chunk.js <<'JS'
export function chunk(a, n) {
  if (!Number.isInteger(n) || n < 1) throw new RangeError("size must be a positive integer");
  const out = [];
  for (let i = 0; i < a.length; i += n) out.push(a.slice(i, i + n));
  return out;
}
JS
cat > test/chunk.test.js <<'JS'
import test from "node:test";
import assert from "node:assert/strict";
import { chunk } from "../src/chunk.js";

test("chunk splits with a remainder", () => {
  assert.deepEqual(chunk([1, 2, 3, 4, 5], 2), [[1, 2], [3, 4], [5]]);
});

test("chunk splits exactly", () => {
  assert.deepEqual(chunk([1, 2, 3, 4], 2), [[1, 2], [3, 4]]);
});

test("chunk of an empty list is empty", () => {
  assert.deepEqual(chunk([], 3), []);
});

test("chunk rejects a size below 1", () => {
  assert.throws(() => chunk([1], 0), RangeError);
});
JS
git add -A
git commit -q -m "feat: add chunk"
