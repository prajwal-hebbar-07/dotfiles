#!/usr/bin/env python3
"""Cursor factory guard. Port of omp/hooks/pre/factory-guard.ts.

Reads one Cursor hook payload on stdin and prints a permission decision.
Fail open: any internal error prints {"permission": "allow"} and exits 0.
No network. Stdlib only.

Events:
  beforeShellExecution — block gh pr merge, unapproved gh pr create,
      git push outside factory/* and feature/*, and --force without lease.
  preToolUse — block edits to a stamped gate file.
  beforeReadFile — block holdout reads when the payload names a non-QA subagent.

Also records which conversation armed `factory-state unattended on` into
<repo>/.factory/cursor-armed.json, so the stage hook continues only that chat.
"""
from __future__ import annotations

import json
import os
import re
import subprocess
import sys

HOLDOUT_MARKERS = (".omp/factory", ".cursor/factory/holdout")
HOLDOUT_ALLOWED = {"factory-qa", "factory-qa-author"}
ALLOWED_PUSH = re.compile(r"^(factory|feature)/.")
ARM = re.compile(r"factory-state\b[^;&|\n]*\bunattended\s+on\b")
DISARM = re.compile(r"factory-state\b[^;&|\n]*\bunattended\s+off\b")
EDIT_TOOLS = {"edit", "write", "ast_edit", "Write", "StrReplace", "Delete", "EditNotebook", "Edit"}
PATH_KEYS = {"path", "paths", "file", "files", "file_path", "filePath", "filepath", "target_notebook"}
PUSH_VALUE_FLAGS = {"--repo", "-o", "--push-option", "--receive-pack", "--exec", "--signed"}
PREFIX_WORDS = {"sudo", "command", "exec", "env", "time", "nohup"}


def allow():
    return {"permission": "allow"}


def deny(reason, event):
    if event == "beforeReadFile":
        return {"permission": "deny", "user_message": reason}
    return {"permission": "deny", "user_message": reason, "agent_message": reason}


def find_root(dir_):
    cur = os.path.abspath(dir_)
    while True:
        if os.path.exists(os.path.join(cur, ".git")):
            return cur
        up = os.path.dirname(cur)
        if up == cur:
            return None
        cur = up


def read_state(dir_):
    root = find_root(dir_)
    if not root:
        return None
    file = os.path.join(root, ".factory", "state.json")
    if not os.path.exists(file):
        return None
    try:
        with open(file, "r", encoding="utf-8") as f:
            state = json.load(f)
    except (OSError, ValueError):
        return None
    if not isinstance(state, dict):
        return None
    return {"root": root, "state": state}


def git(root, args):
    try:
        r = subprocess.run(
            ["git", "-C", root] + list(args),
            stdout=subprocess.PIPE,
            stderr=subprocess.DEVNULL,
            universal_newlines=True,
            timeout=5,
        )
    except (OSError, subprocess.TimeoutExpired):
        return None
    if r.returncode != 0:
        return None
    return r.stdout.strip()


def current_branch(root):
    return git(root, ["rev-parse", "--abbrev-ref", "HEAD"]) or "HEAD"


def realish(path):
    try:
        return os.path.realpath(path)
    except OSError:
        return os.path.abspath(path)


def expand_home(path):
    if path == "~":
        return os.path.expanduser("~")
    if path.startswith("~/"):
        return os.path.join(os.path.expanduser("~"), path[2:])
    return path


def tokenize(segment):
    out = []
    cur = ""
    has = False
    quote = None
    i = 0
    n = len(segment)
    while i < n:
        c = segment[i]
        if quote:
            if c == quote:
                quote = None
            elif c == "\\" and quote == '"' and i + 1 < n:
                i += 1
                cur += segment[i]
            else:
                cur += c
        elif c in ("'", '"'):
            quote = c
            has = True
        elif c == "\\" and i + 1 < n:
            i += 1
            cur += segment[i]
            has = True
        elif c.isspace():
            if has or cur:
                out.append(cur)
            cur = ""
            has = False
        else:
            cur += c
            has = True
        i += 1
    if has or cur:
        out.append(cur)
    return out


