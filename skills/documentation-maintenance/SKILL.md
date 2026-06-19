---
name: documentation-maintenance
description: Agent-first documentation maintenance workflow for deciding whether documentation is needed, choosing the right document type and location, avoiding code repetition, updating or deleting stale docs, and creating discoverable docs. Use when an agent is asked to create, update, clean up, reorganize, review, or decide whether to maintain project documentation, README/AGENTS/CONTEXT/ADR/runbook files, or docs-as-code content.
---

# Documentation Maintenance

## Principle

Optimize documentation for future agents recovering context. Human readability matters, but the primary goal is to preserve the facts, decisions, constraints, and routes that code alone does not reliably expose.

Code should explain current behavior through names, types, schemas, tests, and module boundaries. Documentation should explain why the behavior exists, what must not be broken, how to operate it safely, and where future agents should look first.

## Workflow

1. **Inspect local rules first.** Read project entry points such as `AGENTS.md`, `CLAUDE.md`, `docs/agents/*.md`, `CONTEXT.md`, and existing `docs/` indexes when present.
2. **Classify the change.** Decide whether the task affects implementation only, business rules, operations, architecture, cross-module contracts, domain language, or historical context.
3. **Decide if docs are needed.** Write docs only when future agents would likely misunderstand, miss, or have to rediscover the context from code alone.
4. **Choose one source of truth.** Update the nearest existing source instead of creating duplicates. Link to source facts rather than copying them.
5. **Write for retrieval.** Include trigger conditions, invariants, risks, verification paths, and relevant code entry points.
6. **Guard semantic rewrites.** When replacing a doc rather than editing it, compare the old and new meaning before pruning.
7. **Prune stale material.** Delete, merge, or redirect outdated docs. Incorrect docs are worse than missing docs.
8. **Report the decision.** In the final response, say which docs changed, or why no doc update was needed.

## Write Docs When

- The change alters business rules, user-visible behavior, operating procedure, or system guarantees.
- The decision has durable consequences: architecture, data model, infrastructure, dependency, security, billing, deployment, or integration boundaries.
- The rule spans multiple modules or systems and cannot be safely inferred from one file.
- The work reveals a recurring debugging, migration, rollback, or verification procedure.
- The project needs stable vocabulary for domain concepts, issue titles, tests, or future implementation work.
- A design, UX, accessibility, content, or visual rule guides future implementation and is not obvious from code alone.
- A future agent would otherwise need to repeat expensive investigation.

## Do Not Write Docs When

- The doc would only restate function bodies, parameters, file names, or obvious call flow.
- Good naming, types, schemas, tests, or small comments can make the code self-explanatory.
- The content is temporary and belongs in a scratch note, issue, PR comment, or final response.
- The same fact already exists elsewhere and can be linked.
- There is no clear maintenance trigger.

## Location Heuristics

- **Agent entry/index:** `AGENTS.md` or `CLAUDE.md`. Keep it short; use it as a router to deeper docs.
- **Agent-local rules:** `docs/agents/*.md`. Use for project-specific instructions that agents should read when doing a class of task.
- **Domain vocabulary:** `CONTEXT.md`, or a context map if the repo is multi-context.
- **Architecture decisions:** `docs/adr/NNNN-title.md`. Use for durable decisions, alternatives, tradeoffs, and consequences.
- **Stable runbooks/reference:** `docs/<topic>.md`. Use for operations, environment, deployment, data, billing, worker, API, or integration procedures.
- **Historical records:** `docs/changes/YYYY-MM-title.md`. Use for one-time migrations, incidents, validation records, or background that should not clutter current runbooks.
- **Active work:** `.scratch/<feature>/`. Use for PRDs, issue breakdowns, exploration notes, and unstable plans.

Prefer updating an existing topic doc over creating a new one unless the topic has a stable independent reader and maintenance trigger.

## Agent-First Structure

When creating or reshaping a document, prefer these sections when relevant:

- **Purpose:** what context problem this document solves.
- **Read when:** task triggers that should make an agent open it.
- **Source of truth:** where the canonical fact lives.
- **Invariants:** rules that must not be violated.
- **Procedure:** steps for operation or maintenance tasks.
- **Verification:** tests, commands, logs, screenshots, or API checks that prove correctness.
- **Related files:** important code entry points, without narrating the whole implementation.
- **Update when:** changes that require revisiting the document.

Use concise headings and searchable terms. Avoid long narrative chronology except in historical change records.

## Semantic Rewrite Guard

Use this when replacing or heavily compressing an existing document, especially `DESIGN.md`, runbooks, ADRs, README files, and domain context.

- Compare the old and new document by meaning, not by line count.
- Keep a retention ledger, explicit or internal: fact or constraint, current source, disposition, and reason.
- Delete a fact only when it is stale, duplicated in a better source, or safely recoverable from code, tests, schemas, tokens, or config.
- Preserve design constraints that code does not explain: product stance, interaction rules, layout boundaries, component behavior, accessibility, motion, content style, and acceptance checks.
- Preserve operational constraints that are easy to get wrong: permissions, rollout, rollback, verification, security boundaries, and external service setup.

Completion criterion: a future agent reading the new doc plus linked sources can make the same important implementation and operations decisions as one reading the old doc.

## ADR Guidance

Use an ADR when the team chooses a durable path among meaningful alternatives. Include:

- Context and forces
- Decision
- Considered alternatives
- Consequences and tradeoffs
- Status, if the repository uses ADR statuses

Do not use ADRs for routine implementation notes or temporary plans.

## Final-Response Rule

After a task that could affect documentation, explicitly state one of:

- `Docs updated:` followed by the files and reason.
- `Docs not updated:` followed by the reason the code, tests, or existing docs are sufficient.
