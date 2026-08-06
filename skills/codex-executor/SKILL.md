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

2. **Resolve the profile and context.** Use the profile named by the user exactly as given. When none was named, list the `*.config.toml` files under `${CODEX_HOME:-$HOME/.codex}`, present their names without the suffix, and ask the user to select one. Resolve the target workspace, then give the worker the objective, decisions already made, relevant input pointers, and acceptance conditions that it cannot discover from the workspace.
   - Completion criterion: one user-selected profile, one workspace, and the task-specific context are ready. If no profile is configured, report that prerequisite and stop.

3. **Run and wait.** Start one process with this baseline shape, passing the task through a safely quoted argument or stdin:

   ```sh
   codex exec \
     --profile '<profile>' \
     --cd '<absolute-workspace>' \
     --sandbox workspace-write \
     '<task>'
   ```

   Let the selected profile, Codex base configuration, and workspace supply the worker's model, provider, reasoning, authentication, instructions, skills, and tools. Use the host's persistent process session with a long initial yield. If the process continues, wait on that same session in long intervals and read only newly returned output; Codex Desktop can use an empty-input wait of up to 300 seconds.
   - Completion criterion: the CLI process has exited, or it has returned a blocker that requires the parent Agent's judgment.

4. **Review and decide.** Inspect the actual output and workspace changes, then run the acceptance checks appropriate to the assignment. Accept the work when those checks pass; otherwise refine another bounded assignment or complete the work in the parent Agent.
   - Completion criterion: the parent Agent has accepted the result or chosen the next action based on observed evidence.

## Scope

- The selected profile is the authority for its own execution configuration.
- The parent Agent supplies task context and owns every decision outside the execution assignment.
- Each run is one supervised Codex CLI process; additional flags are chosen only when the current assignment calls for them.
