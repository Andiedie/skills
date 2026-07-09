# Backend-Safe Domain Modeling

Use this lens inside `issue-grill` when package correctness depends on domain terms, naming, glossary conflicts, architectural decisions, or documentation implications.

The goal is to keep the domain-modeling discipline while respecting AND's clarification boundary: record package input in the workflow backend, not local repository docs.

## Behavior

- Challenge glossary conflicts. If repository language defines a term one way and the current discussion uses it another way, surface the conflict and ask which meaning should govern the package.
- Sharpen fuzzy or overloaded language. Propose precise canonical terms when words such as "account", "record", "sync", "state", or "done" could mean several things.
- Discuss concrete scenarios. Use edge cases and specific examples to force clear boundaries between concepts.
- Cross-reference with code and docs. Check repository facts before asking questions the codebase can answer, and surface contradictions between stated behavior and existing implementation.
- Identify ADR candidates when all three are true: the decision is hard to reverse, surprising without context, and the result of a real tradeoff.

## Backend-Safe Outputs

Capture confirmed results as `issue-grill` package input:

- glossary proposals;
- ADR candidates;
- documentation updates to include in the package;
- acceptance implications;
- unresolved domain questions.

When a decision is not confirmed, record it as a remaining blocker or State Reason instead of a resolved decision.

## Boundaries

- Do not update `CONTEXT.md` during clarification.
- Do not create ADR files during clarification.
- Do not modify repository docs during clarification.
- Do not treat guesses, partial answers, or unaccepted recommendations as glossary proposals or ADR candidates.
- Do not make `issue-pack` rerun the domain interview. If package correctness depends on missing domain judgment, route back to `issue-grill`.
