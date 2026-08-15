---
name: setup-worktree-friendly
description: Make one repository's local resources worktree-safe and record a setup/teardown interface.
disable-model-invocation: true
---

# Setup Worktree-Friendly

Prepare one target repository so native Git worktrees can run side by side. Adapt to that repository's real ports, processes, containers, databases, caches, and similar local resources.

## Process

1. **Inspect the target.** Read compose files, env examples, package scripts, Makefiles, port bindings, database config, cache paths, and process managers. List every local resource that would collide if two worktrees started at once.
   - Completion criterion: every discovered colliding resource is named with the file or command that binds it.

2. **Isolate each collision.** Give each worktree its own values derived from its path or name: ports, compose project, database or schema, socket, pid file, cache directory, and similar. Bind those values through the repository's existing config style.
   - Completion criterion: two worktrees starting from the same tree would receive different bindings for every listed collision.

3. **Publish one lifecycle interface.** Add or reuse a repository-owned `setup` command and a `teardown` command that apply and reverse those bindings. Prefer the repo's existing runner (`just`, `make`, `package.json` scripts, or `scripts/`). Record the exact two commands in repository instructions (`AGENTS.md` when that is the agent entrypoint). Ignore `.worktrees/` in Git.
   - Completion criterion: repository instructions contain the exact setup and teardown commands, `.worktrees/` is gitignored, and both commands are executable from a worktree root.

4. **Accept with two temporary worktrees.** From the current `HEAD`:

   ```sh
   git worktree add -b setup-accept-a .worktrees/setup-accept-a
   git worktree add -b setup-accept-b .worktrees/setup-accept-b
   ```

   Run setup in both concurrently. Prove they coexist: distinct live bindings, both healthy. Tear down A and prove B is still healthy. Tear down B. Remove both temporary worktrees and branches.
   - Completion criterion: coexistence and independent teardown were observed, and no `setup-accept-*` worktree or branch remains.

Report the recorded setup and teardown commands.
