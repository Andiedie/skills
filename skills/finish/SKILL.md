---
name: finish
description: Ship the current reviewed branch, merge it, close the Spec or ticket, teardown, and clean safe Git artifacts.
disable-model-invocation: true
---

The invocation authorizes the normal ship path.

Use the Spec or ticket in the current task context, and the Matt `code-review` already in this conversation. Push the branch, create or reuse one PR, wait for required checks, and squash-merge into the repository default branch.

Close the current ticket. When this delivery completes the Spec, close the parent and its contained tickets.

Run the repository teardown. Remove only the worktree and branches that belong to this delivery and are safe to remove.
