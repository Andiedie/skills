# Wide Refactors

Read this reference only when one mechanical change has a blast radius that prevents ordinary tracer-bullet vertical slices from landing green.

## Trigger

All of these must be true:

- the work changes one shared representation, symbol, schema element, protocol, or other mechanical form;
- the change fans across enough call sites or build units that changing the form breaks them together;
- no ordinary end-to-end slice can isolate part of the change and remain green.

Large scope, cross-cutting product behavior, many touched files, or a desire for parallel work do not make a wide refactor. Use ordinary vertical slices whenever they can land green.

## Package Shape

1. **Expand**: add the new form beside the old one without breaking current behavior. Make the migration path explicit and verify both forms can coexist temporarily.
2. **Migrate**: move callers in batches sized by the actual blast radius, such as a package, directory, subsystem, or build unit. Each batch is blocked by Expand. Prefer batches that remain green and can be verified independently.
3. **Contract**: remove the old form after every migration batch is complete. Make this slice depend on all migration batches and verify that no old caller remains.

The temporary coexistence introduced by Expand must be removed by Contract inside the same package.

## Integration Exception

When migration batches cannot remain green independently:

- explain in the Package Contract why the blast radius makes independent green batches impossible;
- run the affected slices on one integration branch under the parent package claim;
- preserve the Expand, Migrate, and Contract dependency order;
- add a final integrate-and-verify slice blocked by Contract, and promise a green result only at that slice.

This exception changes the internal verification boundary, not the public claim unit. The parent package owner remains responsible for integration and final verification.

## Relationships

Publish containment and dependency edges through the configured backend. Do not repeat parent or blocked-by fields in child bodies.
