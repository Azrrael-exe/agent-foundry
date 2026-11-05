---
name: harness-retro
description: "Use at the end of a piece of work, or when the user asks for a retro, to turn repeated mistakes into new harness guides or sensors: 'retro', 'what should the harness learn', 'harness retro'."
---

# Harness retro

Find what went wrong repeatedly and propose how the harness should prevent it next time.
Propose only: apply nothing without the user's approval.

## Steps

1. **Manual corrections in this session.** Re-read the conversation and list every time the
   user corrected, reverted or redirected the work. For each: what happened, what the
   correction was.
2. **Recorded blocks.** Run `harness-report 14 -p <project dir name>` (or the period the user
   asks for) for counts by hook, rule and project. For detail, read
   the active adapter's `events.jsonl` (fields: ts, hook, rule, decision, project, session,
   summary). If there are no events, say so and continue.
3. **Group repeated issues.** Also flag false positives: blocks the user had to work around or
   disable.
4. **Propose one change per group:**
   - **Sensor** if it can be checked mechanically: hook rule, check.sh step, lint rule, test.
   - **Guide** if it cannot: an instruction file or a skill change.
   - **Layer**: global only if it applies to every project; otherwise
     the project (its instructions, `.harness/check.sh`, lint config).
   - The test that proves it: a fixture in the harness test suite for hooks, or
     a project test.
5. **Output** one table and stop:

   | Issue | Evidence | Sensor / guide | Layer | Proposed change | Test |
   |---|---|---|---|---|---|

## After approval

For each approved item: make the change → add the fixture or test → run the suite
(`tests/hooks/run.sh` from the harness repository for global hooks) → commit only with explicit approval (see `git-hygiene`).

## Rules

- Prefer a sensor over a guide whenever the check can be mechanical.
- One-off mistakes do not justify a new rule; say so instead of proposing one.
- Never put project-specific rules in the global layer.
