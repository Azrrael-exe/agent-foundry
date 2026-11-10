# Continuous execution within approved scope

## Goal
Coordinate implementation, verification, repair, and documentation until the approved delivery condition or a bounded stopping condition is reached.

## Context
This is delivery-workflow spec 05 of eight. The existing SDD workflow in
`specs/2026-11-10-spec-workflow.md` separates spec-builder from implementation.
The user authorized implementation of the eight discussed slices using the current
harness and Terra implementation agents on 2026-11-10.

## In scope
- Implement this slice as portable instructions in
  `skills/delivery-workflow/references/execution.md` and relevant Markdown templates.
- Integrate through the new skill entrypoint and current project documentation.
- Validate the documented behavior with concrete scenarios and honest evidence.

## Out of scope
No background runner, unlimited retries, implicit publishing, or mandatory multi-agent execution.

## Acceptance criteria
- **AC-1:** Given approved scope and continuous execution authorization, the agent advances through increments without asking again for already authorized steps.
- **AC-2:** Given a repair inside scope, the agent proceeds; a decision beyond protected boundaries returns for approval before dependent work.
- **AC-3:** Given an external blocker or exhausted no-progress retry limit, execution checkpoints completed and pending work, evidence, and the required next action.

## Constraints
- Use the existing skill installer and SDD workflow; no new executable orchestrator.
- Existing project conventions, OpenSpec, user authorization, sandbox permissions,
  and adapter trust take precedence. Do not modify trust or install hooks.
- Keep documents in English, changes scoped, and historical evidence identifiable.
- Dependencies: 01, 02, 03, 04

## Decisions
- Implement the first version as a skill plus versioned Markdown artifacts, not
  a programmatic state machine. Instructions are not enforced security controls.
- Default stop condition: after two consecutive repair attempts for the same
  failure without new evidence or measurable progress, checkpoint and report the
  blocker. An explicitly agreed budget may replace this default.

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
- **AC-1, manual scenario review:** The execution reference advances from an
  approved increment through verification and the next authorized increment in
  continuous mode; staged mode stops at its agreed increment. This is a review
  of instructions, not a live agent execution.
- **AC-2, manual scenario review:** An in-scope repair proceeds; a protected
  contract change beyond authorization stops before the change and dependent
  work for a revised agreement and missing approval. Existing authorization is
  retained. This does not enforce a permission boundary.
- **AC-3, manual scenario review:** An external blocker or two consecutive
  no-progress repairs for one failure leads to a checkpoint with completed and
  pending increments, evidence, blocker, retry state, and next action. An
  explicitly agreed budget may replace the default. This is not runtime proof.
- Skill structure and local links require integration review after the parallel
  slices are present. Repository checks were not run: active adapter trust has
  not been established. Runtime behavior remains unverified.
