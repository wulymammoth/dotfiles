# Superpowers Fork Main Activation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use
> `superpowers:executing-plans` to implement this plan task-by-task. This is one
> stateful, machine-global activation sequence; keep one top-level writer and do
> not dispatch parallel implementers. Steps use checkbox (`- [ ]`) syntax for
> tracking.

**Goal:** Activate the verified Design Lock v2 checkpoint from the maintained
Superpowers fork in newly started Codex sessions without importing
`upstream/dev`, changing the hosted fork, or losing the recoverable v1 state.

**Architecture:** Protect the primary checkout with a named stash and safety
branch, then fast-forward local fork `main` to the exact pre-dev checkpoint
`47e868d`. Verify the unchanged reviewed source, prove the installer path in an
isolated `CODEX_HOME`, refresh the live same-version cache with an idempotent
`codex plugin add`, and require a fresh-session smoke proof before proposing any
remote promotion.

**Tech Stack:** Git linked worktrees and refs, zsh, SHA-256, npm, shell tests,
Codex CLI 0.147.0 plugin marketplaces, JSON plus `jq`, and a disposable private
evidence directory.

**Spec:** `docs/superpowers-fork-main-activation-design.md`

## Global Constraints

- Primary fork checkout: `/Users/wulymammoth/Desktop/lab/superpowers`.
- Core feature worktree:
  `/Users/wulymammoth/Desktop/lab/superpowers/.worktrees/design-lock-v2`.
- Nested eval checkout:
  `/Users/wulymammoth/Desktop/lab/superpowers/.worktrees/design-lock-v2/evals`.
- Owned remote: `origin = git@github.com:wulymammoth/superpowers.git`.
- Vendor remote: `upstream = https://github.com/obra/superpowers.git`.
- Expected primary and hosted fork start:
  `2b0104cc4f4198a6e8d2f3c5ba076712515901ad`.
- Required v2 integration target:
  `47e868d792443cd1765892e4db28767b5265ac16`.
- Excluded feature merge:
  `3cad75a4b285366ae496e5112f89595e292c0e46`, whose second parent is
  `034958f842a174077e1900345c958063f4595f95` from `upstream/dev`.
- Safety branch: `safety/pre-design-lock-v2-20260809` at `2b0104c`.
- Stash message: `pre-design-lock-v2-main-activation-20260809`.
- Evidence root:
  `/private/tmp/superpowers-design-lock-v2-local-trial-20260809`, mode `0700`;
  it contains no tokens, raw provider data, or authenticated URLs.
- The only allowed primary-source integration is an `--ff-only` update from
  `2b0104c` to `47e868d`. Do not merge the feature head or `upstream/dev`.
- Do not push, force-push, open/edit/close/merge a PR, release, delete a branch,
  drop or pop the stash, remove a worktree, reset a branch, or clean a checkout.
- Do not run Gauntlet, Quorum, Claude OAuth, a paid independent judge, or another
  provider-backed eval. A new Codex smoke session retains its own explicit gate.
- Do not edit installer-managed files under `~/.codex/plugins/cache` directly.
- Do not remove the live Superpowers plugin before refreshing it. Codex 0.147.0
  has been proven to refresh a same-version local plugin through another
  `plugin add` while leaving `config.toml` byte-identical.
- Existing Codex sessions remain stale by design. Never present their loaded
  skill text as v2 proof.
- The feature worktree, eval checkout, open PRs, safety branch, stash, and proof
  directory remain preserved at either terminal state.
- No new Superpowers commit is expected: `47e868d` is the reviewed checkpoint.
  A local fast-forward is not permission to create, push, or rewrite commits.
- Stop at `LOCAL_READY`, `LOCAL_READY (STATIC_ONLY)`, or `BLOCKED`; remote
  promotion and cleanup require later, separate approvals.

---

### Task 1: Protect and Reconcile the Pre-Activation State

**Files and state:**

- Read: `docs/superpowers-fork-main-activation-design.md`
- Preserve:
  `/Users/wulymammoth/Desktop/lab/superpowers/docs/superpowers/plans/2026-08-07-visual-design-lock-v2.md`
- Preserve:
  `/Users/wulymammoth/Desktop/lab/superpowers/docs/superpowers/specs/2026-08-07-visual-design-lock-v2-design.md`
- Create: local branch `safety/pre-design-lock-v2-20260809`
- Create: named Git stash containing only the two paths above
- Create: `/private/tmp/superpowers-design-lock-v2-local-trial-20260809/`

**Interfaces:**

- Consumes: exact remote URLs, primary `main`/`origin/main` at `2b0104c`, v2
  checkpoint `47e868d`, clean feature/eval checkouts, and the two known untracked
  primary documents.
