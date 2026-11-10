# Spec workflow for Agent Foundry

## Goal
Use a traceable spec workflow for significant Agent Foundry changes and make the
same approach available, without imposing it, on repositories using Foundry.

## Context
`spec-builder` already drafts a spec with acceptance criteria but hands off before
implementation. The repository has no project-specific spec convention connecting
implementation, verification, and current documentation. Consumers may already
have their own spec process.

## In scope
- Document when Foundry's own changes need a spec and how to close them.
- Improve the spec-builder handoff and let harness-bootstrap offer a lightweight
  spec workflow adapted to each project.
- Explain the workflow and actual availability of optional agents in the README.

## Out of scope
- Mandatory specs for every consumer or every minor correction.
- Installing agents or hooks, creating a new spec format, or implementing a spec gate.

## Acceptance criteria
- **AC-1:** Project instructions require specs for significant changes and allow
  small, clear corrections without one, while respecting higher-priority direction.
- **AC-2:** A spec connects verifiable, stable acceptance criteria to verification;
  its handoff covers implementation, documentation, and reporting unverified work.
- **AC-3:** Bootstrap offers a lightweight spec workflow without overwriting or
  requiring replacement of an existing project convention; adoption is optional.
- **AC-4:** Documentation distinguishes Foundry's internal convention from the
  reusable workflow and accurately describes optional agents and installation.
- **AC-5:** Applicable checks are reported honestly, including any trust or
  environment limitations; no automatic check is presented as proof of all ACs.

## Constraints
- Keep existing approval and trust boundaries and respect explicit user direction.
- Preserve OpenSpec and project-specific workflows. Do not automatically install
  dependencies, agents, hooks, or project instructions.

## Open questions
None blocking.

## Verification
- Review project instructions, both skills, and README against AC-1 through AC-4.
- Validate the skill metadata and run applicable project checks when permitted by
  the active adapter's trust decision; report anything not run.

## Verification results (2026-11-10)
- Reviewed the project instructions, skills, and README against AC-1 through AC-4;
  no automatic gate asserts complete AC coverage.
- `git diff --check` passed. The skill-creator validator accepted `harness-bootstrap`;
  it rejected `spec-builder` because of its pre-existing `argument-hint` frontmatter,
  which that validator does not recognize.
- `tests/run.sh` was not run: this session did not establish that the repository is
  trusted by the active adapter. No live adapter or agent integration was tested.
