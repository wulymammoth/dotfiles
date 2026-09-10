# Skill cleanup, 2026-09-06

Follow-up: the [2026-09-10 Codex retirement](../2026-09-10/README.md) archives
GSD agents, hooks, and Codex-owned runtime. The shared GSD skills described below
remain disabled; this report records the earlier checkpoint.

The user approved the audit recommendations. Local Codex discovery cleanup, personal skill revisions, and three consolidations are applied. The Superpowers source patch is also applied under the subsequently granted checkout exception; the installed Codex plugin has now been refreshed and verified. Other conditional work below remains pending. At the local-verification checkpoint, nothing had been committed or published. The user subsequently authorized commit, push, and installed-plugin refresh; delivery status is recorded below.

## Applied and verified

- Disabled 149 paths: 142 GSD entries, obsolete standalone using-superpowers, duplicate ctx and Postiz, the standalone Vercel uploader, and three consolidated skill entry points. Files remain available for recovery. Exact paths: [disabled-paths.json](disabled-paths.json).
- Corrected accessibility large-text thresholds, LCP SVG wording, obsolete TTI guidance, and unsupported SEO ranking weights. Improved skill adoption criteria and Repomix version/output-review guidance.
- Replaced the Postiz CLI-first guide with a concise MCP-first workflow that supports draft-only requests without service access.
- Consolidated best-practices into web-quality-audit references, mobile-ios-design into iOS design references, and grill-with-docs into grill-me's documentation-aware mode. Corrected inherited security recipes and glossary template authority rules.
- Added folder symlinks under `~/.agents/skills` for the dotfiles-owned maestro-mobile-testing and orchestrating-parallel-worktrees sources. A fresh scan now discovers both. Existing Stow links were preserved.
- Removed only the broken `~/.agents/skills/superpowers` symlink; its target was absent. Archived skill packages were preserved.

A fresh local `codex app-server` `skills/list` scan changed from 195 enabled entries to 48, with zero discovery errors. This CLI catalog differs from the original conversational catalog of 201: it omits seven remote connector entries and includes one internal review entry. Do not compare the two counts as if they are the same surface. The new conversational catalog requires a new session to verify; this existing conversation retains its initial advertised list.

All 14 active Superpowers package skills remain enabled. Hash checks confirm the audited Visual Companion, Design Lock-related guides, and supporting assets are unchanged. No browser server, simulator, device, paid model evaluation, or provider operation was launched.

Behavior checks: 18px regular text at 3.2:1 fails AA; Postiz draft-only requests require no installation/authentication/service write; terminology discussion respects existing `.Codex-context.md` and ADRs and does not record proposals as accepted decisions. An independent read-only reviewer confirmed these and checked the revised references; all reported findings were fixed and rechecked. Applied file/config hashes match receipts.

## Pending source changes

- [Applied Superpowers source patch](superpowers-applied.patch): relevance-based activation, current Codex fork restrictions, GitHub MCP-first review replies and delivery, persistent approval handling, repository lifecycle precedence, and ownership/authorization-aware cleanup. Applied locally against fork commit `a09484293b0c5118d86f08bf0e438e0881c36e3b` after the user explicitly granted the separate-checkout exception. Fresh `origin/main` matched the base. Read-only before/after evaluation across separate agent sessions passed all seven revised action scenarios; review-found contradictions were corrected. Structural checks passed: 4 Design Lock tests, 6 SessionStart cases, and 29 packaging cases. This is not a full live CLI/Quorum evaluation. Source edits and the appended fork handoff note were committed as `f870f891437e459c105e2f994ae235355810d94a` and pushed to the fork's `origin/main` after explicit follow-on authorization. The native Codex installer subsequently refreshed `superpowers@superpowers-dev` at version 6.3.0. All 51 tracked skill files in the installed cache match the pushed source. No upstream PR or release is involved.
- [Google Drive router proposal](google-drive-router-proposed.patch): defer to the specialized Docs skill's native-template-aware routing. Prepared for the package source; no disposable cache files changed and no upstream message posted. A maintainer destination and authorized submission are still needed.
- Claude-specific changes were conditional on continued Claude use. No Claude plugin refresh or Engram changes were made. Codex path disables do not disable independent Claude discovery. The archived/dormant installations remain intact; this cleanup is not a claim that every client catalog was changed.

## Recovery and maintenance

Machine-private backups (including configuration) are outside Git:

- `~/.local/state/skill-cleanup/20260906-113826`: initial config backup.
- `~/.local/state/skill-cleanup/20260906-114459`: config before consolidations, original personal skill files, and removed symlink target.

[Applied personal skill patch](personal-skills-applied.patch) records source edits without credentials. The full initial [audit](skills-audit.md) and [inventory](skill-inventory.csv) are historical evidence; their pre-cleanup status statements are intentional. Runtime receipts and fresh catalog outputs are in `/tmp/skills-audit-2026-09-06/` for this session.

To re-enable a skill, remove its matching `enabled = false` override after checking for newer configuration changes, then start a fresh session. To restore content, compare the private backup against the current file and restore only the intended changes. Do not blindly replace the entire config or apply the recorded patch twice. Reconcile source updates against the applied patch when upgrading third-party skills.

Dotfiles startup root remained `/Users/wulymammoth/dotfiles`, branch `main`, HEAD `7f2247fa71f8b3af55d66718d8b9d80e309a1433`. A fresh fetch showed `HEAD...origin/main` as `0 0`; the only repository changes are this new documentation directory. The only additional checkout mutated was `/Users/wulymammoth/Desktop/lab/superpowers`, under the explicitly granted one-time exception; its five skill/reference edits and appended existing handoff note are recorded above.

## Authorized delivery

Superpowers source commit `f870f891437e459c105e2f994ae235355810d94a` was pushed successfully to `wulymammoth/superpowers` `origin/main`. This cleanup record is approved for commit/push to dotfiles `origin/main`. The native `codex plugin add superpowers@superpowers-dev --json` refresh completed successfully. Source/cache comparison passed for all 51 tracked skill files; a fresh catalog reported 48 enabled entries and zero discovery errors. Both remote main heads were verified, and both checkouts were clean after delivery. Current sessions may retain previously loaded instructions.
