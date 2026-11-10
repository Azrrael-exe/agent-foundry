# Execution within the agreement

Use the approved spec and agreement to select a bounded increment and its
acceptance criteria. One agent can carry out the workflow; delegate only when
authorized and available. In continuous mode, continue through the approved
increments without seeking approval again for actions already authorized. In
staged mode, stop at the agreed increment and report its result.

For each increment:

1. Implement within the approved scope and reuse boundaries. Preserve unrelated
   and user changes. If a required scope expansion or protected contract change
   exceeds authorization, stop before that change and dependent work; revise
   the spec and agreement and obtain the missing approval.
2. Perform applicable checks under the active adapter's trust rules. Record
   actual outcomes and limitations; skipped or stale evidence cannot establish a
   mandatory criterion. Follow [verification](verification.md) for evidence.
3. Update the [journal and current technical documentation](journal.md), the
   acceptance evidence, and the current checkpoint. Adapt the
   [state template](../assets/state.md) or an existing equivalent. Preserve
   historical evidence and identify the snapshot to which it applies.
4. Repair an in-scope failure, or proceed to the next authorized increment. If
   an external blocker prevents dependent work, continue useful independent
   authorized work where possible, then checkpoint and report what is needed.

Track each failure by its signature, consecutive repair attempts, evidence,
and measurable progress. By default, after two consecutive repair attempts for
the same failure without new evidence or measurable progress, stop repairing
that failure, checkpoint completed and pending work, and report the blocker and
required next action. An explicitly agreed retry budget may replace this default;
record the budget and its stopping condition. Do not retry indefinitely. A new
observation or measurable progress must be recorded, not assumed from an attempt.

At the agreed delivery condition, apply the verification reference before
claiming completion. These instructions coordinate work; they are not a runner
or an enforced security control.
