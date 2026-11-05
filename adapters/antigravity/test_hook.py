#!/usr/bin/env python3
"""Contract tests with temporary projects; no Antigravity install is changed."""
import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

HOOK = Path(__file__).with_name("hook.py")


class HookTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name)
        self.project = self.root / "project"
        self.project.mkdir()
        self.state = self.root / "state"
        self.state.mkdir()
        self.env = dict(os.environ, HARNESS_HOME=str(self.state))
        subprocess.run(["git", "init", "-q", "-b", "main"], cwd=self.project, check=True)
        subprocess.run(["git", "-c", "user.name=test", "-c", "user.email=test@example.invalid", "commit", "-q", "--allow-empty", "-m", "base"], cwd=self.project, check=True)
        self.data = {"workspacePaths": [str(self.project)], "conversationId": "test-session"}

    def tearDown(self):
        self.tmp.cleanup()

    def hook(self, event, **fields):
        payload = dict(self.data, **fields)
        result = subprocess.run(["python3", str(HOOK), event], input=json.dumps(payload), text=True, capture_output=True, env=self.env, check=True)
        return json.loads(result.stdout)

    def pre(self, name, args):
        return self.hook("pre", toolCall={"name": name, "args": args})

    def test_safe_and_blocked_shell_and_approval(self):
        self.assertEqual(self.pre("run_command", {"CommandLine": "git status"})["decision"], "allow")
        self.assertEqual(self.pre("run_command", {"CommandLine": "rm -rf ~"})["decision"], "deny")
        self.assertEqual(self.pre("run_command", {"CommandLine": "git reset --hard"})["decision"], "force_ask")

    def test_secret_paths_and_write_content(self):
        self.assertEqual(self.pre("view_file", {"AbsolutePath": str(self.project / ".env")})["decision"], "deny")
        self.assertEqual(self.pre("view_file", {"AbsolutePath": str(self.project / ".env.example")})["decision"], "allow")
        fake = "ghp_" + "x" * 36
        self.assertEqual(self.pre("write_to_file", {"TargetFile": str(self.project / "x"), "CodeContent": fake})["decision"], "deny")
        self.assertEqual(self.pre("replace_file_content", {"TargetFile": str(self.project / "x"), "ReplacementContent": fake})["decision"], "deny")

    def test_ambiguous_workspace_and_malformed_tool(self):
        self.assertEqual(self.hook("pre", workspacePaths=[], toolCall={"name": "run_command", "args": {}})["decision"], "force_ask")
        self.assertEqual(self.hook("pre", toolCall={})["decision"], "force_ask")
        self.assertEqual(self.pre("run_command", {})["decision"], "force_ask")
        self.assertEqual(self.pre("unmapped_tool", {})["decision"], "allow")

    def test_gate_requires_trust_and_continues_once_on_failure(self):
        check = self.project / ".claude" / "check.sh"
        check.parent.mkdir()
        check.write_text("#!/bin/sh\nexit 1\n")
        check.chmod(0o755)
        self.hook("start")
        (self.project / "change").write_text("changed")
        self.assertEqual(self.hook("stop", fullyIdle=True)["decision"], "stop")
        (self.state / "trusted-projects").write_text(str(self.project) + "\n")
        self.hook("start")
        (self.project / "change").write_text("changed again")
        self.assertEqual(self.hook("stop", fullyIdle=False)["decision"], "stop")
        self.assertEqual(self.hook("stop", fullyIdle=True)["decision"], "continue")
        self.assertEqual(self.hook("stop", fullyIdle=True)["decision"], "stop")


if __name__ == "__main__":
    unittest.main()
