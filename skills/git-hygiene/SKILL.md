---
name: git-hygiene
description: "Use when creating a branch, writing a commit message, preparing a pull request or writing a PR description."
---

# Git hygiene

## First, the repo's own convention

Check `git log --oneline -20`, `CONTRIBUTING.md` and `.github/pull_request_template.md`.
If the repo has a convention (for example Conventional Commits or a PR template), it wins
over the defaults below.

## Branches

- `<type>/<short-kebab-description>`, type one of `feat`, `fix`, `chore`, `docs`, `refactor`, `test`.
- Never commit directly to `main` or `master`; branch first.

## Commits

- One logical change per commit.
- Subject: imperative mood, at most 72 characters, no trailing period.
- Body: why the change was made, and anything non-obvious about how. Wrap at ~72.
- Stage files explicitly; review `git diff --cached` before committing. No blind `git add -A`.
- Never commit secrets, `.env` files or generated artifacts.

## Before opening a PR

1. Run the project's check command (`.harness/check.sh`, `.claude/check.sh`, `just check` or `make check`, in that order).
2. Review the full diff against the base branch (use `code-reviewer` if available).
3. Confirm nothing is out of scope (use `scope-auditor` if available).

## PR description

```markdown
## Summary
One to three lines: what changes for the user or the system.

## Why
The problem or goal; link the issue or spec.

## Changes
- Bullet per meaningful change.

## How tested
Commands actually run and their results. Say what was not tested.

## Risks / rollback
What could break and how to revert.

## Screenshots
Only for UI changes.
```

## Never without explicit approval in this session

Push, force push, create, merge or close a PR, or rewrite pushed history.
