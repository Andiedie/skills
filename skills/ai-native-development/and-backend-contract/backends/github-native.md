# GitHub-Native Backend

## Use When

Use this backend when GitHub issues are the authoritative workflow state.

## Source Of Truth

GitHub issues, labels, native relationships, comments, and assignees carry workflow state.

Branches, commits, pull requests, CI, and review results are implementation artifacts. They may be referenced by workflow-state receipts, but they do not carry workflow state themselves.

Do not create markdown shadow state under `.and/work` when this backend is selected.

## Canonical Identities

Session-recovery and durable-workflow identities are the same:

- repository identity is lowercase `<host>/<owner>/<repository>` from the issue URL;
- work-record identity is the decimal issue number with no `#` prefix.

The canonical identity of a Wayfinding source map is therefore its repository identity plus its issue number. Once a durable key appears in a receipt, retry reuses it.

## Capability Requirements

GitHub-native requires:

- GitHub issues as workflow state;
- labels for active stage state;
- native parent/sub-issue relationships for PRD package containment;
- native blocked-by/blocking relationships for dependency order;
- comments for receipts;
- assignees or claim comments for ownership.

Wayfinding additionally requires the same native parent/sub-issue and blocked-by/blocking capabilities for maps and investigations.

If native parent/sub-issue or blocked-by/blocking relationships are unavailable, do not emulate them with markdown task lists, labels, or comments. Route to `setup-and` to resolve GitHub capability or choose `markdown-file-based`.

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
| Stage state | One active queue label on the top-level work issue. For PRD packages, the parent carries it; investigations carry none. |
| State Reason | Latest issue comment section headed `## State Reason`; material changes are append-only comments. |
| Package Contract | Issue body on the single issue package or parent PRD. |
| Containment relationship | GitHub parent/sub-issue relationship. |
| Wayfinding map | Open issue carrying `wayfinder:map` and one active map stage. |
| Investigation | Sub-issue of a map carrying exactly one `wayfinder:<method>` label and no active stage label. |
| Investigation key | Hidden `<!-- and-investigation:<key> -->` marker in the investigation's initial body. |
| Map relationship | GitHub parent/sub-issue relationship whose parent is `wayfinder:map`. |
| Investigation ownership | Investigation assignee while the issue is open. |
| Investigation resolution | Comment headed `## Investigation Resolution` plus closed investigation state. |
| Investigation asset | Branch, commit, file, screenshot, or other evidence linked from the resolution comment. |
| Dependency relationship | GitHub blocked-by/blocking relationship. |
| External blocker | State Reason for `needs-info`, or explicit package note when it blocks execution after packaging. |
| Ownership | Assignee plus claim comment, or claim comment where assignment is not appropriate. |
| Receipt | Issue comment on the work record whose operation it evidences. |
| Implementation artifact | Branch, commit, PR, CI, or review link referenced by a receipt. |
| Lifecycle outcome | GitHub closed state plus closing comment or close-reason label when the repository already uses one. |

## Operations

- Locate work: query GitHub issues by active stage labels, `parent-prd`, `wayfinder:map`, method label, assignee, relationship, and open or closed state.
- Read delivery unit: read the single issue, or parent PRD plus native sub-issues and dependency relationships.
- Write stage state: ensure exactly one active queue label on the top-level work issue and none on PRD children or investigations.
- Write State Reason: append a comment headed `## State Reason`.
- Chart Wayfinding map: rewrite the selected work issue as the map, set its map labels and State Reason, create investigation issues, then add native sub-issue and dependency relationships.
- Resolve investigation: assign one frontier issue, record its resolution comment, close it, and update the map from freshly read state.
- Publish package: update the issue body or parent PRD body with the Package Contract, create native sub-issues when needed, set relationships, and mark the delivery unit `ready-for-agent`.
- Record ownership: set assignee when appropriate and append a claim comment.
- Record receipt: append an issue comment.
- Record lifecycle outcome: close the issue with completion evidence, or use an existing close-reason label/comment convention.
- Finish delivery: merge the reviewed pull request first, then record completion evidence, remove active stage state, and close the delivery-unit issue.

## Stage State

Use the small active queue label set:

- `needs-triage`;
- `needs-info`;
- `needs-pack`;
- `ready-for-agent`.

PRD child issues do not carry active queue labels. They inherit the parent PRD delivery unit's stage state.

Wayfinding investigations do not carry active queue labels. An active map uses `needs-info`; a clear map awaiting package publication uses `needs-pack`. A map never carries `ready-for-agent`.

`parent-prd` is structural, not stage state.

Closed work uses GitHub closed state, not a `closed` label.

No other label is an AND active stage label.

## State Reason

When an open top-level work issue is in `needs-info`, append a comment with:

