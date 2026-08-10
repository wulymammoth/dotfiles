# Maintained Superpowers Fork and Design Lock v2 Activation

**Status:** Accepted in conversation on 2026-08-09; implementation and
publication remain separately gated.

**Decision owner:** Repository owner

## Goal

Make `wulymammoth/superpowers` the durable Superpowers distribution used by
Codex, activate the verified Design Lock v2 behavior locally, and continue
absorbing stable changes from `obra/superpowers` without importing its
development branch into the maintained fork.

The first activation is a reversible local trial. It does not push, rewrite a
remote branch, merge a pull request, close a pull request, release, or clean up
the existing feature worktree.

## Current Evidence

| Surface | Verified state |
|---|---|
| Primary fork checkout | `main` at `2b0104c`; `origin/main` is the same commit |
| Stable canonical baseline | `upstream/main` is contained by fork `main` |
| Complete Design Lock v2 checkpoint | `47e868d`, exactly 20 commits ahead of `2b0104c` |
| Upstream-PR feature head | `3cad75a`, which adds a final merge of `upstream/dev` |
| Codex marketplace | `superpowers-dev`, sourced from the primary fork checkout |
| Installed Codex cache | Version `6.2.0`; inspected runtime skills are v1 and the embedded cache HEAD is `4f6a227`, not v2 |
| Primary untracked spec | Byte-identical to the tracked v2 spec |
| Primary untracked plan | An earlier copy that differs from the completed tracked v2 plan |

The crucial topology is that `2b0104c` is a direct ancestor of `47e868d`.
Therefore the maintained fork can adopt all verified v2 commits with a
fast-forward. Cherry-picking, rebasing, or merging the later `3cad75a` feature
head would add risk without adding any v2 behavior.

## Branch and Remote Contract

- `origin` is the owned distribution remote: `wulymammoth/superpowers`.
- `upstream` is the read-only vendor remote: `obra/superpowers`.
- Fork `main` follows stable `upstream/main` and carries owned changes on top.
- Routine synchronization fetches and merges `upstream/main` into fork `main`,
  verifies the combined result, then pushes `main` to `origin` only after a
  separate approval.
- `upstream/dev` is not a routine input to fork `main`.
- The existing `feat/visual-design-lock-v2` branch and its draft upstream PR may
  remain for historical review, but neither is the fork's runtime source of
  truth.
- Published fork history is not force-rewritten for ordinary synchronization or
  rollback.

## Approaches Considered

### 1. Trial the pre-dev checkpoint, then promote it — selected

Protect the primary checkout's untracked files, create a local safety branch,
fast-forward local `main` to `47e868d`, verify it, refresh the installer-managed
Codex cache, and test it from a newly started Codex session. Push only after the
owner accepts the trial.

This keeps one durable source of truth, excludes `upstream/dev`, and retains a
clean pre-publication rollback boundary.

### 2. Run Codex from the feature branch — rejected

Repointing the marketplace at `feat/visual-design-lock-v2` would be quick, but
would make a temporary PR branch the runtime source of truth and would activate
the final `upstream/dev` merge. Fork `main` and the installed plugin would then
describe different products.

### 3. Merge the current feature head into fork main — rejected

This is mechanically simple but imports `upstream/dev`, contradicting the
stable-baseline decision and increasing future merge conflicts.

## Local Trial Design

### 1. Fail-closed preflight

Immediately before any mutation:

1. Fetch current remote references and re-check the expected commits and remote
   URLs.
2. Require primary `main` and `origin/main` to remain at `2b0104c`.
3. Require `47e868d` to remain exactly 20 commits ahead of primary `main` and
   require the final `3cad75a` merge to remain excluded from the proposed
   integration.
4. Require the primary checkout to contain no unexpected changes beyond the two
   already inventoried untracked Design Lock documents.
5. Record SHA-256 hashes for both untracked files.
6. Save only those two paths in a clearly named, include-untracked Git stash and
   verify that the stash contains both exact blobs.
7. Create a local safety branch at `2b0104c` and require the primary checkout to
   be clean before continuing.

The stash and safety branch remain until the owner accepts both local behavior
and any later remote promotion. They are not cleanup targets during activation.

### 2. Integrate without development-branch history

On primary `main`, fast-forward only to `47e868d`. Do not merge or reset to
`feat/visual-design-lock-v2` or `3cad75a`.

Post-integration ancestry checks must prove:

- `47e868d` is now contained by local `main`;
- `upstream/main` remains contained by local `main`;
- the `upstream/dev` head merged by `3cad75a` is not contained by local `main`;
- `origin/main` remains unchanged during the trial.

Because this is a fast-forward over already reviewed commits, it creates no new
integration commit.

### 3. Deterministic verification

Run the smallest complete local suite that covers the changed v2 surfaces:

- `npm test` under `tests/brainstorm-server`;
- `scripts/lint-shell.sh`;
- `git diff --check`;
- focused scans confirming the approved-PNG, authority-discovery, capture-gate,
  legacy-HTML, and runtime-screenshot contracts remain present;
- focused scans confirming the removed HTML exporter and its tests remain
  absent.

The existing cross-vendor eval evidence remains evidence for the unchanged
commit contents. This activation does not rerun Gauntlet, use a Claude OAuth
token, incur independent QA calls, or claim new provider evidence.

