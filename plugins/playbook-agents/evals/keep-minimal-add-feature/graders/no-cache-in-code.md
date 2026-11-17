---
type: regex
target:
  source: file
  path: src/products.js
pattern: '^(?![\s\S]*(?:[Cc]ache|TTL|ttl|[Ee]xpir|[Oo]ptions|maxSize|memoiz))[\s\S]+$'
---
