#!/usr/bin/python3
"""Report or reconcile Codex's four Engram injection settings safely."""

import argparse
import copy
import json
import os
from pathlib import Path
import pwd
import selectors
import shutil
import subprocess
import sys
import time


EXIT_CLEAN = 0
EXIT_RECONCILIATION_NEEDED = 1
EXIT_ERROR = 2
REQUEST_TIMEOUT_SECONDS = 10
MAX_PROTOCOL_BUFFER_BYTES = 4 * 1024 * 1024

MODEL_INSTRUCTIONS_KEY = "model_instructions_file"
COMPACT_INSTRUCTIONS_KEY = "experimental_compact_prompt_file"
PLUGIN_ENABLED_KEY = "plugins.engram@engram.enabled"
MCP_ENABLED_KEY = "mcp_servers.engram.enabled"
SCOPED_KEYS = (
    MODEL_INSTRUCTIONS_KEY,
    COMPACT_INSTRUCTIONS_KEY,
    PLUGIN_ENABLED_KEY,
    MCP_ENABLED_KEY,
)

EDITS = (
    {
        "keyPath": MODEL_INSTRUCTIONS_KEY,
        "value": None,
        "mergeStrategy": "replace",
    },
    {
        "keyPath": COMPACT_INSTRUCTIONS_KEY,
        "value": None,
        "mergeStrategy": "replace",
    },
    {
        "keyPath": PLUGIN_ENABLED_KEY,
        "value": False,
        "mergeStrategy": "upsert",
    },
    {
        "keyPath": MCP_ENABLED_KEY,
        "value": True,
        "mergeStrategy": "upsert",
    },
)


class PolicyError(Exception):
    """A fail-closed validation or native protocol error."""


def _resolved(path):
    return Path(path).expanduser().resolve(strict=False)


def _account_home():
    return Path(pwd.getpwuid(os.getuid()).pw_dir)


def _is_production_config_path(candidate, account_home=None):
    home = account_home if account_home is not None else _account_home()
    return _resolved(candidate) == _resolved(Path(home) / ".codex" / "config.toml")


def _configured_codex_home():
    configured = os.environ.get("CODEX_HOME")
    if configured:
        return _resolved(configured)
    return _resolved(Path.home() / ".codex")


def _preflight_config_path(
    apply, allow_production_home=False, config_candidate=None, account_home=None
):
    if config_candidate is None:
        config_candidate = _configured_codex_home() / "config.toml"
    config_candidate = Path(config_candidate)
    if config_candidate.is_symlink():
        raise PolicyError("configuration path must not be a symlink")
    try:
        if not config_candidate.is_file():
            raise PolicyError("configuration file is missing or unsafe")
        config_path = config_candidate.resolve(strict=True)
    except OSError:
        raise PolicyError("configuration file is missing or unsafe")
    if (
        apply
        and _is_production_config_path(config_path, account_home=account_home)
        and not allow_production_home
    ):
        raise PolicyError(
            "production-home --apply requires --allow-production-home"
        )
    return config_path


