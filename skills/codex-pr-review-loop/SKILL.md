---
name: codex-pr-review-loop
description: Loop a GitHub PR through @codex review until clean or blocked on user judgement.
disable-model-invocation: true
---

# Codex PR Review Loop

Run a ready GitHub PR through Codex review until Codex explicitly reports the latest reviewed commit clean, or until the next change needs the user's judgement.

## Steps

1. **Establish and trigger.** Get to exactly one ready-for-review PR and a local branch that can safely modify its head. Confirm the base branch, head branch, draft state, and remote head SHA, then comment `@codex review` on the PR. If the user gave a review focus, append it after the command, e.g. `@codex review for security regressions and missing tests`. Handle only these setup cases:
   - Existing PR: inspect its base, head branch, draft state, and remote head SHA; check out or create a local branch for that PR head if needed.
   - No PR, on a feature branch: confirm the working tree is clean, push the branch if needed, and create a ready-for-review PR.
   - No PR, on the base branch: stop and ask for a PR or feature branch.
   - Draft PR: stop before triggering review. If an `@codex review` comment was already left while it was draft, leave a new trigger after the PR becomes ready because the old mention may not run.

   Completion criterion: you can name the ready PR, base branch, head branch, local branch to modify, target remote head SHA, and trigger comment; or you have stopped because the PR is draft, no PR target can be established from the base branch, or the user must choose the target.

2. **Keep a lightweight ledger.** Track only enough state to distinguish the current round from stale output and safely clean up completed threads: round number, target head SHA, trigger comment, result state, reviewed commit SHA if present, Codex finding thread or comment IDs with classifications, fix commit SHA if any, and verification summary. Treat an eyes reaction as acceptance only; it is not a result and may disappear later.

   Completion criterion: the current round can be distinguished from older reviews by target SHA and trigger comment without maintaining a heavy audit log.

3. **Wait for Codex text.** Poll fast only until you know whether Codex accepted the job, then switch to slower state-based polling. Clean requires a Codex-authored text result for the latest head such as `Didn't find any major issues` or a clearly equivalent no-issues message. Do not use thumbs-up reactions as clean evidence. Absence of output is never clean. If Codex has accepted the job but not returned output, keep waiting unless pausing for a concrete reason.

   Completion criterion: you have Codex output tied to the target SHA, or you have stopped with a concrete setup/access/pending reason that explicitly is not clean.

4. **Read efficiently and thread-aware.** Prefer one aggregated snapshot per poll that includes PR head SHA, ordinary PR comments, PR reviews, and review threads. Use GraphQL or the GitHub connector's thread-aware tools when resolution state, outdated state, inline anchors, or review commit attribution matter. During pending polls, read metadata first and avoid repeatedly expanding large comment bodies; fetch full bodies only when new Codex output appears or attribution is ambiguous.

   Clean output may be an ordinary PR comment. Actionable findings may live in inline review threads. Ignore stale output unless it is tied to the current target SHA or trigger. Do not treat a moved or re-anchored old inline thread as new feedback; prefer review commit SHA and creation time over current line number.

   Completion criterion: the current round's Codex result has been collected, or all relevant lightweight sources show only accepted/pending state.

5. **Triage Codex feedback.** Cluster duplicate comments or comments that point to the same behavior, then classify each Codex finding as:
   - `fix` - the agent can verify and repair it from code, tests, logs, or docs.
   - `no-change` - the finding is stale, already fixed, incorrect, or intentionally accepted, with evidence.
   - `user-decision` - the finding depends on product intent, business rules, security risk acceptance, API compatibility, permissions, or another judgement the agent should not make.

   Completion criterion: every Codex finding from the latest reviewed commit has exactly one classification with evidence.

6. **Stop for judgement when needed.** If any item is `user-decision`, pause and ask the user. State the decision point, options, your recommendation, reasons, and likely impact. Completion criterion: no code is changed for that item before the user decides.

7. **Fix with `/tdd` when practical.** For each `fix` item, prefer the `/tdd` repair loop: verify the claim before editing when feasible, write one behavior-focused failing test or executable reproduction, make the smallest clean change that turns it green, then refactor only while green. If no meaningful automated test can be written, record why and use the strongest executable verification available. Keep changes traceable to the Codex finding cluster and leave unrelated user changes untouched.

   Completion criterion: every `fix` item has passed through a `/tdd` RED->GREEN->refactor cycle or a documented no-automated-test exception, and relevant verification passes.

8. **Push and re-review.** Commit if the branch needs a new commit, push the PR branch, confirm the new remote PR head SHA, then return to Step 1 for the next round against the new SHA. Completion criterion: the PR remote head includes the fix, the ledger records the new target SHA, and the next Codex review has been triggered.

9. **Resolve completed Codex threads.** After the latest remote head receives Codex clean text, resolve Codex-authored inline review threads that are covered by the ledger as `fix` or `no-change`. Do not resolve human threads, `user-decision` threads, ordinary PR comments, review summaries, or threads whose status cannot be mapped to the loop's findings.

   Completion criterion: completed Codex inline threads have been resolved or skipped with a reason.

10. **Exit only on clean text for the latest head.** Stop the loop only when Codex explicitly reports the latest remote PR head clean. If clean evidence is an ordinary PR comment, confirm it was created after the latest trigger and that its reviewed commit matches or prefixes the latest head SHA. If the same item repeats after a verified fix and the next move is unclear, treat it as `user-decision` and ask the user rather than looping blindly.

   Completion criterion: the final report names the PR, latest head SHA, Codex clean text source, fixed findings, verification commands, resolved/skipped thread count, and any remaining unresolved review threads.

## Notes

- Prefer GitHub connector tools when available; otherwise use `gh` CLI.
- Do not treat older Codex feedback as clean or dirty without checking whether it still applies to the latest PR head.
- Do not use `@codex fix it` unless the user explicitly asks Codex cloud to make the changes instead of the current agent.
- The review loop ends at a clean PR. Do not merge or delete branches unless the user explicitly asks. If asked to merge, follow the repository's merge policy or ask about merge method, then verify the local branch, remote branch, remote-tracking ref, PR state, and working tree after cleanup.
- Do not close issues, run production-readiness handoffs, lock conversations, dismiss reviews, merge, or delete branches as part of this skill unless the user explicitly asks.

## Polling Discipline

- Local command polling uses tool waits, not shell busy loops. Do not run `while sleep 1` loops just to poll command output; set `yield_time_ms` on `exec_command` and poll long-running sessions with `write_stdin`.
- Use `250ms-2s` waits for interactive commands, `5s-10s` for ordinary tests or builds, `15s-30s` for long verification such as `pnpm verify`, E2E, or Docker builds, and `30s-120s` for very long deployment, remote CI, or external queue work.
- Codex PR review is an external GitHub/Codex async task, not local stdout/stderr. After triggering, check once after `15s-30s` for an eyes reaction or other acceptance evidence. If there is no acceptance evidence, check draft state, permissions, and Codex app setup before asking the user.
- If Codex accepted the job, check aggregated PR state every `45s-90s`. Do not report every unchanged poll to the user; report state changes, elapsed thresholds, or a concrete next diagnostic step.
- If `5-8min` pass without a result, take one broader thread-aware snapshot. If evidence still shows only an accepted in-progress job, keep waiting or explicitly report pending if pausing; do not mark the round clean.
