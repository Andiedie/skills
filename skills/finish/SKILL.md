---
name: finish
description: Ship reviewed work, close its Spec or ticket, and clean up its worktree.
disable-model-invocation: true
---

The invocation authorizes the normal ship path.

Use the Spec or ticket in the current task context, and the Matt `code-review` already in this conversation. Push the branch, create or reuse one PR, wait for required checks, and squash-merge into the repository default branch.

Close the current ticket. When this delivery completes the Spec, close the parent and its contained tickets.

Run the repository teardown. Remove only the worktree and branches that belong to this delivery and are safe to remove.
