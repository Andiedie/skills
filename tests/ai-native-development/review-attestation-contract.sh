#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
and_root="$repo_root/skills/ai-native-development"
authority="$and_root/and-workflow-contract/review-attestation.md"
delivery_units="$and_root/and-workflow-contract/delivery-units.md"
review="$and_root/code-review/SKILL.md"
implement="$and_root/and-implement/SKILL.md"
finish="$and_root/and-finish/SKILL.md"
helper="$and_root/and-workflow-contract/review-attestation.sh"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

[[ -f "$authority" ]] || fail "review attestation authority is missing"

tmp_dir="$(mktemp -d "${TMPDIR:-/tmp}/and-review-attestation.XXXXXX")"
trap 'rm -rf "$tmp_dir"' EXIT
runtime_bin="$tmp_dir/runtime-bin"
mkdir "$runtime_bin"
bash_executable="$(command -v bash)"
[[ -n "$bash_executable" ]] || fail "test runtime has no env-resolvable Bash"
ln -s "$bash_executable" "$runtime_bin/bash"
if command -v shasum >/dev/null 2>&1; then
  sha_executable="$(command -v shasum)"
elif command -v sha256sum >/dev/null 2>&1; then
  sha_executable="$(command -v sha256sum)"
else
  fail "test runtime has no SHA-256 implementation"
fi
ln -s "$sha_executable" "$runtime_bin/${sha_executable##*/}"

run_helper() {
  PATH="$runtime_bin" "$helper" "$@"
}

expect_render_rejected() {
  local name="$1"
  local input_file="$2"
  if run_helper render <"$input_file" >"$tmp_dir/$name.out" 2>/dev/null; then
    fail "render accepted $name input"
  fi
}

fixture_digest_input=$'package  value  \r\n\r\n'
if ! digest_output="$(printf '%s' "$fixture_digest_input" | run_helper digest 2>/dev/null)"; then
  fail "review attestation helper digest command failed"
fi
expected_digest=256f47a5f997bd8a5ebccc60ce020ab0a1f64bcceb6b5181ceab929a98b65a03
[[ "$digest_output" == "$expected_digest" ]] \
  || fail "helper digest did not canonicalize CRLF/CR and trailing LF exactly"

fixed=1111111111111111111111111111111111111111
reviewed=2222222222222222222222222222222222222222
changed_source_head=3333333333333333333333333333333333333333
wrong_axis_head=5555555555555555555555555555555555555555
symbolic_head=4444444444444444444444444444444444444444
delivery_unit=github.com/example/repo#123
parent_identity=parent-agent
standards_identity=standards-child
spec_identity=spec-child
package_url=https://github.com/example/repo/issues/123
child_url=https://github.com/example/repo/issues/2
child2_url=https://github.com/example/repo/issues/10
acceptance_url=https://example.test/acceptance/123
package_digest="$(printf '%s' 'package contract' | run_helper digest)"
child_digest="$(printf '%s' 'acceptance child two' | run_helper digest)"
child2_digest="$(printf '%s' 'acceptance child ten' | run_helper digest)"
child5_digest="$(printf '%s' 'acceptance child five' | run_helper digest)"
acceptance_digest="$(printf '%s' 'explicit acceptance authority' | run_helper digest)"

authorities_json="$(jq -cn \
  --arg package_url "$package_url" --arg package_digest "$package_digest" \
  --arg child_url "$child_url" --arg child_digest "$child_digest" \
  --arg child2_url "$child2_url" --arg child2_digest "$child2_digest" \
  --arg acceptance_url "$acceptance_url" --arg acceptance_digest "$acceptance_digest" \
  '[
    {kind: "package-contract", url: $package_url, sha256: $package_digest},
    {kind: "acceptance-child", url: $child_url, sha256: $child_digest},
    {kind: "acceptance-child", url: $child2_url, sha256: $child2_digest},
    {kind: "acceptance", url: $acceptance_url, sha256: $acceptance_digest}
  ]')"

