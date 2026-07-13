---
name: and-intake
description: Record raw requests as clear workflow work records.
disable-model-invocation: true
---

# AND Intake

Capture one raw request, bug report, feedback item, or explicitly presented external PR as durable workflow state. Preserve the signal and its uncertainty; `and-triage` decides what should happen next.

## Backend Contract

Before writing durable state, read `.and/config.yml`, then use `and-backend-contract` and its `Write Work Record` operation for the configured representation.

If setup is missing, unsupported, or unavailable, route to `setup-and` or report the missing skill. If a configured backend is temporarily unwritable, return a ready-to-file draft and the exact access problem.

## Process

1. Resolve one work record.
   - Resolve the repository and configured backend from the explicit target, current repository, remotes, or repository instructions.
   - Update the record the user identifies by issue number, URL, work ID, or path.
   - Update an obvious exact duplicate. Create a new record for distinct work, linking related work when useful.
   - Ask only when choosing the wrong create or update target would create durable workflow-state noise.
   - When the user explicitly presents a PR, read [external-pr-signals.md](external-pr-signals.md) before resolving its work record.
   - Completion criterion: one repository, one configured backend, and exactly one create or update target are known.

2. Publish the raw signal.
   - Inspect only the evidence needed to record the signal accurately: a fitting repository template, named files or commands, errors, URLs, and obvious exact duplicates.
   - Use a fitting repository template, or a concise shape that preserves the source signal, evidence, and open questions.
   - Write a concise title that names the requested change or observed problem, and preserve material source wording, observed behavior, errors, logs, screenshots, environment details, links, and commands.
   - Keep user or author claims, Agent-confirmed facts, inferences, and unknowns distinguishable where they differ. Leave unknowns unresolved.
   - Use the user's language and repository conventions, while keeping literal identifiers verbatim.
   - Create or update through the configured backend. New work receives only the backend's raw-entry state; updates merge new durable information without changing existing workflow decisions.
   - Leave routing and scope questions in the record for `and-triage` rather than settling them during intake.
   - Completion criterion: the configured backend contains one evidence-faithful record of the raw signal, or the user has a complete ready-to-file draft and a concrete write blocker.

3. Report the result.
   - Return a short receipt with `created`, `updated`, or `draft`; the work link or ID when available; the final title; and `and-triage` as the next skill.
   - When no write occurred, include the access or target problem that prevented it. Keep the full record, evidence, and open questions in the configured backend or draft.
   - Completion criterion: the receipt truthfully distinguishes a durable create or update from an unwritten draft.
