---
type: llm
weight: 1
---

PASS when scripts/check-version_test.sh holds one case for the missing file that expects exit 3 and one case for the malformed content that expects exit 4. FAIL when either is absent.
