# Existing Setup Convergence

Read this reference only when the repository audit finds Matt setup, another legacy setup authority, or retained legacy work data. The Setup Contract in `SKILL.md` remains the target-state authority; this reference supplies conditional disposition rules.

Treat useful repository facts and obsolete setup authority separately.

| Existing surface | Convergence rule |
| --- | --- |
| `docs/agents/issue-tracker.md` | Migrate only real repository capability facts that still matter. Remove or replace generic tracker commands, PR/MR request-surface policy, Wayfinder configuration, workflow mirrors, and relationship fallbacks as AND authority. |
| `docs/agents/triage-labels.md` | Do not retain label mapping. AND's fixed active-stage and structural labels remain authoritative. |
| `docs/agents/domain.md` | Reuse real nonstandard or multi-context domain and ADR discovery facts. Do not create or retain this file merely because an earlier setup generated it. |
| `## Agent skills` or another setup-owned entrypoint section | Replace or migrate it in place, avoid duplicates, and preserve surrounding user content. |
| `.scratch/` or another legacy work store | Never silently migrate or delete its work records. Remove it as active authority only through an approved plan. |

Retained legacy data can coexist with a successful AND setup only when an authoritative entrypoint or the nearest existing repository-fact source durably says that the data is non-authoritative, receives no new workflow writes, and names its owner and exit condition. Create `docs/agents/ai-native-development.md` for that note only when no existing authoritative surface can hold the repository-specific fact cleanly.

If old workflow instructions still direct writes to the legacy store, or its safe disposition remains unresolved, setup is incomplete. Report the blocker and stop instead of declaring convergence or preserving a dual-running compatibility path.