- Produces: a clean primary checkout on `main`, exact safety ref at `2b0104c`,
  verified stash blobs, and a private evidence root used by Tasks 2-4.

- [ ] **Step 1: Re-read the contract and refresh read-only remote references**

```bash
set -euo pipefail

DOTFILES=/Users/wulymammoth/dotfiles
REPO=/Users/wulymammoth/Desktop/lab/superpowers
FEATURE="$REPO/.worktrees/design-lock-v2"
EVALS="$FEATURE/evals"
PROOF=/private/tmp/superpowers-design-lock-v2-local-trial-20260809
BASE=2b0104cc4f4198a6e8d2f3c5ba076712515901ad
V2=47e868d792443cd1765892e4db28767b5265ac16
FEATURE_HEAD=3cad75a4b285366ae496e5112f89595e292c0e46
DEV_PARENT=034958f842a174077e1900345c958063f4595f95
SAFETY=safety/pre-design-lock-v2-20260809
STASH_MESSAGE=pre-design-lock-v2-main-activation-20260809
PLAN=docs/superpowers/plans/2026-08-07-visual-design-lock-v2.md
SPEC=docs/superpowers/specs/2026-08-07-visual-design-lock-v2-design.md

test ! -e "$PROOF"
umask 077
mkdir -m 700 "$PROOF"
cat > "$PROOF/env" <<EOF
DOTFILES=$DOTFILES
REPO=$REPO
FEATURE=$FEATURE
EVALS=$EVALS
PROOF=$PROOF
BASE=$BASE
V2=$V2
FEATURE_HEAD=$FEATURE_HEAD
DEV_PARENT=$DEV_PARENT
SAFETY=$SAFETY
STASH_MESSAGE=$STASH_MESSAGE
PLAN=$PLAN
SPEC=$SPEC
EOF

sed -n '1,280p' "$DOTFILES/docs/superpowers-fork-main-activation-design.md"
git -C "$REPO" fetch origin
git -C "$REPO" fetch upstream

test "$(git -C "$REPO" remote get-url origin)" = \
  'git@github.com:wulymammoth/superpowers.git'
test "$(git -C "$REPO" remote get-url upstream)" = \
  'https://github.com/obra/superpowers.git'
```

Expected: the design names stable `upstream/main`, target `47e868d`, an
add-only plugin refresh, and separate push/cleanup gates. Both fetches exit 0
and neither remote URL differs. Fetching does not mutate a hosted repository.

- [ ] **Step 2: Assert the exact Git topology and owned checkout state**

```bash
set -euo pipefail
source /private/tmp/superpowers-design-lock-v2-local-trial-20260809/env

test "$(git -C "$REPO" branch --show-current)" = main
test "$(git -C "$REPO" rev-parse HEAD)" = "$BASE"
test "$(git -C "$REPO" rev-parse origin/main)" = "$BASE"
test "$(git -C "$REPO" rev-list --left-right --count "$BASE...$V2")" = $'0\t20'
test "$(git -C "$REPO" show -s --format='%P' "$FEATURE_HEAD")" = \
  "$V2 $DEV_PARENT"
git -C "$REPO" merge-base --is-ancestor upstream/main "$BASE"

test "$(git -C "$FEATURE" rev-parse HEAD)" = "$FEATURE_HEAD"
test -z "$(git -C "$FEATURE" status --porcelain=v1)"
test "$(git -C "$EVALS" rev-parse HEAD)" = \
  2e767eebe45a362c0d175e8d8f9177ea53d7440b
test -z "$(git -C "$EVALS" status --porcelain=v1)"

EXPECTED_STATUS=$'?? docs/superpowers/plans/2026-08-07-visual-design-lock-v2.md\n?? docs/superpowers/specs/2026-08-07-visual-design-lock-v2-design.md'
ACTUAL_STATUS=$(git -C "$REPO" status --porcelain=v1)
test "$ACTUAL_STATUS" = "$EXPECTED_STATUS"
printf '%s\n' "$ACTUAL_STATUS" > "$PROOF/primary-status-before.txt"
```

Expected: every assertion passes. If `upstream/main` advanced beyond `BASE`, an
owned checkout is dirty, or an expected head changed, stop `BLOCKED
(REMOTE_OR_LOCAL_DRIFT)` and revise the integration target.

- [ ] **Step 3: Create private evidence and record the untracked blobs**

```bash
set -euo pipefail
source /private/tmp/superpowers-design-lock-v2-local-trial-20260809/env

(
  cd "$REPO"
  shasum -a 256 "$PLAN" "$SPEC"
) | tee "$PROOF/untracked-before.sha256"

rg -n '^04ef911abd11dce22f85742c0aebb753e52957f2243cfb996ed2b55b459d4632  ' \
  "$PROOF/untracked-before.sha256"
rg -n '^453953bdf8343e78d996df5ad36df82b74b2e34367dd34f553510a09dc48d51a  ' \
  "$PROOF/untracked-before.sha256"
```

