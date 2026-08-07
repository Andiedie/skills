#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
wayfind="$repo_root/skills/ai-native-development/and-wayfind/SKILL.md"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

require_text() {
  local value="$1"
  local message="$2"
  grep -Fq "$value" "$wayfind" || fail "$message"
}

reject_text() {
  local pattern="$1"
  local message="$2"
  if rg -q "$pattern" "$wayfind"; then
    fail "$message"
  fi
}

require_text 'Only independent Research investigations may be selected together.' \
  "parallel selection is not limited to independent research investigations"
require_text 'The Agent chooses a mechanism suited to the current environment; subagents are optional execution capacity, not an AND dependency.' \
  "parallel research is tied to an environment-specific mechanism"
require_text 'Apply eligibility, ownership, evidence, resolution, asset disposition, and recovery separately to each investigation.' \
  "parallel research can mix investigation settlement"
require_text 'A failure or interruption in one investigation does not invalidate completed work from another.' \
  "partial failure does not preserve completed research"
require_text 'Serial research remains valid when parallel execution is unavailable or not useful.' \
  "Wayfinding incorrectly requires parallel capability"

reject_text 'spawn_agent|subagent API|slot scheduling|fixed (parallelism|concurrency)|concurrency threshold' \
  "Wayfinding encodes a scheduler or runtime-specific subagent protocol"

echo "parallel research contract: passed"
