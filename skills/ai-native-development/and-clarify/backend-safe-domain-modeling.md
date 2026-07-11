# Backend-Safe Domain Modeling

This reference defines the domain-modeling discipline used throughout every `and-clarify` interview.

Produce precise package input without editing repository documentation before the delivery unit is claimed and implemented.

## Active Discipline

- Read the relevant `CONTEXT.md`, `CONTEXT-MAP.md`, ADRs, code, and tests before asking questions those sources can answer.
- Challenge conflicts with established language as soon as they appear.
- Sharpen vague or overloaded words into one canonical term.
- Test domain boundaries with concrete scenarios and edge cases.
- Surface contradictions between the proposed model, existing docs, and current behavior.
- Continue until required terminology and architectural decisions are precise enough to package, or one human-owned decision remains as the blocker.

## Choose The Authoritative Home

Put a confirmed result in the place future readers must consult:

- Use the Package Contract for delivery-local scope, behavior, acceptance, and reversible implementation choices.
- Require a `CONTEXT.md` update when a project-specific, implementation-independent term must govern future work. General programming concepts do not belong there.
- Require an ADR only when the decision is hard to reverse, surprising without context, and the result of a real tradeoff. All three conditions must hold.
- Require another repository document update when a stable interface, operational rule, or project fact has an established authoritative home outside the Package Contract.

If no relevant context or ADR location exists, propose the smallest new artifact. File creation remains lazy and belongs to implementation.

## Artifact-Ready Outputs

Return artifact-ready confirmed content, not merely reminders to update documentation.

For a canonical term, record:

```markdown
Target: <existing or proposed CONTEXT.md path>

**<Preferred term>**:
<One or two sentence implementation-independent definition.>
_Avoid_: <ambiguous or rejected alternatives, when relevant>
```

For an ADR, record:

```markdown
Proposed title: <short decision title>
Target: <existing or proposed ADR directory>
Draft: <one to three sentences stating the context, decision, and why>
Relevant options or consequences: <only when they add durable value>
```

For another documentation update, record the target document and section, the precise content to add or replace, and why that document is authoritative.

## Boundaries

- Preserve exact confirmed meaning without editing repository files during clarification.
- Keep `CONTEXT.md` entries implementation-independent, project-specific, concise, and opinionated about preferred language.
- Keep ADRs sparse; easy, obvious, or no-tradeoff decisions remain outside ADRs.
- Keep delivery-local decisions in the Package Contract instead of manufacturing permanent documentation.
- Keep unconfirmed language, decisions, and document drafts as blockers rather than resolved outputs.
