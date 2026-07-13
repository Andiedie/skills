# GitHub Relationship API

Read this reference before verifying native relationship capability or mutating parent/sub-issue or blocked-by edges.

Run commands from a checkout whose GitHub remote identifies `{owner}` and `{repo}`. GitHub CLI expands those placeholders. Replace example issue numbers and numeric database IDs before mutation. These recipes pin REST API version `2026-03-10`.

## Identity

Issue URL paths use the repository-local `number`; relationship payloads and dependency-removal paths use the REST issue object's numeric `id`:

```sh
gh api --method GET \
  -H 'Accept: application/vnd.github+json' \
  -H 'X-GitHub-Api-Version: 2026-03-10' \
  'repos/{owner}/{repo}/issues/42' \
  --jq '{number, id, node_id}'
```

The numeric `id` is neither the issue number nor the GraphQL `node_id`.

## Read Relationships

Read a child's parent:

```sh
gh api --method GET \
  -H 'Accept: application/vnd.github+json' \
  -H 'X-GitHub-Api-Version: 2026-03-10' \
  'repos/{owner}/{repo}/issues/42/parent'
```

Read all sub-issues and both dependency directions. `--slurp` returns page arrays; pipe to `jq 'add'` when one merged array is useful. Do not combine `--slurp` with `gh api --jq` or `--template`.

```sh
gh api --method GET --paginate --slurp \
  -H 'Accept: application/vnd.github+json' \
  -H 'X-GitHub-Api-Version: 2026-03-10' \
  'repos/{owner}/{repo}/issues/42/sub_issues?per_page=100'

gh api --method GET --paginate --slurp \
  -H 'Accept: application/vnd.github+json' \
  -H 'X-GitHub-Api-Version: 2026-03-10' \
  'repos/{owner}/{repo}/issues/42/dependencies/blocked_by?per_page=100'

gh api --method GET --paginate --slurp \
  -H 'Accept: application/vnd.github+json' \
  -H 'X-GitHub-Api-Version: 2026-03-10' \
  'repos/{owner}/{repo}/issues/42/dependencies/blocking?per_page=100'
```

## Mutate Relationships

Run mutation only after the intended issue numbers and numeric IDs are authorized. Use `-F`, not `-f`, so IDs are JSON numbers.

Add or remove a sub-issue. Removal uses singular `sub_issue`. Send `replace_parent` only when moving the child was separately intended and approved.

```sh
gh api --method POST \
  -H 'Accept: application/vnd.github+json' \
  -H 'X-GitHub-Api-Version: 2026-03-10' \
  'repos/{owner}/{repo}/issues/42/sub_issues' \
  -F 'sub_issue_id=123456789'

gh api --method DELETE \
  -H 'Accept: application/vnd.github+json' \
  -H 'X-GitHub-Api-Version: 2026-03-10' \
  'repos/{owner}/{repo}/issues/42/sub_issue' \
  -F 'sub_issue_id=123456789'
```

To make issue 84 block issue 42, call the blocked issue's `blocked_by` endpoint with issue 84's numeric `id`:

```sh
gh api --method POST \
  -H 'Accept: application/vnd.github+json' \
  -H 'X-GitHub-Api-Version: 2026-03-10' \
  'repos/{owner}/{repo}/issues/42/dependencies/blocked_by' \
  -F 'issue_id=987654321'

gh api --method DELETE \
  -H 'Accept: application/vnd.github+json' \
  -H 'X-GitHub-Api-Version: 2026-03-10' \
  'repos/{owner}/{repo}/issues/42/dependencies/blocked_by/987654321'
```

Successful add operations return `201`; successful removals return `200`.

## Interpret Capability

- Relationship reads require fine-grained `Issues: read`; writes require `Issues: write` and at least repository triage role.
- A fully paginated `200` with no items means the relationship direction is empty, not unavailable.
- `GET .../parent` returns `404` for a readable issue with no parent and message `No parent issue found`. Other `404` responses may indicate a wrong identity, hidden resource, or insufficient authentication.
- A `403` may indicate permission or rate limiting. Inspect response body, `x-ratelimit-*`, `retry-after`, and `X-Accepted-GitHub-Permissions` before classifying it.
- Successful reads do not prove write capability. Prove writes from authoritative token and repository-role evidence or an approved disposable add/read/remove/read probe.

For a reversible probe, record original relationships, add one edge, verify it, remove it, and verify cleanup. Residual state is a setup failure that must be reported exactly.

Official references: [REST sub-issues](https://docs.github.com/en/rest/issues/sub-issues?apiVersion=2026-03-10), [REST issue dependencies](https://docs.github.com/en/rest/issues/issue-dependencies?apiVersion=2026-03-10), [`gh api`](https://cli.github.com/manual/gh_api), and [REST troubleshooting](https://docs.github.com/en/rest/using-the-rest-api/troubleshooting-the-rest-api).
