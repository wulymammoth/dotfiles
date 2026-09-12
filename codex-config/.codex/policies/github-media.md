# GitHub committed image media

- For committed image media embedded in GitHub issue or pull-request Markdown,
  do not use `raw.githubusercontent.com` or tokenized download URLs in private
  repositories. Use a commit-pinned repository-relative source:
  `../blob/<full-commit-sha>/<repository-relative-path>?raw=true`.
- Before publishing or updating GitHub Markdown with committed media, verify
  each target exists at the pinned commit. After the mutation, re-read the
  artifact and confirm the expected embed count, zero forbidden raw-host URLs,
  and rendered visibility when an authenticated browser is available.
