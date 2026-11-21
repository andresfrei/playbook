import json
from pathlib import Path
import subprocess
import sys

plugin = Path(__file__).resolve().parent
context = (plugin / "contract.md").read_text(encoding="utf-8")
project = json.load(sys.stdin)["cwd"]
notice = subprocess.check_output([
    "sh", plugin / "skills/migrate/scripts/wiki-format.sh", "status",
    Path(project) / "docs/wiki",
], text=True).strip()
if notice:
    context += "\n" + notice

print(json.dumps({"hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": context,
}}))
