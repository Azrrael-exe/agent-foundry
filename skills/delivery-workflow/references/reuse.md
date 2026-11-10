# Component reuse and boundaries

Before implementation, adapt the [reuse plan template](../assets/reuse-plan.md)
to the approved spec and work agreement. Update an existing project document
when it already serves this purpose; otherwise keep the plan alongside the work,
optionally under `docs/initiatives/<id>/`. Preserve the baseline and unrelated
work. Keep references and decision changes identifiable.

Inventory relevant existing components before choosing new ones. Follow the
project's discovery conventions and prefer available code graph tools; when
they are unavailable or insufficient, use targeted file and text searches.
Inspect relevant interfaces, callers, tests, and documentation. Record evidence
and any gaps, including when access, tool coverage, or adapter trust limits
inspection or execution. Do not treat missing evidence as compatibility.

For each need, record whether to reuse, extend, or create a component, with a
reference and rationale. Identify affected callers and dependencies, protected
contracts and unrelated work, the intended modification boundary, and concrete
regression checks for each boundary. Checks should exercise observable behavior
or compatibility of affected callers; record their prerequisites and actual
results. Run repository-supplied checks only under the active adapter's trust
rules. A branch or worktree alone is neither a security boundary nor evidence of
compatibility.

If the work requires changing a protected contract beyond the existing
authorization, stop before that change and dependent mutations. Revisit the
spec and agreement, resolve the decision and obtain any required authorization,
then update the plan and verification. Existing approval remains valid within
its scope; do not ask again for an already authorized action. These instructions
guide decisions; they do not enforce isolation or guarantee compatibility.
