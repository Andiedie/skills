#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
pack="$repo_root/skills/ai-native-development/and-pack/SKILL.md"
implement="$repo_root/skills/ai-native-development/and-implement/SKILL.md"
finish="$repo_root/skills/ai-native-development/and-finish/SKILL.md"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

require_regex() {
  grep -Eiq -- "$2" <<<"$1" || fail "$3"
}

reject_regex() {
  if grep -Eiq -- "$2" <<<"$1"; then
    fail "$3"
  fi
}

pack_rules="$(sed -n '/^## Contract Standard/,/^## Process/p' "$pack")"
pack_template="$(sed -n '/^### Package Contract/,/^### PRD Child Slice/p' "$pack")"
plan_template="$(sed -n '/^- Verification Plan (record-only):/,/^- Prior art:/p' <<<"$pack_template")"
implement_step="$(sed -n '/^3\. \*\*Implement the contract\.\*\*/,/^4\. \*\*Review the complete diff\.\*\*/p' "$implement")"
finish_step="$(sed -n '/^5\. \*\*Revalidate the final head\.\*\*/,/^6\. \*\*Merge exactly once\.\*\*/p' "$finish")"

require_regex "$plan_template" 'Verification Plan.*record-only' \
  "Pack template has no record-only Verification Plan"
require_regex "$plan_template" 'Risk / highest-practical-seam rationale:' \
  "Pack template does not connect risk to the verification seam"
require_regex "$plan_template" 'Selected evidence and risk/failure coverage:' \
  "Pack template does not connect evidence to coverage"
require_regex "$plan_template" 'Sufficiency rationale:' \
  "Pack template does not record sufficiency"
require_regex "$plan_template" 'Known caveats' \
  "Pack template does not record caveats"
reject_regex "$plan_template" 'Verification (class|tier)|Risk score|Validator|Metrics' \
  "Pack template introduces a classification or enforcement field"

require_regex "$pack_rules" 'bounded low-risk.*focused executable evidence' \
  "Pack does not allow focused evidence for bounded low-risk work"
require_regex "$pack_rules" '(runtime|data).*(integration|broad-suite|real-protocol|environment)' \
  "Pack does not select relevant broad or real evidence for higher-risk work"
require_regex "$pack_rules" 'stable check or workflow identity' \
  "Pack does not retain a stable CI identity"

require_regex "$implement_step" 'selected local evidence.*before.*Implementation receipt' \
  "Implement does not finish local evidence before its receipt"
require_regex "$implement_step" 'additional risk.*strengthen.*actual evidence.*material deviations.*Verification' \
  "Implement does not record strengthened evidence and deviations"
require_regex "$implement_step" 'omit or substitute.*recorded reason.*equivalent risk or failure coverage.*and-pack' \
  "Implement permits reductions without equivalent coverage"
require_regex "$implement_step" 'Time cost or a failing check.*does not authorize reduced coverage.*baseline flake.*substitution.*waiver' \
  "Implement permits downgrade for cost, failure, or a baseline flake"

require_regex "$finish_step" 'stable CI.*final pull-request head.*before merge' \
  "Finish does not bind selected CI to the final head"

echo "verification-plan contract: passed"
