# Claude adapter

The inherited `hooks/` scripts have fixture coverage and preserve their original
Claude event contract. `hooks.example.json` shows a subset of the legacy hook
configuration and is a reference, not an automatic installation. It does not
include the original permission rules, specialized-agent restrictions,
notifications, or status line. Do not replace an existing settings file with it.

Before trying the example, set `AGENT_FOUNDRY_ROOT` to this checkout in Claude's
launch environment, review and merge desired hooks into settings, and confirm
that the runtime expands the variable and invokes each hook. A session using
both the original and new hooks may run each check twice. No live installation
has been tested. See the project [security notes](../../docs/security.md).
