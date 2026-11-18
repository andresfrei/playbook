"""Install Playbook from this checkout with the user's Codex CLI."""
import errno
import filecmp
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import tomllib


def publish_marketplace(root):
    """Publish complete packages before atomically replacing the small catalog."""
    root.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(dir=root) as temporary:
        stage = Path(temporary) / "market"
        subprocess.run(["sh", Path(__file__).with_name("package.sh"), stage], check=True)
        index = Path(".agents/plugins/marketplace.json")
        catalog = json.loads((stage / index).read_text())
        for entry in catalog["plugins"]:
            package = stage / entry["source"]["path"]
            digest = hashlib.sha256()
            for path in sorted(package.rglob("*")):
                if path.is_file():
                    digest.update(str(path.relative_to(package)).encode() + b"\0")
                    digest.update(hashlib.sha256(path.read_bytes()).digest())
            relative = Path("builds") / entry["name"] / digest.hexdigest()
            target = root / relative
            target.parent.mkdir(parents=True, exist_ok=True)
            try:
                package.rename(target)
            except OSError as error:
                if error.errno not in (errno.ENOTEMPTY, errno.EEXIST) or not target.is_dir():
                    raise
            entry["source"]["path"] = "./" + str(relative)
        (stage / index).write_text(json.dumps(catalog, indent=2) + "\n")
        (root / index).parent.mkdir(parents=True, exist_ok=True)
        os.replace(stage / index, root / index)
    agents = next(p for p in catalog["plugins"] if p["name"] == "playbook-agents")
    return root / agents["source"]["path"] / "roles"


def install_roles(source, destination):
    destination.mkdir(parents=True, exist_ok=True)
    declared = {}
    config = destination.parent / "config.toml"
    if config.exists():
        for name, entry in tomllib.loads(config.read_text()).get("agents", {}).items():
            if isinstance(entry, dict):
                declared[name] = config
    for path in destination.glob("*.toml"):
        if path.is_file():
            try:
                name = tomllib.loads(path.read_text()).get("name")
            except (tomllib.TOMLDecodeError, UnicodeDecodeError) as error:
                print(f"Keeping unreadable profile: {path} ({error})", file=sys.stderr)
                continue
            if isinstance(name, str):
                declared[name] = path
    for profile in sorted(source.glob("*.toml")):
        target = destination / profile.name
        existing = declared.get(profile.stem)
        if existing and existing != target:
            print(f"Keeping existing profile: {existing} ({profile.stem})")
            continue
        with tempfile.NamedTemporaryFile(dir=destination) as staged:
            with profile.open("rb") as stream:
                shutil.copyfileobj(stream, staged)
            staged.flush()
            try:
                os.link(staged.name, target)
            except FileExistsError:
                if target.is_symlink() or not target.is_file() or not filecmp.cmp(profile, target, shallow=False):
                    print(f"Keeping existing profile: {target}")


def install():
    choice = input("Install Playbook: [1] wiki only, [2] wiki and agents: ").strip()
    if choice not in {"1", "2"}:
        raise ValueError("Choose 1 or 2.")
    data = Path(os.environ.get("XDG_DATA_HOME") or Path.home() / ".local/share")
    root = (data / "playbook-codex-marketplace").absolute()
    listing = subprocess.check_output(["codex", "plugin", "marketplace", "list", "--json"])
    for marketplace in json.loads(listing)["marketplaces"]:
        if marketplace["name"] == "playbook" and Path(marketplace["root"]).resolve() != root.resolve():
            raise ValueError(f"Marketplace playbook already uses {marketplace['root']}. Resolve the name conflict first.")
    roles = publish_marketplace(root)
    subprocess.run(["codex", "plugin", "marketplace", "add", root], check=True)
    subprocess.run(["codex", "plugin", "add", "playbook-wiki@playbook"], check=True)
    plugins = "playbook-wiki"
    if choice == "2":
        subprocess.run(["codex", "plugin", "add", "playbook-agents@playbook"], check=True)
        profile = Path(os.environ.get("CODEX_HOME") or Path.home() / ".codex")
        install_roles(roles, profile / "agents")
        plugins += " and playbook-agents"
    print(f"Open /hooks and review the hooks from {plugins}. Trust them, then start a new session.")


if __name__ == "__main__":
    try:
        install()
    except (OSError, ValueError, EOFError, subprocess.CalledProcessError) as error:
        sys.exit(f"Installation stopped: {error}")
