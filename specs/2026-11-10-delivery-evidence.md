# Delivery criteria and evidence

## Goal
Make completion a traceable claim about approved acceptance criteria and current evidence.

## Context
This is delivery-workflow spec 04 of eight. The existing SDD workflow in
`specs/2026-11-10-spec-workflow.md` separates spec-builder from implementation.
The user authorized implementation of the eight discussed slices using the current
harness and Terra implementation agents on 2026-11-10.

## In scope
- Implement this slice as portable instructions in
  `skills/delivery-workflow/references/verification.md` and relevant Markdown templates.
- Integrate through the new skill entrypoint and current project documentation.
- Validate the documented behavior with concrete scenarios and honest evidence.

## Out of scope
No universal production certification, automatic trust grant, or runtime gate.

## Acceptance criteria
- **AC-1:** Given a delivery, every acceptance criterion maps to evidence and a passed, failed, or unverified result.
- **AC-2:** Given an unrun check, its reason is recorded without claiming success; execution follows active adapter trust.
- **AC-3:** Given mandatory unresolved criteria or stale evidence, delivery remains incomplete; the report includes run instructions, limitations, and current documentation.

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
Manual review on 2026-11-10 of `references/verification.md` and
`assets/verification.md` in the uncommitted working tree (not a preserved
snapshot):

- **AC-1, instruction review passed:** A walkthrough with three criteria, one
  supported, one contradicted, and one without evidence, maps them respectively
  to passed, failed, and unverified in the template. This is a document review,
  not a live agent execution.
- **AC-2, instruction review passed:** In a walkthrough where adapter trust has
  not been established, the reference calls for the repository check to remain
  unrun and its reason and run instructions to be recorded. No trust was granted
  and no check was executed in that walkthrough.
- **AC-3, instruction review passed:** In a walkthrough where code changes after
  a passing result and a mandatory criterion remains unverified, the reference
  marks affected evidence stale and delivery incomplete, and calls for run
  instructions, limitations, journal, and current documentation review. The
  template has fields for those records.
- Local reference-to-template link was inspected and resolves. Full skill
  structure and cross-resource links await the integrated skill review. Intended
  portability is not evidence of operation in another adapter; no live provider,
  mock integration, or production behavior was tested.
- `tests/run.sh` was not run because repository trust has not been established
  by the active adapter. Run it only after that trust is established. The
  skill-creator validator was not run during this slice; its result remains for
  integrated validation. These manual reviews are not durable snapshot evidence
  and must be reassessed against the final preserved snapshot before claiming
  delivery complete.
