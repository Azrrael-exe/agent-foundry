# Reuse plan: <initiative name>

- **Spec and agreement:** <references and approval evidence>
- **Baseline:** <revision or other identifiable state; relevant existing changes>
- **Discovery and limits:** <sources, interfaces and callers inspected; gaps,
  including access, tool coverage, or trust limitations>

## Components

| Need | Reuse, extend, or create | Component and evidence | Rationale and affected callers |
| --- | --- | --- | --- |
| <need> | <decision> | <reference; for new work, proposed location> | <reason; callers and dependencies> |

## Boundaries and verification

| Protected component or contract | Modification boundary | Compatibility or regression check | Prerequisites and result |
| --- | --- | --- | --- |
| <reference and observable contract> | <allowed change; unrelated work to preserve> | <concrete check of behavior and affected callers> | <trust, environment, and actual result or not run> |

## Decisions and unresolved evidence

- **Uncertainty:** <what is unknown, impact, and how it will be resolved>
- **Out-of-bound contract change:** <none, or required change and link to revised
  spec/agreement and authorization before dependent mutation>
- **Decision history:** <references to prior decisions and changes>
