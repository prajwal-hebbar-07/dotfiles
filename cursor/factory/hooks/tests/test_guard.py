#!/usr/bin/env python3
"""Port of the behavioural cases in omp/hooks/tests/factory-guard.test.ts."""
from __future__ import annotations

import json
import os
import shutil
import subprocess
import tempfile
import unittest

HERE = os.path.dirname(os.path.abspath(__file__))
HOOKS = os.path.dirname(HERE)
import sys

sys.path.insert(0, HOOKS)
import factory_guard as g  # noqa: E402
import factory_stage as s  # noqa: E402


def sh(cwd, *args):
    return subprocess.check_output(["git", "-C", cwd, *args], text=True).strip()


def repo(state=None):
    dir_ = tempfile.mkdtemp(prefix="fguard-")
    dir_ = os.path.realpath(dir_)
    sh(dir_, "init", "-q", "-b", "main")
    sh(dir_, "config", "user.email", "t@t")
    sh(dir_, "config", "user.name", "t")
    with open(os.path.join(dir_, "a.txt"), "w", encoding="utf-8") as f:
        f.write("a")
    os.makedirs(os.path.join(dir_, "docs", "factory"))
    with open(os.path.join(dir_, "docs", "factory", "REQUIREMENTS.md"), "w", encoding="utf-8") as f:
        f.write("r")
    sh(dir_, "add", ".")
    sh(dir_, "commit", "-q", "-m", "init")
    head = sh(dir_, "rev-parse", "HEAD")
    if state is not None:
        os.makedirs(os.path.join(dir_, ".factory"), exist_ok=True)
        text = state if isinstance(state, str) else json.dumps(state)
        with open(os.path.join(dir_, ".factory", "state.json"), "w", encoding="utf-8") as f:
            f.write(text)
    return dir_, head


def guarded(**extra):
    base = {"version": 1, "guard": True, "gates": {}, "prApprovals": {}}
    base.update(extra)
    return base


