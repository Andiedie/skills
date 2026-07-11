# AND Package Instructions

These instructions apply to changes under `skills/ai-native-development`.

## Documentation Authority

Keep each surface focused on one audience and purpose.

| Surface | Primary reader | Owns |
| --- | --- | --- |
| `README.md` | Someone entering the package | Orientation and navigation. |
| `docs/delivery-loop.md` | Someone learning AND | Why the loop exists, how it moves, and how humans and Agents collaborate. |
| `docs/skills.md` | Someone choosing a skill | Task-oriented routing and skill usage. |
| `AGENTS.md` | An Agent maintaining this package | Design balances, authority boundaries, and maintenance checks. |
| `and-backend-contract/backend-contract.md` | A workflow or backend author | Backend-neutral concepts, operations, and invariants. |
| `and-backend-contract/backends/*.md` | A workflow or backend author | Backend-specific representation, operations, validation, and end-to-end examples. |
| `<skill>/SKILL.md` | An Agent running that skill | Runtime behavior, preconditions, side effects, stop routes, and output contract. |
| Skill sibling references | An Agent on a conditional path | Detailed guidance that is needed only for that path. |

Give each durable rule one authoritative expression. Navigation may summarize enough purpose or routing to lead a reader to that source, but schemas, invariants, processes, side effects, and output contracts stay with their owner. Reader-facing documents should describe the current system, not its decision history, migration history, or maintenance process.

## Design Balances

Use these dimensions when designing or editing an AND workflow skill. Choose the smallest intervention that preserves reliable stage behavior, clear responsibility, reachable authoritative information, and appropriate human control.

### Instruction Density: Minimal Guidance vs Fully Explicit Instruction

- Keep instructions that materially change execution and checkable completion criteria that prevent premature completion.
- Remove duplication, no-ops, sediment, and defensive prose that is not justified by a real failure mode.
- Use no target length; every line must earn its context cost through behavioral value.

### Responsibility Span: Atomic Action vs Multi-Stage Workflow

- Complete one meaningful workflow stage, including its normal work and required result recording.
- Avoid fragmenting a stage into micro-skills whose handoffs cost more than the work.
- Route missing upstream decisions and downstream actions to their owning skills instead of absorbing them.

### Constraint Strength: Heuristic Guidance vs Hard Rules

- Express true invariants as explicit, checkable rules.
- Present defaults and heuristics as adaptable guidance rather than mandatory procedure.
- Describe the target behavior positively; keep negation only when a real high-impact failure cannot be prevented clearly without it.

### Information Locality: External Reference vs Inline Detail

- Keep process and constraints that every execution path needs in `SKILL.md`.
- Put conditional branches and long reference material behind context pointers that say when and why to load them.
- Give each normative behavior one authoritative source; do not restate behavior owned by the backend contract, another skill, or a sibling reference.

### Control Allocation: Agent Autonomy vs Human Control

- Agents establish verifiable facts; accountable humans decide value, risk, authorization, and business tradeoffs.
- Treat invocation as authorization for ordinary, clearly targeted stage actions; confirm new judgment, authority changes, or ambiguous mutation targets.
- Consume confirmed decisions once; downstream skills do not ask for the same decision again.

## Change Rules

- Put runtime behavior in the relevant `SKILL.md`, backend-neutral concepts and invariants in the backend contract, and backend-specific representation in the configured backend reference.
- Keep `delivery-loop.md` conceptual and `docs/skills.md` task-oriented. Update them only when their readers' model or route actually changes.
- Keep conditional detail in a sibling reference and link it from the owning skill at the decision point.
- When adding, splitting, or changing invocation, use model invocation only when an Agent or another skill must discover the skill; otherwise prefer user invocation, and add a router when manual discovery becomes costly.
- When a skill is added, renamed, removed, or changes description or group membership, update `skills.sh.json` and the repository skill inventory where applicable.
- When a skill is added, renamed, removed, or changes loop routing, recheck every affected `ask-andie` route.
- When an external runtime dependency changes, update setup checks, installation guidance, and the usage guide together.
- Preserve established terminology unless the change explicitly includes a domain-model update.

## Verification

For package changes, run the checks relevant to the diff:

- `git diff --check`;
- parse `skills.sh.json`;
- validate affected relative Markdown links;
- run `npx --yes skills add . --list` when skill discovery or package structure may be affected;
- search for stale names, terminology drift, or duplicated normative rules when moving responsibilities.
