---
name: codex-pr-review-loop
description: Loop a GitHub PR through @codex review until clean or blocked on user judgement.
disable-model-invocation: true
---

# Codex PR Review Loop

Run a GitHub PR through Codex review until the latest reviewed commit has no actionable Codex feedback, or until the next change needs the user's judgement.

## Steps

1. **Establish the PR target.** Get to exactly one ready-for-review PR and a local branch that can safely modify its head. Handle only these setup cases:
   - Existing PR: inspect its base, head branch, draft state, and remote head SHA; check out or create a local branch for that PR head if needed.
   - No PR, on a feature branch: confirm the working tree is clean, push the branch if needed, and create a ready-for-review PR.
   - No PR, on the base branch: stop and ask for a PR or feature branch.
   - Draft PR: stop before triggering review. If an `@codex review` comment was already left while it was draft, leave a new trigger after the PR becomes ready because the old mention may not run.

   Completion criterion: you can name the ready PR, base branch, head branch, local branch to modify, and target remote head SHA; or you have stopped because the PR is draft, no PR target can be established from the base branch, or the user must choose the target.

2. **Maintain a review ledger.** Keep a lightweight in-thread ledger for every round. Record the round number, target PR head SHA, trigger comment identity or timestamp, Codex acceptance evidence such as an eyes reaction, Codex result source, findings and classifications, fix commit SHA if any, and verification commands. Completion criterion: the latest round can be distinguished from older reviews and comments by SHA and trigger.

3. **Trigger Codex review.** Comment `@codex review` on the ready PR. If the user gave a review focus, append it after the command, e.g. `@codex review for security regressions and missing tests`. Record the target SHA in the ledger before waiting. Completion criterion: the trigger comment exists on the ready PR and the ledger records the commit SHA it targets.

4. **Wait with state-based polling.** Poll fast only until you know whether Codex accepted the job, then switch to slower state-based polling and report only meaningful state changes. For Codex review, absence of a result is never clean; clean requires evidence tied to the latest PR head. If Codex has accepted the job but not returned output, keep waiting or report the pending state if pausing; do not advance to collection or triage. Completion criterion: you have Codex output for the target SHA, or you have stopped with a concrete setup/access failure.

5. **Collect Codex output from every relevant source.** Check trigger reactions, PR reviews, review comments or inline threads, ordinary PR comments, and timeline events as needed. Clean output may be an ordinary comment rather than a review; actionable findings may live in review comments rather than the review body. Ignore stale output unless evidence ties it to the current target SHA or trigger. Completion criterion: every Codex response source relevant to the current round has been checked or ruled out, and the ledger records where the result came from.

6. **Triage every Codex item.** Classify each Codex finding as:
   - `fix` - the agent can verify and repair it from code, tests, logs, or docs.
   - `no-change` - the finding is stale, already fixed, incorrect, or intentionally accepted, with evidence.
   - `user-decision` - the finding depends on product intent, business rules, security risk acceptance, API compatibility, permissions, or another judgement the agent should not make.

   Completion criterion: every Codex finding from the latest review has exactly one classification with evidence.

7. **Stop for judgement when needed.** If any item is `user-decision`, pause and ask the user. State the decision point, options, your recommendation, reasons, and likely impact. Completion criterion: no code is changed for that item before the user decides.

8. **Fix agent-solvable items with `/tdd`.** For each `fix` item, use the `/tdd` skill as the repair loop. Verify the claim before editing when feasible, write one behavior-focused failing test or executable reproduction for the finding, make the smallest clean change that turns it green, then refactor only while green. If no meaningful automated test can be written, record why and use the strongest executable verification available before editing. Record the reproduction, fix, and verification evidence in the ledger. Completion criterion: every `fix` item has passed through a `/tdd` RED->GREEN->refactor cycle or a documented no-automated-test exception, all relevant checks pass, and unrelated user changes are untouched.

9. **Push and re-review.** Commit if the branch needs a new commit, push the PR branch, confirm the new remote PR head SHA, then return to Step 2 for the new round. Completion criterion: the PR remote head includes the fix, the ledger records the new target SHA, and you are ready to trigger a new round against that SHA.

10. **Exit only on a clean latest review.** Stop the loop only when the latest Codex result for the latest remote PR head has no `fix` or `user-decision` items. If clean evidence is an ordinary comment, confirm it was created after the latest trigger and applies to the latest head. If the same item repeats after a verified fix and the next move is unclear, treat it as `user-decision` and ask the user rather than looping blindly. Completion criterion: the final report names the latest head SHA, the clean Codex evidence, each fixed finding with reproduction or test evidence, and the verification commands.

## Notes

- Prefer GitHub connector tools when available; otherwise use `gh` CLI.
- Do not treat older Codex feedback as clean or dirty without checking whether it still applies to the latest PR head.
- Do not use `@codex fix it` unless the user explicitly asks Codex cloud to make the changes instead of the current agent.
- The review loop ends at a clean PR. Do not merge or delete branches unless the user explicitly asks. If asked to merge, follow the repository's merge policy or ask about merge method, then verify the local branch, remote branch, remote-tracking ref, PR state, and working tree after cleanup.

## Polling Discipline

- Local command polling uses tool waits, not shell busy loops. Do not run `while sleep 1` loops just to poll command output; set `yield_time_ms` on `exec_command` and poll long-running sessions with `write_stdin`.
- Use `250ms-2s` waits for interactive commands, `5s-10s` for ordinary tests or builds, `15s-30s` for long verification such as `pnpm verify`, E2E, or Docker builds, and `30s-120s` for very long deployment, remote CI, or external queue work.
- Codex PR review is an external GitHub/Codex async task, not local stdout/stderr. After triggering, check once after `15s-30s` for an eyes reaction or other acceptance evidence. If there is no acceptance evidence, check draft state, permissions, and Codex app setup before asking the user.
- If Codex accepted the job, check reviews and comments every `45s-60s`. Do not report every unchanged poll to the user; report state changes, elapsed thresholds, or a concrete next diagnostic step.
- If `5-8min` pass without a result, check timeline events, PR reviews, review comments, ordinary comments, and reactions. If evidence still shows only an accepted in-progress job, report that Codex accepted the job but has not returned; do not mark the round clean.
- If an eyes reaction disappears before a review appears, immediately check all comment and review sources because clean output may be an ordinary comment.
