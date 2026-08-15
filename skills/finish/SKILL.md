---
name: finish
description: "Ship the current reviewed branch, merge it, close the Spec or ticket, teardown, and clean safe Git artifacts."
disable-model-invocation: true
---

# Finish

The invocation authorizes the normal ship path for the current reviewed work.

## Process

1. **Resolve identities.** Take the parent Spec and current ticket from the current task context. Ask only when that context is missing or contradicts itself.
   - Completion criterion: the Issue numbers to close after merge are known.

2. **Prove the branch is shippable.** Working tree clean, every change committed. Use the Matt `code-review` result already in this conversation. Target is the repository default branch; merge method is squash. An explicit argument on this invocation overrides either default. Stop if the chosen merge method is not enabled on the repository.
   - Completion criterion: one source branch, one target, and one enabled merge method are known, and the source is clean and committed.

3. **Publish.** Push the source branch. Reuse the single open PR for this head and target, or create that one PR. Wait until every GitHub required check on that PR has succeeded. Merge with the chosen method.
   - Completion criterion: the target contains the merge, or the failed step (push, checks, or merge) is reported with remaining work.

4. **Complete the tracker.** Close the current ticket with `gh issue close` after merge. When this delivery finishes the parent Spec — the current ticket was the last open child, or the current work is the whole Spec — close the parent. A whole-Spec delivery also closes its contained tickets.
   - Completion criterion: the Issues resolved in step 1 are closed, or the failed close is reported with remaining work.

5. **Tear down and clean.** Run the recorded teardown command from the current worktree when repository instructions name one. Then remove only the worktree and branches that uniquely belong to this finished delivery and are clean. Keep anything dirty, unique, shared, default, or target.
   - Completion criterion: teardown ran or was absent; every removed Git artifact was proven exclusive and clean; every retained artifact has a reason.

On any failure, stop at that step, report what failed and what remains, and leave repair to a later invocation or the user.
