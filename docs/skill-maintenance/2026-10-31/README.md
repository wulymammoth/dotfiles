# Architecture tooling integration

## Approved scope and plan

The owner requested `codebase-design`, `improve-codebase-architecture`,
`vercel-composition-patterns`, dependency-cruiser, and appropriate agent routing.
Effect is excluded. Startup checkout: `/Users/wulymammoth/dotfiles`, `main`,
`ad52237a14684037da62387285743ae8179c4214`.

- [x] Inspect existing discovery, package paths, prior decisions, and upstream sources.
- [x] Install missing skills; preserve the enabled architecture-review skill.
- [x] Install a pinned global dependency-cruiser executable.
- [x] Add concise global routing and progressive architecture guidance.
- [x] Verify native discovery, reference integrity, routing scenarios, and CLI enforcement.
- [x] Record installed versions, checks, and remaining scope limits.

Existing uncommitted memory-maintenance changes in AGENTS, README, context,
memory policies, and October 30 notes belong to the earlier completed task and
must be preserved. No commit, push, PR, or SoundCoaster checkout edits are part
of this installation.

## Initial evidence

- Native Codex `skills/list` found one enabled user-scoped
  `improve-codebase-architecture`, and neither of the other requested skills.
  The scan reported zero errors.
- The existing architecture skill and its referenced local documentation exist
  under `~/.agents/skills`; retain this working installation rather than importing
  upstream's new workflow dependencies or duplicating discovery.
- ctx's September cleanup and Engram observation #2135 support selective skill
  routing and tracked policy overrides. Current files remain authoritative.
- dependency-cruiser 18.7.0 requires Node `^22 || ^24 || >=26`; the active global
  runtime is Node 22.22.0. A `~/.local` npm prefix avoids tying the executable's
  availability to a single asdf Node installation.
- A native skill scan needs host access on this machine; the restricted shell
  could not initialize the app-server. The read-only host scan succeeded.

## Verification scope

This is installation and instruction integration. Native discovery and fixture
execution establish availability and rule enforcement. Routing scenario checks
are bounded instruction checks, not a guarantee of every future model choice.
Repository-specific CI enforcement requires that repository's approved rules,
pinned development dependency, and task-owned checkout.

## Installed state

The three skills are user-scoped under `~/.agents/skills`. Native Codex discovery
from both dotfiles and SoundCoaster reports exactly one enabled entry for each
and zero scan errors. All Markdown local references resolve. The two new skills
use Codex's installer and pinned revisions; the existing architecture-review
skill and its Vercel Skills CLI lock entry were preserved. No bulk skill update
or additional skill dependencies were introduced.

| Skill | Source revision |
| --- | --- |
| codebase-design | `mattpocock/skills@a496f5513d4a4cf889bc48e189e579f4b0bdf6aa` |
| improve-codebase-architecture | Existing enabled installation, folder hash `688c17ec27fe9309d84987716aca37b5ce7f3a88` in its manager record |
| vercel-composition-patterns | `vercel-labs/agent-skills@1a2c79d4e6c4a2283dc2c614b6538cbe1ed5ca62` |

See [installation.json](installation.json) for installed SHA-256 file manifests.
Preserve these receipts when deliberately upgrading. The new skills are managed
by the Codex installer, not by the existing Vercel Skills CLI lock file.

The pinned global tool installation is:

```sh
npm install --global --prefix "$HOME/.local" --ignore-scripts --no-audit --no-fund \
  dependency-cruiser@18.7.0 typescript@6.0.3
```

`~/.local/bin/depcruise` and `dependency-cruiser` resolve to the same package.
The CLI reports 18.7.0 with Node 22.22.0 and Node 24.8.0. TypeScript 7.0.2 was the
registry's latest at installation, but this dependency-cruiser release requires
TypeScript below 7; 6.0.3 is intentionally pinned for compatibility.

Global AGENTS routes the skills and reads the Stow-managed
`~/.codex/policies/architecture.md`. The policy preserves lifecycle ownership,
pure decision logic, existing behavioral assertions, and project conventions.
It qualifies upstream generic setters and adapter-count heuristics.

The full Stow preview rejected three pre-existing **absolute symlinks** for
`elixir-phoenix.md`, `engram-writes.md`, and `github-media.md`, although inspection
confirmed they already resolve to the correct tracked sources. Activation used
`stow --no-folding --ignore='(elixir-phoenix|engram-writes|github-media)\.md$'`
for `codex-config`; only the new architecture leaf needed linking. No existing
policy was replaced. The isolated Stow integration test passes with architecture
added to its policy-link checks.

## Executable verification

[CLI checks](cli-checks.json) record valid and deliberately violating graphs in
both JavaScript and TypeScript/TSX. Each fixture contains two modules; assertions
confirm both are actually analyzed. The valid graph exits 0. The forbidden
domain-to-UI import and cycle produce two errors and exit 2 with the `err`
reporter. The JSON reporter exits 0 for the same violations while reporting
`summary.error: 2`; the policy explicitly forbids treating that exit status as
an enforcement pass.

The initial global installation lacked a TypeScript compiler and advertised no
TS/TSX coverage. Installing compatible TypeScript beside dependency-cruiser made
the TS/TSX fixtures pass. Source:
[dependency-cruiser FAQ](https://github.com/sverweij/dependency-cruiser/blob/v18.7.0/doc/faq.md).

Passed the existing `zsh tests/codex-config-stow.zsh` integration check and
`git diff --check`. These are configuration/installation changes, so native
discovery and executable fixtures are more useful than new prose unit tests.
Fetched `origin/main`; it still matches the startup HEAD. Changes are local and
uncommitted. SoundCoaster package scripts and CI were not edited; its own
checkout is required for repository-specific enforcement.

Official skill behavior: descriptions drive implicit selection, and
`allow_implicit_invocation` defaults to true. None of these installed skills
disables implicit invocation. New skills should be available on the next turn;
restart Codex if a running client retains its old catalog.
[Official documentation](https://learn.chatgpt.com/docs/build-skills).

## Routing review

A separate read-only reviewer inspected the quiescent policy, installed skills,
and native/CLI receipts. No blocking findings. Six prompt scenarios selected:

| Prompt | Routing |
| --- | --- |
| Business policy tangled with network calls | codebase-design |
| Architecture review of a named subsystem | improve-codebase-architecture; codebase-design as needed for interfaces |
| React Native component with many boolean modes | vercel-composition-patterns and codebase-design |
| README typo | No architecture skill |
| Bounded graph without approved rules | Architecture policy and dependency-cruiser; no enforcement claim |
| Extraction with pressure to delete tests or expose setters | codebase-design; preserve distinct assertions and invariants |

The review identified two portability caveats already covered or clarified in
policy: translate legacy `Agent`/`Explore` tool names to the active harness, and
apply React-version checks to all examples, including general composition rules.
This is a bounded scenario review; future implicit selection remains model-driven.
