#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
authority="$repo_root/skills/ai-native-development/and-workflow-contract/local-cleanup.md"
old_authority="$repo_root/skills/ai-native-development/and-workflow-contract/cleanup-handoff.md"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

[[ -f "$authority" ]] || fail "local cleanup authority is missing"
[[ ! -e "$old_authority" ]] || fail "Docker-global cleanup authority still exists"

grep -Fq 'Cleanup: none — no worktree-owned local resources remain' "$authority" \
  || fail "backend-neutral Cleanup none form is missing"
grep -Fq 'does not require a cleanup identity or access to any resource runtime' "$authority" \
  || fail "Cleanup none still depends on a resource backend"

echo "local cleanup contract: none path passed"

grep -Fq 'Cleanup: required — see typed cleanup items below' "$authority" \
  || fail "typed Cleanup required form is missing"
grep -Fq 'docker-compose: runtime=<Docker context and daemon identity>; project=<exact project>; files=<exact Compose files>' "$authority" \
  || fail "Docker Compose cleanup item is incomplete"
grep -Fq 'docker-label: runtime=<Docker context and daemon identity>; selector=<exact AND cleanup label>' "$authority" \
  || fail "Docker label cleanup item is incomplete"
grep -Fq 'container, network, named volume, and anonymous volume' "$authority" \
  || fail "Docker cleanup does not cover every owned object kind"
grep -Fq 'pre-existing, shared, external, bind-mounted, or merely used' "$authority" \
  || fail "protected Docker resources are not explicit"
grep -Fq 'never stores or executes an arbitrary cleanup command' "$authority" \
  || fail "typed cleanup can fall back to arbitrary commands"
grep -Fq 'lifecycle completion is authoritative' "$authority" \
  || fail "local cleanup is not ordered after lifecycle completion"
grep -Fq 'retain the source worktree and branches' "$authority" \
  || fail "cleanup failure can discard recovery artifacts"

echo "local cleanup contract: required Docker path passed"

kernel="$repo_root/skills/ai-native-development/and-workflow-contract/SKILL.md"
delivery_units="$repo_root/skills/ai-native-development/and-workflow-contract/delivery-units.md"
implement="$repo_root/skills/ai-native-development/and-implement/SKILL.md"
finish="$repo_root/skills/ai-native-development/and-finish/SKILL.md"

grep -Fq '[local-cleanup.md](local-cleanup.md)' "$kernel" \
  || fail "workflow operation cannot reach local cleanup authority"
grep -Fq '[local-cleanup.md](../and-workflow-contract/local-cleanup.md)' "$implement" \
  || fail "Implement cannot reach local cleanup authority"
grep -Fq '[local-cleanup.md](../and-workflow-contract/local-cleanup.md)' "$finish" \
  || fail "Finish cannot reach local cleanup authority"
grep -Fq 'Cleanup: <complete form from local-cleanup.md>' "$implement" \
  || fail "Implementation receipt lacks generic Cleanup disposition"
grep -Fq 'lifecycle completion, typed local cleanup, then Git cleanup' "$finish" \
  || fail "Finish cleanup order is not explicit"
grep -Fq 'deployment and local-cleanup handoffs' "$delivery_units" \
  || fail "delivery handoff cannot recover local cleanup"

ask_andie="$repo_root/skills/ai-native-development/ask-andie/SKILL.md"
triage="$repo_root/skills/ai-native-development/and-triage/SKILL.md"
sweep="$repo_root/skills/ai-native-development/and-sweep/SKILL.md"
sweep_checks="$repo_root/skills/ai-native-development/and-workflow-contract/sweep-checks.md"
skills_guide="$repo_root/skills/ai-native-development/docs/skills.md"

grep -Fq 'missing, stale, or contradictory Deployment or Cleanup disposition' "$ask_andie" \
  || fail "Ask Andie cannot route an incomplete disposition"
grep -Fq 'missing, stale, or contradictory Deployment or Cleanup disposition' "$triage" \
  || fail "Triage cannot route an incomplete disposition"
grep -Fq 'Deployment and Cleanup dispositions' "$sweep" \
  || fail "Sweep does not audit disposition drift"
grep -Fq 'implementation artifacts, Deployment and Cleanup dispositions, or lifecycle outcomes may have drifted' "$skills_guide" \
  || fail "Skill guide does not route Cleanup disposition drift to Sweep"

for router in "$ask_andie" "$triage" "$sweep" "$sweep_checks"; do
  if rg -q 'cleanup-handoff|local-cleanup|Worktree Cleanup|Cleanup Manifest|cleanup selector|docker-compose|docker-label' "$router"; then
    fail "cleanup backend schema leaked into $(basename "$(dirname "$router")")/$(basename "$router")"
  fi
done

for stale_file in \
  "$repo_root/tests/ai-native-development/cleanup-handoff-contract.sh" \
  "$repo_root/tests/ai-native-development/cleanup-handoff-live.sh" \
  "$repo_root/tests/ai-native-development/fixtures/cleanup-handoff-compose.yaml"; do
  [[ ! -e "$stale_file" ]] || fail "superseded cleanup harness remains: $stale_file"
done

if rg -q 'Cleanup key|Worktree Cleanup Manifest|Worktree Cleanup receipt|Protected Resources' \
  "$repo_root/CONTEXT.md" \
  "$repo_root/skills/ai-native-development" \
  -g '*.md'; then
  fail "superseded Docker-global schema remains"
fi
if rg -q 'reviewed-head handoff' \
  "$repo_root/skills/ai-native-development" \
  -g '*.md'; then
  fail "undefined cleanup handoff umbrella term remains"
fi

echo "local cleanup contract: authority and caller scope passed"
