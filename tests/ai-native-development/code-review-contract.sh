#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
and_root="$repo_root/skills/ai-native-development"
review="$and_root/code-review/SKILL.md"
metadata="$and_root/code-review/agents/openai.yaml"
manifest="$repo_root/skills.sh.json"
implement="$and_root/and-implement/SKILL.md"
setup_skill="$and_root/setup-and/SKILL.md"
guide="$and_root/docs/skills.md"
package_readme="$and_root/README.md"
package_agents="$and_root/AGENTS.md"
readme="$repo_root/README.md"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

require_text() {
  grep -Fq -- "$2" "$1" || fail "$1 is missing required text: $2"
}

require_regex() {
  grep -Eq -- "$2" "$1" || fail "$1 does not match required pattern: $2"
}

reject_text() {
  if grep -Fq -- "$2" "$1"; then
    fail "$1 contains prohibited text: $2"
  fi
}

reject_regex() {
  if grep -Eq -- "$2" "$1"; then
    fail "$1 matches prohibited pattern: $2"
  fi
}

[[ -f "$review" ]] || fail "repository-owned code-review skill is missing"
[[ -f "$metadata" ]] || fail "code-review OpenAI metadata is missing"

require_text "$review" 'name: code-review'
require_text "$review" 'Use when the user wants to review a branch, a PR, work-in-progress changes, or asks to "review since X".'
require_text "$metadata" 'display_name: "Code Review"'
require_text "$metadata" 'short_description: "Review a diff on standards and spec"'
reject_text "$metadata" 'allow_implicit_invocation: false'

jq -e '
  [.groupings[] | select(.title == "AI-Native Development") | .skills[] | select(. == "code-review")]
  | length == 1
' "$manifest" >/dev/null || fail "manifest must expose exactly one code-review skill"

require_text "$review" 'git rev-parse <fixed-point>'
require_text "$review" 'git diff <fixed-point>...HEAD'
require_text "$review" 'git log <fixed-point>..HEAD --oneline'
require_regex "$review" 'invalid fixed point|bad ref'

require_text "$review" 'Only skip the Spec axis after the user explicitly confirms that no Spec exists.'
require_text "$review" '1. Spec contents or a path supplied explicitly by the caller.'
require_text "$review" '2. Issue references in the commit messages'
require_text "$review" '3. A spec file under `docs/`, `specs/`, or `.scratch/`'
reject_text "$review" 'Package Contract'
reject_text "$review" 'PRD child'
require_text "$review" '## Standards'
require_text "$review" '## Spec'

for smell in \
  'Mysterious Name' \
  'Duplicated Code' \
  'Feature Envy' \
  'Data Clumps' \
  'Primitive Obsession' \
  'Repeated Switches' \
  'Shotgun Surgery' \
  'Divergent Change' \
  'Speculative Generality' \
  'Message Chains' \
  'Middle Man' \
  'Refused Bequest'; do
  require_text "$review" "**$smell**"
done
require_regex "$review" 'A documented repo(sitory)? standard always wins'
require_text "$review" 'judgement call'
require_regex "$review" '[Ss]kip anything tooling already enforces'

require_text "$review" 'independent review sub-agents concurrently'
require_text "$review" 'Do not fall back to sequential review.'
require_regex "$review" 'Do (\*\*)?not(\*\*)? merge or rerank findings'
reject_text "$review" '`setup-and`'
reject_text "$review" '`setup-matt-pocock-skills`'
reject_text "$review" 'docs/agents/issue-tracker.md'
reject_text "$review" '`general-purpose`'

require_text "$implement" 'repository-owned `code-review`'
require_regex "$implement" 'invoke .*code-review.*complete GitHub Package Contract.*every acceptance-bearing PRD child.*Spec'
require_text "$setup_skill" 'npx --yes skills add Andiedie/skills -g --skill code-review --agent <known-target...>'
require_text "$setup_skill" 'npx --yes skills add mattpocock/skills -g --skill <missing-matt-skill...> --agent <known-target...>'
reject_text "$setup_skill" 'npx --yes skills add mattpocock/skills -g --skill code-review'

and_source='npx --yes skills add Andiedie/skills .*--skill .*and-workflow-contract.*code-review.*setup-and'
matt_source='npx --yes skills add mattpocock/skills .*--skill .*grilling.*research.*prototype.*tdd'
matt_review='npx --yes skills add mattpocock/skills .*--skill .*code-review'
require_regex "$readme" "$and_source"
require_regex "$readme" "$matt_source"
require_regex "$guide" "$matt_source"
reject_regex "$readme" "$matt_review"
reject_regex "$guide" "$matt_review"

require_text "$readme" '`code-review` is a generic review skill owned and distributed by this repository'
require_text "$readme" 'v1.2.3'
reject_text "$readme" 'minimal, behavior-only diff'
reject_text "$readme" 'adopted selectively through evidence-backed work'
require_text "$guide" '| `code-review` | `Andiedie/skills` |'
require_text "$guide" 'repository-owned generic `code-review`'
require_text "$guide" 'v1.2.3'
reject_text "$guide" 'minimal, behavior-only diff'
reject_text "$guide" 'evaluated selectively through an evidence-backed work record'
require_text "$package_agents" 'Keep repository-owned `code-review` runtime at a minimal behavior-only diff from its recorded upstream baseline.'
require_text "$package_agents" 'Adopt later upstream changes only through a separate evidence-backed work record and a verified tag diff; do not synchronize automatically.'
require_text "$package_readme" '- `code-review`'

[[ ! -e "$and_root/and-code-review" ]] || fail "and-code-review compatibility alias must not exist"

echo "code-review contract: passed"
