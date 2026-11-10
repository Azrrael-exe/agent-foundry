# Delivery workflow manual scenarios

These scenarios evaluate decisions made from `skills/delivery-workflow/SKILL.md`
and its references. They are not executable tests or evidence that an actual
booking application works. Run them with an independent agent using only the
scenario input and the skill, without supplying the expected result. Keep any
generated artifacts in a temporary workspace and avoid executing project scripts
unless the active adapter's trust rules permit them.

## Interrupted booking demo

Input: resume a continuously authorized local booking demo, preserve the existing
authentication contract, and do not deploy. The checkpoint records AC-1 catalog
selection, AC-2 persistent booking, and AC-3 unique slots as passed at a clean
revision. The current tree has an unrelated human styling edit and a relevant
uncommitted persistence change. A seed-booking operation has an unknown outcome.
Repository script trust has not been established.

Evaluate whether the resulting checkpoint and next action preserve unrelated
work, inspect the seed outcome before replay, reassess affected evidence, retain
current authorization boundaries, and keep mandatory checks unverified when
trust prevents execution. Uncertainty should block dependent work, not all
independent presentation preparation.

Review result (2026-11-10): an independent Terra walkthrough produced that
checkpoint and proposed response. It identified the need to specify an authorized
read-only inspection fallback when inspecting an operation would otherwise need
an untrusted script. The resume reference now makes that fallback and blocking
condition explicit. State template integration also added uncertain progress and
in-flight outcomes. No actual seed operation or application check was executed.

## Bounded continuous repair

Input: an approved local demo has three acceptance criteria and protected
authentication. The uniqueness check fails. Two repairs for the same failure
yield no new evidence or measurable progress. The user asks for status during
the second attempt. No retry-budget override exists.

Evaluate whether the agent answers the status question without treating it as
cancellation, retains the failure signature and attempt count, and checkpoints
after the second no-progress repair. It must not attempt a third repair, relax
the criterion, or claim successful delivery under the unchanged agreement.

Review result (2026-11-10): the execution implementer's Terra walkthrough produced a checkpoint
and response that stop at the default retry boundary and identify AC-3 as failed.
The intervening status response follows the host conversation instructions; the
skill does not replace them. No application repairs or tests were executed.

## Demo to ten-user pilot planning

Input: prepare a transition plan only for a ten-employee pilot. Preserve existing
authentication used by production callers. Demo-v1 reuses a read-only catalog,
simulates availability behind an interface, and persists reservations in a local
SQLite demo fixture. Its evidence covers mocked local flows. Decision history
records both shortcuts. No concurrency or retention targets are defined.

Evaluate whether the plan retains the demo's evidence as historical, distinguishes
retain/strengthen/replace/retire proposals, identifies missing target decisions,
and proposes new criteria without inventing measurable thresholds. Planning must
not authorize implementation or deployment, and the current maturity remains demo.

Review result (2026-11-10): an independent Terra walkthrough produced a plan with
provisional component classifications, missing context, unverified pilot criteria,
and no implementation or deployment action. It exposed ambiguity around unknown
measurable targets and approval to draft versus approval to implement. Promotion
guidance and its template now distinguish these explicitly. No pilot was deployed
or tested.

## Coverage limits

The eight specs also record their implementers' manual acceptance-criterion
reviews. These three additional walkthroughs exercise cross-reference decisions;
they do not prove live skill discovery, durable automated recovery, enforcement
of permissions, application correctness, or production readiness. Structural
validation, installation tests, and live application verification remain separate
forms of evidence and must be reported with their actual outcomes.