def split_segments(cmd):
    segs = []
    cur = ""
    quote = None
    i = 0
    n = len(cmd)
    while i < n:
        c = cmd[i]
        if quote:
            cur += c
            if c == quote:
                quote = None
            elif c == "\\" and quote == '"' and i + 1 < n:
                i += 1
                cur += cmd[i]
            i += 1
            continue
        if c in ("'", '"'):
            quote = c
            cur += c
        elif c == "\\" and i + 1 < n:
            cur += c + cmd[i + 1]
            i += 1
        elif c in "&|; \n" and c in "&|;\n":
            segs.append(cur)
            cur = ""
            while i + 1 < n and cmd[i + 1] in "&|":
                i += 1
        else:
            cur += c
        i += 1
    segs.append(cur)
    return [s.strip() for s in segs if s.strip()]


def strip_prefix(tokens):
    i = 0
    while i < len(tokens) and re.match(r"^[A-Za-z_][A-Za-z0-9_]*=", tokens[i]):
        i += 1
    while i < len(tokens) and tokens[i] in PREFIX_WORDS:
        i += 1
    while i < len(tokens) and re.match(r"^[A-Za-z_][A-Za-z0-9_]*=", tokens[i]):
        i += 1
    return tokens[i:]


def parse_git_push(tokens):
    if not tokens or tokens[0] != "git":
        return None
    i = 1
    git_dir = None
    while i < len(tokens) and tokens[i] != "push":
        t = tokens[i]
        if t == "-C" and i + 1 < len(tokens):
            git_dir = tokens[i + 1]
            i += 2
        elif t in ("-c", "--git-dir", "--work-tree", "--namespace") and i + 1 < len(tokens):
            i += 2
        elif t.startswith("-"):
            i += 1
        else:
            return None
    if i >= len(tokens) or tokens[i] != "push":
        return None
    res = {"dir": git_dir, "force": False, "lease": False, "targets": [], "unknownTarget": False, "bare": False}
    positionals = []
    i += 1
    while i < len(tokens):
        t = tokens[i]
        if t == "--":
            positionals.extend(tokens[i + 1 :])
            break
        if t.startswith("--"):
            if t == "--force":
                res["force"] = True
            elif t.startswith("--force-with-lease"):
                res["lease"] = True
            elif t in ("--all", "--mirror", "--branches"):
                res["unknownTarget"] = True
            elif t in PUSH_VALUE_FLAGS:
                i += 1
            i += 1
            continue
        if t.startswith("-") and len(t) > 1:
            cluster = t[1:]
            if "f" in cluster:
                res["force"] = True
            if cluster == "o":
                i += 1
            i += 1
            continue
        positionals.append(t)
        i += 1
    refspecs = positionals[1:]
    if not refspecs:
        res["bare"] = True
    res["targets"] = refspecs
    return res


def refspec_dest(spec, current):
    s = spec
    plus = False
    if s.startswith("+"):
        plus = True
        s = s[1:]
    colon = s.find(":")
    if colon >= 0:
        dst = s[colon + 1 :]
        if dst == "":
            dst = s[:colon]
    else:
        dst = s
    if dst == "HEAD":
        dst = current
    if dst.startswith("refs/heads/"):
        dst = dst[len("refs/heads/") :]
    return dst, plus


def push_reason(branches, what):
    for b in branches:
        if not ALLOWED_PUSH.match(b):
            return (
                "factory guard: %s to '%s' is blocked while the factory run is active. "
                "Only factory/* and feature/* branches may be pushed; main and other "
                "branches change through a reviewed PR." % (what, b)
            )
    return None


def force_reason(what):
    return (
        "factory guard: %s with --force/-f is blocked while the factory run is active. "
        "Use --force-with-lease if a rewrite is really needed." % what
    )


