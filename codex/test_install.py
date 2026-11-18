"""Exercise both installer choices with real Codex commands in temporary profiles."""
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

    def test_wiki(self):
        result = self.run_install("1")
        self.assertEqual(result.returncode, 0, result.stderr)
        config = tomllib.loads(self.config.read_text())
        self.assertEqual(set(config["plugins"]), {"playbook-wiki@playbook"})
        self.assertFalse((self.profile / "agents").exists())
        self.assertIn("/hooks", result.stdout)

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