Expected: private evidence exists; plan hash is `04ef...4632`; spec hash is
`4539...d51a`.

- [ ] **Step 4: Stash only the inventoried paths and verify their blobs**

```bash
set -euo pipefail
source /private/tmp/superpowers-design-lock-v2-local-trial-20260809/env

git -C "$REPO" stash push --include-untracked \
  -m "$STASH_MESSAGE" -- "$PLAN" "$SPEC"

test -z "$(git -C "$REPO" status --porcelain=v1)"
test "$(git -C "$REPO" stash list -1 --format='%gs')" = \
  "On main: $STASH_MESSAGE"

STASH=$(git -C "$REPO" rev-parse 'stash@{0}')
printf '%s\n' "$STASH" | tee "$PROOF/stash-commit.txt"
git -C "$REPO" stash show --include-untracked --name-only 'stash@{0}' \
  | sort | tee "$PROOF/stash-paths.txt"
printf '%s\n' "$PLAN" "$SPEC" | sort > "$PROOF/expected-stash-paths.txt"
cmp "$PROOF/expected-stash-paths.txt" "$PROOF/stash-paths.txt"

{
  git -C "$REPO" show "${STASH}^3:$PLAN" | shasum -a 256
  git -C "$REPO" show "${STASH}^3:$SPEC" | shasum -a 256
} | tee "$PROOF/untracked-stashed.sha256"

test "$(sed -n '1s/ .*//p' "$PROOF/untracked-stashed.sha256")" = \
  04ef911abd11dce22f85742c0aebb753e52957f2243cfb996ed2b55b459d4632
test "$(sed -n '2s/ .*//p' "$PROOF/untracked-stashed.sha256")" = \
  453953bdf8343e78d996df5ad36df82b74b2e34367dd34f553510a09dc48d51a
```

Expected: primary is clean; newest stash contains exactly the two paths; stash
blob hashes match the originals.

- [ ] **Step 5: Create and record the local safety checkpoint**

```bash
set -euo pipefail
source /private/tmp/superpowers-design-lock-v2-local-trial-20260809/env

if git -C "$REPO" show-ref --verify --quiet "refs/heads/$SAFETY"; then
  test "$(git -C "$REPO" rev-parse "$SAFETY")" = "$BASE"
else
  git -C "$REPO" branch "$SAFETY" "$BASE"
fi

test "$(git -C "$REPO" rev-parse "$SAFETY")" = "$BASE"
test "$(git -C "$REPO" rev-parse HEAD)" = "$BASE"
test -z "$(git -C "$REPO" status --porcelain=v1)"

{
  git -C "$REPO" status --short --branch
  git -C "$REPO" show -s --format='main=%H %s' main
  git -C "$REPO" show -s --format='origin_main=%H %s' origin/main
  git -C "$REPO" show -s --format='safety=%H %s' "$SAFETY"
  git -C "$REPO" stash list -1 --format='stash=%H %gs'
} | tee "$PROOF/protected-state.txt"
```

Expected: safety, local `main`, and `origin/main` name `2b0104c`; stash remains.
Do not create a new commit—the safety ref and stash are the checkpoint.

---

### Task 2: Fast-Forward Fork Main and Verify the Exact v2 Source

**Files and state:**

- Advance: local `main` from `2b0104c` to `47e868d`
- Verify: the exact ten-path delta from `origin/main`
- Test: `tests/brainstorm-server/`
- Test: `scripts/lint-shell.sh`
- Read: the three changed runtime skill files
- Preserve: `origin/main`, safety branch, stash, feature worktree, eval checkout

**Interfaces:**

- Consumes: Task 1's clean primary, safety ref, verified stash, and evidence.
- Produces: local `main` at reviewed v2 with deterministic evidence; Task 3 uses
  this primary checkout as its marketplace source.

- [ ] **Step 1: Reconcile the checkpoint and fast-forward local main**

```bash
set -euo pipefail
source /private/tmp/superpowers-design-lock-v2-local-trial-20260809/env

test "$(git -C "$REPO" rev-parse HEAD)" = "$BASE"
test "$(git -C "$REPO" rev-parse origin/main)" = "$BASE"
test "$(git -C "$REPO" rev-parse "$SAFETY")" = "$BASE"
test -z "$(git -C "$REPO" status --porcelain=v1)"
test "$(git -C "$REPO" stash list -1 --format='%gs')" = \
  "On main: $STASH_MESSAGE"
test "$(git -C "$REPO" rev-list --left-right --count HEAD..."$V2")" = $'0\t20'

git -C "$REPO" merge --ff-only "$V2"
```

