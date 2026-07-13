# Backend-Safe Domain Modeling

Sharpen the domain model during an interview while leaving repository files unchanged. Return only confirmed package input that a future claimed implementation must apply.

## Active Discipline

- Read the relevant `CONTEXT.md`, `CONTEXT-MAP.md`, ADRs, code, and tests before asking questions those sources can answer.
- Challenge conflicts with established language as soon as they appear.
- Sharpen vague or overloaded words into one canonical term.
- Test domain boundaries with concrete scenarios and edge cases.
- Surface contradictions between the proposed model, existing docs, and current behavior.
- Continue until the terminology and architectural decisions required by the interview objective are precise enough to package, or one human-owned decision remains as the blocker.

## Choose The Authoritative Home

Start with purposeful omission: a confirmed decision needs no repository-document output unless future readers must consult a durable authority beyond this delivery unit.

- Use the Package Contract for delivery-local scope, behavior, acceptance, and reversible implementation choices.
- Return a required `CONTEXT.md` update when a project-specific, implementation-independent term must govern future work. General programming concepts stay in their existing technical authorities.
- Return a required ADR draft only when the decision is hard to reverse, surprising without context, and the result of a real tradeoff. All three conditions must hold.
- Return another required repository-document update when a stable interface, operational rule, or project fact has an established authoritative home outside the Package Contract.

When no existing authority fits a required durable update, propose the smallest new artifact. File creation remains lazy and belongs to implementation. When no category passes these tests, return no repository update.

## Artifact-Ready Outputs

Emit only categories that pass the authority test. For a canonical term, record:

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

- Preserve exact confirmed meaning as package input while repository files remain unchanged.
- Keep `CONTEXT.md` entries implementation-independent, project-specific, concise, and opinionated about preferred language.
- Keep ADRs sparse; only hard-to-reverse, surprising tradeoffs qualify.
- Keep delivery-local decisions in the Package Contract and emit durable-document updates only when their authority test passes.
- Return unconfirmed language or decisions as the current blocker, not as an artifact-ready draft.
