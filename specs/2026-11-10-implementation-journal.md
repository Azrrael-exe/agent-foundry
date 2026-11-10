# Implementation journal and current technical documentation

## Goal
Keep a concise durable record of consequential implementation decisions and an accurate description of the current system.

## Context
This is delivery-workflow spec 02 of eight. The existing SDD workflow in
`specs/2026-11-10-spec-workflow.md` separates spec-builder from implementation.
The user authorized implementation of the eight discussed slices using the current
harness and Terra implementation agents on 2026-11-10.

## In scope
- Implement this slice as portable instructions in
  `skills/delivery-workflow/references/journal.md` and relevant Markdown templates.
- Integrate through the new skill entrypoint and current project documentation.
- Validate the documented behavior with concrete scenarios and honest evidence.

## Out of scope
No command transcript, automatic code extraction, secrets, or duplicated source code.

## Acceptance criteria
- **AC-1:** Given a consequential decision, the journal records its context, choice, consequences, status, and affected component references.
- **AC-2:** Given a replaced decision, history remains available and the successor is unambiguous.
- **AC-3:** Given an increment, current documentation identifies changed components, contracts, limitations, and simulated versus real integrations without copying the action transcript.

## Constraints
- Use the existing skill installer and SDD workflow; no new executable orchestrator.
- Existing project conventions, OpenSpec, user authorization, sandbox permissions,
  and adapter trust take precedence. Do not modify trust or install hooks.
- Keep documents in English, changes scoped, and historical evidence identifiable.
- Dependencies: 01

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
- **AC-1:** Reviewed the reference and journal template against a scenario choosing a real provider over a considered simulator: context, choice, alternatives, consequences, state, component references, and evidence have explicit places. The instructions distinguish intention, assumptions, and observations.
- **AC-2:** Walked a replacement scenario: the original entry remains with a superseded state and successor ID; the successor points back and records the trigger. This is a documentation convention, not an enforced state machine.
- **AC-3:** Reviewed a simulated-to-real integration increment against the current-view template: changed responsibilities, interfaces, flow, integration status, reuse, operation, limits, and evidence can be recorded without an action transcript.
- Reviewed the three new Markdown resources and their relative asset references. Full skill structure and entrypoint link validation remain for the integrating agent because the entrypoint is outside this slice.
- `tests/run.sh` and repository-supplied tools were not run because active adapter trust was not established. No live integration or runtime enforcement was tested.