Expected: `Updating 2b0104c..47e868d` and `Fast-forward`. Any merge commit,
conflict, or non-fast-forward is `BLOCKED (INTEGRATION_DRIFT)`.

- [ ] **Step 2: Prove ancestry, remote isolation, and exact path delta**

```bash
set -euo pipefail
source /private/tmp/superpowers-design-lock-v2-local-trial-20260809/env

test "$(git -C "$REPO" rev-parse HEAD)" = "$V2"
test "$(git -C "$REPO" rev-parse origin/main)" = "$BASE"
test "$(git -C "$REPO" rev-parse "$SAFETY")" = "$BASE"
git -C "$REPO" merge-base --is-ancestor upstream/main HEAD
git -C "$REPO" merge-base --is-ancestor "$V2" HEAD
if git -C "$REPO" merge-base --is-ancestor "$DEV_PARENT" HEAD; then
  echo 'ERROR: upstream/dev parent entered fork main' >&2
  exit 1
fi

git -C "$REPO" diff --name-status origin/main..HEAD \
  | tee "$PROOF/v2-name-status.txt"
cat > "$PROOF/expected-v2-name-status.txt" <<'EOF'
A	docs/superpowers/plans/2026-08-07-visual-design-lock-v2.md
A	docs/superpowers/specs/2026-08-07-visual-design-lock-v2-design.md
A	docs/superpowers/specs/2026-08-07-visual-design-lock-v2-eval-results.md
M	skills/brainstorming/SKILL.md
D	skills/brainstorming/scripts/export-mockup.cjs
D	skills/brainstorming/scripts/export-mockup.sh
M	skills/brainstorming/visual-companion.md
M	skills/writing-plans/SKILL.md
D	tests/brainstorm-server/export-mockup.test.js
M	tests/brainstorm-server/package.json
EOF
cmp "$PROOF/expected-v2-name-status.txt" "$PROOF/v2-name-status.txt"
git -C "$REPO" diff --check origin/main..HEAD
```

Expected: exactly ten changed paths, no dev parent, and no whitespace errors.

- [ ] **Step 3: Run deterministic v2 verification**

```bash
set -euo pipefail
source /private/tmp/superpowers-design-lock-v2-local-trial-20260809/env

(
  cd "$REPO/tests/brainstorm-server"
  npm test
) | tee "$PROOF/brainstorm-server-tests.txt"

(
  cd "$REPO"
  scripts/lint-shell.sh
) | tee "$PROOF/shell-tests.txt"

test -z "$(git -C "$REPO" status --porcelain=v1)"
```

Expected: both exit 0 (last verified: 144/0 brainstorm-server, 134/0 shell),
and tests leave primary clean. Do not silently install missing dependencies.

- [ ] **Step 4: Prove v2 content, source hashes, and preserved state**

