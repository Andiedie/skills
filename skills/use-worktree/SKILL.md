---
name: use-worktree
description: Create an isolated Git worktree and run repository setup.
disable-model-invocation: true
---

Create `.worktrees/<name>` and a same-named branch from the current `HEAD`. Use the caller's name, or generate a legal random name.

Run the repository's recorded setup in the new worktree. If setup fails, keep the worktree and branch.
