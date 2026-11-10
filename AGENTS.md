# Agent Foundry project instructions

Agent Foundry provides reusable agent workflows and experimental adapters. Preserve
existing project conventions and the trust boundary described in `docs/security.md`.

## Changes and specs

- For a feature, behavior change, significant refactor, or change involving a
  consequential decision, write a spec before implementation in
  `specs/<yyyy-mm-dd>-<slug>.md`, using `skills/spec-builder/SKILL.md` as a guide.
- Small, clear corrections that do not change behavior or require a design
  decision may proceed without a spec. Follow explicit user instructions and
  higher-priority instructions when they say otherwise.
- Use the approved spec to guide implementation and verification. Record any
  consequential change in scope or decision in the spec; resolve material open
  questions before implementing the affected behavior.
- Update the README, skills, adapter docs, or other current documentation affected
  by the change. Specs record the decisions for a change; current documentation
  describes current behavior.
- Run applicable checks only under the active adapter's trust rules. Report what
  passed, failed, and was not run, including any manual verification outstanding.
  The repository test entry point is `tests/run.sh`.
