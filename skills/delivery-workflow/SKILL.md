---
name: delivery-workflow
description: Coordinate a spec-driven product, feature, or prototype through implementation and evidence-based delivery; resume work, iterate a demo, or plan its transition to pilot or production. Use when the user wants this continuing workflow, not for drafting a spec alone or a routine isolated edit.
---

# Delivery workflow

Use the project's existing spec and documentation conventions. This skill connects
the implementation stages after specification; it does not replace spec-builder,
install agents, enforce permissions, or run a background process. One coding agent
can perform the whole workflow. Delegate only when authorized and available.

## Start or continue

1. Read the request, project instructions, relevant code, existing spec, and any
   initiative record. Prefer the project's code-discovery tools when available;
   fall back explicitly when they are unavailable or insufficient.
2. For new work, read [agreement](references/agreement.md). Separate work type
   (product, feature, prototype), current/target maturity (exploration, demo,
   pilot, production), and execution mode (staged, continuous). None grants trust
   or extra permissions. Draft or revise the spec before affected implementation;
   use spec-builder if available, otherwise the project's established process.
3. Record the user's approval of scope and execution boundaries, reusing clear
   authorization already present in the session. Ask only for unresolved material
   decisions or authorization that is actually missing.
4. Read [journal](references/journal.md), [reuse](references/reuse.md), and
   [verification](references/verification.md) before implementation. Identify
   protected contracts, existing work, evidence needed, and the minimal durable
   record. Then follow [execution](references/execution.md).

## Route subsequent work

| Request | Read next | Result |
| --- | --- | --- |
| Resume interrupted work | [Resume](references/resume.md) | Reconciled checkpoint and next authorized action |
| Improve a delivered demo | [Iteration](references/iteration.md) | Feedback mapped to a new increment with requirement history |
| Move toward pilot or production | [Promotion](references/promotion.md) | Reviewed gaps and a proposed transition plan |

On resumption, reconcile before applying another route. Read only the references
needed for the operation; each reference links its output templates. Promotion
planning alone does not authorize implementation or deployment.

## Keep a durable initiative record

Reuse existing specs, ADRs, technical docs, and evidence rather than duplicating
them. Where no convention exists, suggest `docs/initiatives/<initiative-id>/`
for the agreement, journal, implementation notes, and current state; keep the spec
in the project's spec location. Small initiatives may combine these sections.
Templates are starting points, not required filenames or machine schemas.

Keep one current checkpoint with links to the approved scope, current code
reference, completed/pending work, verification, blockers, and next action.
Preserve historical decisions and delivered-version evidence separately from the
current technical description. Mark assumptions, simulations, and invalidated
evidence explicitly. Never store credentials or sensitive customer data.

## Delivery and stopping

Continuous execution advances within the approved agreement; staged execution
ends at its agreed increment. Neither mode authorizes commits, publishing,
deployment, destructive actions, or changes to protected contracts by implication.
Respect existing explicit authorization and the active runtime's permissions.

Run repository checks only under the active adapter's trust rules. If checks
cannot run, record why and retain mandatory criteria as unverified. Keep useful
independent work moving without pretending that the blocker is resolved.

Follow the bounded repair rule in [execution](references/execution.md). At a
blocker or exhausted budget, save the checkpoint and report what is required to
continue. At delivery, use [verification](references/verification.md): report each
criterion's evidence, instructions to run/present the result, limitations, and
remaining work. A demo can satisfy its spec while still lacking production
requirements; never promote maturity solely from a plan or passing generic checks.
