---
name: and-wayfind
description: Map and resolve multi-session uncertainty until work can be packaged.
disable-model-invocation: true
---

# AND Wayfind

A destination is visible, but the way there is still in fog. Wayfinding charts that uncertainty as a shared map, then resolves one investigation at a time until `and-pack` can publish the delivery unit.

Wayfinding plans; it does not deliver the destination. The pull to implement is usually evidence that the map has reached its handoff boundary.

## Runtime Contracts

Before reading or writing workflow state, read `.and/config.yml`, invoke `and-backend-contract`, and use the configured backend reference for map, investigation, relationship, ownership, resolution, and lifecycle operations.

Invoke `and-interview-contract` whenever charting or resolving a HITL investigation requires an interview. It owns evidence, recovery, backend-safe domain modeling, and artifact-ready output. Required Matt runtime skills are `grilling`, `research`, and `prototype`. Stop with exact install guidance when a required contract or runtime skill is unavailable.

## Map And Investigation

The map is a shared index, not a store or claim unit. Open investigations are queried through backend relationships rather than copied into its body. Its body is:

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

Each investigation is one sharp question sized for one Agent session:

```markdown
## Question

<the decision or investigation this record resolves>
```

The detailed answer lives only in the investigation resolution. Human-readable narration and map pointers use linked titles, not bare IDs.

The frontier is derived from open, unblocked, unclaimed investigations. Fog remains on the map until it becomes sharp enough to create a record.

Use one test: create an investigation when its question can be stated precisely now, even if it is blocked or unanswered; keep it as fog when the question itself cannot yet be phrased precisely.

## Investigation Methods

- **Research** (AFK): invoke `research` for facts requiring primary sources outside the current worktree. Link its Markdown evidence from the resolution.
- **Prototype** (HITL): invoke `prototype` for a cheap concrete artifact that lets the human judge behavior or form. The human must actually react before resolution.
- **Grilling** (HITL): invoke `grilling` directly under `and-interview-contract`, one question at a time. Do not invoke `and-clarify` from this skill.
- **Task** (AFK or HITL): perform bounded prerequisite work whose result makes a later decision possible. It may act, but it does not deliver the destination.

Create research and prototype assets in a dedicated investigation branch/worktree, never the ordinary worktree. The resolution links the asset and marks it for cleanup or Package promotion. Its answer remains authoritative even when a throwaway asset is later removed.

## Process

Choose exactly one path per invocation. A map whose initial investigation keys have no completed publication evidence resumes `Chart A Map`; other maps use `Work Through A Map`. Never chart a map and resolve an investigation in the same invocation, and never resolve more than one investigation.

### Chart A Map

Use this path for a non-map work record whose current route is `and-wayfind`, or for an existing map whose initial investigation keys lack completed publication evidence.

For an incomplete existing map, read its recorded chart key and pending publication intent, then resume at Publish the map. Do not repeat the destination interview, breadth-first exploration, map promotion, or already verified writes.

1. Resolve the work record.
   - Read its stage, State Reason, source evidence, receipts, relationships, ownership, and linked artifacts.
   - Route unrecorded work to `and-intake`, untriaged work to `and-triage`, a concrete decision to `and-clarify`, and already-clear work to `and-pack`.
   - Supply `and-interview-contract` with host `and-wayfind`, objective `chart-map`, the canonical repository and work identities, current evidence, and the destination question.
   - Completion criterion: one eligible existing work record and its uncertainty boundary are explicit.

2. Name the destination.
   - Invoke `grilling` to establish what must be clear before packaging can begin. The destination fixes scope.
   - Completion criterion: the human confirms a concise destination and its out-of-scope boundary.

3. Explore breadth-first.
   - Invoke `grilling` across the whole decision space, surfacing sharp questions, their likely methods, known ordering, and fog without resolving one thread deeply.
   - Obtain final shared-understanding confirmation for the destination, scope, first visible frontier, and remaining fog before any backend synchronization.
   - If no real fog exists, append one `Wayfinding Exit` receipt carrying the interview checkpoint without creating map state. Keep one concrete remaining decision in `needs-info` with `Resume with: and-clarify`; otherwise move confirmed packageable work to `needs-pack`. Verify the route, clean synchronized recovery, report it, and stop without entering map publication.
   - Completion criterion: the work either exits without a map, or has confirmed multi-session fog plus a complete first visible frontier.

4. Publish the map.
   - When no chart key is recorded, derive it from durable-workflow identity through `and-backend-contract` with namespace `and-wayfind-map-chart:v1`. Retry always reuses the recorded chart key. Before structural mutation, append a pending investigation-publication receipt that lists every planned investigation's stable key, title, method, and question. Derive each investigation key from the chart key plus its stable map ordinal, such as `<chart-key>:I01`; never renumber it.
   - Promote the existing work record through the configured backend; do not create a second map.
   - Preserve material source evidence, write the five map sections, and record the destination-level State Reason with `Resume with: and-wayfind`.
   - Append a map-chart receipt carrying the interview checkpoint so recovered output can be matched to authoritative state.
   - For each planned key, reuse the sole matching investigation or create one whose initial authoritative record carries that key. Create every currently sharp investigation first, then write map membership and dependency edges in a second pass. Keep unsharp uncertainty in `Not yet specified`.
   - Re-read key matches and relationships, then append completed investigation-publication evidence. If multiple records carry one key, stop with the map non-executable and route the drift to `and-sweep`.
   - Verify every created record, method, relationship, stage, and receipt, then clean synchronized interview recovery.
   - Completion criterion: one resumable map exists with a queryable frontier and no investigation has been resolved.

