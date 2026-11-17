---
type: regex
target:
  source: file
  path: style.css
pattern: '^(?![\s\S]*box-shadow:[^;]*rgba\(\s*0\s*,\s*0\s*,\s*0\s*,\s*0?\.(?:0\d?|1\d?|2)\s*\))[\s\S]+$'
---
