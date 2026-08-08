#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
and_root="$repo_root/skills/ai-native-development"
wayfind="$and_root/and-wayfind/SKILL.md"
interview="$and_root/and-interview-contract/SKILL.md"
pack="$and_root/and-pack/SKILL.md"
kernel="$and_root/and-workflow-contract/SKILL.md"
wayfinding="$and_root/and-workflow-contract/wayfinding.md"
delivery_units="$and_root/and-workflow-contract/delivery-units.md"
sweep_checks="$and_root/and-workflow-contract/sweep-checks.md"
local_cleanup_contract="$repo_root/tests/ai-native-development/local-cleanup-contract.sh"
context="$repo_root/CONTEXT.md"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

require_text() {
  local file="$1"
  local value="$2"
  local message="$3"
  grep -Fq "$value" "$file" || fail "$message"
}

reject_text() {
  local file="$1"
  local value="$2"
  local message="$3"
  if grep -Fq "$value" "$file"; then
    fail "$message"
  fi
}

require_section_text() {
  local value="$1"
  local expected="$2"
  local message="$3"
  grep -Fq "$expected" <<<"$value" || fail "$message"
}

resolution_template="$(
  sed -n '/## Investigation Resolution Receipt/,/The disposition begins/p' "$wayfind"
)"
pack_gate="$(
  sed -n '/2\. \*\*Resolve blockers/,/3\. \*\*Write the contract/p' "$pack"
)"
pack_contract="$(
  sed -n '/3\. \*\*Write the contract/,/4\. \*\*Publish safely/p' "$pack"
)"
handoff_template="$(
  sed -n '/### Map Handoff Receipt/,/## Boundary/p' "$pack"
)"

require_text "$wayfind" 'Research assets live in a dedicated investigation branch/worktree and use `cleanup` or `promote-to-package` disposition.' \
  "Wayfinding no longer preserves the Research asset lifecycle"
require_text "$wayfind" 'Prototype artifacts remain primary sources on a dedicated branch outside main.' \
  "Wayfinding does not retain Prototype primary sources"
require_text "$wayfind" 'Resolution records the human reaction and a resolvable branch/ref context pointer.' \
  "Prototype resolution lacks its method-specific evidence"
require_section_text "$resolution_template" 'Research: <asset link with cleanup or Package-promotion disposition; omit for other methods>' \
  "Investigation Resolution lacks the Research evidence form"
require_section_text "$resolution_template" 'Prototype: <retained primary-source branch/ref context pointer; omit for other methods>' \
  "Investigation Resolution lacks the Prototype evidence form"
require_text "$wayfind" 'Apply eligibility, ownership, evidence, resolution, method-specific handling, and recovery separately to each investigation.' \
  "investigation settlement still assumes one universal asset lifecycle"
reject_text "$wayfind" 'Research and prototype assets live in a dedicated investigation branch/worktree.' \
  "Wayfinding still combines Research and Prototype asset lifecycles"
reject_text "$wayfind" 'Apply eligibility, ownership, evidence, resolution, asset disposition, and recovery separately to each investigation.' \
  "Wayfinding still applies asset disposition to every investigation"

require_text "$interview" 'one durable answer with method-required evidence' \
  "interview output still assumes one universal asset disposition"
require_text "$interview" 'method-owned handling remain linked evidence' \
  "interview boundary does not delegate asset handling to the method"
reject_text "$interview" 'one durable answer with required evidence and asset disposition' \
  "interview output still requires a generic asset disposition"
reject_text "$interview" 'An isolated investigation asset and its disposition remain linked evidence' \
  "interview boundary still owns a generic asset disposition"

require_section_text "$pack_gate" 'every linked Research asset has a cleanup or Package-promotion disposition' \
  "Pack does not validate Research disposition separately"
require_section_text "$pack_gate" 'every Prototype resolution has a retained primary-source branch/ref context pointer' \
  "Pack does not validate Prototype evidence separately"
require_section_text "$pack_contract" 'preserve every Prototype primary-source pointer in `Further Notes`' \
  "Pack does not carry Prototype context into the delivery issue"
require_section_text "$handoff_template" 'Research asset disposition: <none, promoted/cleaned list, or pending reason>' \
  "map handoff lacks Research disposition evidence"
require_section_text "$handoff_template" 'Prototype primary sources: <none, retained pointer list, or pending reason>' \
  "map handoff lacks retained Prototype pointers"
reject_text "$pack" 'every linked asset has a cleanup or Package-promotion disposition' \
  "Pack still applies Research disposition to every investigation asset"

require_text "$kernel" 'Its lifecycle is method-specific:' \
  "the shared Investigation asset concept is not method-specific"
require_text "$delivery_units" 'Retained Prototype primary sources stay outside main and remain linked from the delivery unit.' \
  "delivery units do not preserve Prototype context pointers"
require_text "$wayfinding" 'Resolve every temporary Research asset disposition and retain every Prototype primary-source pointer' \
  "Wayfinding handoff still treats all assets as temporary"

require_text "$sweep_checks" 'a linked Research asset without cleanup or Package-promotion disposition' \
  "Sweep no longer detects missing Research disposition"
require_text "$sweep_checks" 'a Prototype resolution with no resolvable primary-source branch/ref context pointer' \
  "Sweep does not detect missing Prototype evidence"
require_text "$sweep_checks" 'a Prototype resolution that assigns cleanup or Package promotion to its primary source' \
  "Sweep does not detect an invalid Prototype disposition"

require_text "$context" 'Its lifecycle is method-specific:' \
  "CONTEXT does not define method-specific investigation assets"
require_text "$context" 'a prototype remains a primary source on a dedicated branch outside main and stays reachable through a durable context pointer' \
  "CONTEXT does not preserve the Prototype primary source"

[[ -f "$local_cleanup_contract" ]] || fail "local cleanup contract test is missing"
bash "$local_cleanup_contract" >/dev/null \
  || fail "implementation local cleanup contract regressed"

if rg -q 'retain-primary-source' "$context" "$and_root"; then
  fail "a generic retain-primary-source disposition was introduced"
fi

echo "Prototype investigation asset contract: passed"
