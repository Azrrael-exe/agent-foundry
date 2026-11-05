# Agent Foundry

Agent Foundry is an early-stage portable harness for coding agents. It combines
shared skills, project checks, trust decisions, and provider-specific adapters.

**Status:** Claude hooks have fixture coverage; Codex and Antigravity adapters
are experimental and have contract tests, not verified runtime integration. Do
not rely on these adapters as security boundaries. Read
[compatibility](docs/compatibility.md) and [security](docs/security.md).

## Skills

```sh
bin/foundry doctor
bin/foundry skills install codex  # or claude, antigravity
```

This only links skills. It does not enable hooks or change instructions,
permissions, or project trust. See [skills installation](docs/skills-install.md).

The core discovers checks in order: `.harness/check.sh`, `.claude/check.sh`,
`just check`, then `make check`. The Claude gate executes checks only for a
trusted Git project. Check and formatter commands are repository code, so trust
must be granted explicitly.

## Testing

On macOS with Bash, Git, jq, Python 3, Perl, and standard Unix tools:

```sh
tests/run.sh
```

The hook suite uses ShellCheck when available. Formatter fixtures use shims;
they do not prove integration with real formatters. Tests do not install hooks
or modify existing agent configurations.

## Components

- `core/`: trust lookup, check discovery, gate state, event writing, and
  credential patterns.
- `hooks/`: inherited Claude-specific hooks and guard implementations.
- `skills/`: reusable workflows; some still have platform-specific details.
- `adapters/`: experimental Codex and Antigravity event translation.
- `instructions/`: an optional working agreement for review and merging.
- `tests/`: isolated tests and fixtures.

`install.sh` is disabled to prevent accidental use of the old incomplete
installer. The legacy script is retained in `legacy/` for reference only;
it can replace existing Claude configuration and must not be run as-is. This
snapshot does not contain the original global settings. See the
[inventory](INVENTORY.md) and adapter READMEs for details.
