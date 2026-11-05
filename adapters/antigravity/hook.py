#!/usr/bin/env python3
"""Translate supported Antigravity hooks to the existing Claude hook contract.

Experimental: this adapter has contract tests, but has not been tested inside
an Antigravity runtime. It only covers the tool names listed in README.md.
"""
from __future__ import annotations

import json
import os
from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[2]
HOME = Path.home()


def emit(value: dict) -> None:
    print(json.dumps(value))


def call(script: str, payload: dict, project: str) -> subprocess.CompletedProcess[str]:
    env = os.environ.copy()
    env["CLAUDE_PROJECT_DIR"] = project
    env.setdefault("HARNESS_HOME", str(HOME / ".agent-foundry"))
    return subprocess.run(
        [str(ROOT / "hooks" / script)], input=json.dumps(payload), text=True,
        capture_output=True, cwd=project, env=env, check=False,
    )


def main(event: str, data: dict) -> None:
    workspaces = data.get("workspacePaths", [])
    # Never guess which project grants trust or defines the shell boundary.
    if not isinstance(workspaces, list) or len(workspaces) != 1 or not isinstance(workspaces[0], str) or not Path(workspaces[0]).is_dir():
        emit({"decision": "force_ask", "reason": "Agent Foundry requires exactly one existing workspace."} if event == "pre" else {})
        return
    project = workspaces[0]
    session = data.get("conversationId", "")
    if not isinstance(session, str) or not session:
        emit({"decision": "force_ask", "reason": "Agent Foundry requires a conversation identifier."} if event == "pre" else {})
        return

    if event in ("start", "stop"):
        if event == "stop" and data.get("fullyIdle") is not True:
            emit({"decision": "stop"})
            return
        mapped = {"hook_event_name": "SessionStart" if event == "start" else "Stop", "session_id": session, "cwd": project}
        result = call("project-gate.sh", mapped, project)
        try:
            reply = json.loads(result.stdout)
        except (ValueError, TypeError):
            reply = {}
        if event == "stop" and reply.get("decision") == "block":
            emit({"decision": "continue", "reason": reply.get("reason", "Project check failed.")})
        else:
            emit({"decision": "stop"} if event == "stop" else {})
        return

    if event != "pre":
        raise ValueError("unknown event")
    tool_call = data.get("toolCall")
    if not isinstance(tool_call, dict) or not isinstance(tool_call.get("args"), dict):
        emit({"decision": "force_ask", "reason": "Agent Foundry could not inspect this tool call."})
        return
    name = tool_call.get("name")
    args = tool_call["args"]
    mapped = {"hook_event_name": "PreToolUse", "session_id": session, "cwd": project, "tool_input": {}}
    scripts = []
    if name == "run_command" and isinstance(args.get("CommandLine"), str):
        mapped["tool_name"] = "Bash"
        mapped["cwd"] = args.get("Cwd") if isinstance(args.get("Cwd"), str) else project
        mapped["tool_input"]["command"] = args["CommandLine"]
        scripts = ["guard-bash.sh", "guard-secrets.sh"]
    elif name == "view_file" and isinstance(args.get("AbsolutePath"), str):
        mapped["tool_name"] = "Read"
        mapped["tool_input"]["file_path"] = args["AbsolutePath"]
        scripts = ["guard-secrets.sh"]
    elif name in ("write_to_file", "replace_file_content") and isinstance(args.get("TargetFile"), str):
        field = "CodeContent" if name == "write_to_file" else "ReplacementContent"
        if not isinstance(args.get(field), str):
            emit({"decision": "force_ask", "reason": "Agent Foundry could not inspect file content."})
            return
        mapped["tool_name"] = "Write" if name == "write_to_file" else "Edit"
        mapped["tool_input"] = {"file_path": args["TargetFile"], "content" if name == "write_to_file" else "new_string": args[field]}
        scripts = ["guard-secrets.sh"]
    elif name in ("run_command", "view_file", "write_to_file", "replace_file_content"):
        emit({"decision": "force_ask", "reason": "Agent Foundry could not inspect required tool arguments."})
        return
    else:
        # No claim of coverage for unknown tools, including search and multi-edit.
        emit({"decision": "allow"})
        return
    for script in scripts:
        result = call(script, mapped, project)
        if result.returncode == 2:
            emit({"decision": "deny", "reason": result.stderr.strip() or "Agent Foundry blocked this action."})
            return
        if result.returncode != 0:
            emit({"decision": "force_ask", "reason": "Agent Foundry could not evaluate the tool call."})
            return
        try:
            reply = json.loads(result.stdout)
        except ValueError:
            reply = {}
        decision = reply.get("hookSpecificOutput", {})
        if decision.get("permissionDecision") == "ask":
            emit({"decision": "force_ask", "reason": decision.get("permissionDecisionReason", "Approval required.")})
            return
    emit({"decision": "allow"})


if __name__ == "__main__":
    try:
        payload = json.load(sys.stdin)
        if not isinstance(payload, dict) or len(sys.argv) != 2:
            raise ValueError("invalid input")
        main(sys.argv[1], payload)
    except (ValueError, OSError, subprocess.SubprocessError):
        emit({"decision": "force_ask", "reason": "Agent Foundry could not evaluate the hook."} if sys.argv[1:] == ["pre"] else {})
