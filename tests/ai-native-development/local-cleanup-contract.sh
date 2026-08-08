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

grep -Fq 'When no worktree-owned local resource remains for Finish, omit Cleanup entirely' "$authority" \
  || fail "optional Cleanup omission rule is missing"
grep -Fq 'An omitted Cleanup field requires no cleanup identity or access to any resource runtime' "$authority" \
  || fail "Cleanup omission still depends on a resource backend"
if rg -Fq 'Cleanup: none' "$authority"; then
  fail "legacy Cleanup none form remains in the shared authority"
fi
echo "local cleanup contract: omitted path passed"

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
grep -Fq 'The latest receipt is authoritative for local cleanup only when it contains exactly one full reviewed head and either no Cleanup field or one complete' "$authority" \
  || fail "latest Implementation selection does not allow an omitted Cleanup"
grep -Fq 'If a later authorized action leaves a new owned resource, publish one complete superseding Implementation receipt' "$authority" \
  || fail "later owned resources do not refresh the complete handoff"
grep -Fq 'An action that only uses pre-existing, shared, external, bind-mounted, or merely used resources' "$authority" \
  || fail "mere use incorrectly requires a Cleanup handoff"
grep -Fq 'When only cleanup state changes and the source head and Package Contract are unchanged' "$authority" \
  || fail "cleanup-only refresh does not preserve review evidence"
grep -Fq 'Finish performs no resource-runtime operation when Cleanup is omitted' "$authority" \
  || fail "Finish omission path still probes a runtime"
grep -Fq 'For `Cleanup: required`, it processes each item only when the current Docker context and daemon identity match' "$authority" \
  || fail "Finish required path lost runtime identity validation"
grep -Fq 'retained Compose files' "$authority" \
  || fail "Finish no longer validates retained Compose files before merge"

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
grep -Fq '<omit Cleanup when no owned local resource remains; include the required form only for surviving supported resources>' "$implement" \
  || fail "Implementation receipt still mandates a Cleanup handoff"
grep -Fq 'handoff-refresh rules in [local-cleanup.md](../and-workflow-contract/local-cleanup.md)' "$implement" \
  || fail "Implement cannot reach the handoff-refresh authority"
grep -Fq 'lifecycle completion, typed local cleanup, then Git cleanup' "$finish" \
  || fail "Finish cleanup order is not explicit"
grep -Fq 'When Cleanup is omitted, perform no resource-runtime operation' "$finish" \
  || fail "Finish does not skip cleanup for an omitted handoff"
grep -Fq 'For Cleanup `required`, re-read each item and apply only its shared type rules' "$finish" \
  || fail "Finish required path is not typed"
grep -Fq 'Deployment disposition and any local-cleanup handoff' "$delivery_units" \
  || fail "delivery handoff cannot recover local cleanup"

ask_andie="$repo_root/skills/ai-native-development/ask-andie/SKILL.md"
triage="$repo_root/skills/ai-native-development/and-triage/SKILL.md"
sweep="$repo_root/skills/ai-native-development/and-sweep/SKILL.md"
sweep_checks="$repo_root/skills/ai-native-development/and-workflow-contract/sweep-checks.md"
skills_guide="$repo_root/skills/ai-native-development/docs/skills.md"

grep -Fq 'missing, stale, or contradictory Deployment disposition' "$ask_andie" \
  || fail "Ask Andie cannot route an incomplete disposition"
grep -Fq 'missing, stale, or contradictory Deployment disposition' "$triage" \
  || fail "Triage cannot route an incomplete disposition"
grep -Fq 'Deployment disposition and any present `Cleanup: required` handoff' "$sweep" \
  || fail "Sweep does not audit disposition drift"
grep -Fq 'An Implementation receipt that omits Cleanup is the valid no-handoff path' "$sweep_checks" \
  || fail "Sweep treats omitted Cleanup as drift"
grep -Fq 'present `Cleanup: required` handoff' "$sweep_checks" \
  || fail "Sweep does not audit present required Cleanup"
grep -Fq 'implementation artifacts, the Deployment disposition or present Cleanup handoff, or lifecycle outcomes may have drifted' "$skills_guide" \
  || fail "Skill guide does not route Cleanup handoff drift to Sweep"

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
