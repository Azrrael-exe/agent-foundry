# Plan a transition to pilot or production

## Goal
Evaluate the gaps between a delivered demo and a target maturity and produce a reviewable transition plan.

## Context
This is delivery-workflow spec 08 of eight. The existing SDD workflow in
`specs/2026-11-10-spec-workflow.md` separates spec-builder from implementation.
The user authorized implementation of the eight discussed slices using the current
harness and Terra implementation agents on 2026-11-10.

## In scope
- Implement this slice as portable instructions in
  `skills/delivery-workflow/references/promotion.md` and relevant Markdown templates.
- Integrate through the new skill entrypoint and current project documentation.
- Validate the documented behavior with concrete scenarios and honest evidence.

## Out of scope
No execution of the entire conversion, automatic deployment, or maturity certification from a checklist alone.

## Acceptance criteria
- **AC-1:** Given a target pilot or production context, the agent reviews simulations, shortcuts, and pending decisions against explicit target requirements.
- **AC-2:** Given the gap analysis, affected components are classified to retain, strengthen, replace, or retire with reasons.
- **AC-3:** Given a transition plan, new criteria and verification are proposed; current maturity changes only after approved criteria have supporting evidence.

## Constraints
- Use the existing skill installer and SDD workflow; no new executable orchestrator.
- Existing project conventions, OpenSpec, user authorization, sandbox permissions,
  and adapter trust take precedence. Do not modify trust or install hooks.
- Keep documents in English, changes scoped, and historical evidence identifiable.
- Dependencies: 01, 02, 04, 07

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
- Manual document review on 2026-11-10: traced AC-1 through the target-context,
  simulations, shortcuts, and decision-trigger guidance. In a hypothetical demo
  with mocked identity and pilot users, the plan calls for identifying the pilot's
  access requirements, recording the mock and evidence gap, and revisiting the
  identity decision. This is a walkthrough of instructions, not a live pilot.
- AC-2: in the same walkthrough, the mocked identity integration can be proposed
  for replacement with a rationale tied to those requirements, dependencies, and
  unresolved evidence; other components may be retained, strengthened, or retired
  based on their own context. No classification is asserted as proven.
- AC-3: the template requests new criteria, verification scope, prerequisites and
  missing decisions; the reference keeps maturity unchanged until approved criteria
  have current supporting evidence. A plan alone does not authorize conversion or
  deployment. This review does not establish runtime behavior.
- Local link and skill structure validation and repository checks are pending
  integration. Repository checks require active adapter trust; no runtime test,
  production certification, or completed delivery is claimed here.
