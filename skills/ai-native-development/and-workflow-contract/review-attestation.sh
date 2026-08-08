#!/usr/bin/env bash
set -euo pipefail
export LC_ALL=C

usage() {
  printf '%s\n' 'usage: review-attestation.sh {digest|render|extract|validate}' >&2
  return 2
}

is_safe_field() {
  local value="$1" tab=$'\t' newline=$'\n' carriage=$'\r' quote='"' slash=$'\\'
  [[ -n "$value" ]] || return 1
  [[ "$value" != *"$tab"* && "$value" != *"$newline"* && "$value" != *"$carriage"* \
    && "$value" != *[[:cntrl:]]* && "$value" != *"$quote"* && "$value" != *"$slash"* ]]
}

is_identity() {
  is_safe_field "$1" && [[ "$1" != *[[:space:]]* ]]
}

is_full_sha() {
  [[ "$1" =~ ^[0-9a-f]{40}$ ]]
}

is_digest() {
  [[ "$1" =~ ^[0-9a-f]{64}$ ]]
}

is_delivery() {
  is_safe_field "$1" && [[ "$1" =~ ^github\.com/[a-z0-9._-]+/[a-z0-9._-]+#[1-9][0-9]*$ ]]
}

is_issue_url() {
  is_safe_field "$1" && [[ "$1" =~ ^https://github\.com/[A-Za-z0-9._-]+/[A-Za-z0-9._-]+/issues/[1-9][0-9]*$ ]]
}

is_acceptance_identity() {
  is_safe_field "$1" && [[ "$1" != *[[:space:]]* ]]
}

is_standard_result() {
  [[ "$1" == clean || "$1" == findings || "$1" == failed ]]
}

is_spec_result() {
  [[ "$1" == clean || "$1" == findings || "$1" == skipped || "$1" == failed ]]
}

normalize_stream() {
  local content
  IFS= read -r -d '' content || true
  content="${content//$'\r\n'/$'\n'}"
  content="${content//$'\r'/$'\n'}"
  while [[ "$content" == *$'\n' ]]; do
    content="${content%$'\n'}"
  done
  content+=$'\n'
  printf '%s' "$content"
}

sha256_stream() {
  local output
  if command -v shasum >/dev/null 2>&1; then
    output="$(shasum -a 256)"
  elif command -v sha256sum >/dev/null 2>&1; then
    output="$(sha256sum)"
  else
    printf '%s\n' 'review-attestation: no SHA-256 implementation available' >&2
    return 1
  fi
  output="${output%% *}"
  is_digest "$output" || {
    printf '%s\n' 'review-attestation: SHA-256 implementation returned malformed output' >&2
    return 1
  }
  printf '%s\n' "$output"
}

digest_command() {
  normalize_stream | sha256_stream
}

record_fields=()
record_parse_error=''
record_first=''
record_first_field() {
  local line="$1"
  if [[ "$line" == *$'\t'* ]]; then
    record_first="${line%%$'\t'*}"
  else
    record_first="$line"
  fi
}

parse_record() {
  local line="$1" expected="$2" remaining field index
  local parsed_fields=()
  record_fields=()
  record_parse_error=''
  remaining="$line"
  while :; do
    if [[ "$remaining" == *$'\t'* ]]; then
      field="${remaining%%$'\t'*}"
      remaining="${remaining#*$'\t'}"
    else
      field="$remaining"
      remaining=''
      parsed_fields[${#parsed_fields[@]}]="$field"
      break
    fi
    [[ -n "$field" ]] || {
      record_parse_error='record contains an empty field'
      return 1
    }
    parsed_fields[${#parsed_fields[@]}]="$field"
  done
  for index in "${!parsed_fields[@]}"; do
    [[ -n "${parsed_fields[index]}" ]] || {
      record_parse_error='record contains an empty field'
      return 1
    }
  done
  (( ${#parsed_fields[@]} == expected )) || {
    record_parse_error='record has the wrong field count'
    return 1
  }
  record_fields=("${parsed_fields[@]}")
}

render_fail() {
  printf 'review-attestation render: %s\n' "$1" >&2
  exit 1
}

render_delivery=''
render_fixed=''
render_head=''
render_parent=''
render_std_reviewer=''
render_std_head=''
render_spec_reviewer=''
render_spec_head=''
render_std_result=''
render_spec_result=''
render_seen_delivery=0
render_seen_fixed=0
render_seen_head=0
render_seen_parent=0
render_seen_std=0
render_seen_spec=0
render_issued=()
render_auth_kind=()
render_auth_locator=()
render_auth_digest=()

identity_check=()
validate_issued_set() {
  local i j
  (( ${#identity_check[@]} >= 2 )) || return 1
  for i in "${!identity_check[@]}"; do
    is_identity "${identity_check[i]}" || return 1
    for j in "${!identity_check[@]}"; do
      (( i == j )) || [[ "${identity_check[i]}" != "${identity_check[j]}" ]] || return 1
    done
  done
}

identity_in() {
  local value="$1" i
  shift
  for i in "$@"; do
    [[ "$value" == "$i" ]] && return 0
  done
  return 1
}

check_kind=()
check_locator=()
check_digest=()
authority_reason=''
authority_check() {
  authority_reason=''
  local count=${#check_kind[@]} i j kind locator digest number last_child=-1 last_accept_locator='' phase=0
  (( count > 0 )) || { authority_reason='authority set is empty'; return 1; }
  for ((i = 0; i < count; i++)); do
    kind="${check_kind[i]}"
    locator="${check_locator[i]}"
    digest="${check_digest[i]}"
    is_safe_field "$kind" && is_safe_field "$locator" && is_digest "$digest" \
      || { authority_reason="authority entry $((i + 1)) is malformed"; return 1; }
    case "$kind" in
      package-contract)
        (( i == 0 && phase == 0 )) || { authority_reason='Package Contract must be first and unique'; return 1; }
        is_issue_url "$locator" || { authority_reason='Package Contract URL is not canonical'; return 1; }
        phase=1
        ;;
      acceptance-child)
        (( i > 0 && phase <= 1 )) || { authority_reason='acceptance-child entries are out of order'; return 1; }
        is_issue_url "$locator" || { authority_reason='acceptance-child URL is not canonical'; return 1; }
        [[ "$locator" =~ /issues/([1-9][0-9]*)$ ]] || { authority_reason='acceptance-child URL lacks a numeric issue'; return 1; }
        number="${BASH_REMATCH[1]}"
        (( number > last_child )) || { authority_reason='acceptance-child issue numbers are not strictly increasing'; return 1; }
        last_child=$number
        phase=1
        ;;
      acceptance)
        (( i > 0 && phase <= 2 )) || { authority_reason='acceptance entries are out of order'; return 1; }
        is_acceptance_identity "$locator" || { authority_reason='acceptance identity is not canonical'; return 1; }
        [[ -z "$last_accept_locator" || "$locator" > "$last_accept_locator" ]] || { authority_reason='acceptance identities are not strictly sorted'; return 1; }
        last_accept_locator="$locator"
        phase=2
        ;;
      *)
        authority_reason='authority kind is invalid'
        return 1
        ;;
    esac
    for ((j = 0; j < i; j++)); do
      [[ "$locator" != "${check_locator[j]}" ]] || { authority_reason='authority locator is duplicated'; return 1; }
    done
  done
}

load_render_authorities() {
  check_kind=("${render_auth_kind[@]}")
  check_locator=("${render_auth_locator[@]}")
  check_digest=("${render_auth_digest[@]}")
}

render_command() {
  local line kind expected
  render_issued=() render_auth_kind=() render_auth_locator=() render_auth_digest=()
  while IFS= read -r line || [[ -n "$line" ]]; do
    [[ -n "$line" ]] || render_fail 'record is empty'
    record_first_field "$line"
    case "$record_first" in
      authority) expected=4 ;;
      axis) expected=5 ;;
      *) expected=2 ;;
    esac
    parse_record "$line" "$expected" || render_fail "$record_parse_error"
    kind="${record_fields[0]}"
    case "$kind" in
      delivery_unit)
        (( render_seen_delivery == 0 )) || render_fail 'delivery_unit is duplicated'
        render_seen_delivery=1; render_delivery="${record_fields[1]}"
        is_delivery "$render_delivery" || render_fail 'delivery_unit is malformed'
        ;;
      fixed_point)
        (( render_seen_fixed == 0 )) || render_fail 'fixed_point is duplicated'
        render_seen_fixed=1; render_fixed="${record_fields[1]}"
        is_full_sha "$render_fixed" || render_fail 'fixed_point must be a full lowercase SHA'
        ;;
      reviewed_head)
        (( render_seen_head == 0 )) || render_fail 'reviewed_head is duplicated'
        render_seen_head=1; render_head="${record_fields[1]}"
        is_full_sha "$render_head" || render_fail 'reviewed_head must be a full lowercase SHA'
        ;;
      parent_identity)
        (( render_seen_parent == 0 )) || render_fail 'parent_identity is duplicated'
        render_seen_parent=1; render_parent="${record_fields[1]}"
        is_identity "$render_parent" || render_fail 'parent_identity is malformed'
        ;;
      issued_reviewer)
        is_identity "${record_fields[1]}" || render_fail 'issued_reviewer is malformed'
        render_issued+=("${record_fields[1]}")
        ;;
      authority)
        render_auth_kind+=("${record_fields[1]}")
        render_auth_locator+=("${record_fields[2]}")
        render_auth_digest+=("${record_fields[3]}")
        ;;
      axis)
        [[ "${record_fields[1]}" == standards || "${record_fields[1]}" == spec ]] || render_fail 'axis name is invalid'
        is_identity "${record_fields[2]}" || render_fail 'axis reviewer is malformed'
        is_full_sha "${record_fields[3]}" || render_fail 'axis echoed head is malformed'
        if [[ "${record_fields[1]}" == standards ]]; then
          (( render_seen_std == 0 )) || render_fail 'Standards axis is duplicated'
          render_seen_std=1; render_std_reviewer="${record_fields[2]}"; render_std_head="${record_fields[3]}"; render_std_result="${record_fields[4]}"
          is_standard_result "$render_std_result" || render_fail 'Standards result is invalid'
        else
          (( render_seen_spec == 0 )) || render_fail 'Spec axis is duplicated'
          render_seen_spec=1; render_spec_reviewer="${record_fields[2]}"; render_spec_head="${record_fields[3]}"; render_spec_result="${record_fields[4]}"
          is_spec_result "$render_spec_result" || render_fail 'Spec result is invalid'
        fi
        ;;
      *) render_fail 'unknown render record' ;;
    esac
  done
  (( render_seen_delivery && render_seen_fixed && render_seen_head && render_seen_parent && render_seen_std && render_seen_spec )) \
    || render_fail 'required render records are missing'
  [[ "$render_std_head" == "$render_head" && "$render_spec_head" == "$render_head" ]] \
    || render_fail 'axis echoed head does not equal reviewed_head'
  identity_check=("${render_issued[@]}")
  validate_issued_set || render_fail 'issued_reviewers must be a unique non-empty identity set'
  [[ "$render_std_reviewer" != "$render_spec_reviewer" ]] || render_fail 'axis identities must be distinct'
  [[ "$render_std_reviewer" != "$render_parent" && "$render_spec_reviewer" != "$render_parent" ]] \
    || render_fail 'axis identities cannot be the parent'
  identity_in "$render_std_reviewer" "${render_issued[@]}" || render_fail 'Standards reviewer is not runtime-issued'
  identity_in "$render_spec_reviewer" "${render_issued[@]}" || render_fail 'Spec reviewer is not runtime-issued'
  load_render_authorities
  authority_check || render_fail "$authority_reason"

  local authority_json='' i
  for ((i = 0; i < ${#render_auth_kind[@]}; i++)); do
    (( i == 0 )) || authority_json+=','
    authority_json+="{\"kind\":\"${render_auth_kind[i]}\",\"url\":\"${render_auth_locator[i]}\",\"sha256\":\"${render_auth_digest[i]}\"}"
  done
  printf '{"schema":"and-review-attestation/v1","delivery_unit":"%s","fixed_point":"%s","reviewed_head":"%s","diff_command":"git diff %s...%s","spec_authorities":[%s],"axes":{"standards":{"reviewer":"%s","head":"%s","result":"%s"},"spec":{"reviewer":"%s","head":"%s","result":"%s"}}}\n' \
    "$render_delivery" "$render_fixed" "$render_head" "$render_fixed" "$render_head" "$authority_json" \
    "$render_std_reviewer" "$render_std_head" "$render_std_result" "$render_spec_reviewer" "$render_spec_head" "$render_spec_result"
}

att_delivery=''
att_fixed=''
att_head=''
att_std_reviewer=''
att_std_head=''
att_std_result=''
att_spec_reviewer=''
att_spec_head=''
att_spec_result=''
att_auth_kind=()
att_auth_locator=()
att_auth_digest=()
attestation_reason=''

attestation_bad() {
  attestation_reason="$1"
  return 1
}

parse_attestation() {
  local value="$1" pattern rest token sep
  local kind locator digest
  attestation_reason=''
  [[ "$value" != *$'\n'* && "$value" != *$'\r'* && "$value" != *$'\t'* ]] \
    || { attestation_bad 'attestation payload contains a forbidden line separator'; return 1; }
  pattern='^\{"schema":"and-review-attestation/v1","delivery_unit":"([^"]*)","fixed_point":"([^"]*)","reviewed_head":"([^"]*)","diff_command":"([^"]*)","spec_authorities":\[(.*)\],"axes":\{"standards":\{"reviewer":"([^"]*)","head":"([^"]*)","result":"([^"]*)"\},"spec":\{"reviewer":"([^"]*)","head":"([^"]*)","result":"([^"]*)"\}\}\}$'
  [[ "$value" =~ $pattern ]] || { attestation_bad 'attestation compact JSON shape is malformed (missing or unknown field)'; return 1; }
  att_delivery="${BASH_REMATCH[1]}"; att_fixed="${BASH_REMATCH[2]}"; att_head="${BASH_REMATCH[3]}"
  att_diff_command="${BASH_REMATCH[4]}"; rest="${BASH_REMATCH[5]}"
  att_std_reviewer="${BASH_REMATCH[6]}"; att_std_head="${BASH_REMATCH[7]}"; att_std_result="${BASH_REMATCH[8]}"
  att_spec_reviewer="${BASH_REMATCH[9]}"; att_spec_head="${BASH_REMATCH[10]}"; att_spec_result="${BASH_REMATCH[11]}"
  is_delivery "$att_delivery" || { attestation_bad 'attestation delivery_unit is malformed'; return 1; }
  is_full_sha "$att_fixed" || { attestation_bad 'attestation fixed_point is not a full lowercase SHA'; return 1; }
  is_full_sha "$att_head" || { attestation_bad 'attestation reviewed_head is not a full lowercase SHA'; return 1; }
  [[ "$att_diff_command" == "git diff $att_fixed...$att_head" ]] || { attestation_bad 'attestation diff_command does not name its frozen SHAs'; return 1; }
  is_identity "$att_std_reviewer" && is_identity "$att_spec_reviewer" || { attestation_bad 'attestation axis reviewer identity is malformed'; return 1; }
  is_standard_result "$att_std_result" || { attestation_bad 'Standards axis result is invalid'; return 1; }
  is_spec_result "$att_spec_result" || { attestation_bad 'Spec axis result is invalid'; return 1; }
  is_full_sha "$att_std_head" && is_full_sha "$att_spec_head" || { attestation_bad 'axis head is not a full lowercase SHA'; return 1; }
  [[ "$att_std_reviewer" != "$att_spec_reviewer" ]] || { attestation_bad 'axis reviewer identities are duplicated'; return 1; }
  [[ "$att_std_head" == "$att_head" && "$att_spec_head" == "$att_head" ]] || { attestation_bad 'axis head does not equal reviewed_head'; return 1; }
  att_auth_kind=(); att_auth_locator=(); att_auth_digest=()
  local authority_pattern='^\{"kind":"([^"]+)","url":"([^"]+)","sha256":"([^"]*)"\}(,|$)'
  while [[ -n "$rest" ]]; do
    [[ "$rest" =~ $authority_pattern ]] || { attestation_bad 'authority entry or digest format is malformed'; return 1; }
    kind="${BASH_REMATCH[1]}"; locator="${BASH_REMATCH[2]}"; digest="${BASH_REMATCH[3]}"; sep="${BASH_REMATCH[4]}"; token="${BASH_REMATCH[0]}"
    is_safe_field "$kind" && is_safe_field "$locator" && is_digest "$digest" \
      || { attestation_bad 'authority kind, URL, or digest format is malformed'; return 1; }
    att_auth_kind+=("$kind"); att_auth_locator+=("$locator"); att_auth_digest+=("$digest")
    rest="${rest:${#token}}"
    [[ "$sep" != ',' || -n "$rest" ]] \
      || { attestation_bad 'authority array has a trailing separator'; return 1; }
    [[ -z "$sep" ]] && break
  done
  load_attested_authorities
  authority_check || { attestation_bad "authority order or membership is malformed: $authority_reason"; return 1; }
}

load_attested_authorities() {
  check_kind=("${att_auth_kind[@]}"); check_locator=("${att_auth_locator[@]}"); check_digest=("${att_auth_digest[@]}")
}

validate_reasons=()
record_error() {
  validate_reasons+=("$1")
}

emit_validation() {
  local status="$1" paired="$2" i
  printf '{"status":"%s","reasons":[' "$status"
  for i in "${!validate_reasons[@]}"; do
    (( i == 0 )) || printf ','
    printf '"%s"' "${validate_reasons[i]}"
  done
  printf '],"paired_review_clean":%s}\n' "$paired"
}

validate_command() {
  local line kind first_line expected
  local seen_att=0 seen_delivery=0 seen_fixed=0 seen_source=0 seen_pr=0
  local attestation_raw='' current_delivery='' current_fixed='' current_source='' current_pr=''
  local current_auth_kind=() current_auth_locator=() current_auth_digest=()
  validate_reasons=()
  if ! IFS= read -r first_line; then
    validate_reasons=('input record envelope is empty')
    emit_validation malformed false
    return 0
  fi
  if [[ "$first_line" == $'attestation\tabsent' ]]; then
    validate_reasons=('latest Implementation receipt has no review attestation')
    emit_validation missing false
    return 0
  fi
  line="$first_line"
  while :; do
    [[ -n "$line" ]] || record_error 'record is empty'
    record_first_field "$line"
    case "$record_first" in
      current_authority) expected=4 ;;
      *) expected=2 ;;
    esac
    if ! parse_record "$line" "$expected"; then
      record_error "$record_parse_error"
    else
      kind="${record_fields[0]}"
      case "$kind" in
      attestation)
        (( seen_att == 0 )) || record_error 'attestation record is duplicated'
        seen_att=1; attestation_raw="${record_fields[1]:-}"
        ;;
      current_delivery_unit)
        (( seen_delivery == 0 )) || record_error 'current_delivery_unit is duplicated'
        seen_delivery=1; current_delivery="${record_fields[1]:-}"
        is_delivery "$current_delivery" || record_error 'current_delivery_unit is malformed'
        ;;
      receipt_fixed_point)
        (( seen_fixed == 0 )) || record_error 'receipt_fixed_point is duplicated'
        seen_fixed=1; current_fixed="${record_fields[1]:-}"
        is_full_sha "$current_fixed" || record_error 'receipt_fixed_point is malformed'
        ;;
      source_head)
        (( seen_source == 0 )) || record_error 'source_head is duplicated'
        seen_source=1; current_source="${record_fields[1]:-}"
        is_full_sha "$current_source" || record_error 'source_head is malformed'
        ;;
      pr_head)
        (( seen_pr == 0 )) || record_error 'pr_head is duplicated'
        seen_pr=1; current_pr="${record_fields[1]:-}"
        is_full_sha "$current_pr" || record_error 'pr_head is malformed'
        ;;
      current_authority)
        current_auth_kind+=("${record_fields[1]:-}"); current_auth_locator+=("${record_fields[2]:-}"); current_auth_digest+=("${record_fields[3]:-}")
        ;;
      *) record_error 'unknown validate record' ;;
      esac
    fi
    if IFS= read -r line; then :; else break; fi
  done
  (( seen_att == 1 && seen_delivery == 1 && seen_fixed == 1 && seen_source == 1 && seen_pr == 1 )) \
    || record_error 'required current context records are missing'
  [[ -n "$attestation_raw" ]] || record_error 'attestation payload is missing'
  if [[ -n "$attestation_raw" ]] && ! parse_attestation "$attestation_raw"; then
    [[ -n "$attestation_reason" ]] || attestation_reason='attestation JSON shape is malformed'
    record_error "$attestation_reason"
  fi
  if (( ${#current_auth_kind[@]} == 0 )); then
    record_error 'current Spec authority set is missing'
  else
    check_kind=("${current_auth_kind[@]}"); check_locator=("${current_auth_locator[@]}"); check_digest=("${current_auth_digest[@]}")
    authority_check || record_error "current Spec authority set is malformed: $authority_reason"
  fi
  if (( ${#validate_reasons[@]} > 0 )); then
    emit_validation malformed false
    return 0
  fi

  local stale=() current_matched=() i j same_pair same_locator paired=false
  [[ "$att_delivery" == "$current_delivery" ]] || stale+=("delivery_unit differs: attested=$att_delivery current=$current_delivery")
  [[ "$att_fixed" == "$current_fixed" ]] || stale+=("fixed_point differs: attested=$att_fixed current=$current_fixed")
  [[ "$att_head" == "$current_source" ]] || stale+=("source_head differs: attested reviewed_head=$att_head current=$current_source")
  [[ "$att_head" == "$current_pr" ]] || stale+=("pr_head differs: attested reviewed_head=$att_head current=$current_pr")
  for ((j = 0; j < ${#current_auth_kind[@]}; j++)); do
    current_matched[j]=0
  done
  for ((i = 0; i < ${#att_auth_kind[@]}; i++)); do
    same_pair=-1
    same_locator=-1
    for ((j = 0; j < ${#current_auth_kind[@]}; j++)); do
      if [[ "${att_auth_kind[i]}" == "${current_auth_kind[j]}" && "${att_auth_locator[i]}" == "${current_auth_locator[j]}" ]]; then
        same_pair=$j
        break
      fi
      if (( same_locator < 0 )) && [[ "${att_auth_locator[i]}" == "${current_auth_locator[j]}" ]]; then
        same_locator=$j
      fi
    done
    if (( same_pair >= 0 )); then
      current_matched[same_pair]=1
      if [[ "${att_auth_digest[i]}" != "${current_auth_digest[same_pair]}" ]]; then
        stale+=("authority ${att_auth_kind[i]} ${att_auth_locator[i]} digest differs: attested=${att_auth_digest[i]} current=${current_auth_digest[same_pair]}")
      fi
    elif (( same_locator >= 0 )); then
      current_matched[same_locator]=1
      stale+=("authority kind differs: attested=${att_auth_kind[i]} ${att_auth_locator[i]} current=${current_auth_kind[same_locator]} ${current_auth_locator[same_locator]}")
      if [[ "${att_auth_digest[i]}" != "${current_auth_digest[same_locator]}" ]]; then
        stale+=("authority ${att_auth_kind[i]} ${att_auth_locator[i]} digest differs: attested=${att_auth_digest[i]} current=${current_auth_digest[same_locator]}")
      fi
    else
      stale+=("authority membership missing current: ${att_auth_kind[i]} ${att_auth_locator[i]}")
    fi
  done
  for ((j = 0; j < ${#current_auth_kind[@]}; j++)); do
    if (( current_matched[j] == 0 )); then
      stale+=("authority membership added current: ${current_auth_kind[j]} ${current_auth_locator[j]}")
    fi
  done
  if [[ "$att_std_result" == clean && "$att_spec_result" == clean && "$att_std_reviewer" != "$att_spec_reviewer" ]]; then paired=true; fi
  if (( ${#stale[@]} > 0 )); then
    validate_reasons=("${stale[@]}")
    emit_validation stale "$paired"
  else
    validate_reasons=()
    emit_validation valid "$paired"
  fi
}

extract_command() {
  local line syntax state=0 marker_count=0 payload='' payload_lines=0 malformed=0 apparent_v1=0
  while IFS= read -r line || [[ -n "$line" ]]; do
    syntax="${line%$'\r'}"
    if [[ "$syntax" == *'"schema":"and-review-attestation/v1"'* && "$state" -ne 2 ]]; then
      apparent_v1=1
      malformed=1
    fi
    if [[ "$syntax" == 'Review attestation:' ]]; then
      (( ++marker_count ))
      (( marker_count == 1 && state == 0 )) || malformed=1
      state=1
      continue
    fi
    case "$state" in
      0)
        ;;
      1)
        if [[ "$syntax" == '```json' ]]; then state=2; else malformed=1; fi
        ;;
      2)
        if [[ "$syntax" == '```' ]]; then state=3
        else
          (( ++payload_lines ))
          (( payload_lines == 1 )) || malformed=1
          payload+="$line"$'\n'
        fi
        ;;
      3)
        ;;
    esac
  done
  if (( marker_count == 0 )); then
    if (( apparent_v1 )); then
      printf '%s\n' 'review-attestation extract: apparent v1 payload has no attestation marker' >&2
      return 4
    fi
    printf '%s\n' 'review-attestation extract: latest Implementation receipt has no attestation block' >&2
    return 3
  fi
  if (( malformed || state != 3 || payload_lines != 1 )); then
    printf '%s\n' 'review-attestation extract: duplicate or malformed fenced payload' >&2
    return 4
  fi
  payload="${payload%$'\n'}"
  parse_attestation "$payload" || {
    printf '%s\n' 'review-attestation extract: payload is not a v1 compact JSON object' >&2
    return 4
  }
  printf '%s\n' "$payload"
}

main() {
  [[ "$#" -eq 1 ]] || usage
  case "$1" in
    digest) digest_command ;;
    render) render_command ;;
    extract) extract_command ;;
    validate) validate_command ;;
    *) usage ;;
  esac
}

main "$@"