write_render_records() {
  local output_file="$1"
  local authorities="$2"
  local delivery="${3:-$delivery_unit}"
  local spec_result="${4:-clean}"
  {
    printf 'delivery_unit\t%s\n' "$delivery"
    printf 'fixed_point\t%s\n' "$fixed"
    printf 'reviewed_head\t%s\n' "$reviewed"
    printf 'parent_identity\t%s\n' "$parent_identity"
    printf 'issued_reviewer\t%s\n' "$standards_identity"
    printf 'issued_reviewer\t%s\n' "$spec_identity"
    printf '%s\n' "$authorities" \
      | jq -r '.[] | ["authority", .kind, .url, .sha256] | @tsv'
    printf 'axis\tstandards\t%s\t%s\tclean\n' "$standards_identity" "$reviewed"
    printf 'axis\tspec\t%s\t%s\t%s\n' "$spec_identity" "$reviewed" "$spec_result"
  } >"$output_file"
}

render_input_file="$tmp_dir/render-input.records"
write_render_records "$render_input_file" "$authorities_json"

render_file="$tmp_dir/attestation.json"
run_helper render <"$render_input_file" >"$render_file" \
  || fail "helper render command failed"
jq -e \
  --arg delivery_unit "$delivery_unit" \
  --arg fixed_point "$fixed" \
  --arg reviewed_head "$reviewed" \
  --arg standards_identity "$standards_identity" \
  --arg spec_identity "$spec_identity" \
  '.schema == "and-review-attestation/v1"
   and .delivery_unit == $delivery_unit
   and .fixed_point == $fixed_point
   and .reviewed_head == $reviewed_head
   and .diff_command == ("git diff " + $fixed_point + "..." + $reviewed_head)
   and .axes.standards == {reviewer: $standards_identity, head: $reviewed_head, result: "clean"}
   and .axes.spec == {reviewer: $spec_identity, head: $reviewed_head, result: "clean"}
   and (.spec_authorities | length == 4)' "$render_file" >/dev/null \
  || fail "render did not produce the exact frozen v1 block"

immutable_identity='urn:sha256:dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd'
identity_authorities="$(jq -c --arg identity "$immutable_identity" \
  '[.[0], {kind: "acceptance", url: $identity, sha256: .[3].sha256}]' <<<"$authorities_json")"
identity_input="$tmp_dir/immutable-identity.records"
write_render_records "$identity_input" "$identity_authorities"
identity_render="$tmp_dir/immutable-identity.json"
run_helper render <"$identity_input" >"$identity_render" \
  || fail "render rejected a canonical immutable acceptance identity"
jq -e --arg identity "$immutable_identity" --arg digest "$acceptance_digest" \
  '.spec_authorities[1] == {kind: "acceptance", url: $identity, sha256: $digest}' \
  "$identity_render" >/dev/null \
  || fail "render did not preserve the immutable acceptance identity"

tab=$'\t'
leading_tab_render="$tmp_dir/leading-tab-render.records"
sed "s/^delivery_unit/${tab}delivery_unit/" "$render_input_file" >"$leading_tab_render"
expect_render_rejected leading-tab "$leading_tab_render"
trailing_tab_render="$tmp_dir/trailing-tab-render.records"
sed "s/^delivery_unit.*/&${tab}/" "$render_input_file" >"$trailing_tab_render"
expect_render_rejected trailing-tab "$trailing_tab_render"
consecutive_tab_render="$tmp_dir/consecutive-tab-render.records"
sed "s/^delivery_unit${tab}/delivery_unit${tab}${tab}/" "$render_input_file" >"$consecutive_tab_render"
expect_render_rejected consecutive-tab "$consecutive_tab_render"

receipt_file="$tmp_dir/implementation-comment.md"
{
  printf '%s\n' '## Implementation' '```text' 'unrelated fenced context' '```' 'Review attestation:' '```json'
  cat "$render_file"
  printf '%s\n' '```' 'After receipt context:' '```text' 'more unrelated context' '```' 'Next step:'
} >"$receipt_file"
extracted_file="$tmp_dir/extracted.json"
run_helper extract <"$receipt_file" >"$extracted_file" \
  || fail "helper extract command failed"
