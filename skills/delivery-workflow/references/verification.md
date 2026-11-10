# Delivery verification

Adapt the [verification template](../assets/verification.md) to the approved
acceptance criteria and the project's existing evidence conventions. Link the
agreement, spec, journal, and current technical documentation rather than
duplicating them. A suggested location is `docs/initiatives/<id>/`; follow the
project's established conventions. These instructions support a reviewable
claim, not an executable gate or production certification.

Identify the exact code snapshot and environment to which each result applies.
For a clean committed tree, a commit identifier can identify the snapshot. For
uncommitted work, preserve a durable, retrievable artifact containing the base
commit, the complete tracked diff and untracked-file manifest with the necessary
file contents (or an equivalent complete snapshot); link it and identify it in
the record. Do not rely on `HEAD` alone. Protect sensitive content when storing
evidence. Record the check or observation, result, date, environment, and link
to its output or other evidence. When the relevant code, dependencies,
configuration, environment, or acceptance criterion changes, reassess affected
evidence; mark it stale and the criterion unverified until current evidence
supports a result. Preserve historical evidence with its original snapshot.

Map every approved acceptance criterion to evidence and one status:

- **passed:** current evidence supports the whole criterion within its stated scope.
- **failed:** current evidence shows the criterion is not satisfied.
- **unverified:** evidence is missing, stale, inconclusive, or a necessary check
  was not run. Record what remains and why.

Record each applicable check's exact command or manual procedure, outcome, and
limitations. For skipped checks, give the reason and how to run them. Establish
repository trust under the active adapter before executing repository-supplied
scripts or checks; an instruction to verify does not grant trust. Follow the
adapter's guard decisions and permissions. A weakened or substituted check must
be identified with its reduced coverage and cannot by itself establish completion
of a criterion requiring the original coverage.

Review the decision journal and current technical documentation for completeness
for the changed work, including contracts, dependencies, operation and run
instructions, and known limitations. Record gaps and who or what must resolve
them. Distinguish intended compatibility from observed evidence; identify mocks,
simulations, and environments used, and do not present them as proof of live or
production behavior.

Report delivery as complete only when every mandatory criterion has passed on
current evidence and required documentation is complete. Mandatory failed or
unverified criteria, stale evidence, and unresolved required documentation keep
delivery incomplete. Report remaining work, run instructions, limitations, and
links to current documentation with the claim. Do not commit, install, or publish
as a consequence of verification without authorization.
