---
name: progress-title
description: Update the current Codex task title for an AND delivery unit being claimed, implemented, or finished whenever evidence changes its estimated delivery progress.
---

# Progress Title

Keep the current Codex task title aligned with the evidenced progress of one AND delivery unit.

## Process

1. **Resolve the title context.** Identify the public delivery unit from the current work. Use the single package Issue, or the parent Issue for a PRD package. Choose the project display name from the existing title, project documentation, product name, and current context; preserve an existing name that remains accurate. Preserve an accurate existing task short name, otherwise derive one from the Package Contract's core deliverable.
   - Completion criterion: one project display name, one public Issue number, and one concrete task short name describe the current delivery unit.

2. **Estimate current progress.** Judge completion from current delivery evidence rather than elapsed time, within the active stage's range:
   - Claim: `0%–5%`
   - Implement: `5%–90%`
   - Finish: `90%–100%`

   Re-estimate whenever new evidence changes the judgment. Progress may decrease when later evidence invalidates earlier completion. Reserve `100%` for a fully completed Finish.
   - Completion criterion: the whole-number percentage reflects current evidence and falls within the active stage's range.

3. **Write the title.** Use this exact format:

   ```text
   <project> | <progress>% | #<issue> <short name>
   ```

   Make the short name name the core deliverable directly. Replace standalone process words such as “优化”, “处理”, or “相关” with the concrete artifact or behavior being delivered. For Chinese or mixed-language names, aim for 4–10 visible characters and require no more than 12. For English-only names, use 1–3 words and no more than 20 visible characters.

   Call `codex_app__set_thread_title` without a thread ID so it updates the calling task. While continuing the work, repeat steps 2–3 immediately whenever the estimated percentage changes.
   - Completion criterion: the title update succeeds with the exact formatted value.

Example:

```text
AutoAE | 30% | #62 motion策略
```