cmp -s "$render_file" "$extracted_file" \
  || fail "extract/readback changed attestation bytes"

make_envelope() {
  local attestation_file="$1"
  local source_head="$2"
  local pr_head="$3"
  local current_authorities="$4"
  local attestation
  attestation="$(<"$attestation_file")"
  {
    printf 'attestation\t%s\n' "$attestation"
    printf 'current_delivery_unit\t%s\n' "$delivery_unit"
    printf 'receipt_fixed_point\t%s\n' "$fixed"
    printf 'source_head\t%s\n' "$source_head"
    printf 'pr_head\t%s\n' "$pr_head"
    printf '%s\n' "$current_authorities" \
      | jq -r '.[] | ["current_authority", .kind, .url, .sha256] | @tsv'
  }
}

run_validate() {
  local envelope="$1"
  local output_file="$2"
  run_helper validate <<<"$envelope" >"$output_file" \
    || fail "helper validate command failed"
}

assert_status() {
  local output_file="$1"
  local expected_status="$2"
  local paired_clean="$3"
  jq -e --arg status "$expected_status" --argjson paired "$paired_clean" \
    '.status == $status and .paired_review_clean == $paired' "$output_file" \
    >/dev/null || fail "expected status=$expected_status paired_review_clean=$paired_clean"
}

base_envelope="$(make_envelope "$render_file" "$reviewed" "$reviewed" "$authorities_json")"
valid_output="$tmp_dir/valid.json"
run_validate "$base_envelope" "$valid_output"
assert_status "$valid_output" valid true
jq -e '.reasons == []' "$valid_output" >/dev/null \
  || fail "matched fixture reported a false stale reason"

expect_validate_tab_malformed() {
  local name="$1"
  local envelope_file="$2"
  local output_file="$tmp_dir/$name.json"
  run_validate "$(<"$envelope_file")" "$output_file"
  assert_status "$output_file" malformed false
  jq empty "$output_file" >/dev/null \
    || fail "$name did not emit parseable validation JSON"
}

leading_tab_validate="$tmp_dir/leading-tab-validate.records"
sed "s/^current_delivery_unit/${tab}current_delivery_unit/" <<<"$base_envelope" >"$leading_tab_validate"
expect_validate_tab_malformed leading-tab-validate "$leading_tab_validate"
trailing_tab_validate="$tmp_dir/trailing-tab-validate.records"
sed "s/^current_delivery_unit.*/&${tab}/" <<<"$base_envelope" >"$trailing_tab_validate"
expect_validate_tab_malformed trailing-tab-validate "$trailing_tab_validate"
consecutive_tab_validate="$tmp_dir/consecutive-tab-validate.records"
sed "s/^current_delivery_unit${tab}/current_delivery_unit${tab}${tab}/" <<<"$base_envelope" >"$consecutive_tab_validate"
expect_validate_tab_malformed consecutive-tab-validate "$consecutive_tab_validate"

hostile_record_output="$tmp_dir/hostile-record.json"
printf 'bad"record\tvalue\n' | run_helper validate >"$hostile_record_output"
jq -e '.status == "malformed" and any(.reasons[]; . == "unknown validate record")' \
  "$hostile_record_output" >/dev/null \
  || fail "malformed record name escaped the machine-readable validation envelope"

control_authorities="$(jq -c --arg control_url $'https://example.test/acceptance/\a' \
  '.[3].url = $control_url' <<<"$authorities_json")"
control_envelope="$(make_envelope "$render_file" "$reviewed" "$reviewed" "$control_authorities")"
control_output="$tmp_dir/control-authority.json"
run_validate "$control_envelope" "$control_output"
jq -e '.status == "malformed" and any(.reasons[]; contains("current Spec authority set is malformed"))' \
  "$control_output" >/dev/null \
  || fail "control-byte authority did not fail closed as parseable malformed JSON"

