"""Install Playbook from this checkout with the user's Codex CLI."""
import argparse
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


def codex_output(*args, env=None):
    command = ["codex", *args]
    result = subprocess.run(command, capture_output=True, text=True, env=env)
    if result.returncode:
        raise ValueError(f"Required command failed: {' '.join(command)}\n{result.stderr.strip()}")
    return result.stdout.strip()


def list_marketplaces(env=None):
    output = codex_output("plugin", "marketplace", "list", "--json", env=env)
    data = json.loads(output)
    entries = data.get("marketplaces") if isinstance(data, dict) else None
    if not isinstance(entries, list):
        raise ValueError("Expected a marketplaces list from codex plugin marketplace list --json.")
    for entry in entries:
        if not isinstance(entry, dict) or not isinstance(entry.get("name"), str):
            raise ValueError("Missing marketplace name in Codex output.")
        if entry["name"] == "playbook" and not isinstance(entry.get("root"), str):
            raise ValueError("Missing playbook marketplace root in Codex output.")
    return entries


def check_requirements():
    version = sys.version.split()[0]
    print(f"Python {version}")
    if sys.version_info < (3, 11):
        raise ValueError(f"Python 3.11 or newer is required (found {version}).")

    commands = ("git", "codex", "sh", "python3", "dirname", "mkdir", "cp", "sed")
    missing = [name for name in commands if not shutil.which(name)]
    if missing:
        raise ValueError("Missing required commands on PATH: " + ", ".join(missing))

    print(subprocess.check_output(["git", "--version"], text=True).strip())
    # Even read-only CLI commands can initialize files in the Codex profile.
    with tempfile.TemporaryDirectory() as profile:
        env = dict(os.environ, CODEX_HOME=profile)
        print(codex_output("--version", env=env))
        list_marketplaces(env)
        codex_output("plugin", "marketplace", "add", "--help", env=env)
        codex_output("plugin", "add", "--help", env=env)
    print("Installer requirements met.")


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
    import tomllib

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
    for marketplace in list_marketplaces():
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
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true", help="check requirements and exit")
    args = parser.parse_args()
    try:
        check_requirements()
        if not args.check:
            install()
    except (OSError, ValueError, EOFError, subprocess.CalledProcessError) as error:
        sys.exit(f"Installation stopped: {error}")
