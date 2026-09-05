---
name: maestro-mobile-testing
description: Use when writing, running, or reviewing Maestro native UI tests, or explicitly adopting a Maestro harness in an Expo or React Native project.
---

# Maestro Mobile Testing

## Shared commands

The shared `maestro` launcher uses a checked-in release pin and local-testing
privacy settings. No extra MCP server or Codex startup flags are required.

```sh
maestro-toolchain doctor --ios  # Java/CLI/Xcode + read-only simulator inventory
maestro --version
```

If commands are missing, setup lives in the user's **dotfiles checkout**, not the
application repo: `make maestro-install`, `make maestro-preview`, then
`make maestro-activate`. Installation/activation requires authorization; a
read-only check must not silently install dependencies. Restart the agent if it
has an old environment or cached skill inventory. `maestro-toolchain doctor`
without `--ios` checks only Java and the CLI, not Android prerequisites.

## Project entry point

Read the repository's agent instructions, test runbook, package scripts, and
existing `.maestro/` flows. Prefer its canonical runner and build/dev-client
lifecycle. Do not create another launcher, replace an established Swift/XCUITest
or Detox stack, or require Storybook to write functional app flows.

Before touching a simulator, resolve **ownership, explicit UDID, installed app
ID, binary/source or JS-bundle identity, backend, fixture/auth/reset state**.
Another session's booted simulator is not an available test target. CLI
installation and passing doctor output prove prerequisites, not native driver
compatibility or application regression coverage.

When a repo has no wrapper but does have approved flows, the direct CLI shape is:

```sh
maestro --device "$SIMULATOR_UDID" test .maestro/flows
```

Run only after the target, fixture data, and runtime use are authorized. Do not
guess an app ID, auto-select a booted device, or run reset/publish/delete flows
against a personal or production account. Shared tests should use dedicated
accounts and the project's approved secret-injection mechanism, not secrets in
YAML or chat. Test-only launch/auth helpers must not enable production bypasses.

## Durable regression boundary

- Reuse/add the narrowest appropriate lower-level tests and committed flow for
  the behavior at risk. For a bug, demonstrate RED/GREEN when practical.
- Use purpose-based stable RN `testID` values on queried native controls. Keep
  `accessibilityLabel` human-readable; custom controls must forward IDs. Avoid
  coordinates, list indices, or changing display text as identity.
- Inspect the **installed native hierarchy**: a React-tree test that finds an ID
  does not prove Maestro can see it. Do not break VoiceOver grouping to expose a
  selector, blanket-tag layout views, or assume a WebView host ID names its DOM
  internals. Maestro ID selectors are regex; anchor literal matches as needed.
- Use semantic readiness waits, controlled fixtures, and meaningful assertions:
  navigation result, restored state, disabled/enabled behavior, or persistence
  after leaving/reopening. A tap alone is not an assertion. Preserve real
  service-boundary proof when claiming end-to-end persistence.
- Functional assertions and visual comparisons are separate. A captured PNG is
  evidence, not a visual regression test without a reviewed comparison. Preserve
  existing visual baselines and human approval for baseline updates.

## Completion evidence and privacy

Report: **command/result; tested revision/build/JS bundle and target; assertions;
artifact locations; skipped checks and remaining device/provider/visual risk**.
Keep reports and screenshots in repository-approved, ignored artifact paths;
redact private data before publishing. Do not retry away an unexplained flake.

This shared launcher disables analytics and redirects the Maestro service API
to loopback because 2.10.0 error/update traffic bypasses some opt-out flags.
It is **not a network sandbox**. Cloud, login, AI analysis, upload/bugreport,
external services in flows, and paid CI are outside this local setup and need
their own review/authorization. Do not bypass the launcher to restore them.

Use existing `ios-ui-regression-guard` for native/visual test selection and
`expo-mobile-release-discipline` when release/runtime boundaries apply. Simulator
success does not establish TestFlight, real-device audio, or provider readiness.
