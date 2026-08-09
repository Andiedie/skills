# Review Attestation

Load this reference when repository-owned `code-review` is called by an AND
implementation path with a delivery-unit identity and a complete Spec
authority set, or when `and-implement` or `and-finish` reads an attestation from
an Implementation receipt. Generic `code-review` calls without that context
keep their ordinary two-axis contract.

The machine behavior surface is the package-local executable
[review-attestation.sh](review-attestation.sh). It is a shared authority, not
a service or a second receipt selector. Callers load this reference for the
operation and pass data through the helper; they do not copy its schema or
status algorithm.

The helper runtime uses only Bash built-ins and an existing `shasum` or
`sha256sum` implementation. It introduces no parser, language runtime, or
service dependency. Its four commands fail closed:

- `digest` reads exact authority bytes from stdin, applies the Canonical digest
  rules below, and prints one lowercase SHA-256 digest. It requires an existing
  SHA-256 implementation and reports an error when none is available.
- `render` reads the tab-separated record protocol below, rejects malformed
  fields, authorities, or runtime identities, adds the immutable diff command
  and the same reviewed head to both axes, and prints the one compact v1 JSON
  object. The caller adds the receipt's fenced delimiters without changing
  those bytes.
- `extract` reads only the caller-selected latest Implementation comment body,
  finds exactly one `Review attestation:` followed immediately by one compact
  fenced JSON payload, validates the v1 shape, and prints the payload bytes
  unchanged. Exit 3 means the selected receipt has no block (`missing`); exit 4
  means a marker or payload exists but is duplicate or malformed (`malformed`).
- `validate` reads the tab-separated record protocol below. For a non-missing
  block, it trusts the producer's persisted receipt evidence for runtime
  issuance, checks structure first, then compares current values and emits
  machine-readable `{status,reasons,paired_review_clean}`.
  Every failed comparison appears in `reasons`. `paired_review_clean` depends
  only on independent identities and both axis results being `clean`, so a
  stale freshness status can still carry `paired_review_clean: true`; `Spec`
  `skipped` always sets it to false.

## Helper record protocol

Each input is UTF-8 text with one tab-separated record per line and no blank
lines. Every field except the `attestation` payload is a canonical safe field:
it contains no control character, quote, or backslash. Identities
use the runtime-issued labels supplied by dispatch; URLs, SHAs, result values,
and delivery-unit identities use the forms defined below. The `attestation`
field is the one deliberate exception: it is either the literal `absent` or
one compact, one-line v1 JSON block emitted by `render`.

`render` records are supplied in this shape (repeat `issued_reviewer` and
`authority`, then provide each axis once):

```
delivery_unit<TAB>github.com/<owner>/<repo>#<issue>
fixed_point<TAB><full lowercase SHA>
reviewed_head<TAB><full lowercase SHA>
parent_identity<TAB><runtime parent identity>
issued_reviewer<TAB><runtime-issued child identity>
authority<TAB><kind><TAB><canonical URL or immutable identity><TAB><64 lowercase digest>
axis<TAB>standards<TAB><runtime-issued child identity><TAB><full echoed reviewed-head SHA><TAB>clean|findings|failed
axis<TAB>spec<TAB><runtime-issued child identity><TAB><full echoed reviewed-head SHA><TAB>clean|findings|skipped|failed
```

`validate` records are supplied in this shape. The first record is
`attestation<TAB>absent` for a legacy/no-block receipt; that is reported as
`missing` before any current context is required. Otherwise the persisted
block carries the producer-issued axis identities, and the caller supplies
only the current values needed for freshness:

```
attestation<TAB><compact v1 JSON payload>
current_delivery_unit<TAB>github.com/<owner>/<repo>#<issue>
receipt_fixed_point<TAB><full lowercase SHA>
source_head<TAB><full lowercase SHA>
pr_head<TAB><full lowercase SHA>
current_authority<TAB><kind><TAB><canonical URL or immutable identity><TAB><64 lowercase digest>
```

The producer `render` operation requires live parent and issued-child records
and rejects duplicate, parent, or invented identities before emitting a block.
Later `validate` runs across sessions from the append-only receipt and does not
re-prove runtime issuance or reconstruct a dispatch set; it checks only the
block's axis identity shape, bindings, and current freshness records. The record
protocol is the sole machine input surface; callers pass records and do not
reproduce its parsers or status rules.

## One attestation block

`and-review-attestation/v1` is one JSON object embedded in the latest `## Implementation` receipt. It is implementation evidence, not workflow state,
an acceptance verdict, a finding ledger, a second review receipt, a selector,
an overlay, or a service. No review framework, database, GitHub Action, or new
runtime dependency is introduced. The complete block has this shape; no caller
may invent a second schema or copy these fields into a receipt wrapper:

```json
{
  "schema": "and-review-attestation/v1",
  "delivery_unit": "github.com/<owner>/<repo>#<issue>",
  "fixed_point": "<full commit SHA>",
  "reviewed_head": "<full commit SHA>",
  "diff_command": "git diff <full fixed-point SHA>...<full reviewed-head SHA>",
  "spec_authorities": [
    {
      "kind": "package-contract|acceptance-child|acceptance",
      "url": "<canonical GitHub URL or immutable authority identity>",
      "sha256": "<64 lowercase hexadecimal characters>"
    }
  ],
  "axes": {
    "standards": {
      "reviewer": "<runtime-issued child identity>",
      "head": "<full reviewed-head SHA>",
      "result": "clean|findings|failed"
    },
    "spec": {
      "reviewer": "<runtime-issued child identity>",
      "head": "<full reviewed-head SHA>",
      "result": "clean|findings|skipped|failed"
    }
  }
}
```