```bash
set -euo pipefail
source /private/tmp/superpowers-design-lock-v2-local-trial-20260809/env

rg -n 'creating or finalizing design specifications and Visual Design Locks' \
  "$REPO/skills/brainstorming/SKILL.md"
rg -n 'approved PNG artifacts' "$REPO/skills/brainstorming/SKILL.md"
rg -n 'Design Lock capture hard gate' "$REPO/skills/brainstorming/SKILL.md"

rg -n 'Human-authored guidance' "$REPO/skills/brainstorming/visual-companion.md"
rg -n 'STYLE\.md' "$REPO/skills/brainstorming/visual-companion.md"
rg -n 'STYLEGUIDE\.md' "$REPO/skills/brainstorming/visual-companion.md"
rg -n 'DESIGN_SYSTEM\.md' "$REPO/skills/brainstorming/visual-companion.md"
rg -n 'design-language documents' "$REPO/skills/brainstorming/visual-companion.md"
rg -n 'Style Dictionary configuration' "$REPO/skills/brainstorming/visual-companion.md"
rg -n 'Storybook or another component catalog' \
  "$REPO/skills/brainstorming/visual-companion.md"
rg -n 'Check screenshot capability' "$REPO/skills/brainstorming/visual-companion.md"
rg -n 'no HTML fallback' "$REPO/skills/brainstorming/visual-companion.md"

rg -n 'v2 Design Lock with approved PNG screenshots' \
  "$REPO/skills/writing-plans/SKILL.md"
rg -n 'capture a runtime screenshot' "$REPO/skills/writing-plans/SKILL.md"
rg -n 'legacy HTML Design Lock' "$REPO/skills/writing-plans/SKILL.md"
rg -n 'explicit continuation without a v2 Design Lock' \
  "$REPO/skills/writing-plans/SKILL.md"

if rg -n 'export-mockup|HTML is the artifact|Opportunistic screenshot|HTML, plus PNG when captured|diffing DOM structure' \
  "$REPO/skills/brainstorming/SKILL.md" \
  "$REPO/skills/brainstorming/visual-companion.md" \
  "$REPO/skills/writing-plans/SKILL.md"; then
  echo 'ERROR: active v1 Design Lock language remains' >&2
  exit 1
fi

test ! -e "$REPO/skills/brainstorming/scripts/export-mockup.cjs"
test ! -e "$REPO/skills/brainstorming/scripts/export-mockup.sh"
test ! -e "$REPO/tests/brainstorm-server/export-mockup.test.js"

(
  cd "$REPO"
  shasum -a 256 \
    skills/brainstorming/SKILL.md \
    skills/brainstorming/visual-companion.md \
    skills/writing-plans/SKILL.md
) | tee "$PROOF/source-v2.sha256"
cat > "$PROOF/expected-source-v2.sha256" <<'EOF'
31ec6af86eb07a2af12db818dd000363e7716e0a91542419137c7e45299cb6f9  skills/brainstorming/SKILL.md
a8952833731e245f64e52e5be1fdd610c43016f5d5a6fd7075b86d04cb1e5582  skills/brainstorming/visual-companion.md
e58c772e5752f3e3626d23ea2bcd0009312429074608a33c2b8734298e93c6fd  skills/writing-plans/SKILL.md
EOF
cmp "$PROOF/expected-source-v2.sha256" "$PROOF/source-v2.sha256"

test "$(git -C "$FEATURE" rev-parse HEAD)" = "$FEATURE_HEAD"
test -z "$(git -C "$FEATURE" status --porcelain=v1)"
test "$(git -C "$EVALS" rev-parse HEAD)" = \
  2e767eebe45a362c0d175e8d8f9177ea53d7440b
test -z "$(git -C "$EVALS" status --porcelain=v1)"
test "$(git -C "$REPO" stash list -1 --format='%gs')" = \
  "On main: $STASH_MESSAGE"
```

Expected: exact `47e868d` hashes match, v2 terms are present, v1 exporter terms
and paths are absent, feature/eval remain clean, and stash remains. No new
commit is created; local `main` at reviewed `47e868d` is the checkpoint.

---

### Task 3: Prove and Apply the Add-Only Codex Plugin Refresh

**Files and state:**

- Read: `/Users/wulymammoth/.codex/config.toml`
- Refresh:
  `/Users/wulymammoth/.codex/plugins/cache/superpowers-dev/superpowers/6.2.0`
- Create: `$PROOF/codex-home/` plus JSON and SHA-256 evidence
- Do not modify: marketplace source, unrelated plugins, or dotfiles links

**Interfaces:**

- Consumes: Task 2's clean source at `47e868d` and `source-v2.sha256`.
- Produces: isolated installer proof, live add-only refresh, unchanged live
  config, and live cache equal to source v2.

- [ ] **Step 1: Install the v2 source in an isolated Codex home**

```bash
set -euo pipefail
source /private/tmp/superpowers-design-lock-v2-local-trial-20260809/env
ISOLATED_HOME="$PROOF/codex-home"
test ! -e "$ISOLATED_HOME"
mkdir -m 700 "$ISOLATED_HOME"

CODEX_HOME="$ISOLATED_HOME" codex plugin marketplace add "$REPO" --json \
  | tee "$PROOF/isolated-marketplace-add.json"
CODEX_HOME="$ISOLATED_HOME" codex plugin add superpowers@superpowers-dev --json \
  | tee "$PROOF/isolated-plugin-add.json"
CODEX_HOME="$ISOLATED_HOME" codex plugin list --json --marketplace superpowers-dev \
  | tee "$PROOF/isolated-plugin-list.json"

jq -e --arg repo "$REPO" '
  .marketplaceName == "superpowers-dev" and
  .installedRoot == $repo and .alreadyAdded == false
' "$PROOF/isolated-marketplace-add.json"
jq -e --arg root "$ISOLATED_HOME/plugins/cache/superpowers-dev/superpowers/6.2.0" '
  .pluginId == "superpowers@superpowers-dev" and
  .version == "6.2.0" and .installedPath == $root
' "$PROOF/isolated-plugin-add.json"
jq -e --arg repo "$REPO" '
  .installed | length == 1 and
  .installed[0].pluginId == "superpowers@superpowers-dev" and
  .installed[0].enabled == true and
  .installed[0].marketplaceSource.source == $repo
' "$PROOF/isolated-plugin-list.json"
```

Expected: all JSON assertions pass without reading or modifying live Codex state
and without launching a provider.

