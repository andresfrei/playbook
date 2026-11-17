#!/bin/bash
# Builds a repository with one small module, its tests, and no documentation.
set -eu
git init -q -b main .
git config user.email eval@example.com
git config user.name Eval
mkdir -p src/slugify
cat > package.json <<'JSON'
{
  "name": "shop",
  "version": "1.0.0",
  "type": "module",
  "engines": { "node": ">=18" },
  "scripts": { "test": "node --test src/slugify/" }
}
JSON
cat > src/slugify/index.js <<'JS'
// Turns a title into a URL slug: lowercase, accents removed, words joined by
// the separator. Handles accents, so "Canción" becomes "cancion".
export function slugify(text, options = {}) {
  const separator = options.separator ?? '-';
  const maxLength = options.maxLength ?? 80;
  const slug = text
    .normalize('NFD')
    .replace(/[̀-ͯ]/g, '')
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, separator)
    .replace(new RegExp(`^${separator}+|${separator}+$`, 'g'), '');
  return slug.slice(0, maxLength);
}
JS
cat > src/slugify/index.test.js <<'JS'
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { slugify } from './index.js';

test('lowercases and joins words', () => {
  assert.equal(slugify('Hello World'), 'hello-world');
});

test('removes accents', () => {
  assert.equal(slugify('Canción de cuna'), 'cancion-de-cuna');
});

test('uses the separator option', () => {
  assert.equal(slugify('a b', { separator: '_' }), 'a_b');
});
JS
git add -A
git commit -q -m "feat: slugify module"
