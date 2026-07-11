# Markdown-File-Based Backend

## Use When

Use this backend when markdown files under `.and/work` are the authoritative workflow state.

## Source Of Truth

`.and/work` is the only workflow state source for this backend. GitHub issues are not request surfaces, mirrors, notification threads, or synchronization targets. Git branches, commits, pull requests, CI, and reviews may be referenced as implementation artifacts, but they do not carry workflow state.

During finish, terminal state prepared on a source branch is a proposal. It becomes authoritative only when the authorized target branch receives that proposal through the reviewed implementation pull request.

## Config

```yaml
version: 1
workflow_state_backend: markdown-file-based
```

Version 1 config has exactly `version` and `workflow_state_backend`. Any additional workflow backend fields are invalid for v1.

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

`package.md` is the delivery-unit record. `children/` exists only for PRD packages. `receipts/` stores append-only evidence. Setup may create `.and/work`, but should not create sample work records.

## ID Rules

Delivery-unit IDs use stable repo-local IDs:

- `AND-0006`;
- `AND-0007`.

Child slice IDs derive from the parent:

- `AND-0006-01`;
- `AND-0006-02`.

Allocate a new delivery-unit ID by scanning `.and/work/AND-*`, taking the highest numeric ID, and adding one. Confirm the target directory does not already exist before writing. If it exists, rescan and pick the next ID.

Allocate child IDs within the parent by taking the next numeric suffix. Never renumber IDs after creation. IDs are stable even when titles change.

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
  resume_with: and-clarify
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

Required delivery-unit fields:

- `id`;
- `kind`;
- `shape`;
- `stage` when lifecycle is open;
- `lifecycle`.

Delivery-unit `shape` values are:

- `raw`;
- `single`;
- `prd-package`.

Optional package frontmatter fields:

- `state_reason`;
- `external_blockers`;
- `children`.

Do not add ownership fields, implementation artifact fields, GitHub issue mirror fields, branch fields, or PR fields to package frontmatter.

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

## Relationship Representation

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

## State Reason

`state_reason` stores the latest queryable State Reason only. Each material State Reason change must also be recorded as an append-only receipt so the history is not overwritten.

If `stage` is no longer `needs-info`, remove `state_reason` from frontmatter. The history remains in receipts.

## External Blockers

External blockers apply to a delivery unit. Each current blocker requires:

- `owner`;
- `description`;
- `exit_criteria`.

Resolved external blockers should be removed from current frontmatter and preserved in receipts when materially relevant. Current frontmatter is query state, not append-only history.

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

Packed delivery units should use the Package Contract body from `and-pack`.

Do not keep long raw request history in the main Package Contract after pack. Preserve source evidence in receipts or a short source section.

## Receipts

Receipts are append-only files under `receipts/`.

Use deterministic receipt filenames:

```text
receipts/<operation>-YYYY-MM-DD.md
receipts/<operation>-YYYY-MM-DD-2.md
```

Use the stage or operation name, such as `triage`, `grill`, `pack`, `claim`, `implementation`, `review`, `verification`, `completion`, `rejection`, or `state-reason`. If the target filename exists, append `-2`, then `-3`, and so on. Do not overwrite existing receipts.

Use receipts for:

- State Reason changes;
- and-clarify decisions;
- pack publication;
- claim;
- implementation;
- review;
- verification;
- completion or rejection.

Implementation receipts may reference branches, commits, PRs, CI, and review results as implementation artifacts.

Receipt body shape is owned by the calling workflow skill.

## Ownership

Ownership is receipt-only in this backend. Record claims as append-only receipts under `receipts/`.

The current owner is derived from ownership receipts. The latest valid ownership receipt determines ownership: claim sets the owner, release clears the owner, and override replaces the owner. Do not add ownership frontmatter fields to `package.md` or child slice files.

## Implementation Artifacts

Implementation artifacts are referenced in receipts. Do not add branch, commit, PR, CI, or review fields to package or child frontmatter.

## Lifecycle Outcome

Terminal outcomes are lifecycle values, not active stage states:

- `completed`;
- `rejected`;
- `duplicate`;
- `superseded`.

Record completion evidence in a receipt.

When lifecycle is terminal, active `stage` should not be present. Child lifecycle can complete before the parent, but the parent remains open until package integration closes.

## Finish Delivery

`and-finish` first creates or resolves the GitHub pull request for the reviewed source branch and authorized target. It then prepares the terminal state on that source branch:

1. set the delivery unit's `lifecycle` to `completed` and remove its active `stage`;
2. append the `and-finish` completion receipt; and
3. commit and push only that deterministic workflow-state proposal.

Re-evaluate checks, reviews, conflicts, and mergeability on the resulting final pull-request head. Until the pull request merges, the target branch retains the open lifecycle and the source-branch proposal is non-authoritative.

Pending external checks or reviews leave the proposal in place for resume. When final validation requires a route back before merge, `and-finish` reverts only its non-authoritative completion proposal, restores open workflow state on the source branch, and pushes that withdrawal before handing work to the owning stage. Implementation commits remain intact. Removing a proposal that never reached the authoritative target does not alter append-only receipt history; a later finish attempt prepares a fresh proposal from the current reviewed head.

After merge, verify the authorized target contains both the delivered implementation and the exact completion proposal. Do not create a second post-merge completion commit or mirror lifecycle state to GitHub. A failed merge leaves the proposal resumable; a successful merge is never repeated to repair later verification or cleanup.

Source-branch and worktree cleanup begins only after target-branch completion is verified.

## End-To-End Example

This walkthrough validates the representation defined in this reference. It introduces no additional workflow or schema rules.

1. `setup-and` selects the [configuration](#config) and prepares the required [storage](#storage).
2. `and-intake` follows the [ID rules](#id-rules) and creates a raw delivery-unit record with valid [package frontmatter](#package-frontmatter).
3. `and-triage` records its result in frontmatter and [receipts](#receipts), including a [State Reason](#state-reason) or [lifecycle outcome](#lifecycle-outcome) when applicable.
4. `and-clarify` preserves confirmed decisions in receipts and updates the current State Reason until work can advance.
5. `and-pack` publishes the selected package shape and its [relationship representation](#relationship-representation).
6. `and-pick` selects a public ready delivery unit after checking its frontmatter, blockers, and receipt-derived [ownership](#ownership).
7. `and-claim` appends the ownership receipt for the complete delivery unit.
8. `and-implement` references [implementation artifacts](#implementation-artifacts) only through receipts.
9. `and-finish` follows [finish delivery](#finish-delivery) so implementation and completion become authoritative through one target-branch merge.
10. `and-sweep` applies the backend-specific [sweep checks](#sweep-checks).

## Sweep Checks

Check for:

- missing `.and/config.yml`;
- unsupported backend value;
- invalid frontmatter schema;
- open lifecycle missing `stage`;
- terminal lifecycle still carrying active `stage`;
- delivery-unit ID collisions;
- receipt filename collision pattern not followed;
- delivery-unit directory missing `receipts/`;
- child IDs that do not match their parent;
- parent `children` and child `parent` drift;
- `blocked_by` references to missing work records;
- child slices with public stage state;
- `needs-info` without `state_reason`;
- non-`needs-info` work still carrying `state_reason`;
- malformed external blockers;
- stale external blockers whose exit criteria appears satisfied;
- claimed delivery units with no claim receipt;
- ownership frontmatter fields on package or child slice files;
- implementation artifacts recorded in frontmatter instead of receipts;
- terminal lifecycle on the authoritative target without matching completion evidence;
- markdown-file-based work with GitHub issue mirror references.