- [ ] **Step 2: Verify the isolated cache is exact v2**

```bash
set -euo pipefail
source /private/tmp/superpowers-design-lock-v2-local-trial-20260809/env
ISOLATED_HOME="$PROOF/codex-home"
ISOLATED_CACHE="$ISOLATED_HOME/plugins/cache/superpowers-dev/superpowers/6.2.0"
(
  cd "$ISOLATED_CACHE"
  shasum -a 256 \
    skills/brainstorming/SKILL.md \
    skills/brainstorming/visual-companion.md \
    skills/writing-plans/SKILL.md
) | tee "$PROOF/isolated-cache-v2.sha256"

cmp "$PROOF/source-v2.sha256" "$PROOF/isolated-cache-v2.sha256"
test "$(git -C "$ISOLATED_CACHE" rev-parse HEAD)" = "$V2"
```

Expected: isolated cache hashes and Git HEAD equal source `47e868d`. Stop before
live activation on any mismatch.

- [ ] **Step 3: Snapshot the live v1 boundary**

```bash
set -euo pipefail
source /private/tmp/superpowers-design-lock-v2-local-trial-20260809/env
LIVE_HOME=/Users/wulymammoth/.codex
LIVE_CACHE="$LIVE_HOME/plugins/cache/superpowers-dev/superpowers/6.2.0"

shasum -a 256 "$LIVE_HOME/config.toml" \
  | tee "$PROOF/live-config-before.sha256"
codex plugin marketplace list --json \
  | tee "$PROOF/live-marketplaces-before.json"
codex plugin list --json --marketplace superpowers-dev \
  | tee "$PROOF/live-plugin-before.json"

(
  cd "$LIVE_CACHE"
  shasum -a 256 \
    skills/brainstorming/SKILL.md \
    skills/brainstorming/visual-companion.md \
    skills/writing-plans/SKILL.md
) | tee "$PROOF/live-cache-v1.sha256"
cat > "$PROOF/expected-live-cache-v1.sha256" <<'EOF'
9214e3d188d8e3eb01b69e52cf8bb33a3a4a2dc7add19acdd556b5dd59efdbdb  skills/brainstorming/SKILL.md
30f246179d225ee176976deb8254f3f44089cc18067be16822acc188f8a42224  skills/brainstorming/visual-companion.md
2b07a7c4c4ac53ec78bb096dc1a1c48d421221c0ecd247eee36895113ffa7902  skills/writing-plans/SKILL.md
EOF
cmp "$PROOF/expected-live-cache-v1.sha256" "$PROOF/live-cache-v1.sha256"
test "$(git -C "$LIVE_CACHE" rev-parse HEAD)" = \
  4f6a227fbf4bce7713f8cb2c898e8b91bab3bcd1
test "$(git -C "$LIVE_CACHE" status --porcelain=v1)" = ' D AGENTS.md'

jq -e --arg repo "$REPO" '
  .installed | length == 1 and
  .installed[0].pluginId == "superpowers@superpowers-dev" and
  .installed[0].enabled == true and
  .installed[0].marketplaceSource.source == $repo
' "$PROOF/live-plugin-before.json"
```

Expected: live config and plugin provenance are recorded; the three relevant
runtime files are exactly v1; the older installer snapshot is at `4f6a227` with
only its intentional `AGENTS.md` pruning. A mismatch is `BLOCKED
(LIVE_STATE_DRIFT)`.

- [ ] **Step 4: Refresh the live plugin without removing it**

```bash
set -euo pipefail
source /private/tmp/superpowers-design-lock-v2-local-trial-20260809/env
LIVE_CACHE=/Users/wulymammoth/.codex/plugins/cache/superpowers-dev/superpowers/6.2.0

codex plugin add superpowers@superpowers-dev --json \
  | tee "$PROOF/live-plugin-refresh.json"

jq -e --arg root "$LIVE_CACHE" '
  .pluginId == "superpowers@superpowers-dev" and
  .version == "6.2.0" and .installedPath == $root
' "$PROOF/live-plugin-refresh.json"
```

Expected: add exits 0 with the same plugin ID, version, and cache path. There is
no preceding removal and no direct cache write.

- [ ] **Step 5: Prove config isolation and activated cache content**

