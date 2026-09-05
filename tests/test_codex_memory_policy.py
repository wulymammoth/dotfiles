import importlib.util
import json
import os
from pathlib import Path
import selectors
import shutil
import signal
import stat
import subprocess
import tempfile
import time
import unittest


REPO_ROOT = Path(__file__).resolve().parents[1]
SCRIPT = REPO_ROOT / "scripts" / "codex-memory-policy.py"
PROFILE = REPO_ROOT / "codex-config" / ".codex" / "parallel-work.config.toml"
PYTHON = "/usr/bin/python3"
SCOPED_KEYS = (
    "model_instructions_file",
    "experimental_compact_prompt_file",
    "plugins.engram@engram.enabled",
    "mcp_servers.engram.enabled",
)


class AppServerClient:
    """Small test-side client for credential-free native config/read calls."""

    def __init__(self, env, cwd):
        self.env = env
        self.cwd = cwd
        self.next_id = 1
        self.process = None
        self.selector = None

    def __enter__(self):
        self.process = subprocess.Popen(
            ["codex", "app-server", "--listen", "stdio://"],
            cwd=self.cwd,
            env=self.env,
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.DEVNULL,
            text=True,
            bufsize=1,
        )
        self.selector = selectors.DefaultSelector()
        self.selector.register(self.process.stdout, selectors.EVENT_READ)
        self.request(
            "initialize",
            {"clientInfo": {"name": "codex-memory-policy-test", "version": "1"}},
        )
        self.notify("initialized")
        return self

    def __exit__(self, exc_type, exc, traceback):
        if self.selector is not None:
            self.selector.close()
        if self.process is None:
            return
        if self.process.stdin is not None:
            try:
                self.process.stdin.close()
            except OSError:
                pass
        try:
            self.process.wait(timeout=3)
        except subprocess.TimeoutExpired:
            self.process.terminate()
            try:
                self.process.wait(timeout=3)
            except subprocess.TimeoutExpired:
                self.process.kill()
                self.process.wait(timeout=3)
        if self.process.stdout is not None:
            self.process.stdout.close()

    def _send(self, payload):
        self.process.stdin.write(json.dumps(payload, separators=(",", ":")) + "\n")
        self.process.stdin.flush()

    def notify(self, method, params=None):
        payload = {"jsonrpc": "2.0", "method": method}
        if params is not None:
            payload["params"] = params
        self._send(payload)

    def request(self, method, params):
        request_id = self.next_id
        self.next_id += 1
        self._send(
            {
                "jsonrpc": "2.0",
                "id": request_id,
                "method": method,
                "params": params,
            }
        )
        deadline = time.monotonic() + 10
        while time.monotonic() < deadline:
            remaining = deadline - time.monotonic()
            if not self.selector.select(remaining):
                break
            line = self.process.stdout.readline()
            if not line:
                break
            message = json.loads(line)
            if message.get("id") != request_id:
                continue
            if "error" in message:
                raise AssertionError("native app-server request failed")
            return message["result"]
        raise AssertionError("native app-server did not return a response")

    def read_config(self):
        return self.request("config/read", {"includeLayers": True})


