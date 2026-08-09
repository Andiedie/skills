#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
and_root="$repo_root/skills/ai-native-development"
authority="$and_root/and-workflow-contract/acceptance-gate.md"
kernel="$and_root/and-workflow-contract/SKILL.md"
pack="$and_root/and-pack/SKILL.md"
implement="$and_root/and-implement/SKILL.md"
finish="$and_root/and-finish/SKILL.md"
ask_andie="$and_root/ask-andie/SKILL.md"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

require_literal() {
  grep -Fq "$2" <<<"$1" || fail "$3"
}

reject_literal() {
  ! grep -Fq "$2" <<<"$1" || fail "$3"
}

section() {
  sed -n "/^$2$/,/^$3$/p" "$1"
}

[[ -f "$authority" ]] || fail "acceptance gate authority is missing"
authority_text="$(<"$authority")"
kernel_text="$(<"$kernel")"
declaration="$(section "$authority" '## Omission and declaration' '## Public Acceptance receipt')"
receipt="$(section "$authority" '## Public Acceptance receipt' '## Binding and freshness')"
binding="$(section "$authority" '## Binding and freshness' '## Latest-only selection')"
selection="$(section "$authority" '## Latest-only selection' '## Boundary consumption and recovery')"
pack_template="$(section "$pack" '### Package Contract' '### PRD Child Slice')"
implement_step6="$(section "$implement" '6\. \*\*Record the handoff\.\*\*' '## Implementation Receipt')"
finish_step5="$(section "$finish" '5\. \*\*Revalidate the final head\.\*\*' '6\. \*\*Merge exactly once\.\*\*')"
finish_step7="$(section "$finish" '7\. \*\*Complete workflow state\.\*\*' '8\. \*\*Clean typed local resources\.\*\*')"

require_literal "$kernel_text" '| Read or Validate Acceptance Gate | [acceptance-gate.md](acceptance-gate.md). |' "kernel does not locate the shared operation"
require_literal "$pack_template" '<when required, add the shared Acceptance Gate declaration; omit this section otherwise>' "Pack template does not keep the gate optional"
! grep -Fxq '## Acceptance Gate' <<<"$pack_template" || fail "Pack template makes the gate mandatory"

for field in 'Timing:' 'Owner:' 'Binding kind:' 'Evidence expectation:'; do
  require_literal "$declaration" "$field" "declaration is missing $field"
done
require_literal "$declaration" '| pre-merge | merge | source-head or artifact |' "pre-merge contract row is missing"
require_literal "$declaration" '| post-merge | source completion | artifact |' "post-merge contract row is missing"
require_literal "$declaration" 'current reviewed PR/head' "pre-merge boundary evidence is missing"
require_literal "$declaration" 'merged PR plus exact merge commit; receipt `created_at >= merged_at`' "post-merge boundary evidence is missing"
reject_literal "$declaration" 'Blocking target:' "declaration stores a redundant blocking target"

for field in 'Owner:' 'Timing:' 'Binding:' 'Boundary evidence:' 'Result: <accepted|rejected>' 'Evidence:' 'Side effects:'; do
  require_literal "$receipt" "$field" "receipt is missing $field"
done
require_literal "$receipt" 'comment author' "GitHub owner proof is missing"
require_literal "$receipt" 'durably identifiable through `Evidence`' "external authority proof is missing"
require_literal "$receipt" 'Side effects: none' "direct no-side-effect path is missing"
require_literal "$receipt" 'produced after the Acceptance comment' "side-effect refresh freshness is missing"
reject_literal "$receipt" 'Blocking target:' "receipt stores a redundant blocking target"

require_literal "$binding" 'full 40-character hexadecimal SHA' "source-head freshness is missing"
require_literal "$binding" 'one immutable identity' "artifact freshness is missing"
require_literal "$binding" 'Unrelated repository or environment activity does not' "artifact invalidation is too broad"
require_literal "$binding" 'stale an artifact receipt' "artifact invalidation rule is incomplete"
require_literal "$selection" 'newest comment whose heading is exactly `## Acceptance`' "latest receipt selection is missing"
require_literal "$selection" 'no older accepted comment is eligible as fallback' "latest-only failure is missing"
require_literal "$selection" 'Pending waits for the declared `Owner`' "pending has no owning action"

require_literal "$declaration" 'repair orchestration remains out of scope' "repair orchestration boundary is missing"
reject_literal "$authority_text" 'Acceptance repair:' "authority contains repair orchestration state"
require_literal "$(<"$implement")" 'acceptance-gate.md' "Implement does not load the authority"
require_literal "$implement_step6" 'current Implementation receipt is written and read back' "pre-merge handoff precedes the reviewed receipt"
require_literal "$finish_step5" 'Validate Acceptance Gate' "Finish does not call the shared operation before merge"
require_literal "$finish_step7" 'Validate Acceptance Gate' "Finish does not call the shared operation before completion"
require_literal "$(<"$ask_andie")" 'acceptance-gate.md' "Ask Andie cannot load the authority"
require_literal "$(<"$ask_andie")" '| Post-merge acceptance reports a source defect | `and-intake`' "Ask Andie exposes the wrong defect route"

echo "acceptance-gate contract: passed"