```bash
set -euo pipefail
source /private/tmp/superpowers-design-lock-v2-local-trial-20260809/env
LIVE_HOME=/Users/wulymammoth/.codex
LIVE_CACHE="$LIVE_HOME/plugins/cache/superpowers-dev/superpowers/6.2.0"

shasum -a 256 "$LIVE_HOME/config.toml" \
  | tee "$PROOF/live-config-after.sha256"
cmp "$PROOF/live-config-before.sha256" "$PROOF/live-config-after.sha256"

codex plugin list --json --marketplace superpowers-dev \
  | tee "$PROOF/live-plugin-after.json"
jq -e --arg repo "$REPO" '
  .installed | length == 1 and
  .installed[0].pluginId == "superpowers@superpowers-dev" and
  .installed[0].enabled == true and
  .installed[0].marketplaceSource.source == $repo
' "$PROOF/live-plugin-after.json"

(
  cd "$LIVE_CACHE"
  shasum -a 256 \
    skills/brainstorming/SKILL.md \
    skills/brainstorming/visual-companion.md \
    skills/writing-plans/SKILL.md
) | tee "$PROOF/live-cache-v2.sha256"

cmp "$PROOF/source-v2.sha256" "$PROOF/live-cache-v2.sha256"
test "$(git -C "$LIVE_CACHE" rev-parse HEAD)" = "$V2"

rg -n 'Design Lock capture hard gate' \
  "$LIVE_CACHE/skills/brainstorming/SKILL.md"
rg -n 'approved PNG artifacts' "$LIVE_CACHE/skills/brainstorming/SKILL.md"

rg -n 'STYLE\.md' "$LIVE_CACHE/skills/brainstorming/visual-companion.md"
rg -n 'STYLEGUIDE\.md' "$LIVE_CACHE/skills/brainstorming/visual-companion.md"
rg -n 'DESIGN_SYSTEM\.md' "$LIVE_CACHE/skills/brainstorming/visual-companion.md"
rg -n 'design-language documents' \
  "$LIVE_CACHE/skills/brainstorming/visual-companion.md"
rg -n 'Style Dictionary configuration' \
  "$LIVE_CACHE/skills/brainstorming/visual-companion.md"
rg -n 'Storybook or another component catalog' \
  "$LIVE_CACHE/skills/brainstorming/visual-companion.md"
rg -n 'Check screenshot capability' \
  "$LIVE_CACHE/skills/brainstorming/visual-companion.md"
rg -n 'no HTML fallback' "$LIVE_CACHE/skills/brainstorming/visual-companion.md"

rg -n 'approved PNG screenshots' "$LIVE_CACHE/skills/writing-plans/SKILL.md"
rg -n 'capture a runtime screenshot' "$LIVE_CACHE/skills/writing-plans/SKILL.md"
rg -n 'legacy HTML Design Lock' "$LIVE_CACHE/skills/writing-plans/SKILL.md"

if rg -n 'export-mockup|HTML is the artifact|Opportunistic screenshot|HTML, plus PNG when captured|diffing DOM structure' \
  "$LIVE_CACHE/skills/brainstorming/SKILL.md" \
  "$LIVE_CACHE/skills/brainstorming/visual-companion.md" \
  "$LIVE_CACHE/skills/writing-plans/SKILL.md"; then
  echo 'ERROR: live cache still exposes v1 Design Lock behavior' >&2
  exit 1
fi
```

Expected: config is byte-identical, plugin remains enabled from the same local
marketplace, and cache hashes plus Git HEAD equal `47e868d`. Current sessions
remain stale; this proves only the next-session filesystem boundary.

- [ ] **Step 6: Record the static activation checkpoint**

```bash
set -euo pipefail
source /private/tmp/superpowers-design-lock-v2-local-trial-20260809/env
LIVE_CACHE=/Users/wulymammoth/.codex/plugins/cache/superpowers-dev/superpowers/6.2.0

{
  git -C "$REPO" show -s --format='source=%H %s' HEAD
  git -C "$REPO" show -s --format='origin_main=%H %s' origin/main
  git -C "$REPO" show -s --format='safety=%H %s' "$SAFETY"
  git -C "$REPO" stash list -1 --format='stash=%H %gs'
  git -C "$LIVE_CACHE" show -s --format='cache=%H %s' HEAD
} | tee "$PROOF/static-activation-checkpoint.txt"
```

Expected: source/cache are `47e868d`; origin/safety remain `2b0104c`; stash
remains. Report `LOCAL_READY (STATIC_ONLY)` until Task 4 proves a new session.

---

### Task 4: Obtain Fresh-Session Proof and Stop Before Promotion

**Files and state:**

- Read: live v2 cache and Task 3 evidence
- Optionally create: one new Codex session after explicit provider approval
- Preserve: every repository, ref, stash, proof file, plugin cache, and PR
- Do not push or clean up

**Interfaces:**

- Consumes: Task 3's static activation checkpoint.
- Produces: `LOCAL_READY`, honest `LOCAL_READY (STATIC_ONLY)`, or a specific
  `BLOCKED` report plus a separate promotion decision.

- [ ] **Step 1: Reconcile static activation**

