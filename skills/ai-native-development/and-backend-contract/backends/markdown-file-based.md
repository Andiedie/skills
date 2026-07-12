# Markdown-File-Based Backend

## Use When

Use this backend when markdown files under `.and/work` are the authoritative workflow state.

## Source Of Truth

`.and/work` is the only workflow state source for this backend. GitHub issues are not request surfaces, mirrors, notification threads, or synchronization targets. Linked branches, commits, pull requests, CI, reviews, and investigation assets do not carry workflow state.

During finish, terminal state prepared on a source branch is a proposal. It becomes authoritative only when the authorized target branch receives that proposal through the reviewed implementation pull request.

## Config

```yaml
version: 1
workflow_state_backend: markdown-file-based
```

Version 1 config has exactly `version` and `workflow_state_backend`. Any additional workflow backend fields are invalid for v1.

## Canonical Identities

Session-recovery identity for `and-clarify` is:

- repository identity is the real absolute path of the repository root containing `.and/config.yml`;
- work-record identity is the normalized repository-relative path to the current record, with `.` and `..` resolved and `/` as the separator.

Durable-workflow identity for `and-wayfind`, investigation publication, and map handoff survives linked worktrees and `package.md` becoming `map.md`:

- repository identity is the real absolute path obtained by resolving `git rev-parse --git-common-dir` from the repository root;
- work-record identity is the stable operation target: top-level `AND-xxxx` for map chart, investigation publication, and handoff; `AND-xxxx-Iyy` for one investigation's interview recovery.

Once a durable key appears in a receipt, retry reuses it instead of deriving another.

Canonical actor identity is `git-email:<email>`, where `<email>` is the trimmed, lowercased effective `git config user.email` for the repository. Resolve it before reading or writing investigation ownership. Changing that value selects a different workflow actor; it does not transfer an existing claim. If it is unavailable, stop before ownership mutation and report the missing Git identity.

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
    AND-0007/
      map.md
      investigations/
        AND-0007-I01/
          investigation.md
          receipts/
            claim-2026-07-08.md
            resolution-2026-07-08.md
      receipts/
        map-chart-2026-07-08.md
```

Each top-level work-record directory is one identity boundary. A delivery unit uses `package.md`; a Wayfinding map uses `map.md`. A directory never contains both as competing current records.

`package.md` is the delivery-unit record. `children/` exists only for PRD packages. `receipts/` stores append-only evidence. Setup may create `.and/work`, but should not create sample work records.

`map.md` is the Wayfinding index. `investigations/` exists only for maps, and each investigation directory contains one `investigation.md` plus its own append-only receipts. Maps never use `children/`, and packages never use `investigations/`.

## ID Rules

Top-level work-record IDs use stable repo-local IDs:

- `AND-0006`;
- `AND-0007`.

Child slice IDs derive from the parent:

- `AND-0006-01`;
- `AND-0006-02`.

Investigation IDs derive from the map and use an explicit namespace:

- `AND-0007-I01`;
- `AND-0007-I02`;
- `AND-0007-I01-N01` for an investigation sharpened while advancing `AND-0007-I01`.

Allocate a new top-level work-record ID by scanning `.and/work/AND-*`, taking the highest numeric ID, and adding one. Confirm the target directory does not already exist before writing. If it exists, rescan and pick the next ID.

Allocate child IDs within the parent by taking the next numeric suffix. Never renumber IDs after creation. IDs are stable even when titles change.

Allocate initial investigation IDs within the map by taking the next `I` numeric suffix in confirmed chart order. For a later batch, derive each ID from the source investigation ID plus its stable `N` ordinal in confirmed batch order. Independent source investigations therefore use different paths. Before writing, verify the intended path is absent or carries the same investigation key; conflicting content is drift, never an overwrite or re-key. Never reuse or renumber a closed investigation ID.

Do not use GitHub `#6` as the file-based work record ID.

## Wayfinding Frontmatter

Active map:

```yaml
---
id: AND-0007
kind: wayfinding-map
stage: needs-info
lifecycle: open
investigations:
  - AND-0007-I01
state_reason:
  cause: decision-needed
  owner: agent
  question: Clear the remaining route to the map destination.
  resume_with: and-wayfind
  exit_criteria: No open investigation or in-scope fog remains.
---
```

Clear map awaiting package publication:

