# Work modes and execution agreement

## Goal
Declare work type, current and target maturity, and authorized execution mode independently while preserving the existing SDD handoff.

## Context
This is delivery-workflow spec 01 of eight. The existing SDD workflow in
`specs/2026-11-10-spec-workflow.md` separates spec-builder from implementation.
The user authorized implementation of the eight discussed slices using the current
harness and Terra implementation agents on 2026-11-10.

## In scope
- Implement this slice as portable instructions in
  `skills/delivery-workflow/references/agreement.md` and relevant Markdown templates.
- Integrate through the new skill entrypoint and current project documentation.
- Validate the documented behavior with concrete scenarios and honest evidence.

## Out of scope
No task runner, automatic permissions, hook changes, or mandatory workflow for all consumers.

## Acceptance criteria
- **AC-1:** Given a new initiative, its agreement records product, feature, or prototype independently from exploration, demo, pilot, or production maturity.
- **AC-2:** Given an approved spec, the agreement identifies authorized actions, protected boundaries, consultation triggers, and the delivery condition; demo maturity never grants additional permissions.
- **AC-3:** Given a staged SDD request, the existing spec-builder handoff remains available without opting into continuous execution.

## Constraints
- Use the existing skill installer and SDD workflow; no new executable orchestrator.
- Existing project conventions, OpenSpec, user authorization, sandbox permissions,
  and adapter trust take precedence. Do not modify trust or install hooks.
- Keep documents in English, changes scoped, and historical evidence identifiable.
- Dependencies: None.

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
- **AC-1:** Manual review passed: a feature can be recorded with current
  exploration and target demo maturity in separate template fields.
- **AC-2:** Manual review passed: for an approved demo spec, the template
  separately records authorized actions and evidence, protected boundaries,
  consultation triggers, and the delivery condition; the reference states
  that maturity and mode confer no authority and preserves existing approvals.
- **AC-3:** Manual review passed: the reference retains the staged spec-builder
  handoff without requiring continuous execution. This is guidance, not runtime
  enforcement; no live execution scenario was run.
- The agreement reference's relative template link resolves. Full skill
  structure and link integration remain to be reviewed after the other slices
  are assembled. Repository checks were not run: adapter trust for repository
  scripts was not established.