```markdown
## State Reason

State: needs-info
Cause: <missing-facts, decision-needed, access-needed, external-state, or acceptance-needed>
Owner: <reporter, maintainer, human, agent, or external-system>
Question: <one specific question, decision, permission, external event, or acceptance gate>
Resume with: <and-triage, and-clarify, and-wayfind, or and-pack>
Exit criteria: <what must be true before this work issue can leave needs-info>
```

State Reason comments are append-only. The latest State Reason supersedes earlier State Reasons.

## Relationships

Use native GitHub relationships when available:

- parent/sub-issue for PRD containment;
- parent/sub-issue for map/investigation membership when the parent carries `wayfinder:map`;
- blocked-by/blocking for execution dependencies.

Do not duplicate native sub-issues with markdown task lists. The parent kind determines whether the relationship is PRD containment or map membership; never reinterpret one as the other. Do not use blocked-by to express either parent/child structure. A parent is not a blocker for its children merely because it is the parent.

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

Investigation ownership is separate: assign only the open frontier investigation immediately before work. Do not assign the map as a claim, write a delivery Claim receipt, or treat investigation assignment as package ownership. Closing the investigation ends its active ownership.

## Receipts And Implementation Artifacts

Workflow receipts are comments on the record whose operation they evidence:

- State Reason, intake, triage, Wayfinding-exit, pack, claim, implementation, review, verification, and completion receipts live on the original top-level work issue or delivery unit;
- map-chart, investigation-publication, and map-handoff receipts live on the map;
- investigation resolution receipts live on the investigation; current ownership uses the assignee rules above.

Branches, commits, PRs, CI, and review results linked from delivery receipts are implementation artifacts. Evidence linked from an investigation resolution is an investigation asset. Neither replaces workflow state, ownership, or lifecycle outcome.

## Wayfinding

### Labels

Use exactly these structural and method labels:

- `wayfinder:map`;
- `wayfinder:research`;
- `wayfinder:prototype`;
- `wayfinder:grilling`;
- `wayfinder:task`.

The map also carries `needs-info` or `needs-pack`. Each investigation carries exactly one method label and no active stage label.

### Chart A Map

1. Re-read the selected work issue and verify it has no existing map, package, ownership, or implementation conflict. If it is already a map whose initial investigation keys lack completed publication evidence, resume that publication instead of starting a new chart.
2. Reuse the recorded map chart key, or derive it from durable-workflow identity when none exists, then append the pending investigation-publication receipt before structural mutation.
3. Preserve material source evidence in the map Notes, a receipt comment, or GitHub history; update the existing issue rather than creating a second map.
4. Replace the body with `Destination`, `Notes`, `Decisions so far`, `Not yet specified`, and `Out of scope`; set `wayfinder:map` plus `needs-info` and append a State Reason with `Resume with: and-wayfind`.
5. Append a map-chart receipt with the interview checkpoint.
6. For each planned investigation, search issue bodies for its exact `<!-- and-investigation:<key> -->` marker. Reuse a sole match or create one issue whose initial body carries the marker and `## Question`, with exactly one method label.
7. Add every investigation as a native sub-issue of the map. Add native blocked-by edges only after all required issue IDs exist.
8. Re-read key matches, map membership, labels, and dependencies. Append completed investigation-publication evidence only when each key has one match and every relationship is present; then stop without resolving an investigation.

If publication fails, retry against the same map and pending receipt. Reuse exact-key matches and finish missing relationships before creating missing investigations. Multiple matches for one key keep the map non-executable and route to `and-sweep`.

Use the sub-issues and issue-dependencies REST endpoints defined by GitHub. Payload relationship IDs are numeric database IDs, not issue numbers or GraphQL node IDs. If either native capability is unavailable, route to `setup-and`; do not write a fallback convention.

### Query The Frontier

List the map's open native sub-issues, retain those with one method label, and drop any issue with an open blocker or assignee. Preserve the backend's child order when choosing the first frontier investigation.

For resume, first select an open, unblocked investigation assigned to the current actor. Assignment to another actor remains unavailable. A closed investigation with one resolution but a missing map pointer or map advance is pending recovery, not frontier work.

### Resolve One Investigation

1. Re-read the map, chosen investigation, assignee, open blockers, resolution comments, and map pointer.
2. Reuse ownership when the current actor is already assigned; otherwise assign an unclaimed investigation before work and re-read authoritative state. Never continue under another actor's assignment.
3. If one durable resolution already exists, do not rerun the method or append another. Otherwise run the investigation method and append one comment:

```markdown
## Investigation Resolution

Checkpoint: <interview checkpoint when HITL; omit for AFK>

Answer:
<durable answer>

Assets:
- <link and cleanup or Package-promotion disposition, or none>
```