def check_push(push, root, what):
    if push["force"] and not push["lease"]:
        return force_reason(what)
    current = current_branch(root)
    if push["unknownTarget"]:
        return (
            "factory guard: %s with --all/--mirror is blocked while the factory run is active. "
            "Push one factory/* or feature/* branch by name." % what
        )
    branches = []
    if push["bare"]:
        branches.append(current)
    for spec in push["targets"]:
        dest, plus = refspec_dest(spec, current)
        if plus and not push["lease"]:
            return force_reason(what)
        branches.append(dest)
    return push_reason(branches, what)


def pr_create_reason(root, state, head, what):
    branch = head or current_branch(root)
    sha = git(root, ["rev-parse", head or "HEAD"])
    approvals = state.get("prApprovals") or {}
    approved = approvals.get(branch)
    if sha and approved == sha:
        return None
    if not approved:
        why = "no PR approval is recorded for '%s'" % branch
    else:
        why = "the approval for '%s' is for %s but HEAD is %s" % (
            branch,
            approved[:8],
            sha[:8] if sha else "unknown",
        )
    return (
        "factory guard: %s is blocked: %s. Run the PR gate, then "
        "'factory-state pr-approve %s <head sha>'." % (what, why, branch)
    )


def merge_reason(what):
    return "factory guard: %s is blocked. The factory never merges; the human merges the PR." % what


def check_bash(command, cwd):
    if not isinstance(command, str) or not command:
        return None
    dir_ = cwd or os.getcwd()
    for seg in split_segments(command):
        tokens = strip_prefix(tokenize(seg))
        if not tokens:
            continue
        if tokens[0] == "cd" and len(tokens) > 1:
            dir_ = os.path.abspath(os.path.join(dir_, expand_home(tokens[1])))
            continue
        push = parse_git_push(tokens)
        is_gh = tokens[0] == "gh"
        if not push and not is_gh:
            continue
        seg_dir = dir_
        if push and push.get("dir"):
            seg_dir = os.path.abspath(os.path.join(dir_, expand_home(push["dir"])))
        st = read_state(seg_dir)
        if not st or st["state"].get("guard") is not True:
            continue
        if push:
            hit = check_push(push, st["root"], "git push")
            if hit:
                return hit
            continue
        rest = tokens[1:]
        if "pr" not in rest:
            continue
        pr_idx = rest.index("pr")
        sub = rest[pr_idx + 1] if pr_idx + 1 < len(rest) else None
        if sub == "merge":
            return merge_reason("gh pr merge")
        if sub == "create":
            head = None
            i = pr_idx + 2
            while i < len(rest):
                if rest[i] in ("--head", "-H") and i + 1 < len(rest):
                    head = rest[i + 1]
                elif rest[i].startswith("--head="):
                    head = rest[i][7:]
                i += 1
            if head and ":" in head:
                head = head.split(":")[-1]
            hit = pr_create_reason(st["root"], st["state"], head, "gh pr create")
            if hit:
                return hit
    return None


def collect_paths(value, out, key=""):
    if isinstance(value, str):
        if key in PATH_KEYS:
            out.append(value)
    elif isinstance(value, list):
        for item in value:
            collect_paths(item, out, key)
    elif isinstance(value, dict):
        for k, item in value.items():
            collect_paths(item, out, k)


def check_edit(tool_input, cwd):
    st = read_state(cwd or os.getcwd())
    if not st or st["state"].get("guard") is not True:
        return None
    paths = []
    collect_paths(tool_input if isinstance(tool_input, dict) else {}, paths)
    if not paths:
        return None
    gates = list((st["state"].get("gates") or {}).items())
    for p in paths:
        if not isinstance(p, str):
            continue
        expanded = expand_home(p)
        abs_path = realish(expanded if os.path.isabs(expanded) else os.path.join(cwd or os.getcwd(), expanded))
        for name, gate in gates:
            if not isinstance(gate, dict) or not gate.get("file"):
                continue
            if abs_path == realish(os.path.join(st["root"], gate["file"])):
                return (
                    "factory guard: '%s' is the approved '%s' doc and is read-only. "
                    "Reopen the gate ('factory-state reopen %s') and get it re-approved before changing it."
                    % (gate["file"], name, name)
                )
    return None