```yaml
---
id: AND-0007
kind: wayfinding-map
stage: needs-pack
lifecycle: open
investigations:
  - AND-0007-I01
---
```

Investigation:

```yaml
---
id: AND-0007-I01
kind: wayfinding-investigation
parent_map: AND-0007
investigation_key: <map-chart-key>:I01
method: research
lifecycle: open
blocked_by: []
---
```

Investigation `method` is exactly one of `research`, `prototype`, `grilling`, or `task`. Investigations never carry `stage`, `state_reason`, delivery `shape`, package `children`, or ownership frontmatter.

Required map fields are `id`, `kind`, `stage` while open, `lifecycle`, and `investigations`. Required investigation fields are `id`, `kind`, `parent_map`, `investigation_key`, `method`, `lifecycle`, and `blocked_by`.

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

### Map Membership

Map frontmatter lists `investigations`. Each investigation names `parent_map`. These redundant indexes must agree and are never represented through package `children` or child-slice `parent`.

### Dependencies

Store execution dependencies only on the blocked work record:

```yaml
blocked_by:
  - AND-0006-01
```

Do not maintain a hand-written reverse `blocks` list.

Investigation `blocked_by` may reference only another investigation on the same map. A map is never a blocker merely because it is the parent.

### External Blockers

Use `external_blockers` for missing access, third-party state, manual acceptance, or other blockers outside the work record graph. Each entry requires:

- `owner`;
- `description`;
- `exit_criteria`.

External blockers are not dependency relationships.

## State Reason

`state_reason` stores the latest queryable State Reason only. Each material State Reason change must also be recorded as an append-only receipt so the history is not overwritten.

If `stage` is no longer `needs-info`, remove `state_reason` from frontmatter. The history remains in receipts.

Ordinary work records use one specific missing input. A map uses one destination-level uncertainty with `resume_with: and-wayfind`; its changing sharp questions live in investigation records rather than `state_reason`.

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

