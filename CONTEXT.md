# Skills

This context describes the language for the AI-native skills package and its delivery workflow.

## Language

**Workflow state backend**:
The source of truth for AI-native delivery loop state, including Wayfinding maps, package contracts, relationships, blockers, ownership, artifact references, and completion evidence.
_Avoid_: Issue tracker adapter, tracker fallback

**Markdown-file-based backend**:
A workflow state backend where `.and/work` is the authoritative storage for delivery-loop state, with no GitHub issue discussion or mirror surface in the first design.
_Avoid_: GitHub issue mirror, text fallback

**GitHub-native backend**:
A workflow state backend where GitHub Issues, labels, native relationships, comments, and assignees are the authoritative storage for delivery-loop state.
_Avoid_: Markdown shadow state

**Backend contract**:
A shared reference that defines how workflow skills read and write delivery-loop state for a configured workflow state backend.
_Avoid_: Backend skill, per-skill backend fork

**Work record**:
A durable record in the AI-native delivery loop, such as a raw request, Wayfinding map, investigation, single issue package, parent PRD, or child slice.
_Avoid_: Task, ticket

**Delivery unit**:
The unit of work that can be publicly picked, claimed, implemented, and completed; either a single issue package or a parent PRD package with its children.
_Avoid_: Child issue, subtask

**Containment relationship**:
A relationship that expresses PRD package structure: a parent PRD contains child slices, and a child slice is part of one parent PRD.
_Avoid_: Dependency, blocker

**Dependency relationship**:
A relationship that expresses execution order: one work record blocks another, and the blocked work must wait for the blocker.
_Avoid_: Parent-child relationship

**Wayfinding map**:
A shared planning index that holds a destination, decision pointers, fog, and scope until work can be packaged; it is not a delivery unit or claim unit.
_Avoid_: Parent PRD, delivery package

**Investigation**:
One sharp question under a Wayfinding map, sized for one Agent session and carrying no public stage state.
_Avoid_: Task, ticket, child slice

**Map relationship**:
The relationship between a Wayfinding map and its investigations; it remains distinct from PRD containment even when a backend uses the same parent/sub-issue primitive.
_Avoid_: Containment relationship, dependency relationship

**Fog**:
In-scope uncertainty that cannot yet be phrased as a sharp investigation question.
_Avoid_: Open investigation, out-of-scope work

**Frontier**:
The open, unblocked, unclaimed investigations currently available on a Wayfinding map.
_Avoid_: Stored queue, implementation backlog

**Investigation ownership**:
Responsibility for one investigation while it is open; it grants no ownership of the map or later delivery unit.
_Avoid_: Delivery claim, map claim

**Investigation asset**:
Linked evidence produced to answer an investigation, such as a research note or throwaway prototype; it is not workflow state or repository truth unless a Package Contract promotes it.
_Avoid_: Implementation artifact, package requirement

**Investigation method**:
The way an investigation is resolved: `research`, `prototype`, `grilling`, or `task`. Here `task` is a fixed method name, not a generic name for a work record.
_Avoid_: Stage state, work-record kind

**Stage state**:
The public queue state of an open top-level work record, such as needs-triage, needs-info, needs-pack, or ready-for-agent. Investigations and PRD child slices carry none; maps never become ready-for-agent.
_Avoid_: Implementation progress, child slice status

**State reason**:
The structured explanation for why a top-level work record is waiting in needs-info. Ordinary work names one missing input; a Wayfinding map names destination-level uncertainty and delegates sharp questions to its frontier.
_Avoid_: Dependency relationship, external blocker

**Lifecycle outcome**:
The terminal result of a work record, such as completed, rejected, duplicate, or superseded.
_Avoid_: Active queue state

**Completion evidence**:
The receipt or linked proof that explains why a delivery unit reached its lifecycle outcome, such as verification results, PR links, commits, or closing notes.
_Avoid_: Stage state

**Receipt**:
Append-only evidence written by a workflow stage, such as interview decisions, Wayfinding progress, pack publication, claim, implementation, review, verification, completion, rejection, or follow-up.
_Avoid_: Package contract, mutable status field

**Implementation artifact**:
A Git branch, commit, pull request, test result, or review result produced while implementing a delivery unit; it can be referenced as evidence but does not carry workflow state.
_Avoid_: Workflow state backend, package contract

**And config**:
The minimal machine-readable workflow configuration at `.and/config.yml`, containing only the config version and the selected workflow state backend in the first schema version.
_Avoid_: General settings file, project documentation

**And work root**:
The markdown-file-based backend's authoritative work storage directory at `.and/work`.
_Avoid_: GitHub issue mirror, scratch directory

**Work record ID**:
A stable, repo-local identifier for a markdown-file-based work record, such as `AND-0006` for a top-level record, `AND-0006-01` for a child slice, and `AND-0006-I01` for an investigation; new top-level IDs are allocated by scanning `.and/work` for the highest existing ID and adding one.
_Avoid_: GitHub issue number, slug

**Containment index**:
The markdown-file-based backend's redundant parent/child index: parent work records list `children`, and child work records name `parent`; both sides must agree.
_Avoid_: Parallel source of truth

**Map membership index**:
The markdown-file-based backend's redundant map/investigation index: maps list `investigations`, and investigation records name `parent_map`; both sides must agree.
_Avoid_: Containment index, parallel source of truth

**Blocked-by index**:
The markdown-file-based backend's dependency index, stored only on the blocked work record as `blocked_by` work record IDs.
_Avoid_: Hand-written blocks list

**External blocker**:
A blocker outside the work record graph, such as missing access, third-party state, or human acceptance, recorded separately from `blocked_by`.
_Avoid_: Dependency relationship

**Package frontmatter**:
The machine-readable metadata at the top of a markdown-file-based package file, used for routing, indexing, state, lifecycle, and relationships.
_Avoid_: Package contract

**Child slice frontmatter**:
The machine-readable metadata at the top of a markdown-file-based child slice file, used for identity, parent containment, lifecycle, and internal dependencies.
_Avoid_: Public queue state
