---
name: progress-title
description: Update the current Codex task title throughout AND setup, intake, triage, clarification, wayfinding, packaging, picking, claiming, implementation, finish, or sweep whenever the active stage or evidenced progress changes.
---

# Progress Title

Project the current AND work into a compact Codex task title. Read AND workflow evidence and write only the calling task title.

## Process

1. **Resolve the work context.** Identify the current substantive AND action together with its GitHub evidence; a queue label alone does not distinguish stages such as Clarify, Wayfind, or an external wait. Use the top-level work Issue before packaging, the Wayfinding map Issue for map or investigation work, and the selected public delivery unit from Pick onward. Use the parent Issue for a PRD package. When no canonical Issue exists yet, keep the title issue-less.

   Choose the project display name from the existing title, project documentation, product name, and current context; preserve an existing name that remains accurate. Preserve an accurate existing task short name. Otherwise derive it from the work record's purpose, the Wayfinding destination, or the Package Contract's core deliverable, whichever currently owns the work.
   - Completion criterion: one project display name, one substantive AND action, one concrete task short name, and the canonical Issue when one exists are known.

2. **Classify the display stage.** Use the canonical English stage names and these progress ranges:

   | Display stage | Progress range | Optional substage |
   | --- | --- | --- |
   | `Intake` | `0%–2%` | — |
   | `Triage` | `2%–5%` | — |
   | `Clarify` | `5%–12%` | — |
   | `Wayfind` | `5%–12%` | `Map`, `Investigate` |
   | `Pack` | `12%–18%` | — |
   | `Pick` or `Claim` | `18%–20%` | — |
   | `Implement` | `20%–90%` | `Resolve`, `Isolate`, `Code`, `Verify`, `Review`, `Handoff` |
   | `Finish` | `90%–100%` | `PR`, `Checks`, `Merge`, `Complete`, `Cleanup` |
   | `Done` | `100%` | — |

   At `100%`, display `Done` instead of `Finish`. `Setup` is a repository operation and carries no delivery percentage. A targeted `Sweep` displays `Sweep` while retaining the underlying work's estimated percentage; a repository-wide `Sweep` carries no percentage. Terminal outcomes that did not deliver the work display `Duplicate`, `Rejected`, or `Superseded` without a percentage. Display the substantive stage supported by routers, contracts, TDD, or code review rather than naming those helpers as stages.
   - Completion criterion: one stage, any useful substage, and whether the title carries a percentage or terminal outcome are unambiguous.

3. **Estimate current progress.** Use simple judgment grounded in current workflow and implementation evidence, not elapsed time. Stay within the active stage's range. Skipping an optional stage may move directly into the next range; returning work upstream may decrease progress. Reserve `100%` for a completed delivery with authoritative Finish evidence. Create no weighting record or other workflow state for the estimate.
   - Completion criterion: the whole-number percentage reflects current evidence and the classified stage, or the title correctly carries no percentage.

4. **Write the title.** Use the first matching format:

   Issue-bound active work:

   ```text
   <project> | <progress>% · <stage>[/<substage>] | #<issue> <short name>
   ```

   Issue-bound non-delivery outcome:

   ```text
   <project> | <outcome> | #<issue> <short name>
   ```

   Work without one canonical Issue or delivery percentage:

   ```text
   <project> | <stage> | <short name>
   ```

   Make the short name name the core deliverable directly. Replace standalone process words such as “优化”, “处理”, or “相关” with the concrete artifact or behavior being delivered. For Chinese or mixed-language names, aim for 4–10 visible characters and require no more than 12. For English-only names, use 1–3 words and no more than 20 visible characters.

   Call `codex_app__set_thread_title` without a thread ID so it updates the calling task. While continuing the work, repeat steps 2–4 immediately whenever the stage, substage, percentage, or outcome changes.
   - Completion criterion: the title update succeeds with the exact formatted value.

Examples:

```text
AutoAE | 9% · Clarify | #62 motion策略
AutoAE | 46% · Implement/Code | #62 motion策略
AutoAE | 84% · Implement/Review | #62 motion策略
AutoAE | 96% · Finish/Merge | #62 motion策略
AutoAE | Setup | AND配置
```
