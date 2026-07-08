# GitHub-Native Backend

## Use When

Use this backend when GitHub issues are the authoritative workflow state.

## Source Of Truth

GitHub issues, labels, native relationships, comments, and assignees carry workflow state.

Branches, commits, pull requests, CI, and review results are implementation artifacts. They may be referenced by workflow-state receipts, but they do not carry workflow state themselves.

Do not create markdown shadow state under `.and/work` when this backend is selected.

## Capability Requirements

GitHub-native requires:

- GitHub issues as workflow state;
- labels for active stage state;
- native parent/sub-issue relationships for PRD package containment;
- native blocked-by/blocking relationships for dependency order;
- comments for receipts;
- assignees or claim comments for ownership.

If native parent/sub-issue or blocked-by/blocking relationships are unavailable, do not emulate them with markdown task lists, labels, or comments. Route to `setup-ai-native-development` to resolve GitHub capability or choose `markdown-file-based`.

## Config

```yaml
version: 1
workflow_state_backend: github-native
```

## Representation

| Workflow concept | GitHub-native representation |
| --- | --- |
| Work record | GitHub issue. |
| Delivery unit | Single issue package, or parent PRD issue plus all native sub-issues. |
| Stage state | One active queue label on the delivery unit. For PRD packages, the parent PRD carries it. |
| State Reason | Latest issue comment section headed `## State Reason`; material changes are append-only comments. |
| Package Contract | Issue body on the single issue package or parent PRD. |
| Containment relationship | GitHub parent/sub-issue relationship. |
| Dependency relationship | GitHub blocked-by/blocking relationship. |
| External blocker | State Reason for `needs-info`, or explicit package note when it blocks execution after packaging. |
| Ownership | Assignee plus claim comment, or claim comment where assignment is not appropriate. |
| Receipt | Issue comment on the delivery unit. |
| Implementation artifact | Branch, commit, PR, CI, or review link referenced by a receipt. |
| Lifecycle outcome | GitHub closed state plus closing comment or close-reason label when the repository already uses one. |

## Operations

- Locate work: query GitHub issues by active stage labels, `parent-prd`, assignee, relationship, and open or closed state.
- Read delivery unit: read the single issue, or parent PRD plus native sub-issues and dependency relationships.
- Write stage state: ensure exactly one active queue label on the delivery unit.
- Write State Reason: append a comment headed `## State Reason`.
- Publish package: update the issue body or parent PRD body with the Package Contract, create native sub-issues when needed, set relationships, and mark the delivery unit `ready-for-agent`.
- Record ownership: set assignee when appropriate and append a claim comment.
- Record receipt: append an issue comment.
- Record lifecycle outcome: close the issue with completion evidence, or use an existing close-reason label/comment convention.

## Stage State

Use the small active queue label set:

- `needs-triage`;
- `needs-info`;
- `needs-pack`;
- `ready-for-agent`.

PRD child issues do not carry active queue labels. They inherit the parent PRD delivery unit's stage state.

`parent-prd` is structural, not stage state.

Closed work uses GitHub closed state, not a `closed` label.

No other label is an AND active stage label.

## State Reason

When a delivery unit is in `needs-info`, append a comment with:

```markdown
## State Reason

State: needs-info
Cause: <missing-facts, decision-needed, access-needed, external-state, or acceptance-needed>
Owner: <reporter, maintainer, human, agent, or external-system>
Question: <one specific question, decision, permission, external event, or acceptance gate>
Resume with: <issue-triage, issue-grill, or issue-pack>
Exit criteria: <what must be true before this delivery unit can leave needs-info>
```

State Reason comments are append-only. The latest State Reason supersedes earlier State Reasons.

## Relationships

Use native GitHub relationships when available:

- parent/sub-issue for PRD containment;
- blocked-by/blocking for execution dependencies.

Do not duplicate native sub-issues with markdown task lists. Do not use blocked-by to express parent/child structure. A parent PRD is not a blocker for its children merely because it is the parent.

Cross-PRD dependencies use native blocked-by/blocking relationships between delivery units or child records, depending on the actual execution dependency. Do not create fake parent-child links to express cross-package dependency.

## Package Shapes

### Single Issue Package

The issue body contains the complete Package Contract and carries `ready-for-agent`.

### PRD Package

The parent PRD issue body contains the complete Package Contract and carries `parent-prd` plus `ready-for-agent`. Child issues are native sub-issues and do not carry `ready-for-agent`.

The parent PRD is the public delivery unit. Child issues are internal execution slices under the parent PRD claim.

## Ownership

Record ownership on the delivery unit:

- assignee when appropriate;
- claim comment;
- linked branch or draft PR as implementation artifact evidence only.

For PRD packages, the claim covers the parent PRD and all child issues.

## Receipts And Implementation Artifacts

Workflow receipts are issue comments on the delivery unit.

Branches, commits, PRs, CI, and review results may be linked from receipts. They do not replace the Package Contract, ownership, or lifecycle outcome.

## Sweep Checks

Check for:

- multiple active queue labels;
- `needs-info` without a current State Reason;
- malformed State Reason fields;
- PRD children with active queue labels;
- missing or inconsistent native parent/sub-issue relationships;
- `parent-prd` issues without native sub-issue structure when the package body claims child slices exist;
- parent PRD used as a blocker for children;
- relationship emulation through markdown task lists, labels, or comments;
- open external blockers on ready work;
- stale or partial claims;
- implementation artifacts used as ownership without assignee or claim comment;
- completed children with an open parent PRD.