Store the map and investigation body schemas defined by [`and-wayfind`](../../and-wayfind/SKILL.md#map-and-investigation) in `map.md` and each investigation record. The detailed answer lives in one investigation resolution receipt. `Decisions so far` contains only a named relative link and one-line gist.

Do not keep long raw request history in the main Package Contract after pack. Preserve source evidence in receipts or a short source section.

## Receipts

Receipts are append-only files under `receipts/`.

Use deterministic receipt filenames:

```text
receipts/<operation>-YYYY-MM-DD.md
receipts/<operation>-YYYY-MM-DD-2.md
```

Use the stage or operation name, such as `triage`, `grill`, `pack`, `claim`, `implementation`, `review`, `verification`, `completion`, `rejection`, or `state-reason`. If the target filename exists, append `-2`, then `-3`, and so on. Do not overwrite existing receipts.

Top-level Wayfinding receipts use operations such as `wayfinding-exit`, `map-chart`, `investigation-publication`, and `map-handoff`. Investigation receipts live under that investigation's `receipts/` and use `claim`, `release`, or `resolution`.

Use receipts for:

- State Reason changes;
- and-clarify decisions;
- Wayfinding map chart, investigation claim and resolution, and map handoff;
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

Investigation ownership is derived independently from the sequenced claim and release receipts defined by `and-wayfind`. The highest valid sequence determines current ownership. A claim applies only while the investigation is open, grants no delivery ownership, and does not assign the map. The same owner may resume across invocations; an explicit release receipt clears unfinished ownership after recovery or blocker evidence is preserved. Closing a resolved investigation ends active investigation ownership without a separate release.

## Implementation Artifacts

Implementation artifacts are referenced in receipts. Do not add branch, commit, PR, CI, or review fields to package or child frontmatter.

Investigation assets are referenced only from the resolution receipt with a link and `cleanup` or `promote-to-package` disposition. They are planning evidence, not implementation artifacts or workflow state.

## Lifecycle Outcome

Terminal outcomes are lifecycle values, not active stage states:

- `completed`;
- `rejected`;
- `duplicate`;
- `superseded`.

Record completion evidence in a receipt.

When lifecycle is terminal, active `stage` should not be present. Child lifecycle can complete before the parent, but the parent remains open until package integration closes.

A resolved investigation uses `lifecycle: completed` and requires one resolution receipt. A map uses `lifecycle: completed` only after its separate replacement Package Contract is authoritative and a map-handoff receipt links that delivery-unit ID.

## Wayfinding Operations

### Chart A Map

After the opening grill proves that fog exists:

Apply the backend-neutral Chart Wayfinding Map operation with these representations:

- investigation-publication evidence is an append-only receipt under the selected top-level record, including when publication intent precedes renaming `package.md` to `map.md`;
- map promotion renames that file, replaces delivery-unit frontmatter with map frontmatter, writes the five map sections, and preserves material source evidence and the interview checkpoint in Notes and a `map-chart` receipt;
- exact-key lookup scans investigation frontmatter for `investigation_key`;
- each investigation uses its intended directory and record, map membership is the map's investigation ID list, and dependencies use `blocked_by` after all identities exist;
- completed investigation-publication evidence is appended after reciprocal membership, dependencies, State Reason, and receipts verify.

### Query The Frontier

Read the map's investigation list. Retain investigations whose lifecycle is open, whose `blocked_by` records are all completed, and whose latest valid investigation ownership receipt is absent or released. Preserve map order when selecting the first frontier investigation.

### Resolve One Investigation

Apply the backend-neutral Resolve Investigation operation and the `and-wayfind` receipt content with these representations:

- investigation ownership is derived from append-only claim and release receipts under that investigation;
- blockers are IDs in `blocked_by`;
- the Investigation Resolution receipt is append-only evidence under the investigation;
- completed investigation lifecycle is `lifecycle: completed` in frontmatter;
- the map pointer is one named relative link in `Decisions so far`, or one linked reason in `Out of scope`;
- newly sharp investigations use the Chart A Map representation above.

### Complete And Hand Off A Map

When no open investigation or in-scope fog remains, set the map stage to `needs-pack` and remove `state_reason`.

Apply the backend-neutral Hand Off Wayfinding Map operation with append-only pending and completed map-handoff receipts and exact-key lookup over the hidden `<!-- and-map-handoff:<key> -->` marker in top-level package records. A replacement `package.md` begins in `needs-pack` with the source-map link; successful Package publication moves it to `ready-for-agent`, then removes the map stage and sets map lifecycle to `completed`.

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
5. When work requires multi-session discovery, `and-wayfind` follows [Wayfinding operations](#wayfinding-operations) until the map is clear.
6. `and-pack` publishes the selected package shape and its [relationship representation](#relationship-representation), including a separate package for a clear map.
7. `and-pick` selects a public ready delivery unit after checking its frontmatter, blockers, and receipt-derived [ownership](#ownership).
8. `and-claim` appends the ownership receipt for the complete delivery unit.
9. `and-implement` references [implementation artifacts](#implementation-artifacts) only through receipts.
10. `and-finish` follows [finish delivery](#finish-delivery) so implementation and completion become authoritative through one target-branch merge.
11. `and-sweep` applies the backend-specific [sweep checks](#sweep-checks).

## Sweep Checks

Check for:

- missing `.and/config.yml`;
- unsupported backend value;
- invalid frontmatter schema;
- open top-level package or map missing `stage`;
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
- markdown-file-based work with GitHub issue mirror references;
- work-record directory containing both `package.md` and `map.md`;
- map with missing sections, invalid stage, `ready-for-agent`, stale `state_reason`, delivery ownership evidence, or inconsistent investigation index;
- investigation stored under package `children/`, using a child-slice ID, carrying stage, or naming a missing or non-map parent;
- invalid or missing investigation method, cross-map `blocked_by`, or dependency on the map parent;
- derived frontier inconsistent with lifecycle, blockers, or investigation claim receipts;
- stale investigation claim, duplicate resolution receipt, or completed investigation without a resolution;
- malformed, duplicate, or non-increasing investigation ownership sequence, release by a non-owner, or conflicting current ownership;
- pending investigation publication with a missing index or dependency write, no exact-key match, or multiple exact-key matches;
- investigation key missing or duplicated, investigation omitted from its map, or completed resolution with an incomplete map advance;
- map decision pointer that duplicates the answer, lacks a named investigation link, or points to an open investigation;
- clear map still carrying `needs-info`, in-scope fog, or an open investigation;
- completed map without one authoritative linked replacement package, distinct handoff keys, or multiple replacements for one key;
- temporary investigation asset without cleanup or Package-promotion disposition.
