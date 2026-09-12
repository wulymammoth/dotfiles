# Astra instruction cleanup

Approved scope: implement the September 11 review recommendations in the global
policy and selected skills. Preserve ownership, shipping authorization, Design
Lock, native proof requirements, model settings, and GSD disablements. The user
subsequently approved local checkpoint commits in both repositories and the
Superpowers plugin refresh. Push, PR, and unrelated runtime actions are excluded.

Source: [OpenAI guidance](https://developers.openai.com/blog/rethinking-skills-and-prompts-for-gpt-6-astra).

## Work plan

- [x] Make startup reads conditional and move specialized policy detail behind
  explicit read triggers; verify Stow and retained policy contracts.
- [x] Align brainstorming with existing approval, narrow TDD exceptions, and
  reuse applicable verification evidence; preserve visual acceptance gates.
- [x] Narrow mobile release, runtime debugging, and UI regression skill routing.
- [x] Evaluate small approved fixes, unchanged tested code, regression recovery,
  missing visual acceptance, and native debugging without a release request.
- [x] Verify source changes and installed discovery, then record limitations.

## Ownership and activation

Startup: `/Users/wulymammoth/dotfiles`, `main`,
`b336a7faa708ccca6b80e5a3ed0ab16ba4b74291`, initially clean.
Global AGENTS is already linked to this repository; edits affect new reads
immediately. New policy leaves need Stow activation. Superpowers source is
`/Users/wulymammoth/Desktop/lab/superpowers`, initially clean at
`f870f891437e459c105e2f994ae235355810d94a`; cross-checkout authorization and
installed-plugin refresh were explicitly authorized by the user. Subsequent
approval covered local checkpoint commits because the native installer reads
committed Git snapshots rather than uncommitted source.
Personal mobile skills are local regular files in `~/.codex/skills`; preserve
their metadata and references and record a portable patch here.

## Implemented changes

- Global policy: conditional startup reads, three specialized policy leaves,
  and reuse of current-state verification evidence. Global policy decreased from
  1,712 to 1,505 words. Specialized leaf contents retain the original rules.
- Superpowers: brainstorming 2,843 -> 1,924 words; TDD 1,375 -> 974; verification
  708 -> 403. Existing approval is reused; regression recovery preserves code;
  unchanged-state evidence is reusable; missing required proof remains incomplete.
- Personal skills: release decisions, installed-runtime diagnosis, and SwiftUI/
  UIKit regression coverage now have distinct descriptions. Bodies and metadata
  remain unchanged. [Portable patch](personal-skills.patch).
- [Superpowers source patch](superpowers.patch) records the three skill changes.
  Context and a handoff note also exist in the Superpowers repository.

## Validation and limitations

- `zsh tests/codex-config-stow.zsh`: pass, including installed-policy route/link
  fixtures and existing ownership/shell/memory contracts.
- `zsh tests/parallel-work-profile.zsh`: pass for isolated configuration behavior;
  its existing live-hook/Superpowers canary remains explicitly unproven.
- `node --test tests/design-lock-supervised-contract.test.js` in Superpowers:
  all four checks pass. Approved PNG/spec, visual-file allowlist, final screenshot
  and diff, and explicit human acceptance remain required.
- Superpowers `tests/codex/test-package-codex-plugin.sh`: all 29 assertions pass.
- Both repository whitespace checks pass. Both refreshed origin/main refs matched
  their initial HEADs before any checkpoint commit.
- Native `skills/list`: 197 entries, 48 enabled, zero errors; the three revised
  personal skill descriptions are present. This CLI catalog differs from the
  conversational catalog and does not hot-reload an existing thread.
- Native config inspection reported Astra/high at final inspection, whereas the
  earlier raw-file audit showed Astra/medium. This task did not edit model,
  reasoning, profile, Engram, or GSD settings; preserve independently changed state.

### Scenario review

Separate read-only agent reviews compared baseline instructions and candidate
choices. These are instruction-level scenario checks, not execution benchmarks,
statistical improvement evidence, or full Gauntlet/paid model evaluation.

| Scenario | Revised decision |
| --- | --- |
| Approved mechanical config fix | Implement and validate without another design/TDD exception approval |
| Tests passed; relevant state unchanged | Reuse observed results and report their scope |
| Implementation predates regression | Preserve code; prove failure with only relevant fix absent, restore, verify |
| Dependency/config changed since tests | Rerun affected checks |
| Visual tests pass; final screenshot not accepted | Present screenshot and allowlisted diff; await human acceptance |
| Native API bug without release request | Diagnose installed boundary; no automatic release workflow |
| Authentication/runtime proof unavailable | Report exact gap; do not claim required outcome complete |
| Wrong checkout | Stop dependent writes; resolve ownership or explicit exception |

Review corrected global ADR guidance accidentally hidden behind Engram routing,
remaining fresh-output wording, absolute RED wording, and architectural handoff
clarity. Design Lock guidance remains substantive, not merely preserved keywords.

## Activation status

Global AGENTS is already Stow-linked; the three new leaves were activated with
links under `~/.codex/policies`. Personal skill edits are active for fresh discovery.
The native Superpowers installer returned success but installed the old committed
content; a 51-file source/cache comparison found exactly the three changed skills
unmatched. The local manifest cachebuster attempt was ineffective for uncommitted
Git content and was reverted. No disposable plugin cache files were hand-edited.
The user then authorized both local checkpoint commits and the final refresh.
Superpowers source is committed as
`988f0a3ff6d3667d6554dc47e9b6beabbfd2dc74` on local `main`. Native
`codex plugin add superpowers@superpowers-dev --json` installed version 6.3.0
from that committed local snapshot. All 51 tracked skill files match the source
byte-for-byte. A fresh native scan returned 48 enabled skills, zero errors, and
the three revised Superpowers descriptions. No manual cache edits were needed.

This dotfiles checkpoint includes the policy, tests, portable patches, and final
activation evidence. No push, PR, external release, or provider/device action
was performed.

## Continuation

Implementation and authorized local activation are complete. Start a new
conversation to pick up the refreshed skill catalog reliably. Both repositories
have local checkpoint commits; any later push or PR needs separate authorization.
The scenario reviews establish instruction consistency, not measured model
performance; assess real task outcomes before making further workflow changes.
