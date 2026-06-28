---
name: codex-pr-review-loop
description: Loop a GitHub PR through @codex review until clean or blocked on user judgement.
disable-model-invocation: true
---

# Codex PR Review Loop

Run a GitHub PR through Codex review until the latest reviewed commit has no actionable Codex feedback, or until the next change needs the user's judgement.

## Steps

1. **Orient on the PR.** Identify the PR URL or number, repository, local working tree, PR branch, base branch, current local `HEAD`, and current remote PR head. If any of these cannot be determined from tools, CLI, or repository state, ask the user for the missing fact. Completion criterion: you can name the PR, the branch you will modify, and the commit SHA Codex will review.

2. **Trigger Codex review.** Comment `@codex review` on the PR. If the user gave a review focus, append it after the command, e.g. `@codex review for security regressions and missing tests`. Completion criterion: the trigger comment exists on the PR and you have recorded the commit SHA it targets.

3. **Wait for the result.** Poll the PR comments, reviews, and review threads until Codex responds to the trigger, or until tool/API evidence shows the review cannot start. If Codex does not respond, check whether the repo has Codex GitHub review enabled before asking the user. Completion criterion: you have either the Codex review output for the targeted SHA or a concrete setup/access failure.

4. **Triage every Codex item.** Classify each Codex finding as:
   - `fix` - the agent can verify and repair it from code, tests, logs, or docs.
   - `no-change` - the finding is stale, already fixed, incorrect, or intentionally accepted, with evidence.
   - `user-decision` - the finding depends on product intent, business rules, security risk acceptance, API compatibility, permissions, or another judgement the agent should not make.

   Completion criterion: every Codex finding from the latest review has exactly one classification with evidence.

5. **Stop for judgement when needed.** If any item is `user-decision`, pause and ask the user. State the decision point, options, your recommendation, reasons, and likely impact. Completion criterion: no code is changed for that item before the user decides.

6. **Fix agent-solvable items.** For each `fix` item, verify the claim before editing when feasible, then make the smallest clean change that matches the repository's architecture and style. Add or update tests when the feedback exposes behavior that should stay fixed. Completion criterion: all `fix` items are addressed, relevant tests or checks pass, and unrelated user changes are untouched.

7. **Push and re-review.** Commit if the branch needs a new commit, push the PR branch, then return to Step 2 for the new head SHA. Completion criterion: the PR remote head includes the fix and the next Codex review was triggered against that new SHA.

8. **Exit only on a clean latest review.** Stop the loop only when the latest Codex review for the latest PR head has no `fix` or `user-decision` items. If the same item repeats after a verified fix and the next move is unclear, treat it as `user-decision` and ask the user rather than looping blindly.

## Notes

- Prefer GitHub connector tools when available; otherwise use `gh` CLI.
- Do not treat older Codex feedback as clean or dirty without checking whether it still applies to the latest PR head.
- Do not use `@codex fix it` unless the user explicitly asks Codex cloud to make the changes instead of the current agent.
