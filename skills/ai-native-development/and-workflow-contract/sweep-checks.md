# Workflow Sweep Checks

Read this checklist only when `and-sweep` audits GitHub workflow state.

Check for:

- multiple active queue labels on one top-level issue;
- `needs-info` without a current State Reason, or a malformed non-clearing State Reason;
- PRD children or investigations carrying an active queue label;
- missing or inconsistent native parent/sub-issue relationships;
- `parent-prd` without native children when its Package Contract requires slices;
- a parent PRD used as a blocker for its children;
- relationship emulation through task lists, labels, or comments;
- open external blockers on ready work;
- stale, partial, or conflicting delivery ownership, including assignee/receipt mismatch or multiple delivery assignees;
- implementation artifacts used as ownership without a valid ownership record;
- reviewed implementation handed to Finish whose latest Implementation receipt lacks one authoritative Deployment disposition for its reviewed head, or whose disposition is stale or internally contradictory;
- a `custom` Deployment disposition with a missing, stale, incomplete, or contradictory Deployment Manifest, or a `none` or `standard` disposition that incorrectly includes a Manifest;
- merged delivery missing completion evidence, retaining an active stage, or remaining open;
- a parent closed while a contained child remains open, or Finish ending with completed children and an open parent;
- an open map missing `wayfinder:map`, carrying `ready-for-agent` or delivery ownership, or carrying neither `needs-info` nor `needs-pack`;
- an investigation with an active stage, missing or multiple method labels, missing map parent, or a parent that is not a map;
- a map sub-issue reused as a PRD child or an investigation reused as an implementation slice;
- an open, unblocked, unassigned investigation omitted from the derived frontier;
- stale or multiple investigation assignees, conflicting resolutions, or a closed investigation without a resolution;
- pending investigation publication with a missing edge, no exact-key match, or multiple exact-key matches;
- a keyed investigation missing from its map, or a closed resolved investigation with incomplete map projection;
- a map decision pointer that duplicates an answer, lacks a named investigation link, or points to an open investigation;
- a clear map retaining `needs-info`, unresolved fog, or an open investigation;
- a handoff that closed its map before the replacement Package Contract became authoritative, or multiple replacements sharing one handoff key;
- a linked temporary investigation asset without cleanup or Package-promotion disposition.

Each finding must identify the violated authority, observed evidence, impact, and owning repair stage. Detection alone does not authorize mutation.
