# Codex adapter (experimental)

This is a manually installable plugin hook definition, not an installed or
verified Codex integration. It dispatches documented `SessionStart`, `Stop`,
and `PreToolUse` Bash events to the legacy guards and gate. It defaults state
to `${XDG_STATE_HOME:-$HOME/.local/state}/agent-foundry`; trust roots must be
managed explicitly in that directory. It never adds a project to the trust list.

The root `plugin.json` points its OpenAI extension's `hooks` field to
`./adapters/codex/hooks.json`. The runtime must provide
`PLUGIN_ROOT`; hooks must be installed in the execution environment and trusted
by the user. The installation flow has not been tested here.

## Coverage and limitations

* The adapter guards documented `Bash` calls only. It does not protect
  `apply_patch`, arbitrary MCP tools, hosted tools, interactive `write_stdin`,
  indirect scripts, or all shell syntax. Keep sandbox and approval controls on.
  Relative-path analysis uses the event's session `cwd`, not necessarily the
  shell command's effective working directory. Codex has been reported to omit
  command-level `workdir` in hook payloads; consequently the `rm` boundary can
  miss an outside-project path. Do not rely on that guard for containment. See
  [Codex issue 57184](https://github.com/openai/codex/issues/57184).
* Codex does not currently support `permissionDecision: ask` in PreToolUse;
  a Claude guard's ask is translated to **deny**, and the message asks the
  user to review and run the operation themselves. This is more restrictive.
  The legacy event log still labels that event `ask`, reflecting the guard's
  original decision rather than the final Codex denial.
* Stop is a continuation request, not an absolute prohibition on finishing.
  A tree state failing the check is blocked once, following the legacy gate.
* Missing jq, invalid input, and many hook/runtime errors can fail open. Do not
  treat the adapter as a security boundary or a comprehensive audit mechanism.
* Fixture tests exercise the wire contract directly; they do not prove actual
  loading, trust, execution, timing, or coverage in a given Codex surface.

Official reference: <https://learn.chatgpt.com/docs/hooks> and
<https://developers.openai.com/plugins/build/plugins>.
