import json
from pathlib import Path

rules = Path(__file__).with_name("rules.md").read_text(encoding="utf-8")
print(json.dumps({"hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": rules,
}}))
