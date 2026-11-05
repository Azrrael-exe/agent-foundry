# Antigravity adapter (experimental)

This adapter translates documented Antigravity camelCase hook payloads into
the existing Claude hook protocol. Contract tests do not establish that an
installed Antigravity App or IDE discovers or runs these hooks. No automatic
installation is provided yet.

`hooks.example.json` is a template, not an installer. To experiment, set
`AGENT_FOUNDRY_ROOT` to this repository's absolute path in Antigravity's
launch environment, merge the entries into an existing global or workspace
hooks configuration without overwriting other entries, then inspect the
active hooks in the application. Environment expansion and event behavior must
be verified in the chosen runtime before relying on them. See
[Antigravity hooks](https://antigravity.google/docs/hooks).

Supported mappings: `run_command` to both existing shell and secrets guards;
`view_file`, `write_to_file` and `replace_file_content` to the secrets guard;
`SessionStart` and idle `Stop` to the existing gate. Search, multi-edit,
other tools, MCP, and alternate shell execution paths are not covered. Existing
guard patterns are heuristics, not a sandbox. Multiple or missing workspaces
cannot be attributed safely: tool calls request approval and the gate skips.

The gate and repository-local formatters remain governed by the explicit trust
list at `${HARNESS_HOME:-~/.agent-foundry}/trusted-projects`; this adapter does
not add projects to it. PreToolUse translations retain the original guard's
limitations and fail-open behavior when that guard cannot run. An adapter error
requests confirmation; it cannot compensate for missing native hook coverage.

Run `python3 adapters/antigravity/test_hook.py` from the repository root.
