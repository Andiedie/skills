# Wayfinding Workflow State

Read this reference when an operation charts, reads, advances, or hands off a Wayfinding map.

## Representation

A map is an open issue carrying `wayfinder:map` and `needs-info` or `needs-pack`. An investigation is its native sub-issue, carries exactly one method label, has no active queue label, and uses native blocked-by edges for investigation dependencies.

The map is a shared index rather than a store or claim unit. Open investigations come from native relationships instead of a second body list. Its body is:

```markdown
## Destination

<what must be clear before packaging can begin>

## Notes

<domain sources, standing constraints, and skills relevant to every session>

## Decisions so far

<!-- one named, linked gist per resolved investigation -->

## Not yet specified

<in-scope fog that cannot yet be phrased as a sharp question>

## Out of scope

<work beyond this destination>
```

Method labels are:

- `wayfinder:research`;
- `wayfinder:prototype`;
- `wayfinder:grilling`;
- `wayfinder:task`.

An investigation's initial body carries `<!-- and-investigation:<key> -->` and `## Question`. Publication and handoff receipts live on the map; resolution receipts live on the investigation.

```markdown
## Question

<the decision or investigation this record resolves>
```

The detailed answer lives only in the investigation resolution. The map and human-facing narration use a linked title and one-line gist. Create an investigation when its question can be stated precisely now, even if it is blocked or unanswered; keep it as fog when the question itself cannot yet be phrased precisely.

## Read A Map

Read the map destination, Notes, decision pointers, fog, out-of-scope boundary, current stage and State Reason, native sub-issues, dependencies, owners, resolutions, and linked assets. Derive the frontier from current investigation state rather than storing a second list.

The frontier is the map's open investigations with exactly one method label, no open blocker, and no assignee. Preserve native child order when choosing the first item.

## Deterministic Publication

The chart key identifies exactly one initial outcome: a no-map Wayfinding Exit or an initial investigation publication whose key equals the chart key. Before recording or applying either outcome, query both receipt types by that key.

A valid pending and completed publication pair belongs to one history and is resumable. Duplicate Exit receipts, competing initial intents, mismatched content, or both initial outcome types are drift; route them to `and-sweep` rather than choosing a winner.

Each later investigation batch uses a separate publication key derived from its source investigation key. Its pending and completed receipts form one resumable history independent of the initial chart and other batches.

Before structural mutation, inspect exact-key publication evidence. Resume a pending intent without replaying the interview or deriving a new key. Otherwise append the deterministic publication intent to the source map first.

Every investigation carries its key in its initial body. Create all missing issues before membership and dependency edges. On retry, reuse one exact-key match only when it has no parent or already belongs to the target map and its method, title, and question match the recorded intent. A different parent, content mismatch, or multiple matches is drift.

## Chart A Map

Promote the selected top-level issue in place:

- preserve material source evidence in Notes, a receipt, or GitHub history;
- write the map's five sections;
- apply `wayfinder:map`, `needs-info`, and an `and-wayfind` State Reason;
- append investigation-publication intent before creating issues;
- create each keyed investigation issue;
- add native map membership and dependency edges after numeric issue IDs exist;
- append completed publication evidence only after every issue and relationship verifies.

Map creation is authoritative only when the map, every planned investigation, and every edge can be recovered from GitHub. Native relationship capability is a setup prerequisite.

## Investigation Ownership

Immediately before work, assign one frontier investigation to the authenticated actor. An open investigation has no owner with no assignee and one owner with exactly one assignee; multiple assignees are drift. The owner may resume it across invocations or explicitly release unfinished ownership after preserving recovery or blocker evidence.

The map remains shared and unclaimed. Investigation ownership ends with that investigation and never authorizes delivery pick, claim, implementation, or closure.

## Resolve An Investigation

Run the method only when no durable resolution exists. Then:

1. append one `## Investigation Resolution` comment with the durable answer and evidence;
2. close the investigation;
3. append one linked, named gist to the map's `Decisions so far`, or one linked reason to `Out of scope`;
4. update newly visible investigations, dependencies, fog, and scope through deterministic publication.

Write the durable resolution before projecting it onto the map. A closed resolved investigation with incomplete projection resumes the missing map mutation instead of rerunning the method. A current owner may resume an open, unblocked investigation.

## Hand Off A Clear Map

On entry, resolve the source map from either the map itself or a replacement's handoff key and source-map link. This recovery path applies even when replacement creation succeeded before its identity was recorded on the map.

A map is clear only when no open investigation or in-scope fog remains. Replace `needs-info` with `needs-pack` and append the State Reason tombstone.

Derive one deterministic handoff key and append pending handoff evidence before creating a separate delivery unit. Create the replacement as an open top-level issue in `needs-pack`; its initial body carries `<!-- and-map-handoff:<key> -->` and a source-map link. Re-read the map and exact-key matches immediately before allocation and after creation.

Continue only when exactly one replacement matches. Multiple matches remain non-executable and route to `and-sweep`; the handoff never chooses a winner. Finish Package promotion and every temporary-asset cleanup or promotion before making the replacement `ready-for-agent`.

After all effects verify, append completed handoff evidence with the replacement identity, remove the map's active stage, and close the map. Pending and completed evidence with one key are one operation. Resolved investigations remain closed planning evidence; a failed handoff leaves the map open and resumable.

## Invariants

- A map is planning state rather than a delivery unit or claim target.
- An investigation is not a PRD child slice even though both use native sub-issues.
- Map membership, dependency, and delivery containment never convert into one another.
- Investigation ownership never becomes delivery ownership.
- A map carrying `ready-for-agent`, delivery ownership, or an executable child slice is drift.
- Exactly-once keys and receipts survive worktree changes and retries.
