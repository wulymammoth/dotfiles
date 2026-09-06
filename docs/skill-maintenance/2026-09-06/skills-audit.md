Skill usefulness audit — 6 September 2026

Your useful core is Superpowers, especially its Visual Companion and Design Lock workflow. GSD is the largest source of unnecessary discovery overhead for your stated usage. The initial recommendation is to retire **146 of 201 advertised entries**, leaving **55**. That includes 142 GSD entries, three duplicate/obsolete entries, and the unsafe standalone Vercel uploader. This is a recommendation; no installed skills, configuration, Git files, or provider state were changed.

The counts refer to discoverable entry points, not independent capabilities or measured execution savings. Skill bodies are loaded on demand; removing 73% of the entries does not demonstrate a 73% token or latency improvement. [OpenAI skill documentation](https://learn.chatgpt.com/docs/build-skills) describes discovery, invocation, and reversible path-based disabling.

The audit enumerated **425 SKILL.md paths** across the current Codex catalog, local Claude/OpenCode installations, installed Claude plugins, and retained skill archives. Shared links, disabled plugins, and archived copies are separated in the accompanying CSV. Marketplace catalogs and unused older Codex plugin-cache versions were not treated as installed active skills. Every one of the 201 advertised entries has a verdict below and in [the complete inventory](skill-inventory.csv).

**The decisions that matter most**

| Area | Recommendation | Reason |
|---|---|---|
| Superpowers fork: 14 advertised skills | Keep the package; revise a few adapters | Visual Companion depends on brainstorming, planning, verification, and supporting assets. Preserve the system that carries your approved design through implementation. |
| GSD: 142 advertised entries | Retire from active discovery | You cannot recall recent use. The catalog contains both 73 newer command wrappers and a 69-entry legacy conversion. |
| Duplicate using-superpowers, Postiz, ctx | Remove three redundant discovery routes | Preserve the maintained fork, one Postiz entry, and one Codex ctx entry; retain shared resources needed by other apps. |
| Standalone vercel-deploy | Retire from active discovery first | Its upload archive includes local environment files and other gitignored content. |
| Custom mobile debugging, release, regression, Maestro guidance | Keep | These encode concrete runtime and test boundaries relevant to your native work. |
| Web accessibility, CWV, SEO, performance | Keep the capabilities; correct guidance | Several factual errors and unsupported blanket rules need correction. |
| General native-design, interview, architecture guides | Keep as specialists; consolidate overlap | Useful when selected for the actual task; avoid adding competing default workflows. |
| Bundled artifacts, Google Workspace, image generation | Keep | They provide real authoring, rendering, or connector capabilities, with intentional format-specific routing. |
| Sites and inline visualization | Keep for their own use cases | They complement Visual Companion; they do not replace its persistent design review and acceptance process. |

**Evidence behind the findings**

1. **The standalone Vercel uploader is unsuitable for ordinary private repositories.** [deploy.sh](/Users/wulymammoth/.codex/skills/vercel-deploy/scripts/deploy.sh:209) creates an archive with only `node_modules` and `.git` excluded, then posts it to a claimable deployment endpoint. A harmless local fixture using that exact tar command included `.env.local` and a gitignored private-note fixture. No real secrets or files were uploaded. Its static-site branch also renames a source HTML file in place. [Fixture evidence](packaging-proof.txt). Replace this route with the project's existing deployment process and available Vercel tools, preserving deployment approval.

2. **GSD is both unused for your current workflow and installed in two generations.** The 69-entry [legacy bundle](/Users/wulymammoth/.agents/skills/gsd/SKILL.md:1) identifies itself as version 1.0.0. Its installation record points to an [AI conversion whose own README describes it as untested](https://github.com/ctsstc/get-shit-done-skills). The 73 newer flat wrappers point at the installed GSD 1.36.0 runtime; all 73 literal absolute dependency paths found in their entrypoints exist, so this is not a claim that every command is broken. The [old primary upstream is archived and points to GSD Core](https://github.com/gsd-build/get-shit-done), which now has a [separate current home](https://github.com/open-gsd/gsd-core). Since you are not using GSD, there is no reason to turn cleanup into an unsolicited migration. Preserve existing `.planning` handoffs and runtime files during initial deactivation.

3. **Preserve the current Visual Companion implementation.** The active Codex plugin is 6.3.0. Its brainstorming skill, Visual Companion guide, writing-plans skill, verification skill, and all five browser/server assets match committed source `a09484293b0c5118d86f08bf0e438e0881c36e3b` in your maintained fork. [Hash comparison](visual-companion-proof.json). This establishes source/cache parity for those files; it is not a fresh browser or full behavioral harness pass. The maintained [brainstorming entrypoint](/Users/wulymammoth/.codex/plugins/cache/superpowers-dev/superpowers/6.3.0/skills/brainstorming/SKILL.md:1) should remain the route into the companion.

4. **The web guides need factual repairs.** [accessibility](/Users/wulymammoth/.agents/skills/accessibility/SKILL.md:94) labels 18px regular / 14px bold as large text; [WCAG uses 18pt / 14pt bold](https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum.html), approximately 24px / 18.67px. [performance](/Users/wulymammoth/.agents/skills/performance/SKILL.md:345) still recommends a Lighthouse TTI target, although [TTI was removed in Lighthouse 10](https://developer.chrome.com/docs/lighthouse/performance/interactive). [core-web-vitals](/Users/wulymammoth/.agents/skills/core-web-vitals/SKILL.md:32) incorrectly lists a whole SVG as an LCP candidate; [Google distinguishes SVG image elements from the SVG container](https://web.dev/articles/lcp). [seo](/Users/wulymammoth/.agents/skills/seo/SKILL.md:16) assigns unsubstantiated percentage weights to ranking factors; [Google's guidance describes multiple signals without those weights](https://developers.google.com/search/docs/appearance/page-experience). Keep the useful technical checks and remove false precision.

5. **Some useful skills point at the wrong operating path.** [Postiz](/Users/wulymammoth/.agents/skills/postiz/SKILL.md:8) starts with CLI installation/authentication even though direct Postiz MCP tools are available here. The CLI is absent from PATH and its linked `COMMAND_LINE_GUIDE.md` is missing in both duplicate skill locations. MCP authentication was not tested. [Repomix](/Users/wulymammoth/.agents/skills/repomix-explorer/SKILL.md:298) tells the agent to trust automated secret checks; [the actual project recommends reviewing output before sharing](https://repomix.com/guide/security). Prefer your installed Repomix 1.18.0 over automatically executing `npx repomix@latest`.

6. **Keep skill rules subordinate to your actual operating policy.** The standalone old using-superpowers copy makes an invalid claim about skill priority over system behavior. In the maintained fork, the 1% skill-trigger rule, some generic worktree/cleanup assumptions, hardcoded `gh` comment guidance, and the claim that full-history forks accept model overrides should be tightened against the current instructions and tools. This is a targeted compatibility cleanup, not a reason to remove Visual Companion or weaken Design Lock.

7. **One managed Google Docs routing inconsistency is worth reporting upstream.** [google-drive](/Users/wulymammoth/.codex/plugins/cache/openai-curated-remote/google-drive/0.1.16/skills/google-drive/SKILL.md:40) says new Docs always follow DOCX-first creation, while the specialized [google-docs](/Users/wulymammoth/.codex/plugins/cache/openai-curated-remote/google-drive/0.1.16/skills/google-docs/SKILL.md:3) preserves supplied native templates and uses DOCX-first only without that constraint. Preserve template-aware behavior and align the router at the package source; do not edit disposable cache files as the durable fix.

**Every non-GSD advertised entry**

“Keep” means the capability earns its place; “specialist” means use when relevant, not a proposed invocation-policy change. “Revise” preserves a useful capability but identifies a correction. “Consolidate” is a second-pass simplification and is not included in the initial 146-entry reduction.

| Skill | Verdict | Role and rationale |
|---|---|---|
| [accessibility](/Users/wulymammoth/.agents/skills/accessibility/SKILL.md) | Revise | Keep the capability. Correct large-text contrast thresholds from 18px/14px bold to 18pt/14pt bold, approximately 24px/18.67px. Keep keyboard and assistive-technology verification. |
| [best-practices](/Users/wulymammoth/.agents/skills/best-practices/SKILL.md) | Consolidate | Broad generic overlap with web-quality-audit and current engineering policy. Retain useful security/browser checks as references; avoid blanket npm update/audit-fix and permissions-policy examples as automatic remediation. |
| [core-web-vitals](/Users/wulymammoth/.agents/skills/core-web-vitals/SKILL.md) | Revise | Keep targeted LCP/INP/CLS diagnosis. Correct the claim that a whole SVG is an LCP candidate and clarify the per-page interaction calculation; retain measured field/lab distinctions. |
| [ctx (Codex copy)](/Users/wulymammoth/.codex/skills/ctx/SKILL.md) | Keep | Keep one Codex discovery entry for historical forensics. Installed CLI is 1.3.1. Your narrower historical-lookup policy governs its broad working-memory trigger; no index-health claim was tested here. |
| [ctx (shared agents copy)](/Users/wulymammoth/.agents/skills/ctx/SKILL.md) | Retire | Exact duplicate of ~/.codex/skills/ctx/SKILL.md. Disable this path for Codex discovery only; preserve manager-owned copies used by other agents. |
| [deep-research-work:deep-research](/Users/wulymammoth/.codex/plugins/cache/openai-curated-remote/deep-research-work/0.1.14/skills/deep-research/SKILL.md) | Keep | Useful for explicitly requested deep research; its trigger excludes ordinary quick research, reducing unnecessary overhead. |
| [documents:documents](/Users/wulymammoth/.codex/plugins/cache/openai-primary-runtime/documents/26.904.11930/skills/documents/SKILL.md) | Keep | DOCX authoring, editing, and render verification offer concrete capability. Keep the managed artifact runtime. |
| [expo-mobile-release-discipline](/Users/wulymammoth/.codex/skills/expo-mobile-release-discipline/SKILL.md) | Keep | Separates backend, JavaScript update, native build, and store metadata changes. Prevents unnecessary cloud builds and weak release evidence. |
| [expo-react-native-runtime-debugging](/Users/wulymammoth/.codex/skills/expo-react-native-runtime-debugging/SKILL.md) | Keep | High-value custom guidance for reproducing the exact installed client boundary, preserving native semantics in tests, and reporting the strongest runtime proof. |
| [find-skills](/Users/wulymammoth/.agents/skills/find-skills/SKILL.md) | Revise | Useful only when a real capability gap exists. Star/install counts are weak quality proxies; assess source, applicability, permissions, tests, and maintenance instead of popularity alone. |
| [frontend-design:frontend-design](/Users/wulymammoth/.codex/plugins/cache/claude-plugins-official/frontend-design/local/skills/frontend-design/SKILL.md) | Keep | Adds visual craft and intentional typography. Use within the chosen brief and approved design system; it does not supersede a Design Lock. |
| [google-drive:google-docs](/Users/wulymammoth/.codex/plugins/cache/openai-curated-remote/google-drive/0.1.16/skills/google-docs/SKILL.md) | Keep | Useful native Google Docs editing, structural preservation, and template-aware routing. Not a duplicate of local DOCX creation. |
| [google-drive:google-drive](/Users/wulymammoth/.codex/plugins/cache/openai-curated-remote/google-drive/0.1.16/skills/google-drive/SKILL.md) | Revise | Keep file discovery and lifecycle routing. Its blanket DOCX-first rule for new Docs conflicts with the newer google-docs template/native-copy exception; align router wording with the specialized skill. |
| [google-drive:google-drive-comments](/Users/wulymammoth/.codex/plugins/cache/openai-curated-remote/google-drive/0.1.16/skills/google-drive-comments/SKILL.md) | Keep | Adds evidence-grounded comment handling across Drive file types. Sending comments still requires user authorization. |
| [google-drive:google-sheets](/Users/wulymammoth/.codex/plugins/cache/openai-curated-remote/google-drive/0.1.16/skills/google-sheets/SKILL.md) | Keep | Useful connected range-level operations and native import, distinct from standalone workbook authoring. |
| [google-drive:google-slides](/Users/wulymammoth/.codex/plugins/cache/openai-curated-remote/google-drive/0.1.16/skills/google-slides/SKILL.md) | Keep | Useful native template/source handling and Google Slides routing, distinct from local deck rendering. |
| [grill-me](/Users/wulymammoth/.agents/skills/grill-me/SKILL.md) | Keep | A small, distinct opt-in challenge mode. Useful when you request intensive questioning; not a default pre-coding ceremony. |
| [grill-with-docs](/Users/wulymammoth/.agents/skills/grill-with-docs/SKILL.md) | Revise | Useful documentation-aware challenge mode, but adapt its automatic CONTEXT.md glossary writing to your existing authoritative documents and accepted decision process. It overlaps grill-me and can become its documentation mode. |
| [imagegen](/Users/wulymammoth/.codex/skills/.system/imagegen/SKILL.md) | Keep | Adds actual raster generation/editing capability for mockups and assets. The built-in image tool is available; an API key is not required for that route. |
| [improve-codebase-architecture](/Users/wulymammoth/.agents/skills/improve-codebase-architecture/SKILL.md) | Revise | Useful deep-module analysis and visual before/after proposals. Keep repository terminology and documentation conventions instead of mandating a new glossary vocabulary or document layout. |
| [ios-design-guidelines](/Users/wulymammoth/.agents/skills/ios-design-guidelines/SKILL.md) | Revise | Useful iPhone design reference, but 1,083 lines mix platform guidance with rigid product choices (for example, max-three-page onboarding and always showing a permission pre-screen). Separate actual requirements from preferences and use current Apple sources. |
| [ios-ui-regression-guard](/Users/wulymammoth/.codex/skills/ios-ui-regression-guard/SKILL.md) | Keep | Selects behavior and visual regression coverage for native UI. Distinct from release routing and runtime diagnosis; retain the repository-selected test stack. |
| [mobile-ios-design](/Users/wulymammoth/.agents/skills/mobile-ios-design/SKILL.md) | Consolidate | Mostly generic SwiftUI/HIG examples that overlap ios-design-guidelines. Merge useful examples into one focused native design reference; keep platform version assumptions explicit. |
| [mom-test](/Users/wulymammoth/.agents/skills/mom-test/SKILL.md) | Keep | Useful for evidence-led product discovery: past behavior, non-leading interviews, and separating compliments from commitment. Scope outreach to explicit user authorization. |
| [openai-docs](/Users/wulymammoth/.codex/skills/.system/openai-docs/SKILL.md) | Keep | Useful current official guidance for Codex and OpenAI; retain as a bundled utility. |
| [pdf:pdf](/Users/wulymammoth/.codex/plugins/cache/openai-primary-runtime/pdf/26.904.11930/skills/pdf/SKILL.md) | Keep | PDF extraction, forms, and visual verification offer concrete capability; not redundant with Word document authoring. |
| [performance](/Users/wulymammoth/.agents/skills/performance/SKILL.md) | Revise | Keep loading/runtime optimization. Remove the retired Lighthouse TTI target, treat budgets as project-specific, and avoid loading the overlapping CWV guide without need. |
| [plugin-creator](/Users/wulymammoth/.codex/skills/.system/plugin-creator/SKILL.md) | Keep | Useful when maintaining your own plugins, including future packaging work. Separate creation from activation/publication. |
| [plugin-management:plugin-management](/Users/wulymammoth/.codex/plugins/cache/openai-curated-remote/plugin-management/0.1.0/skills/plugin-management/SKILL.md) | Keep | Useful for permission/dependency inspection and managing actual integrations; distinct from text-skill discovery. |
| [postiz (nested duplicate)](/Users/wulymammoth/.agents/skills/postiz/skills/postiz/SKILL.md) | Retire | Exact duplicate of the top-level Postiz SKILL.md. Disable nested discovery; keep one corrected entry and required package resources. |
| [postiz (primary)](/Users/wulymammoth/.agents/skills/postiz/SKILL.md) | Revise | Social scheduling remains useful, but this 798-line CLI-centric guide mismatches available direct Postiz MCP tools. CLI is absent from PATH; authentication was not tested. Restore the missing COMMAND_LINE_GUIDE.md or remove its link; remove unrelated paid-media recommendations. |
| [presentations:Presentations](/Users/wulymammoth/.codex/plugins/cache/openai-primary-runtime/presentations/26.904.11930/skills/presentations/SKILL.md) | Keep | Presentation authoring and template fidelity are specialized capabilities. Keep on demand. |
| [repomix-explorer](/Users/wulymammoth/.agents/skills/repomix-explorer/SKILL.md) | Revise | Useful for broad or remote repository exploration; Repomix 1.18.0 is installed. Prefer the installed/pinned CLI over npx @latest and review packed output rather than trusting secret scanning as a guarantee. |
| [seo](/Users/wulymammoth/.agents/skills/seo/SKILL.md) | Revise | Keep crawlability, indexing, canonical, and structured-data checks. Remove unsupported ranking-factor percentages and rigid title/description lengths presented as universal rules. |
| [sites:sites-building](/Users/wulymammoth/.codex/plugins/cache/openai-bundled/sites/0.1.57/skills/sites-building/SKILL.md) | Keep | Useful for selected Sites projects. Your four inspected repositories have no .openai/hosting.json; do not substitute this for their established app workflows or the Visual Companion. |
| [sites:sites-hosting](/Users/wulymammoth/.codex/plugins/cache/openai-bundled/sites/0.1.57/skills/sites-hosting/SKILL.md) | Keep | Useful deployment path for actual Sites projects. Keep paired with sites-building; building or reviewing does not by itself authorize publication under your policy. |
| [skill-creator](/Users/wulymammoth/.codex/skills/.system/skill-creator/SKILL.md) | Keep | Preferred authoring guidance for concise, scoped skills and supporting resources; appropriate for any later cleanup. |
| [skill-installer](/Users/wulymammoth/.codex/skills/.system/skill-installer/SKILL.md) | Keep | Distinct installation capability. Use for requested installs, not speculative additions during an audit. |
| [spreadsheets:excel-live-control](/Users/wulymammoth/.codex/plugins/cache/openai-primary-runtime/spreadsheets/26.904.11930/skills/excel-live-control/SKILL.md) | Keep | Distinct from file authoring: operates a registered live Excel workbook. Useful only when the add-in/session route is selected; no live workbook connection was tested. |
| [spreadsheets:Spreadsheets](/Users/wulymammoth/.codex/plugins/cache/openai-primary-runtime/spreadsheets/26.904.11930/skills/spreadsheets/SKILL.md) | Keep | Workbook formulas, formatting, and verification are specialized capabilities. Keep on demand. |
| [superpowers:brainstorming](/Users/wulymammoth/.codex/plugins/cache/superpowers-dev/superpowers/6.3.0/skills/brainstorming/SKILL.md) | Keep | Owns the Visual Companion and approved PNG Design Lock. Preserve the full workflow and its supporting server assets; retain your existing authorization across its steps. |
| [superpowers:dispatching-parallel-agents](/Users/wulymammoth/.codex/plugins/cache/superpowers-dev/superpowers/6.3.0/skills/dispatching-parallel-agents/SKILL.md) | Keep | Useful for explicitly selected independent agent work. Not a reason to add delegation to every ordinary task. |
| [superpowers:executing-plans](/Users/wulymammoth/.codex/plugins/cache/superpowers-dev/superpowers/6.3.0/skills/executing-plans/SKILL.md) | Keep | Useful when resuming an approved written plan. Retain as part of the coherent Superpowers package. |
| [superpowers:finishing-a-development-branch](/Users/wulymammoth/.codex/plugins/cache/superpowers-dev/superpowers/6.3.0/skills/finishing-a-development-branch/SKILL.md) | Revise | Keep delivery guidance; align it with your persistent commit/push/PR approvals, explicit merge approval, and ownership-aware cleanup. A worktree directory name alone does not establish cleanup authority. |
| [superpowers:receiving-code-review](/Users/wulymammoth/.codex/plugins/cache/superpowers-dev/superpowers/6.3.0/skills/receiving-code-review/SKILL.md) | Revise | Keep its evidence-led review discipline; replace its hardcoded gh comment reply instruction with your GitHub MCP-first policy. |
| [superpowers:requesting-code-review](/Users/wulymammoth/.codex/plugins/cache/superpowers-dev/superpowers/6.3.0/skills/requesting-code-review/SKILL.md) | Keep | Useful review handoff with a named base and result. A review request does not grant permission to post to GitHub. |
| [superpowers:subagent-driven-development](/Users/wulymammoth/.codex/plugins/cache/superpowers-dev/superpowers/6.3.0/skills/subagent-driven-development/SKILL.md) | Keep | Useful for approved multi-task execution. The installed version preserves Design Lock precedence; keep runtime tool adapters current. |
| [superpowers:systematic-debugging](/Users/wulymammoth/.codex/plugins/cache/superpowers-dev/superpowers/6.3.0/skills/systematic-debugging/SKILL.md) | Keep | Useful root-cause procedure; complements installed-app debugging rather than replacing it. |
| [superpowers:test-driven-development](/Users/wulymammoth/.codex/plugins/cache/superpowers-dev/superpowers/6.3.0/skills/test-driven-development/SKILL.md) | Keep | Useful for behavior changes. Apply your practical TDD policy and proportional verification to mechanical edits. |
| [superpowers:using-git-worktrees](/Users/wulymammoth/.codex/plugins/cache/superpowers-dev/superpowers/6.3.0/skills/using-git-worktrees/SKILL.md) | Revise | Retain as fallback. Repository lifecycle tooling and the physical startup checkout must govern; generic create-and-cd instructions must not authorize cross-root implementation. |
| [superpowers:using-superpowers](/Users/wulymammoth/.codex/plugins/cache/superpowers-dev/superpowers/6.3.0/skills/using-superpowers/SKILL.md) | Revise | Keep the plugin entry point. Narrow the 1% activation rule and correct the Codex reference that says full-history forks accept model overrides; current session tool instructions forbid that combination. |
| [superpowers:verification-before-completion](/Users/wulymammoth/.codex/plugins/cache/superpowers-dev/superpowers/6.3.0/skills/verification-before-completion/SKILL.md) | Keep | Requires fresh evidence and preserves screenshot comparison plus human acceptance for Design Lock work. |
| [superpowers:writing-plans](/Users/wulymammoth/.codex/plugins/cache/superpowers-dev/superpowers/6.3.0/skills/writing-plans/SKILL.md) | Keep | Carries approved screenshots, file allowlists, and visual acceptance into implementation. Essential companion to visual brainstorming. |
| [superpowers:writing-skills](/Users/wulymammoth/.codex/plugins/cache/superpowers-dev/superpowers/6.3.0/skills/writing-skills/SKILL.md) | Keep | Useful for complex behavioral evaluations of your fork. Use the bundled skill-creator for ordinary skill edits; do not turn every small edit into a large evaluation project. |
| [template-creator:template-creator](/Users/wulymammoth/.codex/plugins/cache/openai-primary-runtime/template-creator/26.904.11930/skills/template-creator/SKILL.md) | Keep | Useful when explicitly saving reusable artifact templates; not needed for one-off outputs. Preserve as an optional capability. |
| [using-superpowers](/Users/wulymammoth/.agents/skills/using-superpowers/SKILL.md) | Retire | Standalone upstream copy overlaps the maintained plugin, differs in content, and incorrectly claims skill priority over system behavior. Keep superpowers:using-superpowers instead. |
| [vercel-deploy](/Users/wulymammoth/.codex/skills/vercel-deploy/SKILL.md) | Retire | Retire this claimable uploader from active discovery. Its archive includes .env files and gitignored content and can rename the input HTML file. Use the existing project deployment path and available Vercel tools. |
| [visualize:visualize](/Users/wulymammoth/.codex/plugins/cache/openai-bundled/visualize/1.0.29/skills/visualize/SKILL.md) | Keep | Useful for inline explanations and interactive comparisons. Complements the persistent browser review and acceptance workflow in Visual Companion. |
| [web-quality-audit](/Users/wulymammoth/.agents/skills/web-quality-audit/SKILL.md) | Revise | Keep as a small router to focused web reviews. Remove unsupported issue-distribution percentages and universal deployment/weekly checklists; fix linked guidance before trusting the aggregate audit. |

**All 142 GSD entries: retire from active discovery**

The common verdict is based on your stated usage and the competing installed generations, not on an assumption that each individual GSD capability lacks value. The complete CSV includes each entry's exact path and assessment.

**Legacy agents**

`gsd-codebase-mapper`, `gsd-debugger`, `gsd-executor`, `gsd-integration-checker`, `gsd-phase-researcher`, `gsd-plan-checker`, `gsd-planner`, `gsd-project-researcher`.

`gsd-research-synthesizer`, `gsd-roadmapper`, `gsd-verifier`.

**Legacy bundle root (1)**

`gsd`.

**Legacy commands**

`gsd:add-phase`, `gsd:add-todo`, `gsd:audit-milestone`, `gsd:check-todos`, `gsd:complete-checkpoint`, `gsd:complete-milestone`, `gsd:continue-phase`, `gsd:create-checkpoint`.

`gsd:debug`, `gsd:discuss-phase`, `gsd:execute-phase`, `gsd:help`, `gsd:init-repo`, `gsd:insert-phase`, `gsd:integrate`, `gsd:list-phase-assumptions`.

`gsd:map-codebase`, `gsd:new-milestone`, `gsd:new-project`, `gsd:pause-work`, `gsd:plan-milestone-gaps`, `gsd:plan-phase`, `gsd:progress`, `gsd:remove-phase`.

`gsd:research-phase`, `gsd:research-project`, `gsd:resume-work`, `gsd:review-plan`, `gsd:roadmap`, `gsd:synthesize`, `gsd:update`, `gsd:update-checkpoint`.

`gsd:verify-work`, `gsd:whats-new`.

**Legacy references**

`gsd:reference:checkpoints`, `gsd:reference:continuation-format`, `gsd:reference:git-integration`, `gsd:reference:questioning`, `gsd:reference:tdd`, `gsd:reference:ui-brand`, `gsd:reference:verification-patterns`.

**Legacy workflows**

`gsd:workflow:brownfield`, `gsd:workflow:checkpoint`, `gsd:workflow:complete-milestone`, `gsd:workflow:debug`, `gsd:workflow:diagnose-issues`, `gsd:workflow:discovery-phase`, `gsd:workflow:discuss-phase`, `gsd:workflow:execute-phase`.

`gsd:workflow:execute-plan`, `gsd:workflow:list-phase-assumptions`, `gsd:workflow:new-project`, `gsd:workflow:research`, `gsd:workflow:resume-project`, `gsd:workflow:transition`, `gsd:workflow:verify-phase`, `gsd:workflow:verify-work`.

**Newer command wrappers (73)**

`gsd-add-backlog`, `gsd-add-phase`, `gsd-add-tests`, `gsd-add-todo`, `gsd-ai-integration-phase`, `gsd-analyze-dependencies`, `gsd-audit-fix`, `gsd-audit-milestone`.

`gsd-audit-uat`, `gsd-autonomous`, `gsd-check-todos`, `gsd-cleanup`, `gsd-code-review`, `gsd-code-review-fix`, `gsd-complete-milestone`, `gsd-debug`.

`gsd-discuss-phase`, `gsd-do`, `gsd-docs-update`, `gsd-eval-review`, `gsd-execute-phase`, `gsd-explore`, `gsd-extract_learnings`, `gsd-fast`.

`gsd-forensics`, `gsd-from-gsd2`, `gsd-graphify`, `gsd-health`, `gsd-help`, `gsd-import`, `gsd-insert-phase`, `gsd-intel`.

`gsd-join-discord`, `gsd-list-phase-assumptions`, `gsd-list-workspaces`, `gsd-manager`, `gsd-map-codebase`, `gsd-milestone-summary`, `gsd-new-milestone`, `gsd-new-project`.

`gsd-new-workspace`, `gsd-next`, `gsd-note`, `gsd-pause-work`, `gsd-plan-milestone-gaps`, `gsd-plan-phase`, `gsd-plant-seed`, `gsd-pr-branch`.

`gsd-profile-user`, `gsd-progress`, `gsd-quick`, `gsd-reapply-patches`, `gsd-remove-phase`, `gsd-remove-workspace`, `gsd-research-phase`, `gsd-resume-work`.

`gsd-review`, `gsd-review-backlog`, `gsd-scan`, `gsd-secure-phase`, `gsd-session-report`, `gsd-set-profile`, `gsd-settings`, `gsd-ship`.

`gsd-stats`, `gsd-thread`, `gsd-ui-phase`, `gsd-ui-review`, `gsd-undo`, `gsd-update`, `gsd-validate-phase`, `gsd-verify-work`.

`gsd-workstreams`.

**Additional installations and discovery issues**

| Installation | Finding and recommendation |
|---|---|
| `maestro-mobile-testing` | Keep. Its tracked Stow-linked file exists and the launcher is installed, but it is absent from this session's advertised catalog. Verify discovery in a fresh session before changing packaging. |
| `orchestrating-parallel-worktrees` | Keep for explicit multiple-writer work. Its tracked Stow-linked file also exists but is not advertised here. The current AGENTS instructions explicitly name it as a fallback path. |
| `.agents/skills/superpowers` | Dangling link to `.codex/superpowers/skills`. Remove the obsolete link in a cleanup; preserve the active plugin and retained archive. |
| `ctx-agent-history-search` directories | Retained integration metadata directories contain no SKILL.md in inspected roots. They are not extra active skills. |
| Claude local skills | 76 discovered paths, mostly shared GSD and specialist links. Coordinate any future shared-root cleanup; disabling a Codex path does not disable Claude discovery. |
| Claude Superpowers | Enabled at 6.1.1, while this Codex session uses fork 6.3.0. Reconcile deliberately if Claude is still in use; no refresh was performed. |
| Claude Engram memory skill | Enabled older 0.1.1 copy has broad proactive write/recovery rules. Align with current attribution and authority policy if using Claude; memory data is not a cleanup target. |
| Claude Vercel plugin | Installed, disabled, 41 SKILL.md paths including nested upstream references. Leave dormant; it is not part of the 201-entry Codex catalog. |
| OpenCode | `ctx` and `supabase-postgres-best-practices` remain useful in that agent. Per-agent portability is not automatically wasteful duplication. |
| Disabled GSD archive | 73 paths already outside active discovery. Keep dormant during initial cleanup; deletion has no current discovery benefit. |
| Archived Superpowers | 14 retained skill files are not the active plugin. Leave alone during initial cleanup. |
| Bundled `review-agent` | Internal review helper on disk, not advertised as an ordinary skill in this session. Leave managed. |

**A concrete cleanup sequence, if requested later**

1. Reversibly disable the 142 GSD entrypoints, the standalone old using-superpowers entry, nested Postiz duplicate, duplicate Codex ctx discovery route, and standalone Vercel uploader. Use application-appropriate discovery controls; preserve shared resources, project handoffs, runtimes, archives, and installed plugin contents. This produces the proposed 201 → 55 catalog.
2. Verify a fresh session sees the expected catalog and still reaches the maintained Visual Companion, planning, and verification skills. Check the two tracked skills currently absent from discovery; if made discoverable, they add two entries to that 55-entry target. Diagnose rather than assuming their individual-file symlinks are the cause.
3. Correct the useful web guidance, Postiz route, Repomix advice, and narrow Superpowers tool/policy adapters at their maintained sources. Preserve accepted Design Lock semantics.
4. Consolidate generic native-design, broad web best-practices, and overlapping interview modes only after the first cleanup is verified. Do not install a replacement framework merely to shrink this one.

No activation, removal, edits to installed skills, publication, browser/server launches, simulator work, paid jobs, or authentication flows were performed. The only generated files are this local audit, its inventory/evidence, and harmless packaging fixtures. The startup dotfiles checkout was inspected on `main` at `7f2247fa71f8b3af55d66718d8b9d80e309a1433`.

This is a static catalog, content, reference, and targeted script audit. The Vercel packaging behavior was checked with a dummy fixture; selected CLI versions and managed artifact-runtime presence were checked. It does not certify all scripts, connected accounts, framework examples, or every skill's end-to-end behavior. “Keep” is a usefulness judgment, not a blanket runtime or security certification.
