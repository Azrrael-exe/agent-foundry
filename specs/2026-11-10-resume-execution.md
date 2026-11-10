# Resume an interrupted execution

## Goal
Recover a development initiative from durable state while reconciling it with current repository evidence.

## Context
This is delivery-workflow spec 06 of eight. The existing SDD workflow in
`specs/2026-11-10-spec-workflow.md` separates spec-builder from implementation.
The user authorized implementation of the eight discussed slices using the current
harness and Terra implementation agents on 2026-11-10.

## In scope
- Implement this slice as portable instructions in
  `skills/delivery-workflow/references/resume.md` and relevant Markdown templates.
- Integrate through the new skill entrypoint and current project documentation.
- Validate the documented behavior with concrete scenarios and honest evidence.

## Out of scope
No automatic crash recovery, concurrency coordinator, or assumption that historical approval grants expired runtime permissions.

## Acceptance criteria
- **AC-1:** Given an interrupted initiative, resumption identifies approved scope, completed and pending increments, and the next authorized action.
- **AC-2:** Given repository changes since the checkpoint, the agent reconciles relevant differences before continuing and preserves unrelated work.
- **AC-3:** Given evidence invalidated by a relevant change, it is marked stale and required verification is repeated without blindly repeating completed work.

## Constraints
- Use the existing skill installer and SDD workflow; no new executable orchestrator.
- Existing project conventions, OpenSpec, user authorization, sandbox permissions,
  and adapter trust take precedence. Do not modify trust or install hooks.
- Keep documents in English, changes scoped, and historical evidence identifiable.
- Dependencies: 01, 02, 04, 05

## Decisions
- Implement the first version as a skill plus versioned Markdown artifacts, not
  a programmatic state machine. Instructions are not enforced security controls.

## Open questions
None blocking this instruction-based first version. Runtime enforcement and live
provider integration are separate future work.

## Verification
- **AC-1:** Review the reference and template against the criterion and walk
  a representative scenario, recording the outcome and any runtime limitations.
- **AC-2:** Review the reference and template against the criterion and walk
  a representative scenario, recording the outcome and any runtime limitations.
- **AC-3:** Review the reference and template against the criterion and walk
  a representative scenario, recording the outcome and any runtime limitations.
- Validate skill structure and local links; execute applicable repository checks
  only when active adapter trust is established.

## Integrated validation (2026-11-10)
- The assembled `delivery-workflow` skill passed the installed skill-creator
  `quick_validate.py` validator. All changed/new Markdown files passed a local
  relative-link and whitespace scan, including untracked files; tracked edits
  also passed `git diff --check`.
- [Manual scenarios](../tests/delivery-workflow/scenarios.md) record cross-slice
  walkthroughs, findings, and corrections. These are instruction-level evidence,
  not application tests or proof of live provider integration.
- Entrypoint, references, templates, README, and the workflow guide are integrated.
  The shared state template now includes uncertain progress and in-flight outcomes.
- After explicit user authorization, `bash tests/run.sh` passed with exit status
  0: all 11 suites completed, including 139/139 hook fixtures. The shared trust
  lookup confirmed this checkout against a temporary `HARNESS_HOME/trusted-projects`
  entry before execution. That entry was removed afterward; global configuration
  was unchanged. This result supersedes the earlier trust-blocked slice notes.
- No live skill installation, automated recovery, or production deployment was
  exercised. The slice notes below preserve the earlier implementation review;
  this integrated review supersedes their pending structure/template status.

## Slice verification results
- Manual tabletop review of `references/resume.md` against AC-1: with an approved
  agreement, one completed increment, one pending increment, and an expired
  runtime permission, the procedure retains the historical approval, identifies
  the remaining work, and records the permission-dependent action as blocked.
- AC-2: with a dirty checkpoint and a later unrelated user edit, the procedure
  compares the preserved snapshot to current work and protects the unrelated
  edit; a missing baseline blocks dependent work instead of inventing it.
- AC-3: with a relevant dependency change after a passing check, the procedure
  preserves the old result, marks it stale, and calls for the relevant required
  check again without repeating the completed increment. These are walkthroughs
  of written instructions, not a live recovery or proof of runtime enforcement.
- Reviewed the shared state template and verified that the resume and state
  links exist. The template's status and in-flight outcome representation needs
  reconciliation with the resume procedure; skill-wide validation remains
  outstanding. `git diff --check` on these paths passed (untracked files are not
  covered by that command). Repository checks were not run because active
  adapter trust has not been established.
