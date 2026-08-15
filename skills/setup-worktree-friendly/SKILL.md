---
name: setup-worktree-friendly
description: Prepare a repository for concurrent Git worktrees.
disable-model-invocation: true
---

Make the target repository safe for concurrent Git worktrees.

Isolate the local resources that would collide across worktrees, using that repository's actual setup. Leave a repository-owned setup and teardown interface later agents can find. Add `.worktrees/` to Git ignore.

Accept with two temporary worktrees taken from the candidate state that includes this isolation change: they must set up concurrently, coexist, and tear down independently.
