#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
and_root="$repo_root/skills/ai-native-development"
authority="$and_root/and-workflow-contract/deployment-handoff.md"
finish="$and_root/and-finish/SKILL.md"
delivery_loop="$and_root/docs/delivery-loop.md"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

require_text() {
  local haystack="$1"
  local needle="$2"
  local message="$3"
  grep -Fq -- "$needle" <<<"$haystack" || fail "$message"
}

require_regex() {
  local haystack="$1"
  local pattern="$2"
  local message="$3"
  grep -Eq -- "$pattern" <<<"$haystack" || fail "$message"
}

reject_text() {
  local haystack="$1"
  local needle="$2"
  local message="$3"
  ! grep -Fq -- "$needle" <<<"$haystack" || fail "$message"
}

[[ -f "$authority" ]] || fail "deployment handoff authority is missing"
[[ -f "$finish" ]] || fail "Finish skill is missing"
[[ -f "$delivery_loop" ]] || fail "delivery loop document is missing"

followup="$(sed -n '/^## Deferred Finish follow-up$/,$p' "$authority")"
[[ -n "$followup" ]] || fail "shared deferred Finish follow-up authority is missing"
runtime_contracts="$(sed -n '/^## Runtime Contracts$/,/^## Preconditions$/p' "$finish")"
finish_step7="$(sed -n '/^7\. \*\*Complete workflow state\.\*\*$/,/^8\. \*\*Clean typed local resources\.\*\*$/p' "$finish")"
finish_step10="$(sed -n '/^10\. \*\*Report the result\.\*\*$/,/^## Completion Receipt$/p' "$finish")"
completion_receipt="$(sed -n '/^## Completion Receipt$/,/^## Boundaries$/p' "$finish")"
delivery_reader="$(sed -n '/^## Feedback And Completion$/,/^## Continue Reading$/p' "$delivery_loop")"

require_regex "$followup" 'concrete piece of work.*continue after source Finish.*still incomplete' \
  "positive deferred branch does not bind concrete, deferred, and unfinished work"
require_regex "$followup" 'Deployment: none.*no confirmed delay.*work completed within the current process do not create an Issue' \
  "no-work/no-delay conditions are not bound to the no-Issue outcome"
require_regex "$followup" 'standard.*custom.*alone never does' \
  "standard/custom classification can still auto-trigger"
require_regex "$followup" 'ordinary `needs-triage` Issue' \
  "zero-match branch does not name the ordinary queue"
require_regex "$followup" 'free text.*not a second workflow contract' \
  "free-text follow-up still implies a fixed schema"
require_regex "$followup" 'normal delivery loop.*not a second workflow contract' \
  "follow-up still implies a new lifecycle"
require_text "$followup" 'Completion or handoff evidence' "follow-up does not use existing completion/handoff evidence"
require_text "$followup" 'Issue URL/text cross-reference' "follow-up link is not a textual URL cross-reference"
require_text "$followup" 'not a native relationship' "follow-up link is not bounded away from native relationships"

require_text "$runtime_contracts" 'Read Work Record' "Finish cannot read follow-up Issues"
require_text "$runtime_contracts" 'Write Work Record' "Finish cannot create follow-up Issues"
reject_text "$runtime_contracts" 'Write Relationships' "Finish loads native relationship mutation"
reject_text "$runtime_contracts" 'relationship-api' "Finish loads relationship API for a textual link"
require_text "$finish_step7" 'Deferred Finish follow-up' "Finish lacks the shared trigger/action pointer"
require_text "$finish_step7" 'deployment-handoff.md' "Finish pointer does not name shared authority"
reject_text "$finish_step7" '## Deferred Finish follow-up' "Finish duplicates shared authority"
require_text "$finish_step10" 'selected deferred follow-up Issue' "Finish report omits selected follow-up Issue"
require_text "$completion_receipt" 'Deployment handoff:' "Completion Receipt lost existing deployment line"
require_text "$completion_receipt" 'follow-up Issue URL' "Completion Receipt does not extend existing handoff line"
reject_text "$completion_receipt" 'Deferred Finish:' "Completion Receipt adds a new receipt field"
require_text "$delivery_reader" 'deferred-finish-follow-up' "delivery reader lacks authority link"
reject_text "$delivery_reader" 'needs-triage' "delivery reader copies queue mechanics"

echo "deferred-followup contract: passed"
