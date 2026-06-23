---
name: documentation-maintenance
description: Documentation maintenance for agent-first project docs. Use when asked to create, update, prune, reorganize, review, or decide whether to document repository knowledge such as agent instructions, context maps, ADRs, runbooks, docs indexes, or docs-as-code.
---

# Documentation Maintenance

## Principle

Optimize documentation for future agents recovering context. Human readability matters, but the primary goal is to preserve the facts, decisions, constraints, and routes that code alone does not reliably expose.

Code should explain current behavior through names, types, schemas, tests, and module boundaries. Documentation should explain why the behavior exists, what must not be broken, how to operate it safely, and where future agents should look first.

## Workflow

1. **Inspect local rules first.** Read project documentation conventions before applying these defaults: agent entrypoints, context maps, docs indexes, and repository-specific doc guidance when present.
2. **Classify the change.** Identify durable facts, decisions, constraints, procedures, vocabulary, and source-of-truth changes; then classify them as implementation-only, business rules, operations, architecture, cross-module contracts, domain language, or historical context.
3. **Decide if docs are needed.** Write docs only when future agents would likely misunderstand, miss, or have to rediscover the context from code alone.
4. **Choose one source of truth.** Update the nearest existing source instead of creating duplicates. Link to source facts rather than copying them. For docs-as-code, update the upstream schema, generator, config, source comments, or specification before generated output.
5. **Write for retrieval.** Include trigger conditions, invariants, risks, verification paths, and relevant code entry points.
6. **Guard semantic rewrites.** When replacing a doc rather than editing it, compare the old and new meaning before pruning.
7. **Prune stale material.** Delete, merge, or redirect outdated docs. Incorrect docs are worse than missing docs.
8. **Report the decision.** In the final response, say which docs changed, or why no doc update was needed.

Completion criterion: every durable fact, decision, constraint, procedure, vocabulary change, and source-of-truth change has one disposition: updated in an existing source, documented in a new location with a stable reader and update trigger, pruned or redirected as stale, or intentionally left undocumented because code, tests, or existing docs are sufficient.

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
- No predictable future change would require revisiting it.

## Location Heuristics

Follow local documentation conventions first. When no stronger convention exists, use these destinations:

- **Agent entry/index:** the repo's agent entrypoint, such as `AGENTS.md` or `CLAUDE.md`. Keep it short; use it as a router to deeper docs.
- **Agent-local rules:** a dedicated agent-docs area, such as `docs/agents/*.md`. Use for project-specific instructions that agents should read when doing a class of task.
- **Domain vocabulary:** the repo's context map or domain glossary. Use for stable terminology and bounded contexts.
- **Architecture decisions:** an ADR-style record. Use for durable decisions, alternatives, tradeoffs, and consequences.
- **Stable runbooks/reference:** a topic doc. Use for operations, environment, deployment, data, billing, worker, API, or integration procedures.
- **Historical records:** a dated change, migration, incident, or validation record. Use for background that should not clutter current runbooks.
- **Active work:** a scratch, planning, or issue-tracking area. Use for PRDs, issue breakdowns, exploration notes, and unstable plans.

Prefer updating an existing topic doc over creating a new one unless the topic has a stable independent reader and a predictable future change that would require revisiting it.

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

Use this when replacing or heavily compressing an existing document, especially legacy design docs, runbooks, ADRs, README files, and domain context.

- Compare the old and new document by meaning, not by line count.
- Keep a retention ledger, explicit or internal: fact or constraint, current source, disposition, and reason.
- Delete a fact only when it is stale, duplicated in a better source, or safely recoverable from code, tests, schemas, design tokens, generated artifacts, or config.
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
