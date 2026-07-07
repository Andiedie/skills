# Markdown-File-Based Backend

Use this backend when markdown files under `.and/work` are the authoritative workflow state.

GitHub issues are not used as discussion, notification, mirror, or synchronization surfaces in this backend. Git branches, commits, pull requests, CI, and reviews may be referenced as implementation artifacts, but they do not carry workflow state.

## Config

```yaml
version: 1
workflow_state_backend: markdown-file-based
```

The first config schema has no other fields.

## Storage

```text
.and/
  config.yml
  work/
    AND-0006/
      package.md
      children/
        AND-0006-01.md
        AND-0006-02.md
      receipts/
        grill-2026-07-07.md
        claim-2026-07-07.md
        implementation-2026-07-07.md
```

The delivery-unit directory is the boundary for a delivery unit. A single package can still use a directory so receipts and future evidence have a stable home.

## ID Rules

Delivery-unit IDs use stable repo-local IDs:

- `AND-0006`;
- `AND-0007`.

Child slice IDs derive from the parent:

- `AND-0006-01`;
- `AND-0006-02`.

Allocate a new delivery-unit ID by scanning `.and/work/AND-*`, taking the highest numeric ID, and adding one. Confirm the target directory does not already exist before writing. If it exists, rescan and pick the next ID.

Do not use GitHub `#6` as the file-based work record ID.

## Package Frontmatter

Raw request:

```yaml
---
id: AND-0006
kind: delivery-unit
shape: raw
stage: needs-triage
lifecycle: open
---
```

Single package:

```yaml
---
id: AND-0006
kind: delivery-unit
shape: single
stage: ready-for-agent
lifecycle: open
---
```

PRD package:

```yaml
---
id: AND-0006
kind: delivery-unit
shape: prd-package
stage: ready-for-agent
lifecycle: open
children:
  - AND-0006-01
  - AND-0006-02
---
```

Needs-info State Reason:

```yaml
---
id: AND-0006
kind: delivery-unit
shape: raw
stage: needs-info
lifecycle: open
state_reason:
  cause: decision-needed
  owner: human
  question: Decide whether markdown files should use one file or a delivery-unit directory.
  resume_with: issue-grill
  exit_criteria: Delivery-unit storage shape is decided.
---
```

External blockers:

```yaml
external_blockers:
  - owner: human
    description: Production API token is unavailable.
    exit_criteria: Token is available in the agreed secret store.
```

Package frontmatter stores routing, lifecycle, and relationship metadata. The Package Contract belongs in the markdown body.

`state_reason` stores the latest queryable State Reason only. Each material State Reason change must also be recorded as an append-only receipt so the history is not overwritten.

## Child Slice Frontmatter

```yaml
---
id: AND-0006-01
kind: child-slice
parent: AND-0006
lifecycle: open
blocked_by: []
---
```

Child slices do not carry public queue stage state. They can carry lifecycle and dependency metadata.

## Relationships

### Containment

Parent package frontmatter lists `children`. Child slice frontmatter names `parent`. These are redundant indexes and must agree.

### Dependencies

Store execution dependencies only on the blocked work record:

```yaml
blocked_by:
  - AND-0006-01
```

Do not maintain a hand-written reverse `blocks` list.

### External Blockers

Use `external_blockers` for missing access, third-party state, manual acceptance, or other blockers outside the work record graph. Each entry requires:

- `owner`;
- `description`;
- `exit_criteria`.

External blockers are not dependency relationships.

## Body Sections

Raw request records should use concise source sections:

```markdown
# <title>

## Request

<raw request summary>

## Evidence

- <links, logs, screenshots, or none>

## Open Questions

- <question, or none>
```

Packed delivery units should use the Package Contract body from `issue-pack`.

Do not keep long raw request history in the main Package Contract after pack. Preserve source evidence in receipts or a short source section.

## Receipts

Receipts are append-only files under `receipts/`.

Use receipts for:

- State Reason changes;
- issue-grill decisions;
- pack publication;
- claim;
- implementation;
- review;
- verification;
- completion or rejection.

Implementation receipts may reference branches, commits, PRs, CI, and review results as implementation artifacts.

## Ownership

Ownership is receipt-only in this backend. Record claims as append-only receipts under `receipts/`.

The current owner is derived from the latest valid claim receipt. Release and override receipt schemas are out of scope for the first stage. Do not add ownership frontmatter fields to `package.md` or child slice files.

## Lifecycle Outcome

Terminal outcomes are lifecycle values, not active stage states:

- `completed`;
- `rejected`;
- `duplicate`;
- `superseded`.

Record completion evidence in a receipt.

## Sweep Checks

Check for:

- missing `.and/config.yml`;
- unsupported backend value;
- invalid frontmatter schema;
- delivery-unit ID collisions;
- child IDs that do not match their parent;
- parent `children` and child `parent` drift;
- `blocked_by` references to missing work records;
- child slices with public stage state;
- `needs-info` without `state_reason`;
- malformed external blockers;
- stale external blockers whose exit criteria appears satisfied;
- claimed delivery units with no claim receipt;
- ownership frontmatter fields on package or child slice files;
- implementation artifacts recorded in frontmatter instead of receipts;
- markdown-file-based work with GitHub issue mirror references.