Any failed check stops the trial before plugin activation.

### 4. Refresh the installed Codex plugin

Keep the existing local marketplace source pointed at the primary fork
checkout. Re-run `codex plugin add superpowers@superpowers-dev`; Codex 0.147.0
refreshes an already-installed same-version plugin to the local source's current
Git commit. Do not remove the working plugin first, and do not edit the cache
directly. Removal creates an unnecessary failure window, while direct cache
edits are installer-hostile and are not durable.

After refreshing, verify:

- `codex plugin list` reports `superpowers@superpowers-dev` installed and
  enabled from the expected primary checkout;
- hashes of the cached `brainstorming/SKILL.md`,
  `brainstorming/visual-companion.md`, and `writing-plans/SKILL.md` match the
  source at local fork `main`;
- the cache contains the v2 PNG/capture language and no active v1 HTML-export
  contract.

Retain the existing marketplace name and upstream version during this first
activation. The active fork commit and verified cache hashes provide provenance
without adding fork-only packaging churn. A distinct marketplace or fork
version becomes worthwhile only if the fork is distributed to other machines
or users.

### 5. New-session smoke proof

Running Codex sessions do not hot-reload plugin skills. Close or leave the old
session unchanged and start a new Codex session after the cache refresh.

The smoke proof must show that the fresh session loads the v2 skill text and
reports the screenshot-first Design Lock contract. A semantic provider-backed
exercise requires a separate explicit approval; static cache inspection alone
must not be described as provider proof.

### 6. Acceptance and promotion

Report the local trial as one of:

- `LOCAL_READY`: deterministic verification and cache proof pass, and the fresh
  session is ready for owner evaluation;
- `BLOCKED`: a preflight, integration, verification, cache, or fresh-session
  proof failed.

Only after the owner accepts the local trial may fork `main` be pushed to
`origin/main`. Pushing, changing or closing either existing upstream PR, and
deleting any branch, stash, or worktree remain separate actions.

## Rollback

### Before remote promotion

Rollback is local and preserves evidence:

1. Stop using newly started v2 sessions.
2. Confirm the primary checkout contains no new work.
3. With explicit destructive-action approval, return local `main` to the named
   safety branch at `2b0104c`.
4. Reinstall the plugin through Codex so its cache again matches v1.
5. Restore or retain the named untracked-file stash as directed by the owner.

`origin/main` is unchanged, so no remote rewrite is required.

### After remote promotion

Do not force-push the published fork backward. Create an ordinary reviewed
rollback commit against fork `main`, verify it, and push it through the normal
approval gate. The safety branch and preflight hashes remain comparison
evidence until cleanup is explicitly approved.

## Upstream Synchronization Procedure

For each later upstream update:

1. Fetch `upstream` and inspect the stable `upstream/main` delta.
2. Merge `upstream/main` into a local fork-main integration branch or isolated
   worktree.
3. Resolve conflicts by preserving owned Design Lock contracts unless an
   explicit superseding decision changes them.
4. Run upstream's relevant suite plus the focused Design Lock deterministic
   checks.
5. Review the complete delta and obtain push approval.
6. Fast-forward or merge the verified result into fork `main`, push to
   `origin/main`, refresh the Codex plugin cache, and start new sessions.

An upstream release is not active locally merely because it was fetched or
merged; source integration, plugin-cache refresh, and fresh-session proof are
distinct gates.

## Failure Handling

Stop without improvising when:

- any expected commit or remote has drifted;
- primary contains an unexpected dirty path;
- the stash cannot be proven to contain the exact untracked files;
- the proposed update is not fast-forward-only to `47e868d`;
- any deterministic test fails;
- plugin refresh changes unrelated configuration;
- source and cache hashes differ;
- a fresh session cannot prove it loaded v2.

Never respond to one of these failures by deleting the cache manually, dropping
the stash, force-updating a branch, importing `upstream/dev`, or rerunning paid
evaluation without a new decision and approval.

## Acceptance Criteria

- Local fork `main` contains `47e868d` and excludes the final
  `upstream/dev` merge.
- `origin/main` remains unchanged until separately approved.
- The two pre-existing untracked files are recoverable with verified hashes.
- Deterministic v2 verification passes from the primary checkout.
- The installer-managed Codex cache matches local fork `main` for every changed
  runtime skill.
- A newly started Codex session, not the pre-activation session, loads v2.
- The local safety branch, stash, feature worktree, eval checkout, and open PRs
  remain intact.
- Later stable upstream changes have one documented inbound path through
  `upstream/main`.

## Out of Scope

- Merging from or continuously tracking `upstream/dev`.
- Force-pushing or rewriting the fork's published history.
- Closing, merging, or editing the existing core or eval PRs.
- Re-running paid or provider-backed evaluation.
- Rebranding or publishing a fork-specific plugin package in this slice.
- Removing the v1 safety branch, stash, feature branch, worktree, or eval
  checkout.

## TDD Note

This document establishes Git and local-activation policy rather than new
application behavior. TDD is not applicable to the document itself. The later
execution plan must use ancestry assertions, focused behavioral tests, cache
hash comparisons, and a fresh-session smoke proof as executable acceptance
checks.
