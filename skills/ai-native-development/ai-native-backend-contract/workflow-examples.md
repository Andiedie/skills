# Workflow Backend Examples

Use these examples as a dry-run checklist for the AI-native delivery loop.

These examples are dry-run checklists, not a third source of truth. If an example conflicts with `backend-contract.md` or a backend reference, the contract and backend reference win.

## GitHub-Native Dry Run

1. `setup-ai-native-development` creates `.and/config.yml`:

   ```yaml
   version: 1
   workflow_state_backend: github-native
   ```

2. `issue-intake` records a raw signal as a GitHub issue with `needs-triage`.
3. `issue-triage` moves it to `needs-info` and appends a `## State Reason` comment when a decision is missing.
4. `issue-grill` resolves the decision and records issue notes, or appends a new State Reason when still blocked.
5. `issue-pack` publishes either:
   - one issue with a Package Contract and `ready-for-agent`; or
   - one parent PRD with a Package Contract, native sub-issues, native dependency relationships, `parent-prd`, and `ready-for-agent`.
   Native relationships are required; do not emulate package containment or dependency order with task lists, labels, or comments.
6. `issue-pick` reads ready delivery units, excludes blocked or claimed work, and recommends one claim unit.
7. `issue-claim` records ownership on the delivery unit.
8. `issue-implement` works from the GitHub-native Package Contract in an isolated branch or worktree and references implementation artifacts from receipts.
9. Close or rejection uses GitHub closed state plus a closing comment or existing close-reason convention.
10. `issue-sweep` audits labels, State Reasons, native relationships, external blockers, ownership, and lifecycle drift.

Validation:

- No markdown shadow state exists under `.and/work`.
- PRD children do not carry public queue labels.
- Dependency relationships are native blocked-by/blocking, not parent/sub-issue links.
- State Reason explains `needs-info`; blocked-by explains execution order.
- No relationship emulation exists through markdown task lists, labels, or comments.

## Markdown-File-Based Dry Run

1. `setup-ai-native-development` creates `.and/config.yml`:

   ```yaml
   version: 1
   workflow_state_backend: markdown-file-based
   ```

2. `issue-intake` scans `.and/work`, allocates the next `AND-0001` style ID, and creates:

   ```text
   .and/work/AND-0001/package.md
   .and/work/AND-0001/receipts/
   ```

3. `issue-triage` updates `package.md` frontmatter to `stage: needs-info` with the latest `state_reason`, or `stage: needs-pack`, or a lifecycle outcome.
4. `issue-grill` records decisions as receipts and updates the latest `state_reason` when still blocked.
   Material State Reason changes always leave receipt history.
5. `issue-pack` transforms the raw work record into:
   - `shape: single` with a Package Contract; or
   - `shape: prd-package` with child slice files under `children/`.
6. `issue-pack` writes containment indexes on parent and child records, and writes `blocked_by` only on blocked child slices.
7. External access or third-party waits are recorded in `external_blockers`, not in `blocked_by`.
8. `issue-pick` reads `.and/work` for `stage: ready-for-agent`, excludes external blockers and claimed delivery units, and recommends one delivery unit.
9. `issue-claim` records ownership as a receipt for the whole delivery unit.
10. `issue-implement` records branches, commits, PRs, CI, and review results as implementation artifacts in receipts.
11. Completion or rejection sets a lifecycle outcome, removes active stage state, and records evidence in a receipt.
12. `issue-sweep` audits frontmatter schema, containment drift, dependency drift, external blockers, claim receipts, and lifecycle outcomes.

Validation:

- `.and/work` is the only workflow state source.
- No GitHub issue mirror, discussion issue, or sync convention is used.
- Package frontmatter carries routing and index metadata, not the full Package Contract.
- State Reason history is preserved in receipts; frontmatter stores only the latest reason for queries.
- Frontmatter is current query state; receipts preserve history.
- Child slices do not carry public stage state.
- Implementation artifacts are receipt evidence, not workflow state.
- Lifecycle outcomes are not active stage states.

## Review Checklist

- `CONTEXT.md`, ADRs, backend contract, backend references, workflow docs, and skill instructions use the same terminology.
- Every workflow skill reads `.and/config.yml` before backend-specific state operations.
- Backend references explain where to read and write stage state, State Reason, Package Contract, containment, dependencies, external blockers, ownership, receipts, implementation artifacts, and lifecycle outcomes.
- GitHub-native examples preserve current GitHub issue behavior.
- Markdown-file-based examples can run from intake through sweep without inventing storage rules.
