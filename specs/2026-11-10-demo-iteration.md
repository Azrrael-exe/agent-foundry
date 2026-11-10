# Iterate a delivered demo

## Goal
Convert feedback into a traceable next increment without losing previous versions or requirement history.

## Context
This is delivery-workflow spec 07 of eight. The existing SDD workflow in
`specs/2026-11-10-spec-workflow.md` separates spec-builder from implementation.
The user authorized implementation of the eight discussed slices using the current
harness and Terra implementation agents on 2026-11-10.

## In scope
- Implement this slice as portable instructions in
  `skills/delivery-workflow/references/iteration.md` and relevant Markdown templates.
- Integrate through the new skill entrypoint and current project documentation.
- Validate the documented behavior with concrete scenarios and honest evidence.

## Out of scope
No customer messaging integrations, automatic releases, or automatic commits.

## Acceptance criteria
- **AC-1:** Given feedback on a delivered version, it is classified as a defect against an existing criterion, a new requirement, or a changed requirement.
- **AC-2:** Given agreed requirement changes, the spec retains stable criterion IDs and history instead of reusing identifiers for different meanings.
- **AC-3:** Given a new delivery, its code reference and differences from the prior version are recorded, including dirty-tree limitations when no immutable revision exists.

## Constraints
- Use the existing skill installer and SDD workflow; no new executable orchestrator.
- Existing project conventions, OpenSpec, user authorization, sandbox permissions,
  and adapter trust take precedence. Do not modify trust or install hooks.
- Keep documents in English, changes scoped, and historical evidence identifiable.
- Dependencies: 01, 02, 04, 06

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
Manual review on 2026-11-10 of the iteration reference and template:

- **AC-1:** Walked feedback that a delivered search fails an existing criterion,
  a request for export, and a request to change the search criterion. The
  instructions classify these as defect, new requirement, and changed requirement,
  respectively, and record source, disposition, and trace links.
- **AC-2:** Walked unchanged AC-1 alongside a changed AC-2: AC-1 retains its ID;
  AC-2 is retained as superseded and linked to a new successor with approval
  evidence. The template records both directions and does not reuse the old ID.
- **AC-3:** Walked a dirty delivery based on a prior commit: the record separates
  HEAD from the working tree and calls for a durable tracked diff and untracked
  contents or equivalent, plus differences and evidence links. It does not claim
  HEAD identifies the dirty delivery.
- The four relative targets referenced by the new reference existed when checked
  with shell file-existence tests. Repository checks and skill validator were not
  run because active adapter trust was not established. These are manual reviews
  of instructions, not runtime or independent behavioral verification; skill
  structure and integration require review after the other slices are complete.