5. Report the chart receipt.
   - Name the map, investigations created, currently available frontier, remaining fog, and next `and-wayfind` invocation.
   - Do not copy the map or investigation bodies into chat.

### Work Through A Map

Use this path for an existing map. An investigation argument is optional.

1. Load the low-resolution map.
   - Read Destination, Notes, Decisions so far, Not yet specified, Out of scope, current stage and State Reason, investigation states, and dependencies.
   - Fetch full bodies or resolutions only for the selected investigation and directly relevant records.
   - Detect incomplete work before selecting new frontier work.
   - If non-initial investigation keys have pending publication, finish only their missing records or relationships, verify completion, report the recovered map state, and stop.
   - If a closed resolved investigation lacks its map pointer or map advance, continue directly at Advance the map with that durable resolution, report the recovered map state, and stop without selecting another investigation.
   - If an owned open investigation already has a durable resolution but lacks close, carry it directly to Resolve it; do not select or claim another investigation.
   - Completion criterion: current destination, frontier, fog, and relevant prior decisions are known without loading every investigation in full.

2. Choose and claim one investigation.
   - If the user names an investigation, verify that it belongs to the map, is open and unblocked, and is either unclaimed or already owned by the current actor. Otherwise resume the first open investigation owned by the current actor, then fall back to the first unclaimed frontier investigation in backend order.
   - Record ownership only for an unclaimed investigation, then re-read authoritative state. If another actor owns it, select the current frontier or report that none is available.
   - Completion criterion: exactly one eligible investigation is selected and owned by the current actor for this invocation; the map and delivery ownership remain unchanged.

3. Resolve it.
   - If one durable resolution already exists, do not invoke the method or write another; resume the missing close or map advance. Otherwise invoke the investigation's method and follow `and-interview-contract` for HITL evidence and recovery.
   - For a HITL method, supply objective `resolve-investigation` and the selected investigation's canonical identity to `and-interview-contract`, not the map identity.
   - Zoom into linked evidence as needed. A HITL investigation remains open until the human supplies the required response.
   - If the current owner explicitly abandons unfinished work, preserve the blocker or recovery evidence and release only that investigation's ownership. Never release another actor's investigation.
   - When no durable resolution exists, preserve the precise blocker and recovery state, keep the investigation open and owned unless explicitly released, report the blocker, and stop. Do not enter Advance the map.
   - Completion criterion: one durable answer exists with required evidence and asset disposition, or the invocation has stopped with one recoverable blocker.

4. Advance the map.
   - Enter only when the investigation has a complete answer ready to record, or one durable resolution already exists.
   - Re-read the map immediately before mutation.
   - Write the resolution only when none exists, including the valid interview checkpoint when the method was HITL. Close the investigation only when it is still open.
   - Append one linked, named gist to `Decisions so far` when the answer advances the route. If the investigation proves to be beyond the Destination, put one linked reason in `Out of scope` instead and do not add it to Decisions.
   - Before creating newly sharp investigations, append a pending investigation-publication receipt with their next stable keys, titles, methods, and questions. Reuse exact-key matches, create only missing records, wire relationships, verify one match per key, then append completion evidence.
   - Remove graduated fog, update invalidated records, and move beyond-destination findings to `Out of scope`.
   - When no open investigation or in-scope fog remains, move the map to `needs-pack`; otherwise preserve `needs-info` and an accurate `Resume with: and-wayfind` State Reason.
   - Verify every mutation and clean synchronized interview recovery.
   - Completion criterion: the authoritative map reflects the answer, current frontier, remaining fog, and clear-or-resume state without resolving a second investigation.

5. Report the work receipt.
   - Name the map, investigation resolved or blocker, new frontier or clear state, asset disposition when relevant, and next `and-wayfind` or `and-pack`.
   - Do not copy full answers, map bodies, or investigation records into chat.

## Investigation Publication Receipt

Use this append-only receipt before creating an initial or newly visible batch:

```markdown
## Investigation Publication

Chart key: <deterministic map chart key>
Investigations:
- <investigation key> | <method> | <title> | <one sharp question>
Publication: <pending, or completed with linked identities>
```

Append the pending receipt before writes, then append a second receipt with `Publication: completed` and linked identities after verification. For each investigation key, the latest valid publication evidence determines whether work remains. Initial investigation records carry their listed key, so retry searches exact-key matches before creating anything and can finish missing map membership or dependency edges without duplicating records.

## Investigation Ownership Receipts

When the configured backend derives investigation ownership from receipts, use:

```markdown
## Investigation Claim

Sequence: <next positive integer>
Owner: <canonical actor identity>
```

```markdown
## Investigation Release

Sequence: <next positive integer>
Owner: <current canonical actor identity>
Reason: <why unfinished ownership is released>
```

Re-read receipts before append and allocate one greater than the highest valid sequence. The highest valid sequence determines current ownership: claim sets its owner; release clears ownership only when its owner matches the current owner. Resume by the same owner writes no new receipt. Duplicate or non-increasing sequences, release by another actor, or conflicting current ownership route to `and-sweep`.

## Boundaries

- Keep investigation work epistemic; delivery begins only after `and-pack` publishes a separate Package Contract.
- Keep the map shared and unclaimed. Investigation ownership covers one investigation and never authorizes delivery work.
- Keep PRD children and investigations distinct in identity, relationship meaning, queue visibility, and lifecycle.
- Leave a clear map open for `and-pack`; Package publication owns map handoff and closure.