a291_envelope="$(make_envelope "$render_file" "$changed_source_head" "$changed_source_head" "$authorities_json")"
a291_output="$tmp_dir/a291.json"
run_validate "$a291_envelope" "$a291_output"
assert_status "$a291_output" stale true
jq -e 'any(.reasons[]; contains("source_head") or contains("pr_head"))' "$a291_output" >/dev/null \
  || fail "A-291-shaped stale result lacks a precise head reason"

content_authorities="$(jq -c --arg digest aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa \
  '.[0].sha256 = $digest' <<<"$authorities_json")"
content_envelope="$(make_envelope "$render_file" "$reviewed" "$reviewed" "$content_authorities")"
content_output="$tmp_dir/content-stale.json"
run_validate "$content_envelope" "$content_output"
assert_status "$content_output" stale true
jq -e --arg url "$package_url" 'any(.reasons[]; contains($url) and contains("digest"))' "$content_output" >/dev/null \
  || fail "authority content stale result lacks URL and digest comparison"

membership_authorities="$(jq -c \
  --arg url https://example.test/acceptance/new \
  --arg digest bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb \
  '. + [{kind: "acceptance", url: $url, sha256: $digest}]' <<<"$authorities_json")"
membership_envelope="$(make_envelope "$render_file" "$reviewed" "$reviewed" "$membership_authorities")"
membership_output="$tmp_dir/membership-stale.json"
run_validate "$membership_envelope" "$membership_output"
assert_status "$membership_output" stale true
jq -e 'any(.reasons[]; contains("membership"))' "$membership_output" >/dev/null \
  || fail "authority membership stale result lacks a membership reason"

kind_changed_authorities="$(jq -c '[.[0], .[2], .[3], {kind: "acceptance", url: .[1].url, sha256: .[1].sha256}]' <<<"$authorities_json")"
kind_changed_envelope="$(make_envelope "$render_file" "$reviewed" "$reviewed" "$kind_changed_authorities")"
kind_changed_output="$tmp_dir/kind-changed-stale.json"
run_validate "$kind_changed_envelope" "$kind_changed_output"
assert_status "$kind_changed_output" stale true
jq -e --arg url "$child_url" \
  'any(.reasons[]; contains("attested=acceptance-child " + $url) and contains("current=acceptance " + $url))' \
  "$kind_changed_output" >/dev/null \
  || fail "authority kind/locator stale reason did not identify both attested and current entries"

inserted_authorities="$(jq -c --arg url https://github.com/example/repo/issues/5 --arg digest "$child5_digest" \
  '.[0:2] + [{kind: "acceptance-child", url: $url, sha256: $digest}] + .[2:]' <<<"$authorities_json")"
inserted_envelope="$(make_envelope "$render_file" "$reviewed" "$reviewed" "$inserted_authorities")"
inserted_output="$tmp_dir/inserted-child-stale.json"
run_validate "$inserted_envelope" "$inserted_output"
assert_status "$inserted_output" stale true
jq -e --arg url https://github.com/example/repo/issues/5 \
  'any(.reasons[]; . == ("authority membership added current: acceptance-child " + $url))' \
  "$inserted_output" >/dev/null \
  || fail "inserted authority did not report the new child as added"
if jq -e --arg url "$child2_url" \
  'any(.reasons[]; contains("authority membership added current: acceptance-child " + $url) or contains("authority membership missing current: acceptance-child " + $url))' \
  "$inserted_output" >/dev/null; then
  fail "inserted authority incorrectly classified the later existing child"
fi

kind_digest_changed="$(jq -c --arg digest cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc \
  '[.[0], .[2], .[3], {kind: "acceptance", url: .[1].url, sha256: $digest}]' <<<"$authorities_json")"
