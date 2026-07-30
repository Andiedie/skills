#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
adr="$repo_root/skills/ai-native-development/docs/adr/0002-stage-repository-knowledge-through-delivery.md"
interview="$repo_root/skills/ai-native-development/and-interview-contract/SKILL.md"
clarify="$repo_root/skills/ai-native-development/and-clarify/SKILL.md"
wayfind="$repo_root/skills/ai-native-development/and-wayfind/SKILL.md"
pack="$repo_root/skills/ai-native-development/and-pack/SKILL.md"
implement="$repo_root/skills/ai-native-development/and-implement/SKILL.md"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

require_text() {
  local file="$1"
  local text="$2"
  local message="$3"
  grep -Fq "$text" "$file" || fail "$message"
}

reject_text() {
  local file="$1"
  local text="$2"
  local message="$3"
  if grep -Fq "$text" "$file"; then
    fail "$message"
  fi
}

[[ -f "$adr" ]] || fail "repository knowledge ADR is missing"
require_text "$repo_root/CONTEXT.md" '**Repository knowledge disposition**:' \
  "canonical disposition term is missing"
require_text "$repo_root/CONTEXT.md" 'Its absence means unclassified, not `None`.' \
  "missing disposition is still ambiguous"
require_text "$adr" 'Status: Accepted' "repository knowledge ADR is not accepted"
require_text "$repo_root/skills/ai-native-development/docs/delivery-loop.md" \
  '0002-stage-repository-knowledge-through-delivery.md' \
  "delivery loop does not link the repository knowledge ADR"

require_text "$interview" 'Repository knowledge disposition: Required' \
  "interview output lacks the Required form"
require_text "$interview" 'Repository knowledge disposition: None — <authority-test reason>' \
  "interview output lacks the reasoned None form"
require_text "$interview" 'Return exactly one disposition' \
  "completed results do not require exactly one disposition"
require_text "$interview" 'A Required disposition contains one or more items; Required and None are mutually exclusive.' \
  "Required and None cardinality is ambiguous"
require_text "$interview" '## Repository knowledge disposition' \
  "interview checkpoint does not cover the disposition"
require_text "$interview" 'A result containing only an unresolved blocker remains unclassified.' \
  "blocker-only results can still fabricate None"
reject_text "$interview" 'return no repository update' \
  "interview still represents no-doc by omission"
reject_text "$interview" 'Leave absent categories out of the result' \
  "interview still omits the completed disposition"

require_text "$clarify" 'Repository knowledge disposition:' \
  "Clarification Notes lack a disposition"
require_text "$clarify" 'from and-interview-contract' \
  "Clarify duplicates or loses the shared disposition contract"
require_text "$wayfind" 'Repository knowledge disposition:' \
  "Wayfinding results lack a disposition"
require_text "$wayfind" 'from and-interview-contract' \
  "Wayfind duplicates or loses the shared disposition contract"

publication="$(
  sed -n '/## Investigation Publication Receipt/,/## Investigation Resolution Receipt/p' "$wayfind"
)"
if grep -Fq 'Repository knowledge disposition:' <<<"$publication"; then
  fail "initial investigation publication incorrectly carries a disposition"
fi

require_text "$pack" 'source permalink' \
  "Pack does not retain the disposition source"
require_text "$pack" 'Required items are cumulative across sources; None does not cancel them.' \
  "Pack can still lose Required items during aggregation"
require_text "$pack" 'missing, conflicting, or stale disposition' \
  "Pack lacks the disposition route-back"
require_text "$pack" 'blocks publication and routes back' \
  "invalid dispositions can still become ready"
require_text "$pack" 'A confirmed path-only relocation may update the target when meaning stays unchanged.' \
  "Pack lacks the mechanical target-relocation exception"
require_text "$pack" 'Completed historical records keep their existing form.' \
  "completed historical results can still be backfilled"
require_text "$pack" 'A still-open historical source may be mechanically promoted' \
  "historical promotion is not limited to open work"
require_text "$pack" 'the child inherits the parent item and source unchanged' \
  "a PRD child can still redefine its documentation contribution"

require_text "$implement" 'source, target, and reviewed diff evidence' \
  "Implement lacks per-item documentation evidence"
require_text "$implement" 'Spec review checks each documentation item against its source, Package entry, and diff.' \
  "Spec review lacks per-item documentation evidence"
require_text "$implement" 'new durable repository knowledge' \
  "Implement lacks the new-knowledge route-back"
require_text "$implement" 'Before applying a Required item, re-read its target authority.' \
  "Implement can apply documentation against stale authority"
require_text "$implement" 'Integrate compatible edits on the latest baseline' \
  "compatible concurrent edits lack revalidation"
reject_text "$implement" '<updated, not required, or pending>' \
  "Implementation receipt still accepts generic documentation evidence"

require_text "$adr" 'global pending-decision index, lock, knowledge Issue, or local numbering' \
  "ADR does not reject coordination machinery"
require_text "$adr" 'A compatibility layer would assign invented meaning' \
  "ADR does not reject historical compatibility semantics"
require_text "$adr" 'Historical Issues can preserve context but are not the long-term project authority.' \
  "ADR permits a second project knowledge authority"
require_text "$adr" 'historical omission remains unclassified' \
  "forward-only migration is missing"

echo "repository knowledge disposition contract: passed"