def holdout_text(payload):
    parts = []
    for key in ("command", "file_path"):
        val = payload.get(key)
        if isinstance(val, str):
            parts.append(val)
    tool_input = payload.get("tool_input")
    if isinstance(tool_input, str):
        parts.append(tool_input)
    elif tool_input is not None:
        try:
            parts.append(json.dumps(tool_input))
        except TypeError:
            pass
    return "\n".join(parts)


def check_holdout(payload):
    sub = payload.get("subagent_type")
    if not isinstance(sub, str) or not sub:
        return None
    if sub.lower() in HOLDOUT_ALLOWED:
        return None
    text = holdout_text(payload)
    if not any(marker in text for marker in HOLDOUT_MARKERS):
        return None
    return (
        'factory holdout guard: agent "%s" may not access holdout scenarios '
        "(visible only to factory-qa and factory-qa-author)" % sub
    )


def tool_input_of(payload):
    tool_input = payload.get("tool_input")
    if isinstance(tool_input, str):
        try:
            tool_input = json.loads(tool_input)
        except ValueError:
            return {}
    return tool_input if isinstance(tool_input, dict) else {}


def decide(payload):
    """Return a permission object. Never raises."""
    if not isinstance(payload, dict):
        return allow()
    event = payload.get("hook_event_name") or ""
    try:
        holdout = check_holdout(payload)
        if holdout:
            return deny(holdout, event or "beforeReadFile")
        cwd = payload.get("cwd") or os.getcwd()
        if event == "beforeShellExecution" or (not event and "command" in payload and "tool_name" not in payload):
            hit = check_bash(payload.get("command") or "", cwd)
            if hit:
                return deny(hit, "beforeShellExecution")
            return allow()
        if event == "beforeReadFile":
            return allow()
        if event == "preToolUse" or payload.get("tool_name"):
            name = str(payload.get("tool_name") or "")
            tool_input = tool_input_of(payload)
            if name in ("Shell", "bash") or "command" in tool_input:
                hit = check_bash(str(tool_input.get("command") or payload.get("command") or ""), cwd)
                if hit:
                    return deny(hit, "preToolUse")
            if name in EDIT_TOOLS or any(k in tool_input for k in PATH_KEYS):
                if name in EDIT_TOOLS or event == "preToolUse":
                    hit = check_edit(tool_input, cwd)
                    if hit:
                        return deny(hit, "preToolUse")
            return allow()
        return allow()
    except Exception:
        return allow()


def maybe_arm(payload):
    try:
        if payload.get("hook_event_name") not in (None, "beforeShellExecution"):
            return
        cmd = payload.get("command")
        cid = payload.get("conversation_id")
        cwd = payload.get("cwd")
        if not isinstance(cmd, str) or not isinstance(cid, str) or not cid or not isinstance(cwd, str):
            return
        if not ARM.search(cmd) and not DISARM.search(cmd):
            return
        root = find_root(cwd)
        if not root:
            return
        factory = os.path.join(root, ".factory")
        if not os.path.isdir(factory):
            return
        path = os.path.join(factory, "cursor-armed.json")
        body = json.dumps({"conversation_id": cid, "armed": bool(ARM.search(cmd))}) + "\n"
        tmp = path + ".tmp"
        with open(tmp, "w", encoding="utf-8") as f:
            f.write(body)
        os.replace(tmp, path)
    except Exception:
        return


def main():
    raw = sys.stdin.read()
    try:
        payload = json.loads(raw) if raw.strip() else {}
    except ValueError:
        payload = {}
    if not isinstance(payload, dict):
        payload = {}
    maybe_arm(payload)
    json.dump(decide(payload), sys.stdout)
    sys.stdout.write("\n")


if __name__ == "__main__":
    main()
