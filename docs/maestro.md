# Shared Maestro tooling

Maestro is a shared CLI, not an app dependency or an MCP requirement. Dotfiles
owns installation and agent guidance; each adopting repository owns its flows,
app identifiers, fixtures, build/runtime selection, commands, and acceptance.
Existing native XCUITest/Detox stacks remain valid.

## Install and activate on macOS

Prerequisites: Python 3.9+, curl, GNU Stow, Java 17+, and Xcode for iOS. This
setup does not install Java/Xcode, accept licenses, create devices, or run apps.
Use the existing JDK. If necessary, set `MAESTRO_JAVA_HOME` to a compatible JDK
for Maestro only; the launcher maps it to child-process `JAVA_HOME` without
changing the machine's Java default.

From the dotfiles checkout:

```sh
make test-maestro
make maestro-install
make maestro-preview
make maestro-activate
make maestro-doctor
```

Installation downloads the official version-specific ZIP and checks the SHA256
in `maestro/.local/share/maestro-toolchain/pin.json` **before extraction**. It
refuses path traversal, symlinks, unexpected archive layout, and conflicting or
incomplete installed versions. It does not execute a downloaded install script.
To use a previously downloaded ZIP (the same digest check still applies):

```sh
python3 maestro/.local/bin/maestro-toolchain install --archive /tmp/maestro.zip
```

Activation is separate, selective, and uses `stow --no-folding` for `maestro` and
`codex-config`. It preserves real state directories and aborts on conflicting
local files; it never uses `--adopt` or removes another installation. Inspect
conflicts and obtain approval before moving any existing files.

After activation, from any project:

```sh
maestro --version
maestro --help
maestro-toolchain doctor --ios
```

Tracked zsh startup exposes `~/.local/bin` to noninteractive shells as well as
interactive ones. Other shells/agent launchers must have that directory in
their PATH, or invoke `~/.local/bin/maestro` directly. Newly started Codex
sessions discover `maestro-mobile-testing`; existing sessions may need restart.
No per-session Codex flag or project MCP configuration is needed.

## Ownership and state

| Location | Owner/purpose |
| --- | --- |
| `maestro/.local/bin/` | Tracked wrapper and toolchain helper |
| `maestro/.local/share/maestro-toolchain/pin.json` | Tracked version and SHA256 |
| `~/.local/share/maestro-cli/<version>/` | Installed release plus provenance receipt; never Git |
| `~/.maestro/` (or Maestro's XDG state path) | Upstream mutable logs/cache/state; never Stow |
| `codex-config/.codex/skills/maestro-mobile-testing/` | Tracked shared guidance, installed as leaf links |
| Application `.maestro/`, fixtures, runner/runbook | Project-owned regression coverage |

The receipt records the verified downloaded archive; it is not continuous
integrity monitoring of every installed file. Doctor checks expected receipt,
launcher/JAR presence, Java, and the running CLI version. `--ios` additionally
lists Xcode and available iOS simulators without booting/selecting one. A missing
prerequisite yields nonzero exit. A pass is **not an app or native-driver test**.
Successful CLI startup diagnostics are preserved as `WARN`, not hidden. The
verified local Java 26 runtime emits an upstream Picocli final-field-reflection
warning. Version/help succeed; do not infer driver compatibility, suppress the
warning, or change the global JDK merely to make the check quiet.

## Privacy and external actions

The launcher sets these for the child process on every invocation:

```text
MAESTRO_CLI_NO_ANALYTICS=true
MAESTRO_CLI_ANALYSIS_NOTIFICATION_DISABLED=true
MAESTRO_DISABLE_UPDATE_CHECK=true
MAESTRO_API_URL=http://127.0.0.1:9
```

The API override intentionally takes precedence over inherited values. In
2.10.0, the update flag does not prevent the initial asynchronous fetch, and
automatic error reports are separate from the analytics opt-out. Loopback
prevents these requests from reaching the default remote Maestro service.
This is **not a network sandbox**: device connections, app traffic, flow scripts,
and explicit alternative endpoints are not isolated by this wrapper.

Cloud/login, AI analysis, bug-report uploads, and paid hosted CI are not part of
this local setup. Do not use them or bypass the wrapper without separate
authorization and a reviewed configuration. Do not commit credentials or assume
test artifacts are safe to publish without inspection/redaction.

## Upgrade and rollback

1. Review the official release, published ZIP checksum, relevant startup/privacy
   changes, and Java/Xcode requirements.
2. Update the tracked version/digest together. No floating Homebrew formula or
   background installer manages this pin.
3. Run offline tests, install, doctor, and project-owned runtime acceptance on
   an authorized target. A toolchain upgrade can change native-driver behavior.
4. Review and approve the change before committing/shipping. The live links
   follow this checkout immediately, so a pin edit also changes the selected
   runtime; coordinate the upgrade with other sessions first.

Old release directories are retained. Roll back by restoring the reviewed
version/digest in Git and rechecking the existing release. The installer never
deletes old versions, repairs unknown directories, or removes other packages.

## Sources and next application integration

- [Maestro 2.10.0 release and checksums](https://github.com/mobile-dev-inc/Maestro/releases/tag/cli-2.10.0)
- [Pinned startup/update behavior](https://github.com/mobile-dev-inc/Maestro/blob/14a408335e17a090df1e26bdbeaf80d8122a8fd8/maestro-cli/src/main/java/maestro/cli/App.kt)
- [Pinned error reporting](https://github.com/mobile-dev-inc/Maestro/blob/14a408335e17a090df1e26bdbeaf80d8122a8fd8/maestro-cli/src/main/java/maestro/cli/util/ErrorReporter.kt)
- [Expo Maestro guide](https://docs.expo.dev/eas/workflows/examples/e2e-tests/)

SoundCoaster functional adoption maps to LEA-196; its LEA-211 native visual
catalog/comparison lane remains distinct. Neither app integration nor CI
activation is delivered by installing this shared toolchain.
