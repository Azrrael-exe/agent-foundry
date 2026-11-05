---
name: spec-builder
description: "Use when the user has an idea, feature request or vague task and wants it turned into a spec before implementation: 'write a spec', 'spec this out', 'define acceptance criteria', 'what exactly should we build'."
argument-hint: "What do you want to build?"
---

# Spec builder

Turn a request into a spec that implementation, tests and scope review can trace back to.
Do not implement anything while using this skill.

## Steps

1. **Read context first.** The request, the code it touches, existing specs, and an `openspec/`
   directory if present. If the project uses OpenSpec, offer to write an OpenSpec change
   (`openspec/changes/<name>/`) in its format instead of the template below.
2. **Interview, one question at a time.** Each question offers options and your recommendation.
   Ask only what the repo cannot answer. Stop asking when every acceptance criterion is testable.
3. **Draft the spec** with the template below and show it in the conversation.
4. **Propose the location**: `specs/<yyyy-mm-dd>-<slug>.md`, or wherever the project keeps specs.
   Write the file only after the user approves the draft and the path.
5. **Hand off.** Suggest next steps: `acceptance-test-writer` to turn the ACs into tests, and
   `scope-auditor` against this spec once the work is done (if those agents are available).

## Template

```markdown
# <Title>

## Goal
One or two sentences: the outcome, not the implementation.

## Context
Why now, who is affected, relevant existing code (paths).

## In scope
- ...

## Out of scope
- ... (explicitly excluded, so scope review can flag it)

## Acceptance criteria
- **AC-1**: Given <state>, when <action>, then <observable result>.
- **AC-2**: ...

## Constraints
Performance, compatibility, security, dependencies allowed or not.

## Open questions
- ... (anything still ambiguous; each becomes a skipped test until answered)

## Verification
Commands that prove the ACs (test command, manual check).
```

## Rules

- Every AC must be verifiable by a test or a command. Rewrite vague ones ("fast", "nice").
- AC IDs are stable: never renumber; mark dropped ones as `~~AC-3~~ (dropped: reason)`.
- Unresolved ambiguity goes to Open questions, not into a guessed AC.
