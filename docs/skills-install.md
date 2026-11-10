# Skills-only installation

`bin/foundry` links each skill directory from this checkout into the selected
agent's global skills directory. It does **not** install or activate hooks,
instructions, trust lists, permissions, MCP servers, or any background process.
See the platform's adapter documentation before enabling those separately.

```sh
bin/foundry doctor
bin/foundry skills install claude
bin/foundry skills install codex
bin/foundry skills install antigravity
bin/foundry skills uninstall codex
```

Destinations are respectively `~/.claude/skills`, `~/.agents/skills`, and
`~/.gemini/config/skills`. A conflict with any existing entry prevents the
entire installation for that platform. Uninstall removes only symbolic links
that point to skills in this exact checkout; all other entries are preserved.
Run `doctor` to see how many of these links currently point to this checkout.
It checks common command availability, **not** whether agent hooks are active.

Keep the checkout at a stable path: moving or deleting it breaks its links. To
move it, uninstall the links from the old location before moving the checkout,
then install them again. Agent software may need a restart or a skills reload.
Consult the relevant agent's documentation for discovery behavior and surface
support. A link's presence alone does not prove the agent loaded the skill.

The optional `delivery-workflow` skill is included in the same discovery and
linking process. Its directory contains the workflow references and Markdown
templates used for agreements, journals, verification, and continuation. It adds
no executable runner or agents. See [the workflow guide](delivery-workflow.md).
