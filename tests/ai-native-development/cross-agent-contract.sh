#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
and_root="$repo_root/skills/ai-native-development"
interview="$and_root/and-interview-contract/SKILL.md"
setup="$and_root/setup-and/SKILL.md"

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

expected_policy_metadata="$(printf '%s\n' \
  'skills/ai-native-development/and-claim/agents/openai.yaml' \
  'skills/ai-native-development/and-clarify/agents/openai.yaml' \
  'skills/ai-native-development/and-finish/agents/openai.yaml' \
  'skills/ai-native-development/and-implement/agents/openai.yaml' \
  'skills/ai-native-development/and-intake/agents/openai.yaml' \
  'skills/ai-native-development/and-pack/agents/openai.yaml' \
  'skills/ai-native-development/and-pick/agents/openai.yaml' \
  'skills/ai-native-development/and-sweep/agents/openai.yaml' \
  'skills/ai-native-development/and-triage/agents/openai.yaml' \
  'skills/ai-native-development/and-wayfind/agents/openai.yaml' \
  'skills/ai-native-development/ask-andie/agents/openai.yaml' \
  'skills/ai-native-development/setup-and/agents/openai.yaml')"
actual_policy_metadata="$(
  find "$and_root" -path '*/agents/openai.yaml' -type f -print \
    | xargs grep -lF 'allow_implicit_invocation: false' \
    | sed "s|^$repo_root/||" \
    | LC_ALL=C sort
)"

[[ "$actual_policy_metadata" == "$expected_policy_metadata" ]] \
  || fail "OpenAI invocation policy must exist for exactly the 12 user-invoked AND skills"

while IFS= read -r relative_path; do
  cmp -s "$repo_root/$relative_path" <(printf '%s\n' \
    'policy:' \
    '  allow_implicit_invocation: false') \
    || fail "$relative_path must contain only the explicit-invocation policy"
done <<<"$expected_policy_metadata"

cmp -s "$repo_root/CLAUDE.md" <(printf '%s\n' '@AGENTS.md') \
  || fail "root CLAUDE.md must be a thin AGENTS.md adapter"
cmp -s "$and_root/CLAUDE.md" <(printf '%s\n' '@AGENTS.md') \
  || fail "AND CLAUDE.md must be a thin AGENTS.md adapter"

require_text "$interview" '`grilling` owns question cadence.' \
  "grilling must remain the sole cadence authority"
require_text "$interview" 'one or multiple unresolved inputs' \
  "interview recovery must preserve one or multiple unresolved inputs"
require_text "$interview" '## Current unresolved inputs' \
  "recovery buffer must use a cadence-neutral unresolved-input section"
reject_text "$interview" 'The one-question waits required by `grilling`' \
  "interview contract still copies one-question cadence"
reject_text "$interview" '## Current unresolved question' \
  "recovery buffer still assumes exactly one unresolved question"

require_text "$setup" '## Environment Availability' \
  "setup must report external skills as availability"
require_text "$setup" 'Availability proves discovery only; it does not establish version or semantic compatibility.' \
  "setup does not state the availability boundary"
reject_text "$setup" '## Environment Readiness' \
  "setup still names external skill discovery as readiness"
reject_text "$setup" 'Environment readiness:' \
  "setup receipt still reports environment readiness"
reject_text "$setup" 'Full readiness:' \
  "setup receipt still implies a compatibility-bearing full readiness state"

echo "cross-Agent contract: passed"