class AppServer:
    def __init__(self, cwd):
        self.cwd = cwd
        self.process = None
        self.selector = None
        self.request_id = 1
        self.codex_home = None
        self.read_buffer = b""

    def __enter__(self):
        codex = shutil.which("codex")
        if not codex:
            raise PolicyError("codex executable is unavailable")
        try:
            self.process = subprocess.Popen(
                [codex, "app-server", "--listen", "stdio://"],
                cwd=self.cwd,
                stdin=subprocess.PIPE,
                stdout=subprocess.PIPE,
                stderr=subprocess.DEVNULL,
                bufsize=0,
            )
        except OSError:
            raise PolicyError("codex app-server could not be started")
        try:
            self.selector = selectors.DefaultSelector()
            self.selector.register(self.process.stdout, selectors.EVENT_READ)
            initialized = self.request(
                "initialize",
                {"clientInfo": {"name": "codex-memory-policy", "version": "1"}},
            )
            codex_home = initialized.get("codexHome")
            if not isinstance(codex_home, str) or not Path(codex_home).is_absolute():
                raise PolicyError("app-server initialize response is malformed")
            self.codex_home = _resolved(codex_home)
            self.notify("initialized")
            return self
        except BaseException:
            self._close()
            raise

    def __exit__(self, exc_type, exc, traceback):
        self._close()

    def _close(self):
        if self.selector is not None:
            self.selector.close()
            self.selector = None
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
        self.process = None

    def _send(self, payload):
        try:
            self.process.stdin.write(
                (json.dumps(payload, separators=(",", ":")) + "\n").encode("utf-8")
            )
            self.process.stdin.flush()
        except (BrokenPipeError, OSError):
            raise PolicyError("configuration or app-server protocol failure")

    def notify(self, method, params=None):
        message = {"jsonrpc": "2.0", "method": method}
        if params is not None:
            message["params"] = params
        self._send(message)

    def request(self, method, params):
        request_id = self.request_id
        self.request_id += 1
        self._send(
            {
                "jsonrpc": "2.0",
                "id": request_id,
                "method": method,
                "params": params,
            }
        )
        deadline = time.monotonic() + REQUEST_TIMEOUT_SECONDS
        messages_seen = 0
        while time.monotonic() < deadline and messages_seen < 100:
            line = self._read_protocol_line(deadline)
            messages_seen += 1
            try:
                message = json.loads(line.decode("utf-8"))
            except (TypeError, UnicodeDecodeError, ValueError):
                raise PolicyError("app-server protocol is malformed")
            if not isinstance(message, dict):
                raise PolicyError("app-server protocol is malformed")
            if message.get("id") != request_id:
                continue
            if "error" in message:
                raise PolicyError("configuration request failed")
            result = message.get("result")
            if not isinstance(result, dict):
                raise PolicyError("app-server response is malformed")
            return result
        raise PolicyError("app-server response timed out")

    def _read_protocol_line(self, deadline):
        while True:
            newline_index = self.read_buffer.find(b"\n")
            if newline_index >= 0:
                line = self.read_buffer[:newline_index]
                self.read_buffer = self.read_buffer[newline_index + 1 :]
                return line
            if len(self.read_buffer) > MAX_PROTOCOL_BUFFER_BYTES:
                raise PolicyError("app-server protocol is malformed")
            remaining = deadline - time.monotonic()
            if remaining <= 0 or not self.selector.select(remaining):
                raise PolicyError("app-server response timed out")
            try:
                chunk = os.read(self.process.stdout.fileno(), 65536)
            except OSError:
                raise PolicyError("configuration or app-server protocol failure")
            if not chunk:
                raise PolicyError("configuration or app-server protocol failure")
            self.read_buffer += chunk


def _nested_value(config, first, second, third=None):
    first_value = config.get(first)
    if first_value is None:
        return None
    if not isinstance(first_value, dict):
        raise PolicyError("scoped configuration is malformed")
    second_value = first_value.get(second)
    if second_value is None:
        return None
    if third is None:
        return second_value
    if not isinstance(second_value, dict):
        raise PolicyError("scoped configuration is malformed")
    return second_value.get(third)


def _user_layer(read_result):
    layers = read_result.get("layers")
    if not isinstance(layers, list):
        raise PolicyError("ambiguous user configuration layer")
    candidates = []
    for layer in layers:
        if not isinstance(layer, dict):
            raise PolicyError("ambiguous user configuration layer")
        name = layer.get("name")
        if not isinstance(name, dict):
            raise PolicyError("ambiguous user configuration layer")
        if name.get("type") == "user" and name.get("profile") is None:
            candidates.append(layer)
    if len(candidates) != 1:
        raise PolicyError("ambiguous user configuration layer")
    return candidates[0]


def _validate_origin(origins, key, config_path, version):
    origin = origins.get(key)
    if not isinstance(origin, dict):
        raise PolicyError("scoped setting has an ambiguous user origin")
    name = origin.get("name")
    if not isinstance(name, dict) or name.get("type") != "user":
        raise PolicyError("scoped setting has a non-user origin")
    if name.get("profile") is not None:
        raise PolicyError("scoped setting has an ambiguous user origin")
    origin_file = name.get("file")
    if not isinstance(origin_file, str) or _resolved(origin_file) != config_path:
        raise PolicyError("scoped setting has an ambiguous user origin")
    if origin.get("version") != version:
        raise PolicyError("scoped setting origin version is inconsistent")


def _validate_implicit_mcp_enabled_default(
    origins, user_layer_config, config_path, version
):
    if MCP_ENABLED_KEY in origins:
        raise PolicyError("scoped setting has an ambiguous user origin")
    if not isinstance(user_layer_config, dict):
        raise PolicyError("ambiguous user configuration layer")
    raw_server = _nested_value(user_layer_config, "mcp_servers", "engram")
    if (
        not isinstance(raw_server, dict)
        or not raw_server
        or "enabled" in raw_server
    ):
        raise PolicyError("scoped setting has an ambiguous user origin")

    server_prefix = "mcp_servers.engram."
    server_origin_keys = [
        key
        for key in origins
        if isinstance(key, str) and key.startswith(server_prefix)
    ]
    if not server_origin_keys:
        raise PolicyError("scoped setting has an ambiguous user origin")

    for raw_key, raw_value in raw_server.items():
        if not isinstance(raw_key, str) or not raw_key:
            raise PolicyError("scoped configuration is malformed")
        for raw_path in _raw_leaf_paths(raw_value, server_prefix + raw_key):
            if raw_path not in origins:
                raise PolicyError("scoped setting has an ambiguous user origin")

    for key in server_origin_keys:
        _validate_origin(origins, key, config_path, version)


