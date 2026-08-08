---
name: codex-executor
description: Delegate execution work to a user-selected Codex CLI profile while the parent Agent keeps planning and review.
disable-model-invocation: true
---

# Codex Executor

Use Codex CLI as an execution worker. The parent Agent owns judgment, planning, supervision, and acceptance; the CLI carries out a bounded assignment.

## Workflow

1. **Choose the assignment.** Finish the decisions that shape the work, then delegate a unit whose remaining effort is substantial, whose boundary is clear, and whose result can be checked. State the unit and its acceptance signals before launch.
   - Completion criterion: the parent Agent can describe exactly what the CLI should accomplish and how the parent will judge the result.

2. **Resolve the profile and context.** Use the profile named by the user exactly as given. When none was named, list the `*.config.toml` files under `${CODEX_HOME:-$HOME/.codex}`, present their names without the suffix, and ask the user to select one. Resolve the target workspace and whether it is intentionally outside a Git repository, then give the worker the objective, decisions already made, relevant input pointers, and acceptance conditions that it cannot discover from the workspace. Treat the selected profile, Codex base configuration, and workspace as the authority for model, provider, reasoning, authentication, sandbox, approval, instructions, skills, and tools.
   - Completion criterion: one user-selected profile, one workspace, and the task-specific context are ready. If no profile is configured, report that prerequisite and stop.

3. **Run and wait.** Start one non-TTY process and supply the complete task at launch through a safely quoted argument or complete stdin:

   ```sh
   codex exec \
     --profile '<profile>' \
     --cd '<absolute-workspace>' \
     '<task>'
   ```

   Add `--skip-git-repo-check` for an intentional non-Git workspace; keep the smaller baseline for Git workspaces. Keep plain output and a persistent Codex conversation by default. Choose `--json`, `--ephemeral`, or TTY only when the assignment gives a concrete reason.

   Keep the host process session ID returned by the process tool distinct from the Codex conversation session ID printed by the CLI. Use the host process session for one long initial yield and subsequent blocking waits on that same process, each approaching 300 seconds. In Codex Desktop, let the outer wrapper wait or yield cover the same interval and read only newly returned output. After launch, use process stdin for waiting and process control; make conversational follow-up a resumed or fresh invocation. Return environment-specific test or tool failures as blockers for parent judgment.
   - Completion criterion: the CLI process has exited, returned a blocker for parent judgment, or produced sufficient acceptance evidence and then stopped progressing; interrupt a stalled process and continue to review.

4. **Review and decide.** Inspect the actual output and workspace changes, then run the acceptance checks appropriate to the assignment. Let those checks, rather than process exit status alone, determine acceptance. When an on-track run was interrupted, continue its recorded context with `codex exec resume '<conversation-session-id>' '<follow-up>'`; this starts a new process rather than restoring the interrupted shell process. When the direction needs correction or tighter scope, start a fresh bounded run that sees the existing workspace changes without inheriting the earlier conversation. Accept the work when its checks pass; otherwise refine another bounded assignment or complete the work in the parent Agent.
   - Completion criterion: the parent Agent has accepted the result or chosen the next action based on observed evidence.

## Scope

- The parent Agent supplies task context and owns every decision outside the execution assignment.
- Each run is one supervised Codex CLI process; additional flags are chosen only when the current assignment calls for them.