kind_digest_envelope="$(make_envelope "$render_file" "$reviewed" "$reviewed" "$kind_digest_changed")"
kind_digest_output="$tmp_dir/kind-digest-changed-stale.json"
run_validate "$kind_digest_envelope" "$kind_digest_output"
assert_status "$kind_digest_output" stale true
jq -e --arg url "$child_url" --arg digest cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc \
  'any(.reasons[]; contains("authority kind differs: attested=acceptance-child " + $url + " current=acceptance " + $url))
   and any(.reasons[]; contains("authority acceptance-child " + $url + " digest differs") and contains($digest))' \
  "$kind_digest_output" >/dev/null \
  || fail "same URL kind+digest change did not report both precise reasons"

expect_validate_malformed() {
  local name="$1"
  local malformed_file="$2"
  local output_file="$tmp_dir/$name.json"
  local envelope
  envelope="$(make_envelope "$malformed_file" "$reviewed" "$reviewed" "$authorities_json")"
  run_validate "$envelope" "$output_file"
  assert_status "$output_file" malformed false
  jq -e '.reasons | length > 0' "$output_file" >/dev/null \
    || fail "$name malformed result lacks reasons"
}

malformed_sha_file="$tmp_dir/malformed-sha.json"
jq -c '.fixed_point = "short"' "$render_file" >"$malformed_sha_file"
expect_validate_malformed malformed-sha "$malformed_sha_file"

malformed_diff_file="$tmp_dir/malformed-diff.json"
jq -c '.diff_command = "git diff not-frozen"' "$render_file" >"$malformed_diff_file"
expect_validate_malformed malformed-diff "$malformed_diff_file"

malformed_digest_file="$tmp_dir/malformed-digest.json"
jq -c '.spec_authorities[0].sha256 = "ABC"' "$render_file" >"$malformed_digest_file"
expect_validate_malformed malformed-digest "$malformed_digest_file"

trailing_separator_file="$tmp_dir/trailing-authority-separator.json"
sed 's/],"axes"/,],"axes"/' "$render_file" >"$trailing_separator_file"
expect_validate_malformed trailing-authority-separator "$trailing_separator_file"

missing_axis_file="$tmp_dir/missing-axis.json"
jq -c 'del(.axes.spec)' "$render_file" >"$missing_axis_file"
expect_validate_malformed missing-axis "$missing_axis_file"

duplicate_identity_file="$tmp_dir/duplicate-identity.json"
jq -c '.axes.spec.reviewer = .axes.standards.reviewer' "$render_file" >"$duplicate_identity_file"
expect_validate_malformed duplicate-identity "$duplicate_identity_file"

inconsistent_head_file="$tmp_dir/inconsistent-axis-head.json"
jq -c --arg head "$wrong_axis_head" '.axes.spec.head = $head' "$render_file" >"$inconsistent_head_file"
expect_validate_malformed inconsistent-axis-head "$inconsistent_head_file"

wrong_axis_head_input_file="$tmp_dir/wrong-axis-head-input.records"
write_render_records "$wrong_axis_head_input_file" "$authorities_json"
sed -i.bak "s/^axis\\tstandards\\t${standards_identity}\\t${reviewed}\\tclean$/axis\\tstandards\\t${standards_identity}\\t${wrong_axis_head}\\tclean/" "$wrong_axis_head_input_file"
rm -f "$wrong_axis_head_input_file.bak"
expect_render_rejected wrong-axis-head "$wrong_axis_head_input_file"

missing_axis_head_input_file="$tmp_dir/missing-axis-head-input.records"
write_render_records "$missing_axis_head_input_file" "$authorities_json"
sed -i.bak "s/^axis\\tstandards\\t${standards_identity}\\t${reviewed}\\tclean$/axis\\tstandards\\t${standards_identity}\\tclean/" "$missing_axis_head_input_file"
rm -f "$missing_axis_head_input_file.bak"
expect_render_rejected missing-axis-head "$missing_axis_head_input_file"

