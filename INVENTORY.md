# Baseline inventory

This snapshot was copied from a personal Claude Code harness on 2026-11-04.
It is a working-tree snapshot, not a copy of that repository's Git history.

| Path | Purpose | Status |
| --- | --- | --- |
| `hooks/` | Claude event handlers, safety checks, project gate and trust helpers | Copied without behavior changes; provider-specific |
| `core/trust.sh` | Provider-neutral trust-list lookup | Extracted; Claude wrapper retains the existing state location |
| `core/check.sh` | Check command discovery | Adds `.harness/check.sh` before the legacy Claude, just and make checks |
| `core/gate.sh` | Git fingerprint, baseline and check result state | Extracted; event handling remains Claude-specific |
| `core/events.sh` | JSON event writer | Extracted; callers must avoid sensitive summaries |
| `core/secrets.sh` | Credential path and content patterns | Extracted; heuristic only, not comprehensive protection |
| `adapters/` | Codex and Antigravity hook translations | Experimental; contract tests only |
| `skills/` | Five reusable workflows | Copied; still contain Claude-specific instructions |
| `agents/` | Four specialized agent definitions | Copied; tool restrictions are Claude-specific |
| `bin/` | Event report and macOS GitHub MCP credential helper | Copied; helper is macOS-specific and optional |
| `tests/` | Hook fixtures, report tests, MCP helper tests and status-line fixtures | Copied; hook tests use temporary data |
| `install.sh`, `legacy/`, `statusline.sh` | Disabled installer, legacy reference and status line | Reference only; the old installer must not be run |

Excluded: personal global instruction and settings files, existing harness state,
trust lists, logs, session history, backups, Git history, local credentials and
the personal harness documentation. The test fixtures contain deliberately
synthetic project names and generate fake token-shaped strings for tests.

The baseline depends on Bash, Git, jq, Perl, and standard Unix tools. ShellCheck
is optional but used by the hook test suite when present. Runtime hooks and
integrations may have additional dependencies; the GitHub MCP helper depends on
macOS Keychain or `gh`. Some behavior intentionally fails open when tools or
project configuration are absent. Individual scripts and adapter behavior must
be reviewed during extraction.

Before publication, perform a fresh secret and personal-data review, review the
future Git history, choose a license, and confirm ownership and publication.
No secret scan alone can establish that all sensitive information is absent.