def _raw_leaf_paths(value, prefix):
    if isinstance(value, dict):
        if not value:
            return [prefix]
        paths = []
        for key, nested in value.items():
            if not isinstance(key, str) or not key:
                raise PolicyError("scoped configuration is malformed")
            paths.extend(_raw_leaf_paths(nested, prefix + "." + key))
        return paths
    if isinstance(value, list):
        if not value:
            return [prefix]
        paths = []
        for index, nested in enumerate(value):
            paths.extend(_raw_leaf_paths(nested, prefix + "." + str(index)))
        return paths
    return [prefix]


def _known_instruction_action(value, expected_target):
    if value is None:
        return "absent"
    if not isinstance(value, str) or not Path(value).is_absolute():
        raise PolicyError("instruction target is not a known Engram instruction file")
    if _resolved(value) != _resolved(expected_target):
        raise PolicyError("instruction target is not a known Engram instruction file")
    return "remove"


def _enabled_action(value, desired):
    if value is None:
        return "absent"
    if not isinstance(value, bool):
        raise PolicyError("scoped configuration is malformed")
    if value is desired:
        return "already_true" if desired else "already_false"
    return "set_true" if desired else "set_false"


def _inspect_config(server, expected_config_path):
    read_result = server.request("config/read", {"includeLayers": True})
    config = read_result.get("config")
    origins = read_result.get("origins")
    if not isinstance(config, dict) or not isinstance(origins, dict):
        raise PolicyError("configuration response is malformed")

    layer = _user_layer(read_result)
    layer_name = layer.get("name")
    layer_file = layer_name.get("file")
    user_layer_config = layer.get("config")
    version = layer.get("version")
    if (
        not isinstance(layer_file, str)
        or not Path(layer_file).is_absolute()
        or not isinstance(version, str)
        or not version
        or not isinstance(user_layer_config, dict)
    ):
        raise PolicyError("ambiguous user configuration layer")
    config_path = _resolved(layer_file)
    if config_path != expected_config_path:
        raise PolicyError("user configuration path does not match the inspected file")
    if config_path != _resolved(server.codex_home / "config.toml"):
        raise PolicyError("user configuration path does not match Codex home")

    actions = {
        MODEL_INSTRUCTIONS_KEY: _known_instruction_action(
            config.get(MODEL_INSTRUCTIONS_KEY),
            server.codex_home / "engram-instructions.md",
        ),
        COMPACT_INSTRUCTIONS_KEY: _known_instruction_action(
            config.get(COMPACT_INSTRUCTIONS_KEY),
            server.codex_home / "engram-compact-prompt.md",
        ),
        PLUGIN_ENABLED_KEY: _enabled_action(
            _nested_value(config, "plugins", "engram@engram", "enabled"), False
        ),
        MCP_ENABLED_KEY: _enabled_action(
            _nested_value(config, "mcp_servers", "engram", "enabled"), True
        ),
    }
    if actions[MCP_ENABLED_KEY] == "absent":
        raise PolicyError("scoped Engram configuration is incomplete")

    for key, action in actions.items():
        if action != "absent":
            if key == MCP_ENABLED_KEY and key not in origins:
                if action != "already_true":
                    raise PolicyError("scoped setting has an ambiguous user origin")
                _validate_implicit_mcp_enabled_default(
                    origins, user_layer_config, config_path, version
                )
            else:
                _validate_origin(origins, key, config_path, version)

    return {
        "config_path": config_path,
        "version": version,
        "actions": actions,
        "user_config": copy.deepcopy(user_layer_config),
    }


def _needs_reconciliation(actions):
    return any(
        action in ("remove", "set_false", "set_true")
        for action in actions.values()
    )


