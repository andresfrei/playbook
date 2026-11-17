---
type: regex
target:
  source: file
  path: package.json
pattern: '^(?![\s\S]*"(dependencies|devDependencies)")[\s\S]*$'
---
