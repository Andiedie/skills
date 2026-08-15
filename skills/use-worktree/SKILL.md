---
name: use-worktree
description: Isolated checkout. Use when repository-writing work needs its own worktree.
---

Create `.worktrees/<name>` and a same-named branch from the current `HEAD`. Use the caller's name, or generate a legal random name.

Run the repository's recorded setup in the new worktree. If setup fails, keep the worktree and branch.
