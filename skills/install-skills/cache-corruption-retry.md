# Cache-Corruption Retry

Attempt at most one retry.

Run the failed command in a subshell so the retry owns both its temporary cache and its cleanup traps:

```bash
(
  retry_cache_dir="$(mktemp -d)" || {
    printf 'Failed to create isolated npm retry cache.\n' >&2
    exit 1
  }

  cleanup_retry_cache() {
    retry_exit_code=$?
    trap - EXIT HUP INT TERM
    if ! rm -rf -- "$retry_cache_dir"; then
      printf 'Failed to remove npm retry cache: %s\n' "$retry_cache_dir" >&2
    fi
    exit "$retry_exit_code"
  }

  trap cleanup_retry_cache EXIT
  trap 'exit 129' HUP
  trap 'exit 130' INT
  trap 'exit 143' TERM

  NPM_CONFIG_CACHE="$retry_cache_dir" <same npx command>
)
```

Replace `<same npx command>` with only the failed install or update command, preserving its scope, targets, and flags. The command's original result remains authoritative. If temporary-directory allocation fails, stop without retrying. If cleanup fails, report the exact residual path in addition to the command result. Never delete the default npm cache, use a fixed or shared retry path, or retain a failed retry cache intentionally.
