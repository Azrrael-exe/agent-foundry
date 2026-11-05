---
name: harness-bootstrap
description: "Use when entering a repository to set up or audit its project-level agent harness: instructions, check command and architecture sensors."
---

# Harness bootstrap

Connect a repository to the global harness through its conventions. Work in phases and get the
user's explicit approval before starting each next phase. Never install a dependency, commit,
or overwrite an existing file without asking.

## Phase 1: Inventory (read-only)

Detect and report as a table (found / missing / notes):
- Manifests: `pyproject.toml`, `package.json` + lockfile, `go.mod`, `Cargo.toml`.
- Task runners: Makefile, justfile, npm scripts.
- CI: `.github/workflows/*` (what CI actually runs is the best source of real commands).
- Lint, format, typecheck and test configuration.
- Existing `CLAUDE.md`, `AGENTS.md`, `.claude/` (settings, check.sh), `openspec/`.

## Phase 2: Project instructions (a map, at most ~80 lines)

Use the applicable agent's supported instruction file; preserve existing files.

- Purpose of the repo in two lines; directory map (only the dirs that matter).
- Real commands for build, test, lint, typecheck: run each one to verify it works.
- Conventions and gotchas that cannot be inferred from the code.
- Nothing already covered by global instructions.
- If a CLAUDE.md or AGENTS.md exists: show the diff and merge; never drop existing content.

## Phase 3: Check command

Follow the global convention, first match wins: executable `.harness/check.sh`, then `.claude/check.sh`, a `check`
recipe in a justfile, a `check` target in a Makefile.
- Reuse an existing `check` if there is one. Otherwise create `.harness/check.sh` (`set -euo
  pipefail`) chaining the repo's own lint, typecheck and fast tests.
- Run it, report the result and duration. If it takes more than ~3 minutes, propose a fast
  subset, because the Stop gate runs it after every change.
- The gate and repo-local formatters only run in trusted projects. If the repo is not covered
  by the active adapter's trust list, explain that the check command is repo code the
  harness will execute, and offer to append the repo path. Never add it without approval.

## Phase 4: Architecture sensors (only where they apply)

Propose mechanical checks for boundaries the repo actually has, added to the check command:
- Python: `import-linter` contracts. JS/TS: `dependency-cruiser` rules. Go: `depguard`.
- Or a dependency-free rule, e.g. `! rg -n 'from app.db' app/api/` inside check.sh.
Ask before adding any new dependency.

## Phase 5: OpenSpec (optional)

Offer OpenSpec integration for spec-driven changes. Look up its current setup in the official
docs first (use `docs-researcher` if available). Install nothing without approval.

## Phase 6: Close

- Summarize what was added and how it was verified.
- Explain opt-outs supported by the active adapter; for Claude these include
  `HARNESS_FORMAT=off` and `HARNESS_GATE=off` in project settings.
- Propose a commit (see `git-hygiene`); commit only if the user says so.
