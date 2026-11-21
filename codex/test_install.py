"""Exercise both installer choices with real Codex commands in temporary profiles."""
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import tomllib
import unittest

INSTALLER = Path(__file__).with_name("install.py")


class InstallerTest(unittest.TestCase):
    def setUp(self):
        temp = tempfile.TemporaryDirectory()
        self.addCleanup(temp.cleanup)
        self.root = Path(temp.name)
        self.profile = self.root / "profile"
        self.profile.mkdir()
        self.config = self.profile / "config.toml"
        self.config.write_text('[tui]\ncollapse_turn_details = true\n[mcp_servers.example]\ncommand = "example"\n')
        self.env = dict(os.environ, CODEX_HOME=str(self.profile), XDG_DATA_HOME=str(self.root / "data"))

    def run_install(self, choice):
        return subprocess.run([sys.executable, INSTALLER], env=self.env, input=choice + "\n",
                              text=True, capture_output=True)

    def test_check_only(self):
        before = self.config.read_bytes()
        result = subprocess.run([sys.executable, INSTALLER, "--check"], env=self.env,
                                stdin=subprocess.DEVNULL, capture_output=True, text=True)
        self.assertEqual(result.returncode, 0, result.stderr)
        for label in ("Python ", "git version ", "codex-cli ", "Installer requirements met."):
            self.assertIn(label, result.stdout)
        self.assertEqual(self.config.read_bytes(), before)
        self.assertEqual(list(self.profile.iterdir()), [self.config])
        self.assertFalse((self.root / "data").exists())

    def test_missing_commands_before_prompt(self):
        self.env["PATH"] = str(self.root)
        result = self.run_install("1")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("Missing required commands", result.stderr)
        for command in ("git", "codex", "sh", "sed"):
            self.assertIn(command, result.stderr)
        self.assertNotIn("Install Playbook:", result.stdout)

    def test_missing_marketplace_capability(self):
        wrapper = self.root / "codex"
        wrapper.write_text('#!/bin/sh\nif [ "$1" = "--version" ]; then echo codex-cli 9.0; exit 0; fi\n'
                           'echo "unknown subcommand" >&2\nexit 2\n')
        wrapper.chmod(0o755)
        self.env["PATH"] = str(self.root) + os.pathsep + self.env["PATH"]
        result = self.run_install("2")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("codex plugin marketplace list --json", result.stderr)
        self.assertIn("unknown subcommand", result.stderr)
        self.assertNotIn("Install Playbook:", result.stdout)
        self.assertFalse((self.root / "data").exists())

    def test_older_python_reports_minimum(self):
        result = subprocess.run(
            [sys.executable, "-c", "import runpy, sys; sys.version_info = (3, 10, 0); "
             "runpy.run_path(sys.argv.pop(), run_name='__main__')", INSTALLER],
            env=self.env, capture_output=True, text=True)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("Python 3.11 or newer is required", result.stderr)
        self.assertNotIn("Traceback", result.stderr)

    def test_incompatible_marketplace_output(self):
        wrapper = self.root / "codex"
        wrapper.write_text('#!/bin/sh\necho "{}"\n')
        wrapper.chmod(0o755)
        self.env["PATH"] = str(self.root) + os.pathsep + self.env["PATH"]
        result = self.run_install("1")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("Expected a marketplaces list", result.stderr)
        self.assertNotIn("Install Playbook:", result.stdout)

    def test_wiki(self):
        result = self.run_install("1")
        self.assertEqual(result.returncode, 0, result.stderr)
        config = tomllib.loads(self.config.read_text())
        self.assertEqual(set(config["plugins"]), {"playbook-wiki@playbook"})
        self.assertFalse((self.profile / "agents").exists())
        self.assertIn("/hooks", result.stdout)

    def test_review_with_findings_finishes_and_counts_for_commit(self):
        result = self.run_install("2")
        self.assertEqual(result.returncode, 0, result.stderr)
        cache = self.profile / "plugins/cache/playbook/playbook-agents"
        manifest, = cache.glob("*/hooks/hooks.json")
        hooks = json.loads(manifest.read_text())["hooks"]
        repo = self.root / "repo"
        subprocess.run(["git", "init", "-q", repo], check=True)
        (repo / "example.py").write_text("value = 1\n")
        transcript = self.root / "review.jsonl"
        transcript.write_text("")
        env = dict(self.env, PLUGIN_ROOT=str(manifest.parents[1]), PLUGIN_DATA=str(self.root / "state"))

        def run_hook(event, **fields):
            command = hooks[event][0]["hooks"][0]["command"]
            payload = dict(hook_event_name=event, cwd=str(repo), session_id="reviewed", **fields)
            return subprocess.run(["sh", "-c", command], cwd=repo, env=env, check=True,
                                  input=json.dumps(payload), text=True, capture_output=True).stdout

        output = run_hook("SubagentStop", agent_type="review", agent_id="review-1",
                          agent_transcript_path=str(transcript), stop_hook_active=False,
                          last_assistant_message="Finding: the change drops the last record.")
        self.assertEqual(output, "")
        self.assertTrue((self.root / "state/review/reviewed").is_file())
        self.assertEqual(run_hook("PreToolUse", tool_name="Bash",
                                  tool_input={"command": "git commit -m example"}), "")

    def test_installed_work_close(self):
        repo = self.root / "project with spaces"
        wiki = repo / "docs/wiki"
        wiki.mkdir(parents=True)
        def active_versions():
            output = subprocess.check_output(["codex", "plugin", "list", "--marketplace", "playbook", "--json"],
                                             cwd=repo, env=self.env, text=True)
            return {p["name"]: p["version"] for p in json.loads(output)["installed"] if p["enabled"]}

        result = self.run_install("1")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertNotIn("playbook-agents", active_versions())
        result = self.run_install("2")
        self.assertEqual(result.returncode, 0, result.stderr)
        versions = active_versions()
        cache = self.profile / "plugins/cache/playbook"
        prepare = cache / "playbook-wiki" / versions["playbook-wiki"] / "skills/prepare-project"
        agents = (prepare / "../../../../playbook-agents" / versions["playbook-agents"]).resolve()
        self.assertEqual({p.name for p in (agents / "skills").iterdir()},
                         {"avoid-generic-design", "keep-minimal", "review-change", "write-skill"})
        self.assertIn("references/working-agents.md", (prepare / "SKILL.md").read_text())
        guide = (prepare / "references/working-agents.md").read_text()
        self.assertIn(".codex/agents/<task>.toml", guide)
        self.assertIn("record-findings.md", guide)
        self.assertNotIn("CLAUDE_PLUGIN_ROOT", (agents / "record-findings.md").read_text())

        def run_script(name, *args):
            return subprocess.check_output(["sh", agents / name, *args, wiki], cwd=repo, env=self.env, text=True)

        for work in ("one", "two", "three"):
            run_script("tasks.sh", "add", "check-docs", work, "Check the links")
        run_script("tasks.sh", "check")
        self.assertIn("ready: check-docs: 3 works", run_script("tasks.sh", "count"))
        run_script("tasks.sh", "set-agent", "check-docs", "check-docs")
        self.assertEqual(run_script("tasks.sh", "count"), "")

        (wiki / "evidence.md").write_text(
            "# Evidence\n\n## Kinds\n\n| Kind | Level | Rule | Applies when | Source | Scope |\n"
            "|------|-------|------|--------------|--------|-------|\n"
            "| broken-link | 1 | | | review-one | project |\n\n## Evidence\n\n"
            "| Kind | Level | Review | Date | Finding |\n|------|-------|--------|------|---------|\n"
            + "".join(f"| broken-link | 1 | review-{n} | 2026-11-20 | Broken link {n} |\n" for n in range(3)))
        run_script("evidence.sh", "check")
        self.assertIn("ready to consolidate: broken-link (level 1): 3 distinct reviews",
                      run_script("evidence.sh", "count"))
        self.assertIn("stale-reference-after-layout-change", run_script("evidence.sh", "rule", "stale-reference-after-layout-change"))

    def test_package_follows_migrate(self):
        stage = self.root / "stage"
        subprocess.run(["sh", INSTALLER.with_name("package.sh"), stage], check=True)
        wiki = stage / "plugins/playbook-wiki"
        skill = (wiki / "skills/migrate/SKILL.md").read_text()
        self.assertIn("name: migrate", skill)
        for line in ("context: fork", "agent: playbook-wiki:wiki-writer", "disable-model-invocation"):
            self.assertNotIn(line, skill)
        self.assertTrue((wiki / "skills/migrate/agents/openai.yaml").is_file())
        self.assertTrue((wiki / "skills/migrate/scripts/wiki-format.sh").is_file())
        old = "doc" + "tor"
        self.assertFalse((wiki / "skills" / old).exists())
        self.assertFalse((wiki / "agents").exists())
        self.assertIn("<wiki plugin root>/format.md", (wiki / "wiki-writer.md").read_text())
        for path in wiki.rglob("*"):
            if path.is_file():
                self.assertNotIn(old, path.read_text(errors="ignore"), path)
        # Codex substitutes no Claude Code variable: none may reach a packaged file.
        for path in stage.rglob("*"):
            if path.is_file():
                text = path.read_text(errors="ignore")
                for variable in ("${CLAUDE_SKILL_DIR}", "${CLAUDE_PLUGIN_ROOT}"):
                    self.assertNotIn(variable, text, path)
        for skill_file in ("prepare-project", "write-docs"):
            text = (wiki / "skills" / skill_file / "SKILL.md").read_text()
            self.assertIn("<this skill's folder>/../migrate/scripts/wiki-format.sh", text)
        self.assertIn("wiki-writer.md", skill)
        self.assertNotIn("starts you again", skill)

    def test_concurrent_publication(self):
        from concurrent.futures import ThreadPoolExecutor
        other = self.root / "second-profile"
        other.mkdir()
        def install(profile):
            return subprocess.run([sys.executable, INSTALLER], input="2\n", text=True,
                                  capture_output=True, env=dict(self.env, CODEX_HOME=str(profile)))
        with ThreadPoolExecutor(max_workers=2) as pool:
            results = list(pool.map(install, (self.profile, other)))
        for result in results:
            self.assertEqual(result.returncode, 0, result.stderr)
        for profile in (self.profile, other):
            self.assertTrue((profile / "agents/review.toml").is_file())

    def test_full_after_failure_and_rerun(self):
        real_codex = shutil.which("codex")
        wrapper = self.root / "codex"
        wrapper.write_text('#!/bin/sh\nif [ "$3" = "playbook-agents@playbook" ]; then exit 9; fi\nexec "$REAL_CODEX" "$@"\n')
        wrapper.chmod(0o755)
        old_path = self.env["PATH"]
        self.env.update(PATH=str(self.root) + os.pathsep + old_path, REAL_CODEX=real_codex)
        failure = self.run_install("2")
        self.assertNotEqual(failure.returncode, 0)
        self.assertIn("playbook-agents@playbook", failure.stderr)
        self.env["PATH"] = old_path
        result = self.run_install("2")
        self.assertEqual(result.returncode, 0, result.stderr)
        roles = self.profile / "agents"
        defaults = {p.stem: tomllib.loads(p.read_text()) for p in roles.glob("*.toml")}
        self.assertEqual({n: (r["model"], r["model_reasoning_effort"]) for n, r in defaults.items()},
                         {"explore": ("gpt-6.2-sol", "low"), "write": ("gpt-6.2-sol", "medium"),
                          "review": ("gpt-6.2-astra", "high")})
        scratch = roles / "scratch.toml"
        scratch.write_text("name =")
        alternate = roles / "team-review.toml"
        (roles / "review.toml").rename(alternate)
        custom = roles / "write.toml"
        custom.write_text('name = "custom"\n')
        result = self.run_install("2")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn(str(scratch), result.stderr)
        self.assertEqual(scratch.read_text(), "name =")
        self.assertIn(str(alternate), result.stdout)
        self.assertFalse((roles / "review.toml").exists())
        self.assertIn(str(custom), result.stdout)
        self.assertEqual(custom.read_text(), 'name = "custom"\n')
        config = tomllib.loads(self.config.read_text())
        self.assertTrue(config["tui"]["collapse_turn_details"])
        self.assertEqual(config["mcp_servers"]["example"]["command"], "example")
        self.assertTrue(config["plugins"]["playbook-agents@playbook"]["enabled"])


if __name__ == "__main__":
    unittest.main()
