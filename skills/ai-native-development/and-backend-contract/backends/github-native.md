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

Canonical actor identity is the authenticated GitHub login, lowercased and without an `@` prefix. Resolve it from GitHub's authenticated-user endpoint. An open investigation is unclaimed with no assignee and has one owner with exactly one assignee; multiple assignees are ownership drift. Ownership belongs to the actor only when that sole assignee login matches it case-insensitively.

## Capability Requirements

GitHub-native requires:

- GitHub issues as workflow state;
- labels for active stage state;
- native parent/sub-issue relationships for PRD package containment;
- native blocked-by/blocking relationships for dependency order;
- comments for receipts;
- assignees or claim comments for delivery ownership;
- assignees for investigation ownership, including permission to assign the authenticated actor.

Wayfinding additionally requires the same native parent/sub-issue and blocked-by/blocking capabilities for maps and investigations, plus exactly-one-assignee investigation ownership.

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
| Investigation ownership | Exactly one investigation assignee while the issue is open; none means unclaimed, and more than one is drift. |
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

State Reason comments are append-only. The latest State Reason supersedes earlier State Reasons. When a record leaves `needs-info`, append this tombstone so earlier reasons are no longer current:

```markdown
## State Reason

State: cleared
```

A latest `State: cleared` comment means the record has no current State Reason.

## Relationships

Use native GitHub relationships when available:

- parent/sub-issue for PRD containment;
- parent/sub-issue for map/investigation membership when the parent carries `wayfinder:map`;
- blocked-by/blocking for execution dependencies.

Do not duplicate native sub-issues with markdown task lists. The parent kind determines whether the relationship is PRD containment or map membership; never reinterpret one as the other. Do not use blocked-by to express either parent/child structure. A parent is not a blocker for its children merely because it is the parent.

Cross-PRD dependencies use native blocked-by/blocking relationships between delivery units or child records, depending on the actual execution dependency. Do not create fake parent-child links to express cross-package dependency.

## Relationship API Recipes

Use these recipes from a checkout whose GitHub remote identifies `{owner}` and `{repo}`. GitHub CLI expands those two placeholders. Replace the example issue numbers and numeric database IDs before running a command. The recipes pin the current REST API version documented below.

First distinguish the repo-local issue `number` used in URL paths from the REST issue object's numeric database `id` used in relationship payloads and dependency-removal paths:

```sh
gh api --method GET \
  -H 'Accept: application/vnd.github+json' \
  -H 'X-GitHub-Api-Version: 2026-03-10' \
  'repos/{owner}/{repo}/issues/42' \
  --jq '{number, id, node_id}'
```

`id` is not the issue number and is not the GraphQL `node_id`.

### Read Relationships And Capability

Read a child's parent:

```sh
gh api --method GET \
  -H 'Accept: application/vnd.github+json' \
  -H 'X-GitHub-Api-Version: 2026-03-10' \
  'repos/{owner}/{repo}/issues/42/parent'
```

Read all sub-issues of a parent and both dependency directions. `--slurp` returns an array of page arrays; pipe to `jq 'add'` when one merged array is useful. Do not combine `gh api --slurp` with its built-in `--jq` or `--template` options.

```sh
gh api --method GET --paginate --slurp \
  -H 'Accept: application/vnd.github+json' \
  -H 'X-GitHub-Api-Version: 2026-03-10' \
  'repos/{owner}/{repo}/issues/42/sub_issues?per_page=100'

gh api --method GET --paginate --slurp \
  -H 'Accept: application/vnd.github+json' \
  -H 'X-GitHub-Api-Version: 2026-03-10' \
  'repos/{owner}/{repo}/issues/42/dependencies/blocked_by?per_page=100'

gh api --method GET --paginate --slurp \
  -H 'Accept: application/vnd.github+json' \
  -H 'X-GitHub-Api-Version: 2026-03-10' \
  'repos/{owner}/{repo}/issues/42/dependencies/blocking?per_page=100'
```

### Mutate Relationships

The following commands change issue relationships. Run them only after approval with the intended issue numbers and numeric database IDs. Use `-F`, not `-f`, so GitHub CLI sends the IDs as JSON numbers.

Add and remove a sub-issue. Removal uses singular `sub_issue`. Do not send `replace_parent` unless moving a child from its current parent was separately intended and approved.

```sh
gh api --method POST \
  -H 'Accept: application/vnd.github+json' \
  -H 'X-GitHub-Api-Version: 2026-03-10' \
  'repos/{owner}/{repo}/issues/42/sub_issues' \
  -F 'sub_issue_id=123456789'

gh api --method DELETE \
  -H 'Accept: application/vnd.github+json' \
  -H 'X-GitHub-Api-Version: 2026-03-10' \
  'repos/{owner}/{repo}/issues/42/sub_issue' \
  -F 'sub_issue_id=123456789'
```

To make issue 84 block issue 42, call the blocked issue's `blocked_by` endpoint with issue 84's numeric database `id`. Dependency writes have no symmetric `/blocking` mutation endpoint.

```sh
gh api --method POST \
  -H 'Accept: application/vnd.github+json' \
  -H 'X-GitHub-Api-Version: 2026-03-10' \
  'repos/{owner}/{repo}/issues/42/dependencies/blocked_by' \
  -F 'issue_id=987654321'

gh api --method DELETE \
  -H 'Accept: application/vnd.github+json' \
  -H 'X-GitHub-Api-Version: 2026-03-10' \
  'repos/{owner}/{repo}/issues/42/dependencies/blocked_by/987654321'
```