```bash
set -euo pipefail
source /private/tmp/superpowers-design-lock-v2-local-trial-20260809/env
LIVE_CACHE=/Users/wulymammoth/.codex/plugins/cache/superpowers-dev/superpowers/6.2.0

test "$(git -C "$REPO" rev-parse HEAD)" = "$V2"
test "$(git -C "$REPO" rev-parse origin/main)" = "$BASE"
test "$(git -C "$LIVE_CACHE" rev-parse HEAD)" = "$V2"
cmp "$PROOF/source-v2.sha256" "$PROOF/live-cache-v2.sha256"
test "$(git -C "$REPO" stash list -1 --format='%gs')" = \
  "On main: $STASH_MESSAGE"
```

Expected: static activation remains exact.

- [ ] **Step 2: Obtain a separate fresh-session approval or user handoff**

Explain that a fresh Codex session consumes normal Codex subscription usage but
does not invoke Gauntlet or Claude. Offer either:

1. the owner starts a new interactive Codex session and sends the smoke prompt;
2. the executor launches exactly one read-only `codex exec` after explicit
   approval.

Do not treat design or plan approval as provider-use approval.

```text
Without modifying any files, inspect the installed Superpowers brainstorming,
visual-companion, and writing-plans skills. Report: (1) which repository design
authority sources must be discovered, (2) what artifact completes a v2 Design
Lock, (3) how a legacy HTML lock is handled, and (4) what runtime visual proof an
implementation plan requires. Include the exact installed skill paths you read.
```

Expected concepts: human-authored guidance including `STYLE.md`, style guides,
design-system/design-language documents, Style Dictionary/token sources, and
component catalogs; approved PNG screenshots; equivalent screenshot
capture with no HTML fallback; legacy HTML migration or explicit continuation
without v2; runtime screenshot capture and visual comparison, with unavailable
proof reported incomplete.

- [ ] **Step 3: Classify the proof and deliver the terminal report**

If the owner declines a provider session, retain `LOCAL_READY (STATIC_ONLY)`.

If a fresh session reads the expected cache paths and reports every expected
concept without v1 HTML-export language, save only a sanitized transcript or
owner confirmation under `$PROOF` and classify `LOCAL_READY`.

If it loads v1, cites another cache, omits a gate, or cannot inspect installed
files, classify `BLOCKED (FRESH_SESSION_PROOF_FAILED)`. Do not refresh again or
start a second provider session without a new diagnosis and approval.

Report:

- local source HEAD and unchanged `origin/main`;
- included v2 target and excluded dev merge parent;
- deterministic test outcomes;
- isolated/live cache hashes and unchanged live config hash;
- fresh-session evidence class;
- safety/stash IDs, feature/eval preservation, and proof directory.

Then ask whether to promote local fork `main` to `origin/main`. Do not push in
this plan. Do not drop the stash, delete safety, remove a worktree, close PRs,
or remove proof files even if promotion is approved.

## Rollback Procedure — Explicit Rollback Approval Required

Before hosted promotion, rollback begins only from a clean primary checkout and
preserves the proof directory and stash:

```bash
set -euo pipefail
source /private/tmp/superpowers-design-lock-v2-local-trial-20260809/env
LIVE_CACHE=/Users/wulymammoth/.codex/plugins/cache/superpowers-dev/superpowers/6.2.0

test -z "$(git -C "$REPO" status --porcelain=v1)"
test "$(git -C "$REPO" rev-parse origin/main)" = "$BASE"
test "$(git -C "$REPO" rev-parse "$SAFETY")" = "$BASE"
test "$(git -C "$REPO" stash list -1 --format='%gs')" = \
  "On main: $STASH_MESSAGE"

# Destructive to local main; execute only after explicit rollback approval.
git -C "$REPO" reset --hard "$SAFETY"
codex plugin add superpowers@superpowers-dev --json \
  | tee "$PROOF/live-plugin-rollback.json"

test "$(git -C "$REPO" rev-parse HEAD)" = "$BASE"
test "$(git -C "$LIVE_CACHE" rev-parse HEAD)" = "$BASE"
```

Then hash the live cache and require:

```text
9214e3d188d8e3eb01b69e52cf8bb33a3a4a2dc7add19acdd556b5dd59efdbdb  skills/brainstorming/SKILL.md
30f246179d225ee176976deb8254f3f44089cc18067be16822acc188f8a42224  skills/brainstorming/visual-companion.md
2b07a7c4c4ac53ec78bb096dc1a1c48d421221c0ecd247eee36895113ffa7902  skills/writing-plans/SKILL.md
```

Do not pop or drop the stash automatically. Ask whether the two pre-existing
untracked files should be restored, retained, or archived after comparison with
the tracked v2 documents.