class GuardTest(unittest.TestCase):
    def setUp(self):
        self.dirs = []

    def tearDown(self):
        for d in self.dirs:
            shutil.rmtree(d, ignore_errors=True)

    def make(self, state=None):
        d, head = repo(state)
        self.dirs.append(d)
        return d, head

    def bash(self, dir_, command, subagent=None):
        payload = {"hook_event_name": "beforeShellExecution", "command": command, "cwd": dir_}
        if subagent:
            payload["subagent_type"] = subagent
        return g.decide(payload)

    def blocked(self, result, pattern=None):
        self.assertEqual(result.get("permission"), "deny", result)
        self.assertTrue(str(result.get("agent_message", result.get("user_message", ""))).startswith("factory"), result)
        if pattern:
            self.assertRegex(result.get("agent_message") or result.get("user_message") or "", pattern)

    def allowed(self, result):
        self.assertEqual(result.get("permission"), "allow", result)

    def test_merge_blocked(self):
        d, _ = self.make(guarded())
        self.blocked(self.bash(d, "gh pr merge 12 --squash"), "never merges")
        self.blocked(self.bash(d, "cd . && gh pr merge 12"), "never merges")

    def test_pr_view_allowed(self):
        d, _ = self.make(guarded())
        self.allowed(self.bash(d, "gh pr view 12"))

    def test_no_state_allows(self):
        d, _ = self.make()
        self.allowed(self.bash(d, "gh pr merge 1"))
        self.allowed(self.bash(d, "git push origin main"))

    def test_guard_false_allows(self):
        d, _ = self.make(guarded(guard=False))
        self.allowed(self.bash(d, "gh pr merge 1"))
        self.allowed(self.bash(d, "git push --force origin main"))

    def test_outside_repo_allows(self):
        d = tempfile.mkdtemp(prefix="fguard-norepo-")
        self.dirs.append(d)
        self.allowed(self.bash(d, "git push origin main"))

    def test_corrupt_state_allows(self):
        d, _ = self.make("{not json")
        self.allowed(self.bash(d, "git push origin main"))

    def test_unrelated_allowed(self):
        d, _ = self.make(guarded())
        self.allowed(self.bash(d, "ls -la && git status"))
        self.allowed(self.bash(d, "git commit -m 'git push origin main'"))

    def test_pr_create_no_approval(self):
        d, _ = self.make(guarded())
        sh(d, "checkout", "-q", "-b", "factory/1-x")
        self.blocked(self.bash(d, "gh pr create --fill"), "no PR approval")

    def test_pr_create_approved(self):
        d, head = self.make(guarded())
        sh(d, "checkout", "-q", "-b", "factory/1-x")
        head = sh(d, "rev-parse", "HEAD")
        with open(os.path.join(d, ".factory", "state.json"), "w", encoding="utf-8") as f:
            json.dump(guarded(prApprovals={"factory/1-x": head}), f)
        self.allowed(self.bash(d, "gh pr create --fill"))

    def test_pr_create_stale(self):
        d, head = self.make(guarded())
        sh(d, "checkout", "-q", "-b", "factory/1-x")
        head = sh(d, "rev-parse", "HEAD")
        with open(os.path.join(d, ".factory", "state.json"), "w", encoding="utf-8") as f:
            json.dump(guarded(prApprovals={"factory/1-x": head}), f)
        with open(os.path.join(d, "b.txt"), "w", encoding="utf-8") as f:
            f.write("b")
        sh(d, "add", ".")
        sh(d, "commit", "-q", "-m", "more")
        self.blocked(self.bash(d, "gh pr create --fill"), "approval for 'factory/1-x' is for")

    def test_pr_create_other_branch(self):
        d, head = self.make(guarded())
        sh(d, "checkout", "-q", "-b", "factory/1-x")
        head = sh(d, "rev-parse", "HEAD")
        with open(os.path.join(d, ".factory", "state.json"), "w", encoding="utf-8") as f:
            json.dump(guarded(prApprovals={"factory/2-y": head}), f)
        self.blocked(self.bash(d, "gh pr create --fill"))

    def test_push_matrix(self):
        cases = [
            ("git push", True),
            ("git push origin main", True),
            ("git push -u origin main", True),
            ("git push origin HEAD:main", True),
            ("git push origin HEAD:refs/heads/main", True),
            ("git push origin develop", True),
            ("git push origin :main", True),
            ("git push -u origin factory/12-slug", False),
            ("git push origin feature/login", False),
            ("git push origin HEAD:feature/x", False),
            ("git push origin HEAD:refs/heads/feature/x", False),
            ("git push --force origin factory/1-x", True),
            ("git push -f origin factory/1-x", True),
            ("git push origin +factory/1-x", True),
            ("git push --force-with-lease origin factory/1-x", False),
            ("git push --force-with-lease=factory/1-x origin factory/1-x", False),
            ("git push --all origin", True),
            ("echo hi && git push origin main", True),
            ("GIT_SSH_COMMAND=x git push origin main", True),
        ]
        for cmd, should in cases:
            d, _ = self.make(guarded())
            result = self.bash(d, cmd)
            if should:
                self.blocked(result)
            else:
                self.allowed(result)

    def test_bare_push_follows_branch(self):
        d, _ = self.make(guarded())
        self.blocked(self.bash(d, "git push"))
        sh(d, "checkout", "-q", "-b", "factory/3-z")
        self.allowed(self.bash(d, "git push"))
        sh(d, "checkout", "-q", "-b", "feature/q")
        self.allowed(self.bash(d, "git push"))

    def test_git_c_and_cd(self):
        guarded_repo, _ = self.make(guarded())
        plain, _ = self.make()
        self.blocked(self.bash(plain, "git -C %s push origin main" % guarded_repo))
        self.blocked(self.bash(plain, "cd %s && git push origin main" % guarded_repo))
        self.allowed(self.bash(guarded_repo, "git -C %s push origin main" % plain))

    def test_stamped_edit_blocked(self):
        gates = {"requirements": {"file": "docs/factory/REQUIREMENTS.md", "sha256": "x", "approvedAt": "t"}}
        d, _ = self.make(guarded(gates=gates))
        for name in ("Write", "StrReplace", "Delete"):
            result = g.decide({
                "hook_event_name": "preToolUse",
                "tool_name": name,
                "tool_input": {"path": "docs/factory/REQUIREMENTS.md"},
                "cwd": d,
            })
            self.blocked(result, "read-only")
        result = g.decide({
            "hook_event_name": "preToolUse",
            "tool_name": "Write",
            "tool_input": {"path": os.path.join(d, "docs/factory/REQUIREMENTS.md"), "contents": "x"},
            "cwd": d,
        })
        self.blocked(result)
        result = g.decide({
            "hook_event_name": "preToolUse",
            "tool_name": "StrReplace",
            "tool_input": {"path": "./docs/../docs/factory/REQUIREMENTS.md"},
            "cwd": d,
        })
        self.blocked(result)

    def test_unstamped_allowed(self):
        gates = {"requirements": {"file": "docs/factory/REQUIREMENTS.md", "sha256": "x", "approvedAt": "t"}}
        d, _ = self.make(guarded(gates=gates))
        self.allowed(g.decide({
            "hook_event_name": "preToolUse",
            "tool_name": "Write",
            "tool_input": {"path": "docs/factory/STACK.md"},
            "cwd": d,
        }))
        self.allowed(g.decide({
            "hook_event_name": "preToolUse",
            "tool_name": "StrReplace",
            "tool_input": {"path": "a.txt"},
            "cwd": d,
        }))

    def test_reopened_and_guard_off(self):
        d, _ = self.make(guarded())
        self.allowed(g.decide({
            "hook_event_name": "preToolUse",
            "tool_name": "Write",
            "tool_input": {"path": "docs/factory/REQUIREMENTS.md"},
            "cwd": d,
        }))
        gates = {"requirements": {"file": "docs/factory/REQUIREMENTS.md"}}
        b, _ = self.make(guarded(gates=gates, guard=False))
        self.allowed(g.decide({
            "hook_event_name": "preToolUse",
            "tool_name": "Write",
            "tool_input": {"path": "docs/factory/REQUIREMENTS.md"},
            "cwd": b,
        }))

    def test_holdout(self):
        d, _ = self.make()
        inputs = [
            {"file_path": os.path.expanduser("~/.omp/factory/repo/holdout/1/scenarios.md")},
            {"command": "cat $HOME/.omp/factory/repo/holdout/1/s.md"},
            {"file_path": "/Users/x/.cursor/factory/holdout/repo/1/s.md"},
        ]
        for name in ("factory-builder", "factory-qa-review", "explore"):
            for extra in inputs:
                payload = {"hook_event_name": "beforeReadFile", "cwd": d, "subagent_type": name}
                payload.update(extra)
                if "command" in extra:
                    payload["hook_event_name"] = "beforeShellExecution"
                self.blocked(g.decide(payload), "holdout")
                self.assertIn(name, g.decide(payload).get("user_message", ""))
        for extra in inputs:
            for name in ("factory-qa", "Factory-QA-Author"):
                payload = {"hook_event_name": "beforeReadFile", "cwd": d, "subagent_type": name}
                payload.update(extra)
                self.allowed(g.decide(payload))
            self.allowed(g.decide({"hook_event_name": "beforeReadFile", "cwd": d, **extra}))

    def test_odd_inputs(self):
        self.allowed(g.decide({"hook_event_name": "beforeShellExecution", "command": 5, "cwd": "/nonexistent/dir"}))
        self.allowed(g.decide({"hook_event_name": "preToolUse", "tool_name": "Write", "tool_input": {"path": 3}, "cwd": "/nonexistent/dir"}))
        self.allowed(g.decide({}))

    def test_cli_allow(self):
        proc = subprocess.run(
            [sys.executable, os.path.join(HOOKS, "factory_guard.py")],
            input="{}",
            text=True,
            capture_output=True,
            check=True,
        )
        self.assertEqual(json.loads(proc.stdout)["permission"], "allow")


