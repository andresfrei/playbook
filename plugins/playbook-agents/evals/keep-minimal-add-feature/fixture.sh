#!/bin/bash
set -eu
git init -q -b main .
git config user.email eval@example.com
git config user.name Eval
# Builds a tiny dependency-free Node project for a blog tool.
mkdir -p src test
cat > package.json <<'JSON'
{
  "name": "blog-tools",
  "version": "1.0.0",
  "type": "module",
  "scripts": { "test": "node --test" }
}
JSON
cat > src/greet.js <<'JS'
export function greet(name) {
  return `Hello, ${name}!`;
}
JS
cat > test/greet.test.js <<'JS'
import test from "node:test";
import assert from "node:assert/strict";
import { greet } from "../src/greet.js";

test("greet says hello", () => {
  assert.equal(greet("Ana"), "Hello, Ana!");
});
JS
git add -A
git commit -q -m "feat: greet"
