# Compatibility

| Component | Claude Code | Codex | Antigravity |
| --- | --- | --- | --- |
| Shared skills | Existing baseline; portable edits under test | Files prepared; discovery not verified in a live session | Files prepared; discovery not verified in a live session |
| Guards | Legacy hook fixtures pass; real installation not modified | Experimental Bash translation; contract tests only | Experimental selected tool mappings; contract tests only |
| Gate | Claude fixture and symlink tests | Experimental session/stop translation; contract tests only | Experimental session/idle-stop translation; contract tests only |
| Trust | Existing local trust list | Its own local state by default | Its own local state by default |

Neither new adapter has been verified inside its actual client. Tool
availability, payloads, trust review, and event semantics differ by version and
surface. Consult the [Codex adapter](../adapters/codex/README.md) and
[Antigravity adapter](../adapters/antigravity/README.md) before experimenting.

The Codex adapter translates Claude's `ask` to `deny`; its inherited log still
records the original `ask`. Antigravity's template requires environment and
event configuration to be verified. Neither covers every tool or execution
path. Codex may omit the command's effective working directory from a hook
payload, so its relative-path `rm` guard can miss an outside-project target.
No adapter is a security sandbox.