class StageTest(unittest.TestCase):
    def setUp(self):
        self.dirs = []

    def tearDown(self):
        for d in self.dirs:
            shutil.rmtree(d, ignore_errors=True)

    def test_continues_only_armed_conversation(self):
        d, _ = repo(guarded(stage="build", unattended=True, stop=None, blockedOnUser=False, guardStage={"exitMet": False, "reason": "wave open"}))
        self.dirs.append(d)
        os.makedirs(os.path.join(d, ".factory"), exist_ok=True)
        with open(os.path.join(d, ".factory", "cursor-armed.json"), "w", encoding="utf-8") as f:
            json.dump({"conversation_id": "chat-1", "armed": True}, f)
        payload = {
            "hook_event_name": "stop",
            "status": "completed",
            "conversation_id": "chat-1",
            "workspace_roots": [d],
            "loop_count": 0,
        }
        decision = s.decide(payload)
        self.assertIn("followup_message", decision)
        self.assertIn("build", decision["followup_message"])
        other = dict(payload, conversation_id="chat-2")
        self.assertEqual(s.decide(other), {})
        aborted = dict(payload, status="aborted")
        self.assertEqual(s.decide(aborted), {})

    def test_quiet_when_parked_or_unarmed(self):
        d, _ = repo(guarded(stage="build", unattended=True, stop="S5", guardStage={"exitMet": False}))
        self.dirs.append(d)
        with open(os.path.join(d, ".factory", "cursor-armed.json"), "w", encoding="utf-8") as f:
            json.dump({"conversation_id": "chat-1", "armed": True}, f)
        payload = {
            "hook_event_name": "stop",
            "status": "completed",
            "conversation_id": "chat-1",
            "workspace_roots": [d],
        }
        self.assertEqual(s.decide(payload), {})
        plain, _ = repo()
        self.dirs.append(plain)
        self.assertEqual(s.decide({
            "hook_event_name": "preCompact",
            "workspace_roots": [plain],
        }), {})
        msg = s.decide({"hook_event_name": "preCompact", "workspace_roots": [d]})
        self.assertIn("state.json", msg.get("user_message", ""))

    def test_arm_side_effect(self):
        d, _ = repo(guarded())
        self.dirs.append(d)
        g.maybe_arm({
            "hook_event_name": "beforeShellExecution",
            "command": "/Users/x/.cursor/factory/bin/factory-state unattended on \"feature\"",
            "cwd": d,
            "conversation_id": "chat-9",
        })
        with open(os.path.join(d, ".factory", "cursor-armed.json"), encoding="utf-8") as f:
            data = json.load(f)
        self.assertEqual(data["conversation_id"], "chat-9")
        self.assertTrue(data["armed"])
        g.maybe_arm({
            "hook_event_name": "beforeShellExecution",
            "command": "factory-state unattended off",
            "cwd": d,
            "conversation_id": "chat-9",
        })
        with open(os.path.join(d, ".factory", "cursor-armed.json"), encoding="utf-8") as f:
            data = json.load(f)
        self.assertFalse(data["armed"])


if __name__ == "__main__":
    unittest.main()
