# Component reuse and modification boundaries

## Goal
Plan reuse and extension of existing components while preserving agreed contracts and unrelated work.

## Context
This is delivery-workflow spec 03 of eight. The existing SDD workflow in
`specs/2026-11-10-spec-workflow.md` separates spec-builder from implementation.
The user authorized implementation of the eight discussed slices using the current
harness and Terra implementation agents on 2026-11-10.

## In scope
- Implement this slice as portable instructions in
  `skills/delivery-workflow/references/reuse.md` and relevant Markdown templates.
- Integrate through the new skill entrypoint and current project documentation.
- Validate the documented behavior with concrete scenarios and honest evidence.

## Out of scope
No sandbox, isolation guarantee, compulsory worktree, or automatic architecture analysis engine.

## Acceptance criteria
- **AC-1:** Given a feature request, the reuse plan identifies existing components to reuse or extend and new components, with references and rationale.
- **AC-2:** Given protected components or contracts, the plan names the boundaries and concrete compatibility verification.
- **AC-3:** Given a required change to a protected contract beyond authorization, the workflow revisits the agreement before making that change.

## Constraints
- Use the existing skill installer and SDD workflow; no new executable orchestrator.
- Existing project conventions, OpenSpec, user authorization, sandbox permissions,
  and adapter trust take precedence. Do not modify trust or install hooks.
- Keep documents in English, changes scoped, and historical evidence identifiable.
- Dependencies: 01, 02

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
- **AC-1:** Manual scenario review: for a feature adding an export format, the
  plan records reuse of the existing exporter, extension of its format registry,
  and a new formatter, with references, rationale, and affected callers. The
  template supports these entries; no live project discovery was performed.
- **AC-2:** In that scenario, a protected export API and existing formats are
  recorded with their allowed modification boundary and checks exercising the
  existing callers and outputs. The template records prerequisites and actual
  results; it does not execute or prove compatibility.
- **AC-3:** In that scenario, a needed breaking API change outside authorization
  stops the change and dependent mutations until the spec and agreement are
  revisited and required authorization is obtained. This was a manual review of
  instructions, not a runtime enforcement test.
- Reviewed the reference and template for their local relative link and required
  fields. Repository checks were not run because active adapter trust was not
  established. Full skill structure validation is pending integration of the
  entrypoint and other slices.
