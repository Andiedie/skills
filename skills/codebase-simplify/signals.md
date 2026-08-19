# Simplification Signals

Use these as search directions, then prove each candidate from repository evidence. Simplification removes concepts and obligations; fewer lines alone are not the goal.

## Unused Surface

- Public methods, configuration, events, hooks, helpers, packages, or durable formats without a production consumer.
- Behavior whose only consumers are tests, docs, fixtures, examples, or generated expectations.
- Interface members every adapter implements but no caller exercises.

## Duplicate Truth

- Two representations, caches, summaries, events, or derived states that mirror one fact.
- Flags, promises, sentinels, callbacks, or rollback paths that encode the same lifecycle transition.
- Validation, copying, or freezing repeated across a trusted in-process handoff.

## Shallow Structure

- Wrappers, modules, or packages that mainly forward another interface while adding little policy.
- Abstractions whose complexity would disappear, rather than return to callers, if deleted.
- One logical change that repeatedly crosses many files because the owning behavior is scattered.
- Test, demo, or support code split into a publishable or dependency-bearing package without a production need.

## Speculative Generality

- Extension points, registries, modes, callbacks, adapters, or configuration for an unowned future use.
- General rollback, migration, compatibility, or defensive machinery protecting an unused behavior.
- A seam with one real adapter and no demonstrated variation.

## Hand-Rolled Infrastructure

- Parsers, framing, retry, glob, diff, queue, or protocol machinery covered by the runtime or a maintained dependency.
- A replacement is strong when its semantic coverage, maintenance, adoption, transitive footprint, and net deletion justify the remaining glue.

## Evidence That Complexity Earns Its Keep

- Current production consumers or external, wire, durable, security, or compatibility contracts.
- Multiple real adapters that vary at the seam.
- Distinct ownership, rollback, arbitration, cancellation, or quiescence guarantees.
- A current repository decision whose rationale still applies.
