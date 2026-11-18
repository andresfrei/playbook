"""Build personal Codex agent definitions from the shared role descriptions."""
import json
from pathlib import Path
import sys

defaults = {
    "explore": ("gpt-6.2-sol", "low"),
    "write": ("gpt-6.2-sol", "medium"),
    "review": ("gpt-6.2-astra", "high"),
}

source, destination = map(Path, sys.argv[1:])
destination.mkdir()
for path in sorted(source.glob("*.md")):
    _, front, instructions = path.read_text(encoding="utf-8").split("---\n", 2)
    fields = dict(line.split(": ", 1) for line in front.strip().splitlines())
    name = fields["name"]
    if name == "review":
        instructions = "Use the playbook-agents:review-change skill to review the change. Read only."
    model, effort = defaults[name]
    role = {
        "name": name,
        "description": fields["description"],
        "model": model,
        "model_reasoning_effort": effort,
        "developer_instructions": instructions.strip(),
    }
    content = "".join(f"{key} = {json.dumps(value, ensure_ascii=False)}\n" for key, value in role.items())
    (destination / f"{name}.toml").write_text(content, encoding="utf-8")
