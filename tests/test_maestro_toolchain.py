"""Offline tests: fake archives/processes, never a device, network, or real HOME."""
import contextlib
import hashlib
import importlib.machinery
import importlib.util
import io
import json
import os
import stat
import subprocess
import tempfile
import unittest
import zipfile
from pathlib import Path
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / "maestro/.local/bin/maestro-toolchain"
PIN = ROOT / "maestro/.local/share/maestro-toolchain/pin.json"


class ToolchainTests(unittest.TestCase):
    def setUp(self):
        self.assertTrue(SCRIPT.is_file(), "shared Maestro toolchain helper is missing")
        loader = importlib.machinery.SourceFileLoader("maestro_toolchain", str(SCRIPT))
        spec = importlib.util.spec_from_loader(loader.name, loader)
        self.tool = importlib.util.module_from_spec(spec)
        loader.exec_module(self.tool)
        self.tmp = tempfile.TemporaryDirectory(prefix="maestro-test-")
        self.addCleanup(self.tmp.cleanup)
        self.home = Path(self.tmp.name) / "home with spaces"
        self.home.mkdir()
        self.archive = Path(self.tmp.name) / "maestro.zip"
        self.pin = {"version": "2.10.0", "sha256": "0" * 64}
        self.make_archive()

    def make_archive(self, extra=None, launcher=True, jar=True):
        with zipfile.ZipFile(self.archive, "w") as z:
            if launcher:
                info = zipfile.ZipInfo("maestro/bin/maestro")
                info.external_attr = (stat.S_IFREG | 0o755) << 16
                z.writestr(info, "#!/bin/sh\nprintf '2.10.0\\n'\n")
            if jar:
                z.writestr("maestro/lib/maestro-cli-2.10.0.jar", "fixture")
            if extra:
                z.writestr(*extra)
        self.pin["sha256"] = hashlib.sha256(self.archive.read_bytes()).hexdigest()

    def install(self):
        return self.tool.install(self.pin, self.home, self.archive)

    def test_install_verifies_archive_preserves_executable_and_receipt(self):
        binary = self.install()
        self.assertEqual(subprocess.check_output([str(binary)], text=True).strip(), "2.10.0")
        self.assertEqual(binary, self.tool.installed_binary(self.pin, self.home))
        self.assertEqual(json.loads((binary.parents[2] / "receipt.json").read_text()), self.pin)
        self.assertFalse((self.home / ".maestro").exists())

    def test_existing_install_is_idempotent_without_reading_archive(self):
        binary = self.install()
        before = binary.stat().st_mtime_ns
        self.archive.unlink()
        self.assertEqual(self.install(), binary)
        self.assertEqual(binary.stat().st_mtime_ns, before)

    def test_checksum_mismatch_fails_before_extraction(self):
        self.pin["sha256"] = "f" * 64
        with self.assertRaisesRegex(self.tool.ToolchainError, "checksum"):
            self.install()
        self.assertFalse((self.home / ".local/share/maestro-cli/2.10.0").exists())

    def test_existing_conflicting_install_is_never_overwritten(self):
        binary = self.install()
        (binary.parents[2] / "receipt.json").write_text("{}")
        with self.assertRaisesRegex(self.tool.ToolchainError, "conflicting|incomplete"):
            self.install()
        self.assertEqual(binary.read_text(), "#!/bin/sh\nprintf '2.10.0\\n'\n")

    def test_missing_launcher_or_jar_never_publishes_install(self):
        for options in ({"launcher": False}, {"jar": False}):
            with self.subTest(options=options):
                self.make_archive(**options)
                with self.assertRaisesRegex(self.tool.ToolchainError, "layout"):
                    self.install()
                self.assertFalse((self.home / ".local/share/maestro-cli/2.10.0").exists())

    def test_archive_traversal_absolute_and_unexpected_roots_rejected(self):
        for name in ("maestro/../../../escaped", "/tmp/escaped", "other/bin/run", "maestro/../escaped"):
            with self.subTest(name=name):
                self.make_archive(extra=(name, "bad"))
                with self.assertRaisesRegex(self.tool.ToolchainError, "unsafe"):
                    self.install()
        self.assertFalse((self.home / ".local/share/maestro-cli/2.10.0").exists())

    def test_archive_symlink_rejected(self):
        info = zipfile.ZipInfo("maestro/link")
        info.external_attr = (stat.S_IFLNK | 0o777) << 16
        self.make_archive(extra=(info, "/tmp"))
        with self.assertRaisesRegex(self.tool.ToolchainError, "unsafe"):
            self.install()

    def test_symlink_install_directory_rejected(self):
        base = self.home / ".local/share/maestro-cli"
        base.parent.mkdir(parents=True)
        target = Path(self.tmp.name) / "outside"
        target.mkdir()
        base.symlink_to(target, target_is_directory=True)
        with self.assertRaisesRegex(self.tool.ToolchainError, "symlink"):
            self.install()
        self.assertEqual(list(target.iterdir()), [])

    def test_symlinked_local_or_share_parent_never_receives_binaries(self):
        for relative in (".local", ".local/share"):
            with self.subTest(parent=relative):
                home = self.home / relative.replace("/", "-")
                home.mkdir()
                target = home / "tracked-package"
                target.mkdir()
                link = home / relative
                link.parent.mkdir(parents=True, exist_ok=True)
                link.symlink_to(target, target_is_directory=True)
                with self.assertRaisesRegex(self.tool.ToolchainError, "symlink"):
                    self.tool.install(self.pin, home, self.archive)
                self.assertEqual(list(target.iterdir()), [])

    def test_missing_install_reports_actionable_error(self):
        with self.assertRaisesRegex(self.tool.ToolchainError, "install"):
            self.tool.installed_binary(self.pin, self.home)

    def test_runtime_environment_is_private_child_only(self):
        original = {"JAVA_HOME": "/old", "MAESTRO_JAVA_HOME": "/jdk", "MAESTRO_API_URL": "https://elsewhere", "MAESTRO_CLI_NO_ANALYTICS": "false"}
        result = self.tool.runtime_env(original)
        self.assertEqual(original["JAVA_HOME"], "/old")
        self.assertEqual(result["JAVA_HOME"], "/jdk")
        self.assertEqual(result["MAESTRO_API_URL"], "http://127.0.0.1:9")
        for key in ("MAESTRO_CLI_NO_ANALYTICS", "MAESTRO_DISABLE_UPDATE_CHECK", "MAESTRO_CLI_ANALYSIS_NOTIFICATION_DISABLED"):
            self.assertEqual(result[key], "true")

    def test_java_home_preserved_without_specific_override(self):
        self.assertEqual(self.tool.runtime_env({"JAVA_HOME": "/current"})["JAVA_HOME"], "/current")

    def test_real_wrapper_preserves_arguments_cwd_environment_and_exit_code(self):
        # The fake installed launcher exercises actual CLI process forwarding.
        real_pin = json.loads(PIN.read_text())
        binary = self.install()
        (binary.parents[2] / "receipt.json").write_text(json.dumps(real_pin))
        binary.write_text("#!/usr/bin/env python3\nimport json,os,sys\nprint(json.dumps([sys.argv[1:],os.getcwd(),os.environ['MAESTRO_CLI_NO_ANALYTICS'],os.environ['MAESTRO_API_URL']]))\nsys.exit(37)\n")
        result = subprocess.run([str(SCRIPT.parent / "maestro"), "test", "a flow.yaml", "-e", "TITLE=a b", "--device", "explicit-id"], cwd=self.tmp.name, env={**os.environ, "HOME": str(self.home)}, capture_output=True, text=True, check=False)
        self.assertEqual(result.returncode, 37, result.stderr)
        self.assertEqual(json.loads(result.stdout), [["test", "a flow.yaml", "-e", "TITLE=a b", "--device", "explicit-id"], str(Path(self.tmp.name).resolve()), "true", "http://127.0.0.1:9"])

    def doctor(self, java='openjdk version "26.0.2.1"', maestro="2.10.0", ios=False, devices=None):
        self.install()
        calls = []
        def capture(argv, env):
            calls.append(argv)
            if argv[-1] == "-version":
                return java
            if argv[-1] == "--version":
                return maestro
            if argv[0] == "xcodebuild":
                return "Xcode 26.6\nBuild version fixture"
            if argv[0] == "xcrun":
                return json.dumps({"devices": devices if devices is not None else {"com.apple.CoreSimulator.SimRuntime.iOS-26-5": [{"name": "fixture", "udid": "test-udid", "isAvailable": True, "state": "Shutdown"}]}})
            self.fail("Unexpected probe: " + repr(argv))
        with patch.object(self.tool, "capture", side_effect=capture), patch.object(self.tool.platform, "system", return_value="Darwin"), contextlib.redirect_stdout(io.StringIO()) as output:
            result = self.tool.doctor(self.pin, self.home, ios=ios)
        return result, output.getvalue(), calls

    def test_doctor_reports_toolchain_not_app_readiness(self):
        code, output, calls = self.doctor()
        self.assertEqual(code, 0)
        self.assertIn("app/driver tests NOT RUN", output)
        self.assertFalse(any(x[0] in ("xcrun", "xcodebuild") for x in calls))

    def test_doctor_rejects_old_java(self):
        code, output, _ = self.doctor(java='java version "1.8.0_421"')
        self.assertEqual(code, 1)
        self.assertIn("Java 17", output)

    def test_doctor_rejects_wrong_maestro(self):
        code, output, _ = self.doctor(maestro="2.11.0")
        self.assertEqual(code, 1)
        self.assertIn("2.10.0", output)

    def test_doctor_preserves_successful_startup_warnings(self):
        code, output, _ = self.doctor(maestro="2.10.0\nWARNING: fixture reflection diagnostic")
        self.assertEqual(code, 0)
        self.assertIn("WARN Maestro startup", output)
        self.assertIn("fixture reflection diagnostic", output)

    def test_doctor_ios_only_lists_inventory(self):
        code, output, calls = self.doctor(ios=True)
        self.assertEqual(code, 0)
        self.assertIn("test-udid", output)
        self.assertIn(["xcrun", "simctl", "list", "devices", "available", "--json"], calls)
        self.assertFalse(any(any(word in x for word in ("boot", "launch", "install")) for x in calls))

    def test_doctor_ios_missing_runtime_fails(self):
        code, output, _ = self.doctor(ios=True, devices={})
        self.assertEqual(code, 1)
        self.assertIn("iOS simulator", output)

    def test_doctor_missing_java_returns_failure(self):
        with patch.object(self.tool, "capture", side_effect=self.tool.ToolchainError("java unavailable")), contextlib.redirect_stdout(io.StringIO()) as output:
            self.assertEqual(self.tool.doctor(self.pin, self.home), 1)
        self.assertIn("java unavailable", output.getvalue())

    def test_pinned_manifest_rejects_malformed_version_or_digest(self):
        manifest = Path(self.tmp.name) / "pin.json"
        for change in ({"version": "../../bad"}, {"sha256": "not-a-digest"}):
            manifest.write_text(json.dumps({**self.pin, **change}))
            with self.assertRaises(self.tool.ToolchainError):
                self.tool.load_pin(manifest)


if __name__ == "__main__":
    unittest.main()
