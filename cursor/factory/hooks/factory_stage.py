#!/usr/bin/env python3
"""Cursor stage guard. Port of omp/extensions/factory-stage-guard.ts.

stop: when this conversation armed an unattended factory run and the stage
has not met its exit predicate, submit a follow-up so the turn continues.
A different chat in the same repo is left alone. status aborted or error
(the user pressed Stop, or the turn failed) does not continue.

preCompact: when a workspace has an active factory run, remind the user to
re-read .factory/state.json after compaction.

Fail open. Stdlib only.
"""
from __future__ import annotations

import json
import os
import sys

FOLLOWUP = (
    "The factory stage '{stage}' has not met its exit predicate ({reason}). "
    "Continue that stage from .factory/state.json and .factory/ledger.tsv. "
    "Do not end the turn. If you are waiting on the user, run "
    "factory-state blocked-on-user on. To park, run factory-state stop."
)


def load_state(root):
    path = os.path.join(root, ".factory", "state.json")
    if not os.path.isfile(path):
        return None
    try:
        with open(path, "r", encoding="utf-8") as f:
            state = json.load(f)
    except (OSError, ValueError):
        return None
    if not isinstance(state, dict) or state.get("guard") is not True:
        return None
    return state


def find_root(dir_):
    if not dir_:
        return None
    cur = os.path.abspath(dir_)
    while True:
        if os.path.exists(os.path.join(cur, ".git")):
            return cur
        up = os.path.dirname(cur)
        if up == cur:
            return None
        cur = up


def roots_of(payload):
    found = []
    cwd = payload.get("cwd")
    if isinstance(cwd, str):
        root = find_root(cwd)
        if root:
            found.append(root)
    for item in payload.get("workspace_roots") or []:
        if not isinstance(item, str):
            continue
        root = find_root(item) or (item if os.path.isdir(os.path.join(item, ".git")) else None)
        if root and root not in found:
            found.append(os.path.abspath(root))
    return found


def armed_here(root, conversation_id):
    path = os.path.join(root, ".factory", "cursor-armed.json")
    if not os.path.isfile(path):
        return False
    try:
        with open(path, "r", encoding="utf-8") as f:
            data = json.load(f)
    except (OSError, ValueError):
        return False
    return (
        isinstance(data, dict)
        and data.get("armed") is True
        and data.get("conversation_id") == conversation_id
    )


def stop_decision(payload):
    if payload.get("status") != "completed":
        return {}
    cid = payload.get("conversation_id")
    if not isinstance(cid, str) or not cid:
        return {}
    for root in roots_of(payload):
        if not armed_here(root, cid):
            continue
        state = load_state(root)
        if not state or state.get("unattended") is not True:
            continue
        guard_stage = state.get("guardStage") or {}
        if guard_stage.get("exitMet") is True or state.get("stop") or state.get("blockedOnUser") is True:
            continue
        reason = guard_stage.get("reason") or ""
        return {
            "followup_message": FOLLOWUP.format(stage=state.get("stage") or "unknown", reason=reason)
        }
    return {}


def compact_decision(payload):
    for root in roots_of(payload):
        if load_state(root):
            return {
                "user_message": (
                    "Factory run in progress. After compaction, re-read "
                    ".factory/state.json and .factory/ledger.tsv before continuing."
                )
            }
    return {}


def decide(payload):
    if not isinstance(payload, dict):
        return {}
    event = payload.get("hook_event_name") or ""
    try:
        if event == "preCompact":
            return compact_decision(payload)
        if event == "stop" or "status" in payload:
            return stop_decision(payload)
        return {}
    except Exception:
        return {}


def main():
    raw = sys.stdin.read()
    try:
        payload = json.loads(raw) if raw.strip() else {}
    except ValueError:
        payload = {}
    if not isinstance(payload, dict):
        payload = {}
    json.dump(decide(payload), sys.stdout)
    sys.stdout.write("\n")


if __name__ == "__main__":
    main()