def _unscoped_user_config(config):
    if not isinstance(config, dict):
        raise PolicyError("ambiguous user configuration layer")
    unscoped = copy.deepcopy(config)
    unscoped.pop(MODEL_INSTRUCTIONS_KEY, None)
    unscoped.pop(COMPACT_INSTRUCTIONS_KEY, None)

    plugins = unscoped.get("plugins")
    if isinstance(plugins, dict):
        engram_plugin = plugins.get("engram@engram")
        if isinstance(engram_plugin, dict):
            engram_plugin.pop("enabled", None)
            if not engram_plugin:
                plugins.pop("engram@engram", None)
        if not plugins:
            unscoped.pop("plugins", None)

    mcp_servers = unscoped.get("mcp_servers")
    if isinstance(mcp_servers, dict):
        engram_server = mcp_servers.get("engram")
        if isinstance(engram_server, dict):
            engram_server.pop("enabled", None)
            if not engram_server:
                mcp_servers.pop("engram", None)
        if not mcp_servers:
            unscoped.pop("mcp_servers", None)
    return unscoped


def _print_report(inspection):
    print("config_file=" + str(inspection["config_path"]))
    print("config_version=" + inspection["version"])
    for key in SCOPED_KEYS:
        print(key + "=" + inspection["actions"][key])


def _apply(server, inspection):
    actions = inspection["actions"]
    if not _needs_reconciliation(actions):
        return inspection["version"]
    if actions[MCP_ENABLED_KEY] == "absent":
        raise PolicyError("scoped Engram configuration is incomplete")
    write_result = server.request(
        "config/batchWrite",
        {
            "filePath": str(inspection["config_path"]),
            "expectedVersion": inspection["version"],
            "reloadUserConfig": False,
            "edits": list(EDITS),
        },
    )
    if write_result.get("status") != "ok":
        raise PolicyError("native configuration write was not accepted")
    written_file = write_result.get("filePath")
    written_version = write_result.get("version")
    if (
        not isinstance(written_file, str)
        or _resolved(written_file) != inspection["config_path"]
        or not isinstance(written_version, str)
        or not written_version
    ):
        raise PolicyError("native configuration write response is malformed")

    return written_version


def _parse_args(argv):
    parser = argparse.ArgumentParser(
        description="Report or reconcile Codex Engram injection settings."
    )
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument("--dry-run", action="store_true", help="report without writing")
    mode.add_argument("--apply", action="store_true", help="apply the scoped native edits")
    parser.add_argument(
        "--expected-version",
        help="exact user-config version previously returned by report/dry-run",
    )
    parser.add_argument(
        "--allow-production-home",
        action="store_true",
        help="permit an approved production-home apply; does not grant approval",
    )
    arguments = parser.parse_args(argv)
    if arguments.apply and not arguments.expected_version:
        parser.error("--apply requires --expected-version")
    if arguments.expected_version and not arguments.apply:
        parser.error("--expected-version requires --apply")
    if arguments.allow_production_home and not arguments.apply:
        parser.error("--allow-production-home requires --apply")
    return arguments


def main(argv=None):
    arguments = _parse_args(argv)
    try:
        expected_config_path = _preflight_config_path(
            arguments.apply, arguments.allow_production_home
        )
        with AppServer(cwd=os.getcwd()) as server:
            inspection = _inspect_config(server, expected_config_path)
            if arguments.apply:
                if arguments.expected_version != inspection["version"]:
                    raise PolicyError(
                        "expected version does not match inspected configuration version"
                    )
                before_unscoped = _unscoped_user_config(
                    inspection["user_config"]
                )
                write_required = _needs_reconciliation(inspection["actions"])
                written_version = _apply(server, inspection)
        if arguments.apply:
            with AppServer(cwd=os.getcwd()) as verification_server:
                verified = _inspect_config(verification_server, expected_config_path)
            if verified["version"] != written_version:
                raise PolicyError(
                    "configuration changed during post-write verification"
                )
            expected_actions = {
                MODEL_INSTRUCTIONS_KEY: "absent",
                COMPACT_INSTRUCTIONS_KEY: "absent",
                PLUGIN_ENABLED_KEY: (
                    "already_false"
                    if write_required
                    else inspection["actions"][PLUGIN_ENABLED_KEY]
                ),
                MCP_ENABLED_KEY: "already_true",
            }
            if verified["actions"] != expected_actions:
                raise PolicyError("post-write configuration verification failed")
            if _unscoped_user_config(verified["user_config"]) != before_unscoped:
                raise PolicyError(
                    "unrelated configuration changed during native reconciliation"
                )
        _print_report(inspection)
        if not arguments.apply and _needs_reconciliation(inspection["actions"]):
            return EXIT_RECONCILIATION_NEEDED
        return EXIT_CLEAN
    except PolicyError as error:
        print("ERROR: " + str(error), file=sys.stderr)
        return EXIT_ERROR


if __name__ == "__main__":
    sys.exit(main())
