# Plan a transition to pilot or production

Start from the delivered demo, its approved spec and agreement, current technical
documentation, decision journal, and [verification](verification.md). Reuse and
link existing records instead of copying them. Adapt the [promotion plan](../assets/promotion-plan.md)
or an existing equivalent. Identify the current maturity, proposed target, intended
users, usage, operating environment, and constraints; distinguish known facts
from assumptions and unresolved decisions.

Assess the actual product and target context, not a universal readiness checklist.
Consider operations, access, privacy, reliability, data migration, and performance
when relevant to those users and conditions. Derive explicit target requirements
and identify their sources and missing decisions. Review simulated integrations,
shortcuts, known limits, and pending decisions against those requirements. Revisit
existing `DEC-...` records and identify the evidence or changed conditions that
trigger reconsideration; preserve history and link proposed successors as described
in [journal](journal.md).

Classify each affected component or integration as **retain**, **strengthen**,
**replace**, or **retire**. Explain the target requirement, rationale, evidence
and its limits, dependencies, and unresolved risks or decisions behind each
proposal. Where evidence is insufficient, say so rather than treating the
classification as proven. Sequence proposed work around prerequisites and
dependencies, with the decisions and authorization needed to proceed.

Propose explicit new acceptance criteria and their verification scope, including
the relevant environments, users, data, and evidence needed to support them.
When a measurable target is unknown, label it pending with its decision owner or
next question; do not invent a threshold or treat that criterion as approved or
verifiable yet. Drafting this plan is authorized by a planning request; approval
of the resulting implementation scope is a separate step when still missing.
Preserve existing criteria and historical evidence; reassess affected evidence
when the criteria or snapshot change. Identify missing evidence and the person or
decision needed to resolve each material gap. A plan is a proposal: current
maturity remains unchanged until the target criteria are approved and supported
by current evidence. Follow the agreement and existing explicit authorization;
planning alone grants no permission to implement the conversion or deploy it.
