# Security and trust

Agent Foundry's guard scripts detect selected patterns. They do not parse shell
fully and are not a sandbox or an access-control boundary. Shell expansion,
indirect commands, unobserved tools, and provider-specific hook coverage can
bypass a guard. Use the agent's sandbox, OS permissions, and credential controls
as independent protections.

Project checks and repository-local formatters execute project-supplied code.
The Claude gate and formatter consult the trust list before running them; the
shared trust lookup resolves physical paths and checks explicit roots. Trust is
local state, not a project file. Only trust repositories you intend to run.

The Claude gate is Git-based: ignored files do not affect its fingerprint,
pre-existing changes become the initial baseline, and a failure is blocked once
for each tree state to prevent a loop. It may not attribute concurrent human
edits correctly. Passing tests do not establish that a project is secure.

Event summaries are supplied by adapters. The shared event writer does not redact
secrets. Callers must never put full commands, file contents, or credentials in
event fields. Logs and trust lists must remain local and out of version control.

Each platform and surface must be tested separately. A hook only governs calls
actually delivered to it; missing hooks, untrusted definitions, unsupported
events, and different tool shapes can leave gaps. See the compatibility
documentation before enabling an adapter.