Successful add operations return `201`; successful removals return `200`. For a reversible capability check, use disposable issues, record their original relationships, add one relationship, verify it through the read endpoint, remove it, and verify cleanup. If cleanup fails, report the residual relationship and do not declare the check successful.

### Interpret Capability Results

- Relationship reads require fine-grained `Issues: read`; mutations require `Issues: write`, and the actor also needs at least the repository triage role. Public read access does not imply anonymous write access.
- A fully paginated `200` response containing no items means that direction currently has no relationship; it does not mean the endpoint is unavailable.
- `GET .../parent` returns `404` when the readable child has no parent. First prove the base issue is readable and check for the endpoint-specific `No parent issue found` message. Other `404` responses can mean a wrong identifier, private or hidden resource, or insufficient authentication.
- `403` can mean insufficient permission or a primary or secondary rate limit. Inspect the response body and available `x-ratelimit-*`, `retry-after`, and `X-Accepted-GitHub-Permissions` headers before deciding what failed.
- Successful reads do not prove write capability. Treat write capability as verified only when authoritative token and repository-role evidence establishes it or an approved disposable add/read/remove/read check succeeds. Otherwise mark it unverified and do not declare the GitHub-native backend ready.
Official references: [REST sub-issues](https://docs.github.com/en/rest/issues/sub-issues?apiVersion=2026-03-10), [REST issue dependencies](https://docs.github.com/en/rest/issues/issue-dependencies?apiVersion=2026-03-10), [`gh api`](https://cli.github.com/manual/gh_api), and [REST troubleshooting](https://docs.github.com/en/rest/using-the-rest-api/troubleshooting-the-rest-api).

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
- investigation-publication and map-handoff receipts live on the map;
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

Apply the backend-neutral Chart Wayfinding Map operation with these representations:

- investigation-publication evidence is an issue comment on the selected source issue, including when publication intent precedes map promotion;
- map promotion updates that same issue body to the five map sections, preserves material source evidence in Notes, a receipt, or GitHub history, and applies `wayfinder:map`, `needs-info`, and the `and-wayfind` State Reason;
- exact-key lookup searches issue bodies for `<!-- and-investigation:<key> -->`;
- each investigation is an issue whose initial body carries that marker and `## Question`, with exactly one method label;
- map membership uses native sub-issues, and investigation dependencies use native blocked-by relationships after the required issue IDs exist;
- completed publication evidence is an issue comment on the map after the configured relationships verify.

Use the sub-issues and issue-dependencies REST endpoints defined by GitHub. Payload relationship IDs are numeric database IDs, not issue numbers or GraphQL node IDs. If either native capability is unavailable, route to `setup-and`; do not write a fallback convention.

### Query The Frontier

List the map's open native sub-issues, retain those with one method label, and drop any issue with an open blocker or assignee. Preserve the backend's child order when choosing the first frontier investigation.

### Resolve One Investigation

Apply the backend-neutral Resolve Investigation operation and the `and-wayfind` receipt content with these representations:

- current ownership is the sole investigation assignee, and release removes only that assignee;
- blockers are native blocked-by relationships;
- the Investigation Resolution receipt is an issue comment on the investigation;
- completed investigation lifecycle is the GitHub closed state;
- the map pointer is one linked, named gist in `Decisions so far`, or one linked reason in `Out of scope`;
- newly sharp investigations use the Chart A Map representation above.

### Complete And Hand Off A Map

When no open investigations or in-scope fog remain, replace `needs-info` with `needs-pack` and clear the current State Reason with the append-only tombstone above.

Apply the backend-neutral Hand Off Wayfinding Map operation with pending and completed map-handoff receipts as map comments and exact-key lookup over the hidden `<!-- and-map-handoff:<key> -->` marker in replacement issue bodies. The replacement body also links the source map. A replacement begins as a top-level issue in `needs-pack`; successful Package publication moves it to `ready-for-agent`, then removes the map's active stage and closes the map.

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
- malformed non-clearing State Reason fields;
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
- map missing `wayfinder:map`, carrying `ready-for-agent`, carrying delivery ownership evidence, or carrying neither `needs-info` nor `needs-pack` while open;
- investigation with an active stage, missing or multiple method labels, missing map parent, or a parent that is not a map;
- map sub-issue used as a PRD child or investigation reused as an implementation slice;
- open investigation whose blockers are closed and assignee is absent but which is omitted from the derived frontier;
- stale or multiple investigation assignees, conflicting resolution comments, or closed investigation without a resolution;
- pending investigation publication with a missing relationship, no exact-key match, or multiple exact-key matches;
- investigation carrying an `and-investigation` marker but missing from its map, or a closed resolved investigation whose map advance is incomplete;
- map decision pointer that duplicates an answer, lacks a named investigation link, or points to an open investigation;
- clear map still carrying `needs-info`, unresolved fog, or an open investigation;
- handoff that closed the map before the replacement Package Contract became authoritative, or has multiple replacements with the same handoff key;
- linked temporary investigation asset without cleanup or Package-promotion disposition.
