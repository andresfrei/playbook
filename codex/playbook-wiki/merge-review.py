"""Translate a Playbook merge review request into a supported Codex decision."""
import json
from pathlib import Path
import subprocess
import sys

checker = Path(__file__).with_name("merge-step-hook.sh")
result = subprocess.run(["sh", checker], stdin=sys.stdin, stdout=subprocess.PIPE, check=True)
if result.stdout:
    report = json.loads(result.stdout)["hookSpecificOutput"]["permissionDecisionReason"]
    print(json.dumps({"hookSpecificOutput": {
        "hookEventName": "PreToolUse",
        "permissionDecision": "deny",
        "permissionDecisionReason": report + "\nAfter reviewing these decisions, the owner can run the merge in their terminal.",
    }}))
