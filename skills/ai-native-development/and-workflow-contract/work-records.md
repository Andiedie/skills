# Work Records

Read this reference for work-record discovery, identity, stage, waiting reason, writes, or lifecycle operations.

## Read At The Required Resolution

Begin with the smallest current projection that can select the next operation:

- repository identity and issue number;
- open or closed lifecycle;
- active queue and structural labels;
- latest State Reason heading and permalink when one exists;
- native relationship identities and open or closed state when they can change the route.

For a slate, add only title and the ordering field needed by the caller. Load the complete issue body when its signal or current contract can change the operation. Load the complete latest State Reason when work is in `needs-info`. Retrieve historical comments or raw API metadata only when they can supersede current authority, resolve an identity, or change the selected operation.

## Raw Work Records

Create a new top-level issue with caller-provided title and body, open lifecycle, and `needs-triage`. Updating an identified issue merges new evidence while preserving stage, lifecycle, relationships, ownership, and earlier receipts unless another named operation changes them.

## Canonical Identities

Session-recovery and durable-workflow identity use:

- repository identity: lowercase `<host>/<owner>/<repository>` from the issue URL;
- work-record identity: decimal issue number without `#`.

Canonical actor identity is the authenticated GitHub login, lowercased and without `@`. Resolve it from GitHub's authenticated-user endpoint.

For an operation namespace `<operation>:v<version>`, hash exactly these UTF-8 lines with SHA-256:

```text
<operation>:v<version>
<canonical repository identity>
<canonical work-record identity>
```

Use LF endings, exactly one final LF, and no byte-order mark. Stored publication and handoff keys always use durable-workflow identity. Once a durable key is recorded, retries reuse that key.

## Stage State

The complete active queue label set is:

- `needs-triage`;
- `needs-info`;
- `needs-pack`;
- `ready-for-agent`.

Apply exactly one to an open top-level work issue. A PRD parent carries the package stage; its children carry none. Investigations carry none. An active Wayfinding map uses `needs-info` or `needs-pack` and never `ready-for-agent`. `parent-prd` and `wayfinder:map` are structural. Closed work uses GitHub closed state rather than a stage label.

## State Reason

An issue in `needs-info` requires a current append-only comment:

```markdown
## State Reason

State: needs-info
Cause: <missing-facts, decision-needed, access-needed, external-state, or acceptance-needed>
Owner: <reporter, maintainer, human, agent, or external-system>
Question: <one specific question, decision, permission, external event, or acceptance gate>
Resume with: <and-triage, and-clarify, and-wayfind, or and-pack>
Exit criteria: <what must be true before this work record can leave needs-info>
```

The latest State Reason supersedes earlier comments. When work leaves `needs-info`, append:

```markdown
## State Reason

State: cleared
```

Ordinary work names one specific missing input. A Wayfinding map names destination-level uncertainty and delegates changing sharp questions to its frontier.

## Lifecycle

Terminal outcomes include completed, rejected, duplicate, and superseded. Represent them with GitHub closed state plus the caller-owned completion or close-reason evidence. Remove active stage labels before or as the terminal operation requires.
