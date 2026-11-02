# Architecture skills and dependency analysis

Use the installed skills selectively:

- `codebase-design`: deciding module responsibilities, public interfaces,
  dependency direction, or where new behavior belongs. Use during normal
  feature work when those choices are material.
- `improve-codebase-architecture`: assessing architectural friction or choosing
  cohesive refactoring opportunities. Scope the review to the named subsystem
  or demonstrated change hotspots; do not run a broad audit for every feature.
- `vercel-composition-patterns`: React/React Native component APIs, boolean-prop
  proliferation, compound components, and provider/composition design. Verify
  the installed React version before using version-specific rules or examples,
  including examples outside the explicitly labeled React 19 section.

These skills complement the existing planning, implementation, and verification
workflow. They do not add an approval gate to already authorized work. Existing
project vocabulary, accepted ADRs, ownership rules, and verification requirements
remain authoritative. Resolve terminology from existing project documentation;
do not create a second glossary solely because upstream uses a different filename.
Translate upstream `Skill`, `Agent`, and `Explore` references to this harness's
skill-reading and available exploration tools; do not require unsupported tool
names or agent roles. Keep exploration read-only until implementation is authorized.

## Design preferences

Prefer cohesive modules with small, meaningful interfaces. Identify the behavior,
state/lifecycle owner, side effects, callers, and tests before an extraction.
Judge improvement by reduced caller knowledge and coordination, not file count,
line count, or how many hooks were created.

Prefer pure business decisions with explicit inputs and returned results or
commands. Keep networking, persistence, clocks, randomness, timers, and native
resources in explicit adapters/controllers. An application still needs state:
keep one owner for each lifecycle, derive redundant values, and make meaningful
transitions explicit. Preserve cancellation, stale-result fencing, account or
environment epochs, transaction boundaries, and resource cleanup.

Expose domain operations/events where invariants matter, rather than unrestricted
state setters. A generic context `update` function can suit local UI state but
must not let callers bypass workflow invariants. Do not introduce providers,
ports, event buses, or wrappers without a concrete reduction in coupling.
The upstream two-adapter rule is a heuristic: a real isolation or dependency
boundary can justify one production adapter. Do not add a second merely to
satisfy that rule.

Keep fast pure-logic tests and behavioral integration coverage at real interfaces.
The upstream "replace, don't layer" advice does not authorize blanket deletion
of existing unit tests: retire a test only when its behavior is intentionally
removed or covered by verified replacement evidence. Retain distinct lifecycle,
concurrency, adapter, and native-boundary assertions.

## dependency-cruiser

The globally installed `depcruise` command is available for JS/TS dependency
analysis. Prefer the repository's pinned dependency, configuration, and package
script when present. Inspect its module-resolution setup and source roots first.

For a read-only inventory without repository rules, use a bounded source scope:

```sh
depcruise --no-config --no-cache --output-type json -- src
```

That command produces a graph, not a passing architecture gate. Configured
validation should run the repository's approved rules with `--output-type err`
and fail on error-level violations. The JSON reporter can exit zero even when
`summary.error` is nonzero; do not use its exit status alone as a gate. Do not
suppress violations, loosen rules, or add blanket baselines to make a check pass.
Global installation alone does not configure repository CI.

Check `depcruise --info` before relying on language coverage. TypeScript/TSX needs
a compatible TypeScript compiler installed beside dependency-cruiser. Confirm
the intended source files actually appear in the analyzed graph; an empty graph
is not evidence that the architecture passed.

When integrating a repository gate, pin a development dependency in its package
manager, reuse accepted boundaries, wire its normal local/CI checks, and verify
both a valid graph and deliberate violating fixtures. Check TypeScript aliases,
workspace packages, and platform-specific resolution against that repository.
Import analysis does not prove purity, correct state ownership, runtime behavior,
or freedom from technical debt. Skills do not authorize adding Effect, RxJS,
XState, or another runtime library as an incidental refactor.