duplicate_input_file="$tmp_dir/duplicate-input.json"
write_render_records "$duplicate_input_file" "$authorities_json"
sed -i.bak "s/^axis\\tstandards\\t[^\\t]*/axis\\tstandards\\t$spec_identity/" "$duplicate_input_file"
rm -f "$duplicate_input_file.bak"
expect_render_rejected duplicate-identity "$duplicate_input_file"
parent_input_file="$tmp_dir/parent-input.json"
write_render_records "$parent_input_file" "$authorities_json"
sed -i.bak "s/^axis\\tstandards\\t[^\\t]*/axis\\tstandards\\t$parent_identity/" "$parent_input_file"
rm -f "$parent_input_file.bak"
expect_render_rejected parent-identity "$parent_input_file"
invented_input_file="$tmp_dir/invented-input.json"
write_render_records "$invented_input_file" "$authorities_json"
sed -i.bak 's/^axis\tstandards\t[^\t]*/axis\tstandards\tinvented-child/' "$invented_input_file"
rm -f "$invented_input_file.bak"
expect_render_rejected invented-identity "$invented_input_file"
uppercase_delivery_input_file="$tmp_dir/uppercase-delivery-input.json"
write_render_records "$uppercase_delivery_input_file" "$authorities_json" 'github.com/Example/repo#123'
expect_render_rejected noncanonical-delivery "$uppercase_delivery_input_file"
noncanonical_package_input_file="$tmp_dir/noncanonical-package-input.json"
noncanonical_authorities="$(jq -c '.[0].url = "https://example.test/package/123"' <<<"$authorities_json")"
write_render_records "$noncanonical_package_input_file" "$noncanonical_authorities"
expect_render_rejected noncanonical-package-url "$noncanonical_package_input_file"
noncanonical_child_input_file="$tmp_dir/noncanonical-child-input.records"
noncanonical_child_authorities="$(jq -c '.[1].url = "https://example.test/issues/2"' <<<"$authorities_json")"
write_render_records "$noncanonical_child_input_file" "$noncanonical_child_authorities"
expect_render_rejected noncanonical-child-url "$noncanonical_child_input_file"

unordered_input_file="$tmp_dir/unordered-authorities-input.json"
unordered_render_authorities="$(jq -c '[.[0], .[2], .[1], .[3]]' <<<"$authorities_json")"
write_render_records "$unordered_input_file" "$unordered_render_authorities"
expect_render_rejected unordered-authorities "$unordered_input_file"
unordered_authorities="$(jq -c '[.[0], .[2], .[1], .[3]]' <<<"$authorities_json")"
unordered_envelope="$(make_envelope "$render_file" "$reviewed" "$reviewed" "$unordered_authorities")"
unordered_output="$tmp_dir/unordered-authorities.json"
run_validate "$unordered_envelope" "$unordered_output"
assert_status "$unordered_output" malformed false

legacy_envelope=$'attestation\tabsent\n'
legacy_output="$tmp_dir/legacy-missing.json"
run_validate "$legacy_envelope" "$legacy_output"
assert_status "$legacy_output" missing false

symbolic_envelope="$(make_envelope "$render_file" "$symbolic_head" "$symbolic_head" "$authorities_json")"
symbolic_output="$tmp_dir/symbolic-head-stale.json"
run_validate "$symbolic_envelope" "$symbolic_output"
assert_status "$symbolic_output" stale true
jq -e 'any(.reasons[]; contains("source_head") or contains("pr_head"))' "$symbolic_output" >/dev/null \
  || fail "symbolic HEAD movement lacks a stale head reason"

skipped_input_file="$tmp_dir/skipped-input.json"
write_render_records "$skipped_input_file" "$authorities_json" "$delivery_unit" skipped
skipped_file="$tmp_dir/skipped.json"
run_helper render <"$skipped_input_file" >"$skipped_file" \
  || fail "render rejected generic Spec skipped result"
