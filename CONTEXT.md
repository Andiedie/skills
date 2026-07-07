# Skills

This context describes the language for the AI-native skills package and its delivery workflow.

## Language

**Workflow state backend**:
The source of truth for AI-native delivery loop state, including package contracts, delivery-unit structure, dependencies, blockers, ownership, implementation links, and completion evidence.
_Avoid_: Issue tracker adapter, tracker fallback

**Markdown-file-based backend**:
A workflow state backend where `.and/work` is the authoritative storage for delivery-loop state, with no GitHub issue discussion or mirror surface in the first design.
_Avoid_: GitHub issue mirror, text fallback

**GitHub-native backend**:
A workflow state backend where GitHub Issues, labels, native relationships, comments, assignees, branches, and PR links are the authoritative storage for delivery-loop state.
_Avoid_: Markdown shadow state

**Backend contract**:
A shared reference that defines how workflow skills read and write delivery-loop state for a configured workflow state backend.
_Avoid_: Backend skill, per-skill backend fork

**Work record**:
A durable record of work in the AI-native delivery loop, such as a raw request, single issue package, parent PRD, or child slice.
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

**Stage state**:
The public queue state of a delivery unit, such as needs-triage, needs-info, needs-pack, or ready-for-agent.
_Avoid_: Implementation progress, child slice status

**State reason**:
The structured explanation for why a delivery unit is in its current stage state, especially why it is waiting in needs-info.
_Avoid_: Blocker block, dependency blocker

**Lifecycle outcome**:
The terminal result of a delivery unit, such as completed, rejected, duplicate, or superseded.
_Avoid_: Active queue state

**Completion evidence**:
The receipt or linked proof that explains why a delivery unit reached its lifecycle outcome, such as verification results, PR links, commits, or closing notes.
_Avoid_: Stage state

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
A stable, repo-local identifier for a markdown-file-based work record, such as `AND-0006` for a delivery unit and `AND-0006-01` for a child slice; new delivery-unit IDs are allocated by scanning `.and/work` for the highest existing ID and adding one.
_Avoid_: GitHub issue number, slug

**Containment index**:
The markdown-file-based backend's redundant parent/child index: parent work records list `children`, and child work records name `parent`; both sides must agree.
_Avoid_: Parallel source of truth

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
