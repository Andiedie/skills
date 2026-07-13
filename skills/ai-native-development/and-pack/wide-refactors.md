# Wide Refactors

Read this reference only when one mechanical change has a blast radius that prevents ordinary tracer-bullet slices from landing green.

## Gate

All three conditions must hold:

- one shared representation, symbol, schema element, protocol, or other mechanical form changes;
- its call sites or build units break together when that form changes; and
- no narrow end-to-end slice can isolate part of the change and remain green.

Large or cross-cutting product work still uses ordinary vertical slices whenever they can land green.

## Expand, Migrate, Contract

1. **Expand**: add the new form beside the old without changing current behavior. Verify that both forms can coexist during migration.
2. **Migrate**: move callers in batches sized by the real blast radius, such as a package, directory, subsystem, or build unit. Every batch depends on Expand and should remain green and independently verifiable.
3. **Contract**: after every migration batch, remove the old form and verify that no old caller remains. Contract depends on all migration batches.

Publish containment and dependency through the configured backend. The package is complete only when temporary coexistence is gone and the affected system is green.

## Integration Exception

When migration batches cannot remain green independently:

- explain the inseparable blast radius in the Package Contract;
- run the affected slices on one integration branch under the parent package claim;
- preserve Expand, Migrate, and Contract order; and
- add a final integrate-and-verify slice after Contract. This final slice is the promised green boundary.

The exception changes internal verification, not the public claim unit. The parent package owner remains responsible for integration and final verification.
