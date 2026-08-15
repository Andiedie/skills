---
name: use-worktree
description: Isolated checkout. Use when implementation needs its own worktree.
---

# Use Worktree

Create one worktree from the current `HEAD`, then run the repository's recorded setup.

## Process

1. **Name it.** Use the name the caller supplied. Otherwise generate a random name that is a legal Git branch (`wt-` plus 8 lowercase hex characters).
   - Completion criterion: one branch-safe name is selected.

2. **Create the worktree.** From the repository root:

   ```sh
   git worktree add -b <name> .worktrees/<name>
   ```

   On a Git error, print the native failure and stop.
   - Completion criterion: `.worktrees/<name>` exists as a worktree on branch `<name>`, or Git failed and setup was not started.

3. **Run setup.** Read the setup command from repository instructions and run it with cwd `.worktrees/<name>`. When no setup command is recorded, stop after creation and report the absolute path. On setup failure, leave the worktree and branch in place and report the absolute path plus the failed command and its output.
   - Completion criterion: the absolute worktree path and name are reported, and setup exited 0 or the retained worktree path and outcome (missing command or failing command) are reported.
