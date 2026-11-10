# Iterate a delivered version

Start from the delivered version, its spec, agreement, decision journal,
verification evidence, and feedback. Adapt the [iteration record](../assets/iteration.md)
(or an existing equivalent), preserving the old version and its evidence. If the
work is instead a continuation of the same unfinished scope, resume from the
[current checkpoint](../assets/state.md) rather than treating it as a new delivery.

For each feedback item, record its source and classify it against the delivered
spec:

- **Defect:** behavior fails an existing criterion; identify the criterion and
  the evidence or observation. Investigate uncertain reports before asserting failure.
- **New requirement:** a desired behavior is outside existing criteria.
- **Changed requirement:** an existing criterion's intended meaning must change;
  identify that criterion and the proposed replacement.

Record the disposition, rationale, and links to affected spec criteria,
[decisions](journal.md), changes, and [verification evidence](verification.md).
Mark unresolved feedback and missing evidence explicitly. Feedback alone does
not authorize implementation: compare its disposition with the existing agreement,
approved scope, and user instructions. Continue changes already clearly authorized
without asking again; obtain any missing authorization before work outside those
bounds. Update the agreement and spec when a consequential scope or decision
changes, preserving the user's intent and approval history.

Keep unchanged acceptance criterion IDs and meanings. Never silently renumber or
reuse an ID for different semantics. Retain a changed or retired criterion as
historical, mark it superseded, and link it to a new unique successor ID; link
the successor back and record the change and approval. Reassess affected evidence
when a criterion or snapshot changes, retaining old evidence with its original
version and marking stale evidence accordingly.

For each delivery, record its code reference and substantive differences from
its predecessor, linked to feedback, changes, and current evidence. A clean
committed tree can use its commit ID. For a dirty tree, distinguish `HEAD` from
the delivered working tree and preserve a durable, retrievable snapshot containing
the base commit, complete tracked diff, and untracked manifest with necessary
file contents, or an equivalent complete snapshot. Record its location and any
limitations; `HEAD` alone does not identify dirty work. Protect sensitive content
and do not include secrets. Do not force a commit or push to create a reference.