The object is emitted once with the final paired review. Both active axes bind
to the same `reviewed_head`. Each identity is the runtime-issued identity of
the isolated child that actually ran that axis; both identities must exist,
must differ, and must not be the parent actor or a fabricated label. A generic
Spec `skipped` result remains representable, but it is not a clean AND pair.
Axis result and freshness are separate: a fresh attestation may still report
`findings` or `failed`.

Each active child response echoes the frozen reviewed head and one axis result.
`clean` means the completed axis reported no findings, `findings` means it
reported one or more findings, and `failed` means the dispatched child did not
complete its review. Generic Spec `skipped` means the user explicitly confirmed
that no Spec exists; it cannot satisfy an AND paired-review requirement.

The receipt labels the block `Review attestation:` and embeds exactly one
fenced JSON block immediately after that label (` ```json ` … ` ``` `). The
payload bytes between those fences are authoritative; preserving the complete
fenced block byte-for-byte is the persistence check. The block does not predict
its own GitHub permalink. The Implementation comment node ID and permalink are
the receipt identity after publication.

## Freeze the review input

Before dispatching either reviewer, resolve the caller's fixed point and the
symbolic `HEAD` to full commit SHAs (`git rev-parse --verify <ref>^{commit}`).
Every recorded commit SHA is exactly 40 lowercase hexadecimal characters;
abbreviated or non-hex values are malformed.
Capture those exact values once and freeze:

```
git diff <full fixed-point SHA>...<full reviewed-head SHA>
```

Use that command, the same `reviewed_head`, and the same fixed point in both
prompts and in the block. A later move of symbolic `HEAD`, or any other source
change after dispatch, is a freshness change: aggregation reports stale
evidence and never relabels the result to the new head. A reviewer that does
not echo the frozen head cannot form a valid axis record.

## Spec authority set and Canonical digest

The AND caller supplies a non-empty, complete authority set to the Spec axis;
at minimum it contains the Package Contract, plus every acceptance-bearing PRD
child and each explicit acceptance authority required by that Package Contract.
An authority entry has
its canonical URL or immutable identity, one of `package-contract`,
`acceptance-child`, or `acceptance`, and one reproducible digest.

To compute a canonical SHA-256 authority digest, encode the exact authority content as UTF-8. Normalize `CRLF/CR → LF` (convert CRLF and CR to LF), remove any trailing LF bytes, and append exactly one LF (exactly one final LF). Do not trim spaces or alter internal blank lines.
Hash those bytes with SHA-256 and record 64 lowercase hexadecimal characters.
Order entries as Package Contract first,
acceptance children by numeric issue number, then explicit acceptance authorities by canonical identity.
For an explicit acceptance authority, the caller owns proving that a non-URL
identity is canonical and immutable; the helper enforces its safe record form
and canonical string ordering.
Membership, content, kind, URL, or ordering
changes make an old attestation stale even when the source head is unchanged.

## Implementation persistence and same-head reuse

`and-implement` embeds the generated JSON block byte-for-byte in the latest
`## Implementation` receipt. After writing the GitHub comment it reads the
comment node/permalink back and compares the exact block bytes and the recorded
reviewed head; a mismatch is a failed persistence check, not permission to
rewrite the evidence. It never manually transcribes or reconstructs fields and
never publishes a separate Review receipt.

A same-head superseding Implementation receipt may reuse the exact block only when the
reviewed head, fixed point, complete ordered authority set and both reviewer
axis records are unchanged. A changed head, fixed point, authority content,
authority membership, or reviewer evidence requires a new paired review before
fresh evidence can be valid. This permits cleanup-only or other same-head
receipt refreshes without changing review evidence.

## Finish shadow validation

`and-finish` selects only the block in the latest `## Implementation` receipt;
it never falls back to an older attestation. Immediately before merge it
freshly reads the source and pull-request heads and the complete current Spec
authority set, then compares them with the block. Freshness also compares the
attested `delivery_unit` with the receipt's delivery-unit identity and the
attested `fixed_point` with the receipt wrapper's Fixed point. A well-formed
block whose delivery unit, receipt Fixed point, source/PR head, or authority
comparison differs is `stale`; a malformed field is `malformed`. It reports
exactly one status from `valid`, `stale`, `malformed`, or `missing`:

- `valid` — the schema, delivery unit, full SHAs, immutable diff, complete
  authority set and digests, identity independence, axis heads, and axis
  results are internally coherent and every current comparison matches;
- `stale` — the block is well formed but a source/PR head, fixed point, or
  authority content or membership comparison differs;
- `malformed` — required fields or authorities are missing, a SHA/diff/digest
  is malformed, axis identities are absent or duplicated, or axis bindings
  contradict the block;
- `missing` — the latest Implementation receipt has no block, including a
  legacy receipt.

The report names every failed comparison precisely (for example, `reviewed_head`
expected `<attested>` but source head is `<current>`, or authority `<url>` has
digest `<attested>` versus `<current>`). v1 is shadow-only: the status and
reasons are visible evidence but, by themselves, do not block, authorize,
reroute, change an existing review verdict, alter acceptance/deployment/
cleanup/lifecycle gates, or rewrite history. A legacy `missing` result is
observable and non-blocking.