class CodexMemoryPolicyTests(unittest.TestCase):
    maxDiff = None

    def setUp(self):
        if shutil.which("codex") is None:
            self.fail("codex is required for the native configuration regression tests")
        self.temp_dir = tempfile.TemporaryDirectory(prefix="codex-memory-policy-")
        self.root = Path(self.temp_dir.name)
        self.home = self.root / "home"
        self.codex_home = self.root / "codex-home"
        self.workspace = self.root / "workspace"
        for directory in (
            self.home,
            self.codex_home,
            self.workspace,
            self.root / "xdg-config",
            self.root / "xdg-cache",
            self.root / "xdg-data",
            self.root / "xdg-state",
        ):
            directory.mkdir()

        self.env = {
            "HOME": str(self.home),
            "CODEX_HOME": str(self.codex_home),
            "XDG_CONFIG_HOME": str(self.root / "xdg-config"),
            "XDG_CACHE_HOME": str(self.root / "xdg-cache"),
            "XDG_DATA_HOME": str(self.root / "xdg-data"),
            "XDG_STATE_HOME": str(self.root / "xdg-state"),
            "TMPDIR": os.environ.get("TMPDIR", tempfile.gettempdir()),
            "PATH": os.environ.get("PATH", os.defpath),
            "LANG": os.environ.get("LANG", "C.UTF-8"),
            "COMMAND_MODE": os.environ.get("COMMAND_MODE", "unix2003"),
            "USER": os.environ.get("USER", "fixture-user"),
            "LOGNAME": os.environ.get("LOGNAME", "fixture-user"),
            "__CF_USER_TEXT_ENCODING": os.environ.get(
                "__CF_USER_TEXT_ENCODING", "0x0:0x0:0x0"
            ),
        }

        self.model_instructions = self.codex_home / "engram-instructions.md"
        self.compact_instructions = self.codex_home / "engram-compact-prompt.md"
        self.model_instructions.write_text("PRIVATE_MODEL_MARKER_4F3A\n")
        self.compact_instructions.write_text("PRIVATE_COMPACT_MARKER_993C\n")
        self.agents_marker = "FIXTURE_AGENTS_DISCOVERY_41BA"
        (self.workspace / "AGENTS.md").write_text(self.agents_marker + "\n")
        (self.codex_home / "parallel-work.config.toml").symlink_to(PROFILE)

        self.mcp_started = self.root / "mcp-started"
        self.mcp_command = self.root / "engram-mcp-trap"
        self.mcp_command.write_text(
            "#!/bin/sh\nprintf started >\"${MCP_STARTED:?}\"\nexit 99\n"
        )
        self.mcp_command.chmod(self.mcp_command.stat().st_mode | stat.S_IXUSR)
        self.env["MCP_STARTED"] = str(self.mcp_started)
        self.config_path = self.codex_home / "config.toml"
        self.write_contaminated_config()

    def tearDown(self):
        self.temp_dir.cleanup()

    def write_contaminated_config(
        self,
        model_target=None,
        compact_target=None,
        extra_text="",
        mcp_enabled=True,
    ):
        model_target = model_target or self.model_instructions
        compact_target = compact_target or self.compact_instructions
        mcp_enabled_text = (
            "enabled = true\n" if mcp_enabled else 'args = ["--fixture"]\n'
        )
        self.config_path.write_text(
            "# fixture comment that native deletion may remove\n"
            f'model_instructions_file = "{model_target}"\n'
            f'experimental_compact_prompt_file = "{compact_target}"\n'
            'model = "gpt-5.6-sol"\n'
            'service_tier = "default"\n'
            "\n"
            '[plugins."engram@engram"]\n'
            "enabled = true\n"
            "\n"
            "[mcp_servers.engram]\n"
            f'command = "{self.mcp_command}"\n'
            + mcp_enabled_text
            + "\n"
            "[sandbox_workspace_write]\n"
            'writable_roots = ["/tmp/unrelated-sentinel-root"]\n'
            + extra_text
        )

    def run_helper(self, *arguments, env=None):
        return subprocess.run(
            [PYTHON, "-B", str(SCRIPT), *arguments],
            cwd=self.workspace,
            env=env or self.env,
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            timeout=15,
        )

    def read_config(self):
        with AppServerClient(self.env, str(self.workspace)) as client:
            return client.read_config()

    def user_layer(self, result):
        layers = [
            layer
            for layer in result["layers"]
            if layer["name"].get("type") == "user"
            and layer["name"].get("profile") is None
        ]
        self.assertEqual(1, len(layers))
        return layers[0]

    def parse_report(self, process):
        self.assertEqual("", process.stderr)
        lines = process.stdout.splitlines()
        self.assertEqual(6, len(lines), process.stdout)
        parsed = dict(line.split("=", 1) for line in lines)
        self.assertEqual(
            {"config_file", "config_version", *SCOPED_KEYS}, set(parsed)
        )
        self.assertEqual(str(self.config_path.resolve()), parsed["config_file"])
        self.assertTrue(parsed["config_version"].startswith("sha256:"))
        return parsed

    def assert_no_runtime_side_effects(self):
        self.assertFalse(self.mcp_started.exists(), "fixture MCP command was started")
        self.assertFalse((self.codex_home / "sessions").exists())

    def test_fixture_environment_is_an_explicit_credential_free_allowlist(self):
        self.assertEqual(
            {
                "HOME",
                "CODEX_HOME",
                "XDG_CONFIG_HOME",
                "XDG_CACHE_HOME",
                "XDG_DATA_HOME",
                "XDG_STATE_HOME",
                "TMPDIR",
                "PATH",
                "LANG",
                "COMMAND_MODE",
                "USER",
                "LOGNAME",
                "__CF_USER_TEXT_ENCODING",
                "MCP_STARTED",
            },
            set(self.env),
        )

    def test_report_and_dry_run_are_read_only_and_show_only_scoped_operations(self):
        before_bytes = self.config_path.read_bytes()
        native = self.read_config()
        layer = self.user_layer(native)
        expected_file = str(self.config_path.resolve())
        expected_targets = {
            "model_instructions_file": str(self.model_instructions),
            "experimental_compact_prompt_file": str(self.compact_instructions),
        }
        for key, expected_value in expected_targets.items():
            self.assertEqual(expected_value, native["config"][key])
            self.assertEqual("user", native["origins"][key]["name"]["type"])
            self.assertIsNone(native["origins"][key]["name"]["profile"])
            self.assertEqual(expected_file, native["origins"][key]["name"]["file"])
            self.assertEqual(layer["version"], native["origins"][key]["version"])

        for arguments in ((), ("--dry-run",)):
            with self.subTest(arguments=arguments):
                process = self.run_helper(*arguments)
                self.assertEqual(1, process.returncode)
                report = self.parse_report(process)
                self.assertEqual(layer["version"], report["config_version"])
                self.assertEqual("remove", report["model_instructions_file"])
                self.assertEqual(
                    "remove", report["experimental_compact_prompt_file"]
                )
                self.assertEqual(
                    "set_false", report["plugins.engram@engram.enabled"]
                )
                self.assertEqual(
                    "set_false", report["mcp_servers.engram.enabled"]
                )
                self.assertEqual(before_bytes, self.config_path.read_bytes())
                combined = process.stdout + process.stderr
                self.assertNotIn("unrelated-sentinel-root", combined)
                self.assertNotIn("PRIVATE_MODEL_MARKER", combined)
                self.assertNotIn("PRIVATE_COMPACT_MARKER", combined)

        self.assert_no_runtime_side_effects()

    def test_mcp_implicit_enabled_default_uses_exact_user_server_provenance(self):
        self.write_contaminated_config(mcp_enabled=False)
        before_bytes = self.config_path.read_bytes()
        native = self.read_config()
        layer = self.user_layer(native)
        raw_server = layer["config"]["mcp_servers"]["engram"]

        self.assertNotIn("enabled", raw_server)
        self.assertTrue(native["config"]["mcp_servers"]["engram"]["enabled"])
        self.assertNotIn("mcp_servers.engram.enabled", native["origins"])
        expected_file = str(self.config_path.resolve())
        for key in ("mcp_servers.engram.command", "mcp_servers.engram.args.0"):
            self.assertEqual("user", native["origins"][key]["name"]["type"])
            self.assertIsNone(native["origins"][key]["name"]["profile"])
            self.assertEqual(expected_file, native["origins"][key]["name"]["file"])
            self.assertEqual(layer["version"], native["origins"][key]["version"])

        process = self.run_helper("--dry-run")
        self.assertEqual(1, process.returncode, process.stderr)
        report = self.parse_report(process)
        self.assertEqual("set_false", report["mcp_servers.engram.enabled"])
        self.assertEqual(before_bytes, self.config_path.read_bytes())

        apply_process = self.run_helper(
            "--apply", "--expected-version", report["config_version"]
        )
        self.assertEqual(0, apply_process.returncode, apply_process.stderr)
        applied = self.read_config()
        applied_layer = self.user_layer(applied)
        self.assertFalse(applied["config"]["mcp_servers"]["engram"]["enabled"])
        self.assertFalse(
            applied_layer["config"]["mcp_servers"]["engram"]["enabled"]
        )
        enabled_origin = applied["origins"]["mcp_servers.engram.enabled"]
        self.assertEqual("user", enabled_origin["name"]["type"])
        self.assertEqual(str(self.config_path.resolve()), enabled_origin["name"]["file"])
        self.assertEqual(applied_layer["version"], enabled_origin["version"])
        self.assert_no_runtime_side_effects()

    def test_mcp_implicit_enabled_default_rejects_missing_or_mixed_provenance(self):
        before_bytes = self.config_path.read_bytes()
        expected_errors = {
            "implicit-mcp-missing-origin": "ambiguous user origin",
            "implicit-mcp-mixed-origin": "non-user origin",
        }
        for mode, expected_error in expected_errors.items():
            with self.subTest(mode=mode):
                fake_env, _ = self.fake_codex_environment(mode)
                process = self.run_helper(env=fake_env)
                self.assertEqual(2, process.returncode)
                self.assertIn(expected_error, process.stderr.lower())
                self.assertEqual(before_bytes, self.config_path.read_bytes())
        self.assert_no_runtime_side_effects()

    def test_missing_known_instruction_files_break_both_profile_inheritance_paths(self):
        controls = (
            ("model_instructions_file", self.model_instructions),
            ("experimental_compact_prompt_file", self.compact_instructions),
        )
        for key, target in controls:
            with self.subTest(key=key):
                if not self.model_instructions.exists():
                    self.model_instructions.write_text("model\n")
                if not self.compact_instructions.exists():
                    self.compact_instructions.write_text("compact\n")
                target.unlink()
                self.write_contaminated_config()
                process = subprocess.run(
                    [
                        "codex",
                        "-p",
                        "parallel-work",
                        "debug",
                        "prompt-input",
                        "fixture probe",
                    ],
                    cwd=self.workspace,
                    env=self.env,
                    text=True,
                    stdout=subprocess.PIPE,
                    stderr=subprocess.PIPE,
                    timeout=15,
                )
                self.assertNotEqual(0, process.returncode)
                self.assertIn(target.name, process.stderr)
        self.assert_no_runtime_side_effects()

    def test_apply_uses_native_deletion_preserves_unrelated_config_and_is_idempotent(self):
        report_process = self.run_helper()
        self.assertEqual(1, report_process.returncode)
        expected_version = self.parse_report(report_process)["config_version"]

        apply_process = self.run_helper(
            "--apply", "--expected-version", expected_version
        )
        self.assertEqual(0, apply_process.returncode, apply_process.stderr)
        applied_report = self.parse_report(apply_process)
        self.assertEqual(expected_version, applied_report["config_version"])

        native = self.read_config()
        self.assertIsNone(native["config"]["model_instructions_file"])
        self.assertIsNone(native["config"]["experimental_compact_prompt_file"])
        self.assertFalse(native["config"]["plugins"]["engram@engram"]["enabled"])
        self.assertFalse(native["config"]["mcp_servers"]["engram"]["enabled"])
        self.assertEqual("gpt-5.6-sol", native["config"]["model"])
        self.assertEqual("default", native["config"]["service_tier"])
        self.assertEqual(
            ["/tmp/unrelated-sentinel-root"],
            native["config"]["sandbox_workspace_write"]["writable_roots"],
        )
        config_text = self.config_path.read_text()
        self.assertIn(f'command = "{self.mcp_command}"', config_text)
        self.assertNotIn("model_instructions_file", config_text)
        self.assertNotIn("experimental_compact_prompt_file", config_text)

        for profile_arguments in ((), ("-p", "parallel-work")):
            with self.subTest(profile_arguments=profile_arguments):
                mcp_process = subprocess.run(
                    ["codex", *profile_arguments, "mcp", "list", "--json"],
                    cwd=self.workspace,
                    env=self.env,
                    text=True,
                    stdout=subprocess.PIPE,
                    stderr=subprocess.PIPE,
                    timeout=15,
                )
                self.assertEqual(0, mcp_process.returncode, mcp_process.stderr)
                entries = json.loads(mcp_process.stdout)
                engram = next(entry for entry in entries if entry["name"] == "engram")
                self.assertFalse(engram["enabled"])

                prompt_process = subprocess.run(
                    [
                        "codex",
                        *profile_arguments,
                        "debug",
                        "prompt-input",
                        "fixture probe",
                    ],
                    cwd=self.workspace,
                    env=self.env,
                    text=True,
                    stdout=subprocess.PIPE,
                    stderr=subprocess.PIPE,
                    timeout=15,
                )
                self.assertEqual(0, prompt_process.returncode, prompt_process.stderr)
                self.assertIn(self.agents_marker, prompt_process.stdout)
                self.assertNotIn("PRIVATE_MODEL_MARKER", prompt_process.stdout)
                self.assertNotIn("PRIVATE_COMPACT_MARKER", prompt_process.stdout)

        clean_layer = self.user_layer(native)
        before_reapply = self.config_path.read_bytes()
        reapply_process = self.run_helper(
            "--apply", "--expected-version", clean_layer["version"]
        )
        self.assertEqual(0, reapply_process.returncode, reapply_process.stderr)
        clean_report = self.parse_report(reapply_process)
        self.assertEqual("absent", clean_report["model_instructions_file"])
        self.assertEqual(
            "absent", clean_report["experimental_compact_prompt_file"]
        )
        self.assertEqual(
            "already_false", clean_report["plugins.engram@engram.enabled"]
        )
        self.assertEqual(
            "already_false", clean_report["mcp_servers.engram.enabled"]
        )
        self.assertEqual(before_reapply, self.config_path.read_bytes())
        self.assert_no_runtime_side_effects()

    def test_apply_requires_explicit_expected_version(self):
        before_bytes = self.config_path.read_bytes()
        missing_version = self.run_helper("--apply")
        self.assertEqual(2, missing_version.returncode)
        self.assertIn("--expected-version", missing_version.stderr)
        self.assertEqual(before_bytes, self.config_path.read_bytes())

        version_without_apply = self.run_helper(
            "--expected-version", "sha256:not-authorized"
        )
        self.assertEqual(2, version_without_apply.returncode)
        self.assertIn("requires --apply", version_without_apply.stderr)
        self.assertEqual(before_bytes, self.config_path.read_bytes())
        self.assert_no_runtime_side_effects()

    def test_stale_expected_version_fails_without_mutation(self):
        initial = self.run_helper()
        self.assertEqual(1, initial.returncode)
        stale_version = self.parse_report(initial)["config_version"]
        self.config_path.write_text(
            self.config_path.read_text().replace(
                'model = "gpt-5.6-sol"', 'model = "gpt-5.6-terra"'
            )
        )
        concurrent_bytes = self.config_path.read_bytes()

        process = self.run_helper("--apply", "--expected-version", stale_version)
        self.assertEqual(2, process.returncode)
        self.assertIn("version", process.stderr.lower())
        self.assertEqual(concurrent_bytes, self.config_path.read_bytes())
        self.assert_no_runtime_side_effects()

    def test_unknown_custom_instruction_targets_fail_closed(self):
        custom_target = self.root / "custom-instructions.md"
        custom_target.write_text("custom\n")
        cases = (
            {"model_target": custom_target},
            {"compact_target": custom_target},
        )
        for overrides in cases:
            with self.subTest(overrides=overrides):
                self.write_contaminated_config(**overrides)
                before_bytes = self.config_path.read_bytes()
                process = self.run_helper()
                self.assertEqual(2, process.returncode)
                self.assertIn("instruction", process.stderr.lower())
                self.assertNotIn(str(custom_target), process.stderr)
                self.assertEqual(before_bytes, self.config_path.read_bytes())
        self.assert_no_runtime_side_effects()

    def test_symlink_config_path_fails_closed_before_native_write(self):
        real_config = self.codex_home / "real-config.toml"
        self.config_path.rename(real_config)
        self.config_path.symlink_to(real_config)
        before_bytes = real_config.read_bytes()

        process = self.run_helper()
        self.assertEqual(2, process.returncode)
        self.assertIn("symlink", process.stderr.lower())
        self.assertEqual(before_bytes, real_config.read_bytes())
        self.assert_no_runtime_side_effects()

    def test_malformed_config_and_protocol_fail_closed_without_raw_output(self):
        self.config_path.write_text('[broken\nvalue = "unterminated\n')
        malformed_bytes = self.config_path.read_bytes()
        config_process = self.run_helper()
        self.assertEqual(2, config_process.returncode)
        self.assertIn("configuration", config_process.stderr.lower())
        self.assertEqual(malformed_bytes, self.config_path.read_bytes())

        self.write_contaminated_config()
        fake_env, _ = self.fake_codex_environment("malformed")
        protocol_process = self.run_helper(env=fake_env)
        self.assertEqual(2, protocol_process.returncode)
        self.assertIn("protocol", protocol_process.stderr.lower())
        self.assertNotIn("not-json-protocol-payload", protocol_process.stderr)

        live_child_env, _ = self.fake_codex_environment("malformed-live-child")
        child_pid_path = self.root / "malformed-child.pid"
        live_child_env["FAKE_CODEX_PID"] = str(child_pid_path)
        live_child_process = self.run_helper(env=live_child_env)
        self.assertEqual(2, live_child_process.returncode)
        child_pid = int(child_pid_path.read_text())
        try:
            with self.assertRaises(ProcessLookupError):
                os.kill(child_pid, 0)
        finally:
            try:
                os.kill(child_pid, signal.SIGTERM)
            except ProcessLookupError:
                pass
        self.assert_no_runtime_side_effects()

    def test_protocol_reader_drains_coalesced_messages_without_false_timeout(self):
        fake_env, _ = self.fake_codex_environment("coalesced")
        started = time.monotonic()
        process = self.run_helper(env=fake_env)
        elapsed = time.monotonic() - started
        self.assertEqual(1, process.returncode, process.stderr)
        self.parse_report(process)
        self.assertLess(elapsed, 3)
        self.assert_no_runtime_side_effects()

    def test_non_utf8_protocol_failure_is_sanitized_and_uses_error_status(self):
        fake_env, _ = self.fake_codex_environment("non-utf8")
        process = self.run_helper(env=fake_env)
        self.assertEqual(2, process.returncode)
        self.assertIn("protocol", process.stderr.lower())
        self.assertNotIn("traceback", process.stderr.lower())
        self.assertNotIn("\\xff", process.stderr.lower())
        self.assert_no_runtime_side_effects()

    def test_non_user_origin_and_ambiguous_user_layer_fail_closed(self):
        before_bytes = self.config_path.read_bytes()
        expected_errors = {
            "non-user-origin": "non-user origin",
            "ambiguous-user-layers": "ambiguous user configuration",
        }
        for mode, expected_error in expected_errors.items():
            with self.subTest(mode=mode):
                fake_env, _ = self.fake_codex_environment(mode)
                process = self.run_helper(env=fake_env)
                self.assertEqual(2, process.returncode)
                self.assertIn(expected_error, process.stderr.lower())
                self.assertEqual(before_bytes, self.config_path.read_bytes())
        self.assert_no_runtime_side_effects()

    def test_app_server_invocation_is_unprofiled(self):
        fake_env, argv_path = self.fake_codex_environment("valid")
        process = self.run_helper(env=fake_env)
        self.assertEqual(1, process.returncode, process.stderr)
        self.parse_report(process)
        self.assertEqual(
            ["app-server", "--listen", "stdio://"],
            json.loads(argv_path.read_text()),
        )
        self.assert_no_runtime_side_effects()

    def test_production_home_detection_does_not_trust_environment_home(self):
        spec = importlib.util.spec_from_file_location("codex_memory_policy", SCRIPT)
        module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(module)
        account_home = Path("/Users/fixture-account")
        production_config = account_home / ".codex" / "config.toml"
        unrelated_config = self.codex_home / "config.toml"
        self.assertTrue(
            module._is_production_config_path(
                production_config, account_home=account_home
            )
        )
        self.assertFalse(
            module._is_production_config_path(
                unrelated_config, account_home=account_home
            )
        )

    def fake_codex_environment(self, mode):
        shim_dir = self.root / ("shim-" + mode.replace("-", "_"))
        shim_dir.mkdir(exist_ok=True)
        argv_path = shim_dir / "argv.json"
        shim = shim_dir / "codex"
        shim.write_text(
            """#!/usr/bin/python3
import json
import os
from pathlib import Path
import sys
import time

Path(os.environ["FAKE_CODEX_ARGV"]).write_text(json.dumps(sys.argv[1:]))
mode = os.environ["FAKE_CODEX_MODE"]
codex_home = Path(os.environ["CODEX_HOME"]).resolve()
config_file = (codex_home / "config.toml").resolve()
version = "sha256:fixture-version"

for line in sys.stdin:
    if mode in ("malformed", "malformed-live-child"):
        if mode == "malformed-live-child":
            Path(os.environ["FAKE_CODEX_PID"]).write_text(str(os.getpid()))
        print("not-json-protocol-payload", flush=True)
        if mode == "malformed-live-child":
            time.sleep(30)
        break
    if mode == "non-utf8":
        sys.stdout.buffer.write(b"\\xff\\n")
        sys.stdout.buffer.flush()
        break
    message = json.loads(line)
    request_id = message.get("id")
    if request_id is None:
        continue
    if message.get("method") == "initialize":
        result = {
            "userAgent": "fixture/0",
            "codexHome": str(codex_home),
            "platformFamily": "unix",
            "platformOs": "macos",
        }
    elif message.get("method") == "config/read":
        implicit_mcp = mode in (
            "implicit-mcp-missing-origin",
            "implicit-mcp-mixed-origin",
        )
        effective_mcp = {"enabled": True}
        if implicit_mcp:
            effective_mcp.update({"command": "fixture-engram", "args": ["serve"]})
        config = {
            "model_instructions_file": str(codex_home / "engram-instructions.md"),
            "experimental_compact_prompt_file": str(codex_home / "engram-compact-prompt.md"),
            "plugins": {"engram@engram": {"enabled": True}},
            "mcp_servers": {"engram": effective_mcp},
        }
        user_name = {
            "type": "user",
            "file": str(config_file),
            "profile": None,
        }
        layer_config = json.loads(json.dumps(config))
        if implicit_mcp:
            del layer_config["mcp_servers"]["engram"]["enabled"]
        layer = {"name": user_name, "version": version, "config": layer_config}
        layers = [layer]
        if mode == "ambiguous-user-layers":
            layers.append(dict(layer))
        origins = {
            key: {"name": dict(user_name), "version": version}
            for key in (
                "model_instructions_file",
                "experimental_compact_prompt_file",
                "plugins.engram@engram.enabled",
                "mcp_servers.engram.enabled",
            )
        }
        if mode == "non-user-origin":
            origins["model_instructions_file"] = {
                "name": {"type": "system", "file": "/etc/codex/config.toml"},
                "version": version,
            }
        if implicit_mcp:
            del origins["mcp_servers.engram.enabled"]
            origins["mcp_servers.engram.command"] = {
                "name": dict(user_name),
                "version": version,
            }
            if mode == "implicit-mcp-mixed-origin":
                origins["mcp_servers.engram.args.0"] = {
                    "name": {"type": "system", "file": "/etc/codex/config.toml"},
                    "version": version,
                }
        result = {"config": config, "layers": layers, "origins": origins}
    else:
        print(json.dumps({"id": request_id, "error": {"code": -1}}), flush=True)
        continue
    response = json.dumps({"id": request_id, "result": result})
    if mode == "coalesced" and message.get("method") == "initialize":
        notification = json.dumps({"method": "fixture/notification", "params": {}})
        sys.stdout.write(notification + "\\n" + response + "\\n")
        sys.stdout.flush()
    else:
        print(response, flush=True)
"""
        )
        shim.chmod(shim.stat().st_mode | stat.S_IXUSR)
        fake_env = self.env.copy()
        fake_env["FAKE_CODEX_MODE"] = mode
        fake_env["FAKE_CODEX_ARGV"] = str(argv_path)
        fake_env["PATH"] = str(shim_dir) + os.pathsep + fake_env["PATH"]
        return fake_env, argv_path


if __name__ == "__main__":
    unittest.main()