skipped_envelope="$(make_envelope "$skipped_file" "$reviewed" "$reviewed" "$authorities_json")"
skipped_output="$tmp_dir/skipped-valid.json"
run_validate "$skipped_envelope" "$skipped_output"
assert_status "$skipped_output" valid false
jq -e '.reasons == []' "$skipped_output" >/dev/null \
  || fail "Spec skipped freshness should be valid without clean paired review"

missing_receipt_body='## Implementation\nNext step:'
if printf '%b' "$missing_receipt_body" | run_helper extract >/dev/null 2>&1; then
  fail "extract accepted a receipt with no attestation"
else
  extract_exit=$?
fi
[[ "$extract_exit" -eq 3 ]] || fail "missing receipt did not produce extract exit 3"
duplicate_receipt_file="$tmp_dir/duplicate-receipt.md"
cat "$receipt_file" "$receipt_file" >"$duplicate_receipt_file"
if run_helper extract <"$duplicate_receipt_file" >/dev/null 2>&1; then
  fail "extract accepted duplicate attestation markers"
else
  extract_exit=$?
fi
[[ "$extract_exit" -eq 4 ]] || fail "duplicate receipt did not produce extract exit 4"
malformed_receipt_file="$tmp_dir/malformed-receipt.md"
printf '%s\n' 'Review attestation:' '```json' '{"schema":' '```' >"$malformed_receipt_file"
if run_helper extract <"$malformed_receipt_file" >/dev/null 2>&1; then
  fail "extract accepted malformed JSON payload"
else
  extract_exit=$?
fi
[[ "$extract_exit" -eq 4 ]] || fail "malformed receipt did not produce extract exit 4"

expect_extract_malformed() {
  local name="$1"
  local input_file="$2"
  if run_helper extract <"$input_file" >"$tmp_dir/$name.out" 2>/dev/null; then
    fail "extract accepted $name"
  else
    extract_exit=$?
  fi
  [[ "$extract_exit" -eq 4 ]] || fail "$name did not produce extract exit 4"
}

unmarked_fenced_v1_file="$tmp_dir/unmarked-fenced-v1.md"
{
  printf '%s\n' '```json'
  cat "$render_file"
  printf '%s\n' '```'
} >"$unmarked_fenced_v1_file"
expect_extract_malformed unmarked-fenced-v1 "$unmarked_fenced_v1_file"

unmarked_raw_v1_file="$tmp_dir/unmarked-raw-v1.md"
printf 'apparent payload: %s\n' "$(<"$render_file")" >"$unmarked_raw_v1_file"
expect_extract_malformed unmarked-raw-v1 "$unmarked_raw_v1_file"

unmarked_around_v1_file="$tmp_dir/unmarked-around-v1.md"
{
  printf '%s\n' '```json'
  cat "$render_file"
  printf '%s\n' '```' 'Review attestation:' '```json'
  cat "$render_file"
  printf '%s\n' '```' '```json'
  cat "$render_file"
  printf '%s\n' '```'
} >"$unmarked_around_v1_file"
expect_extract_malformed unmarked-around-v1 "$unmarked_around_v1_file"

trailing_separator_receipt="$tmp_dir/trailing-separator-receipt.md"
printf '%s\n' 'Review attestation:' '```json' >"$trailing_separator_receipt"
cat "$trailing_separator_file" >>"$trailing_separator_receipt"
printf '%s\n' '```' >>"$trailing_separator_receipt"
if run_helper extract <"$trailing_separator_receipt" >/dev/null 2>&1; then
  fail "extract accepted a trailing authority separator"
else
  extract_exit=$?
fi
[[ "$extract_exit" -eq 4 ]] || fail "trailing authority separator did not produce extract exit 4"

for caller in "$review" "$implement" "$finish" "$delivery_units"; do
  grep -Fq -- 'review-attestation.md' "$caller" \
    || fail "$caller does not route conditional behavior to the shared authority"
done
if grep -Fq -- 'and-review-attestation/v1' "$review" "$implement" "$finish"; then
  fail "a caller duplicates the shared schema identifier"
fi

echo "review attestation contract: passed"
