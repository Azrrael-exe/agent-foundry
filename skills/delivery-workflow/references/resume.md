# Resume an interrupted initiative

Read the current checkpoint using the [state template](../assets/state.md), or
the project's equivalent, and follow links to the authoritative spec, agreement,
approval evidence, journal, implementation notes, and verification. These are
working records, not an automatic recovery system or security control.

1. Establish the last approved scope, boundaries, execution mode, stopping
   conditions, and authorized actions from the spec, agreement, and their
   approval evidence. Reconcile conflicts or missing evidence before affected
   work. A changed acceptance criterion requires an approved change; record it
   and preserve the prior criterion and evidence. Historical authorization
   remains valid within unchanged scope, but does not grant current runtime
   permissions, adapter trust, or permission to bypass a guard.
2. Compare the current repository and relevant environment with the checkpoint
   and its actual snapshot. Inspect relevant tracked and untracked changes,
   dependencies, configuration, and contracts; identify unrelated user work and
   protect it. For a dirty checkpoint, use its preserved complete snapshot or
   base, tracked diff, and untracked contents; `HEAD` alone cannot reproduce it.
   If the baseline or a difference cannot be established, record the uncertainty
   and block only work that depends on it. Never overwrite unrelated work to
   recreate the checkpoint.
3. Reconcile each increment as completed, pending, or uncertain against the
   current evidence. Inspect the actual outcome of any in-flight side effect
   before replaying it; if its outcome cannot be established, stop dependent
   actions. Use an authorized read-only inspection route; if inspection itself
   requires an untrusted repository script, keep that dependency blocked rather
   than running it or assuming the prior operation failed.
   Do not blindly repeat completed work, even when its evidence is stale.
   Retain prior repair attempts and the applicable retry budget across resumes.
4. Reassess evidence affected by changes to code, dependencies, configuration,
   environment, or criteria. Preserve the historical result, mark affected
   evidence stale and the criterion unverified, and repeat the relevant required
   verification under current permissions and adapter trust. Do not rerun
   unaffected checks merely because the session changed. Follow
   [verification](verification.md) for evidence and delivery status.
5. Update the checkpoint with the reconciled snapshot, completed and pending
   increments, evidence and stale gaps, outstanding side effects, retry counts,
   and the next action authorized by both the agreement and current runtime.
   If suspended or blocked, record the reason and what authorization, evidence,
   or other condition is needed to proceed. Continue independent authorized work
   where possible; do not infer trust or restore expired runtime permissions from
   historical records.