4. Close an open investigation after its durable resolution exists, then re-read the map and append one linked, named gist to `Decisions so far`, or one linked reason to `Out of scope` when the investigation sits beyond the Destination. If it was already closed, resume only the missing map mutation.
5. Create and wire newly sharp investigations, remove graduated fog, and update out-of-scope evidence when required.

The detailed answer lives only in the resolution comment. A map pointer names and links the investigation without restating it; an out-of-scope investigation never also appears in `Decisions so far`.

When the current owner explicitly abandons an unresolved investigation, preserve its blocker or recovery evidence, then unassign that actor. Do not unassign another actor.

### Complete And Hand Off A Map

When no open investigations or in-scope fog remain, replace `needs-info` with `needs-pack` and remove the current State Reason by superseding it with the map's clear state.

Before issue creation, `and-pack` re-reads the map and searches issue bodies for the exact handoff marker, appends a pending map-handoff intent containing the deterministic key, then searches again. It resumes the sole match or creates a replacement issue in `needs-pack` only when no match exists. The replacement's initial body contains the source-map link and `<!-- and-map-handoff:<key> -->`.

Immediately after creation, search again. Continue Package publication only when exactly one issue carries the marker. Multiple matches remain in `needs-pack`, the map remains open, and `and-pack` routes the competing handoff to `and-sweep`. For one match, append its identity to later handoff evidence, publish the Package Contract, complete asset disposition, replace `needs-pack` with `ready-for-agent`, then remove the map's active stage and close the map.

On retry, read handoff receipts and search issue bodies for the exact handoff marker before creating anything. A sole matching replacement resumes in place whether or not its issue number was written back to the map before interruption.

Resolved investigation issues remain closed planning evidence. A failed handoff leaves the map open and resumable.

## Finish Delivery

The delivery-unit issue remains open with its active stage until the reviewed pull request reaches the authorized target.

After GitHub records the pull request as merged and the target contains the merge result:

1. append the `and-finish` completion receipt;
2. remove the active queue label; and
3. close exactly the completed delivery-unit issue.

Complete a parent PRD only after every child requirement covered by its claim is integrated. Leave merely related work unchanged.

If merge succeeds but receipt or lifecycle mutation fails, resume from the missing backend operation without repeating merge. Source-branch and worktree cleanup begins only after the issue's completion evidence, label removal, and closed state are verified.

## End-To-End Example

This walkthrough validates the representation defined in this reference. It introduces no additional workflow or schema rules.

1. `setup-and` selects the [configuration](#config) and verifies its [capability requirements](#capability-requirements).
2. `and-intake` creates the issue and applies its initial [stage state](#stage-state).
3. `and-triage` changes stage or records the current [State Reason](#state-reason), and may produce the terminal outcome defined by the [representation](#representation).
4. `and-clarify` records confirmed decisions as [receipts](#receipts-and-implementation-artifacts) and advances resolved work.
5. When work requires multi-session discovery, `and-wayfind` follows [Wayfinding](#wayfinding) until the map is clear.
6. `and-pack` publishes one of the supported [package shapes](#package-shapes) with the required native [relationships](#relationships), including a separate package for a clear map.
7. `and-pick` selects a public ready delivery unit after checking its stage, relationships, and [ownership](#ownership).
8. `and-claim` records ownership for the complete delivery unit.
9. `and-implement` references implementation artifacts through the delivery unit's [receipts](#receipts-and-implementation-artifacts).
10. `and-finish` follows [finish delivery](#finish-delivery) to merge, record completion, close the delivery unit, and clean proven-safe artifacts.
11. `and-sweep` applies the backend-specific [sweep checks](#sweep-checks).

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
- merged delivery with missing completion evidence, an active stage label, or an open delivery-unit issue;
- completed children with an open parent PRD;
- map missing `wayfinder:map`, carrying `ready-for-agent`, or carrying neither `needs-info` nor `needs-pack` while open;
- investigation with an active stage, missing or multiple method labels, missing map parent, or a parent that is not a map;
- map sub-issue used as a PRD child or investigation reused as an implementation slice;
- open investigation whose blockers are closed and assignee is absent but which is omitted from the derived frontier;
- stale investigation assignee, conflicting resolution comments, or closed investigation without a resolution;
- pending investigation publication with a missing relationship, no exact-key match, or multiple exact-key matches;
- investigation carrying an `and-investigation` marker but missing from its map, or a closed resolved investigation whose map advance is incomplete;
- map decision pointer that duplicates an answer, lacks a named investigation link, or points to an open investigation;
- clear map still carrying `needs-info`, unresolved fog, or an open investigation;
- handoff that closed the map before the replacement Package Contract became authoritative, or has multiple replacements with the same handoff key;
- linked temporary investigation asset without cleanup or Package-promotion disposition.
