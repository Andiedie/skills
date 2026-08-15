---
name: intake
description: Create one unlabeled GitHub Issue from a raw signal and return its URL.
disable-model-invocation: true
---

# Intake

Turn one raw signal into one unlabeled GitHub Issue.

Planning and implementation after that Issue exists stay with the installed Matt skills: `setup-matt-pocock-skills`, `ask-matt`, `triage`, `grill-with-docs`, `wayfinder`, `to-spec`, `to-tickets`, `implement`, `tdd`, `code-review`, `research`, `prototype`, `domain-modeling`, `codebase-design`, and `handoff`.

## Process

1. **Resolve the repository.** Use the repository the user named. Otherwise use the current GitHub remote.
   - Completion criterion: one `owner/repo` is known. Ask only when more than one plausible repository remains.

2. **Write the Issue.** Title names the requested change or observed problem. Body keeps the raw signal: material wording, errors, logs, links, and commands.

   ```sh
   gh issue create --repo <owner/repo> --title '<title>' --body '<body>'
   ```

   - Completion criterion: `gh` printed one Issue URL, and `gh issue view <url> --json labels` is `[]`.

3. **Return the URL.** If GitHub refused the write, return the ready title and body plus the exact access error.
   - Completion criterion: the caller has the Issue URL, or a complete unwritten draft and the write error.
