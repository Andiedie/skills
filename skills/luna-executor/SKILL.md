---
name: luna-executor
description: Delegate bounded execution work to the configured Luna worker while the parent Agent keeps judgment and review.
disable-model-invocation: true
---

# Luna Executor

Delegate one bounded execution assignment to the configured `luna_worker`. The parent Agent keeps decisions, supervision, verification, and final delivery.

## Workflow

1. **Choose the assignment.** Finish product, architecture, authorization, and scope decisions first. Delegate meaningful implementation, refactoring, testing, or batch-editing work when its boundary is clear, it can be executed independently, and its result can be checked independently. Complete tiny or still-judgment-heavy work in the parent.
   - Completion criterion: one decided assignment and its acceptance signals are explicit.

2. **Write the task contract and delegate.** Give Luna a self-contained message containing the objective, owned scope and files, relevant facts and any useful context pointers, constraints, acceptance criteria, verification expectations, and required return format. For a long assignment, name its first observable milestone. Spawn exactly:

   ```text
   spawn_agent({
     task_name: <bounded task name>,
     agent_type: "luna_worker",
     fork_turns: "none",
     message: <self-contained task contract>
   })
   ```

   Use the existing role configuration unchanged and keep any further delegation with the parent. Wait for the child to return its result and evidence. Supervise at milestone boundaries, judging progress from available evidence such as child messages, workspace changes, active checks, and running processes; ongoing work between reports still counts as progress. When evidence changes the scope materially, resolve the current unit, then issue a new bounded contract. If the role is unavailable in the current task, capacity or permission blocks execution, or the child needs wider scope, a missing decision, or an external or destructive action, bring the facts, blocker, and recommendation back to the parent.
   - Completion criterion: the child returns a result with evidence or a concrete blocker.

3. **Review and decide.** Inspect the actual output and workspace diff, run or confirm risk-proportionate checks, and resolve conflicts. Reuse valid child verification while the diff and relevant risks remain unchanged; after parent edits, rerun the affected checks. Accept based on evidence; otherwise delegate a narrower assignment or complete it in the parent.
   - Completion criterion: the parent accepts the result or chooses the next action while retaining final delivery responsibility.
