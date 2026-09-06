import hashlib
import json
import os
from pathlib import Path
import selectors
import shutil
import sqlite3
import subprocess
import tempfile
import time
import unittest


EXPECTED_INSTALLED_SHA256 = (
    "cbcb115278c332313d35c1500d261eadfc9ff74d400b021f06b3362b1df2d80a"
)
MAX_PROTOCOL_BUFFER_BYTES = 4 * 1024 * 1024


class MCPClient:
    def __init__(self, executable, cwd, env):
        self.executable = executable
        self.cwd = cwd
        self.env = env
        self.process = None
        self.selector = None
        self.request_id = 1
        self.read_buffer = b""
        self.stderr = ""
        self.initialize_result = None

    def __enter__(self):
        try:
            self.process = subprocess.Popen(
                [str(self.executable), "mcp", "--tools=agent"],
                cwd=str(self.cwd),
                env=self.env,
                stdin=subprocess.PIPE,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                bufsize=0,
            )
            self.selector = selectors.DefaultSelector()
            self.selector.register(self.process.stdout, selectors.EVENT_READ)
            self.initialize_result = self.request(
                "initialize",
                {
                    "protocolVersion": "2025-03-26",
                    "capabilities": {},
                    "clientInfo": {
                        "name": "dotfiles-engram-contract-fixture",
                        "version": "1",
                    },
                },
            )
            self.notify("notifications/initialized")
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
        process = self.process
        if process.stdin is not None:
            try:
                process.stdin.close()
            except OSError:
                pass
        try:
            process.wait(timeout=3)
        except subprocess.TimeoutExpired:
            process.terminate()
            try:
                process.wait(timeout=3)
            except subprocess.TimeoutExpired:
                process.kill()
                process.wait(timeout=3)
        if process.stdout is not None:
            process.stdout.close()
        if process.stderr is not None:
            raw_stderr = process.stderr.read()
            process.stderr.close()
            try:
                self.stderr = raw_stderr.decode("utf-8", errors="strict")
            except UnicodeDecodeError:
                self.stderr = "<non-UTF-8 stderr>"
        self.process = None

    def _send(self, payload):
        encoded = (json.dumps(payload, separators=(",", ":")) + "\n").encode(
            "utf-8"
        )
        self.process.stdin.write(encoded)
        self.process.stdin.flush()

    def notify(self, method, params=None):
        payload = {"jsonrpc": "2.0", "method": method}
        if params is not None:
            payload["params"] = params
        self._send(payload)

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
        deadline = time.monotonic() + 15
        messages_seen = 0
        while time.monotonic() < deadline and messages_seen < 200:
            line = self._read_protocol_line(deadline)
            messages_seen += 1
            try:
                message = json.loads(line.decode("utf-8", errors="strict"))
            except (UnicodeDecodeError, ValueError) as error:
                raise AssertionError("Engram MCP returned malformed protocol") from error
            if not isinstance(message, dict) or message.get("jsonrpc") != "2.0":
                raise AssertionError("Engram MCP returned malformed protocol")
            if message.get("id") != request_id:
                continue
            if "error" in message:
                raise AssertionError("Engram MCP request failed")
            return message.get("result")
        raise AssertionError("Engram MCP response timed out")

    def _read_protocol_line(self, deadline):
        while True:
            newline_index = self.read_buffer.find(b"\n")
            if newline_index >= 0:
                line = self.read_buffer[:newline_index]
                self.read_buffer = self.read_buffer[newline_index + 1 :]
                return line
            if len(self.read_buffer) > MAX_PROTOCOL_BUFFER_BYTES:
                raise AssertionError("Engram MCP protocol exceeded fixture limit")
            remaining = deadline - time.monotonic()
            if remaining <= 0 or not self.selector.select(remaining):
                raise AssertionError("Engram MCP response timed out")
            chunk = os.read(self.process.stdout.fileno(), 65536)
            if not chunk:
                raise AssertionError("Engram MCP closed before responding")
            self.read_buffer += chunk

    def list_tools(self):
        tools = []
        cursor = None
        while True:
            params = {} if cursor is None else {"cursor": cursor}
            result = self.request("tools/list", params)
            tools.extend(result.get("tools", []))
            cursor = result.get("nextCursor")
            if not cursor:
                return tools

    def call_tool(self, name, arguments, expect_error=False):
        result = self.request(
            "tools/call", {"name": name, "arguments": arguments}
        )
        self.assert_tool_result_shape(result)
        if bool(result.get("isError")) != expect_error:
            raise AssertionError(
                "unexpected Engram MCP tool status for " + name
            )
        text_items = [item for item in result["content"] if item.get("type") == "text"]
        if len(text_items) != 1:
            raise AssertionError("Engram MCP tool result must contain one text item")
        try:
            envelope = json.loads(text_items[0]["text"])
        except (KeyError, TypeError, ValueError) as error:
            raise AssertionError("Engram MCP tool result lacks JSON envelope") from error
        if not isinstance(envelope, dict):
            raise AssertionError("Engram MCP tool envelope is malformed")
        return envelope

    @staticmethod
    def assert_tool_result_shape(result):
        if not isinstance(result, dict) or not isinstance(result.get("content"), list):
            raise AssertionError("Engram MCP tool result is malformed")


class InstalledEngramMemoryContractTests(unittest.TestCase):
    maxDiff = None

    def setUp(self):
        executable = shutil.which("engram")
        if executable is None:
            self.fail("the installed Engram executable is required")
        self.executable = Path(executable)
        self.resolved_executable = self.executable.resolve(strict=True)
        actual_hash = hashlib.sha256(self.resolved_executable.read_bytes()).hexdigest()
        self.assertEqual(EXPECTED_INSTALLED_SHA256, actual_hash)

        self.temp_dir = tempfile.TemporaryDirectory(prefix="engram-mcp-contract-")
        self.root = Path(self.temp_dir.name).resolve()
        self.home = self.root / "home"
        self.data_dir = self.root / "engram-data"
        directories = (
            self.home,
            self.data_dir,
            self.root / "xdg-config",
            self.root / "xdg-cache",
            self.root / "xdg-data",
            self.root / "xdg-state",
            self.root / "tmp",
        )
        for directory in directories:
            directory.mkdir()

        self.database = self.data_dir / "engram.db"
        connection = sqlite3.connect(str(self.database))
        connection.execute("VACUUM")
        connection.close()
        self.assertEqual(b"SQLite format 3\x00", self.database.read_bytes()[:16])

        self.env = {
            "HOME": str(self.home),
            "XDG_CONFIG_HOME": str(self.root / "xdg-config"),
            "XDG_CACHE_HOME": str(self.root / "xdg-cache"),
            "XDG_DATA_HOME": str(self.root / "xdg-data"),
            "XDG_STATE_HOME": str(self.root / "xdg-state"),
            "TMPDIR": str(self.root / "tmp"),
            "PATH": "/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin",
            "LANG": os.environ.get("LANG", "C.UTF-8"),
            "COMMAND_MODE": os.environ.get("COMMAND_MODE", "unix2003"),
            "USER": "fixture-user",
            "LOGNAME": "fixture-user",
            "ENGRAM_DATA_DIR": str(self.data_dir),
            "ENGRAM_CLOUD_AUTOSYNC": "0",
            "ENGRAM_CLOUD_SYNC": "0",
        }
        self.assertEqual(
            {
                "HOME",
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
                "ENGRAM_DATA_DIR",
                "ENGRAM_CLOUD_AUTOSYNC",
                "ENGRAM_CLOUD_SYNC",
            },
            set(self.env),
        )
        for key in self.env:
            self.assertNotRegex(key.upper(), r"TOKEN|SECRET|PASSWORD|CREDENTIAL|PROXY")

        self.repo_a = self._create_repo(
            "repo-a", "https://example.invalid/fixture-org/engram-adr-contract.git"
        )
        self.repo_b = self._create_repo(
            "repo-b", "https://example.invalid/fixture-org/engram-adr-contract.git"
        )
        self.other_repo = self._create_repo(
            "repo-other", "https://example.invalid/fixture-org/other-contract.git"
        )

    def tearDown(self):
        self.temp_dir.cleanup()

    def _create_repo(self, name, remote):
        repository = self.root / name
        repository.mkdir()
        subprocess.run(
            ["/usr/bin/git", "init", "--quiet"],
            cwd=str(repository),
            env=self.env,
            check=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )
        subprocess.run(
            ["/usr/bin/git", "remote", "add", "origin", remote],
            cwd=str(repository),
            env=self.env,
            check=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )
        return repository

    def test_agent_profile_proves_explicit_shared_project_attribution(self):
        session_a = "fixture-thread-a-6d35"
        session_b = "fixture-thread-b-1f82"
        other_session = "fixture-thread-other-0c47"
        shared_token = "adrcontracttoken9f31"
        content_a = (
            "**What**: Chose fixture boundary A.\n"
            "**Why**: Verify explicit attribution.\n"
            "**Where**: docs/adr/fixture-a.md\n"
            "**Learned**: " + shared_token
        )
        content_b = (
            "**What**: Chose fixture boundary B.\n"
            "**Why**: Verify shared ADR recall.\n"
            "**Where**: docs/adr/fixture-b.md\n"
            "**Learned**: " + shared_token
        )

        client_a = MCPClient(self.executable, self.repo_a, self.env)
        client_b = MCPClient(self.executable, self.repo_b, self.env)
        with client_a, client_b:
            instructions = client_a.initialize_result.get("instructions", "")
            self.assertIn("PROACTIVE SAVE RULE", instructions)
            self.assertIn("mem_session_summary", instructions)

            tools = client_a.list_tools()
            by_name = {tool["name"]: tool for tool in tools}
            required = {
                "mem_session_start",
                "mem_save",
                "mem_session_summary",
                "mem_search",
                "mem_get_observation",
            }
            self.assertTrue(required.issubset(by_name))
            self.assertTrue(
                {"mem_delete", "mem_stats", "mem_timeline", "mem_merge_projects"}.isdisjoint(
                    by_name
                )
            )
            self.assertIn("id", by_name["mem_session_start"]["inputSchema"]["required"])
            self.assertIn("title", by_name["mem_save"]["inputSchema"]["required"])
            self.assertIn("content", by_name["mem_save"]["inputSchema"]["properties"])
            self.assertIn(
                "content", by_name["mem_session_summary"]["inputSchema"]["required"]
            )
            self.assertIn("query", by_name["mem_search"]["inputSchema"]["required"])
            self.assertIn(
                "id", by_name["mem_get_observation"]["inputSchema"]["required"]
            )
            self.assertFalse(by_name["mem_save"]["annotations"]["readOnlyHint"])
            self.assertFalse(
                by_name["mem_session_summary"]["annotations"]["readOnlyHint"]
            )

            start_a = client_a.call_tool(
                "mem_session_start", {"id": session_a, "directory": str(self.repo_a)}
            )
            start_b = client_b.call_tool(
                "mem_session_start", {"id": session_b, "directory": str(self.repo_b)}
            )
            project = start_a["project"]
            self.assertTrue(project)
            self.assertEqual(project, start_b["project"])

            start_other = client_a.call_tool(
                "mem_session_start",
                {"id": other_session, "directory": str(self.other_repo)},
            )
            other_project = start_other["project"]
            self.assertTrue(other_project)
            self.assertNotEqual(project, other_project)

            saved_b = client_b.call_tool(
                "mem_save",
                {
                    "title": "Recorded fixture ADR B",
                    "content": content_b,
                    "type": "architecture",
                    "scope": "project",
                    "topic_key": "architecture/fixture-b",
                    "project": project,
                    "session_id": session_b,
                    "capture_prompt": False,
                },
            )
            self.assertEqual(project, saved_b["project"])
            self.assertIsInstance(saved_b["id"], int)

            unknown = client_a.call_tool(
                "mem_save",
                {
                    "title": "Must not save unknown session",
                    "content": "fixture negative control",
                    "type": "decision",
                    "project": project,
                    "session_id": "fixture-session-does-not-exist",
                    "capture_prompt": False,
                },
                expect_error=True,
            )
            self.assertEqual("unknown_session", unknown["error_code"])

            mismatch = client_a.call_tool(
                "mem_save",
                {
                    "title": "Must not save mismatched project",
                    "content": "fixture negative control",
                    "type": "decision",
                    "project": other_project,
                    "session_id": session_a,
                    "capture_prompt": False,
                },
                expect_error=True,
            )
            self.assertEqual("session_project_mismatch", mismatch["error_code"])

            saved_a = client_a.call_tool(
                "mem_save",
                {
                    "title": "Recorded fixture ADR A",
                    "content": content_a,
                    "type": "decision",
                    "scope": "project",
                    "topic_key": "decision/fixture-a",
                    "project": project,
                    "session_id": session_a,
                    "capture_prompt": False,
                },
            )
            self.assertEqual(project, saved_a["project"])
            self.assertIsInstance(saved_a["id"], int)

            for client, saved, session_id, content in (
                (client_a, saved_a, session_a, content_a),
                (client_b, saved_b, session_b, content_b),
            ):
                loaded = client.call_tool(
                    "mem_get_observation", {"id": saved["id"]}
                )
                self.assertIn(content, loaded["result"])
                self.assertIn("Session: " + session_id, loaded["result"])
                self.assertIn("Project: " + project, loaded["result"])

            search = client_b.call_tool(
                "mem_search", {"query": shared_token, "project": project, "limit": 10}
            )
            search_ids = {entry["id"] for entry in search["results"]}
            self.assertTrue({saved_a["id"], saved_b["id"]}.issubset(search_ids))
            self.assertEqual(project, search["project"])
            self.assertTrue(
                all(entry.get("project") == project for entry in search["results"])
            )

            summary_a = client_a.call_tool(
                "mem_session_summary",
                {
                    "content": self._summary("A"),
                    "project": project,
                    "session_id": session_a,
                },
            )
            summary_b = client_b.call_tool(
                "mem_session_summary",
                {
                    "content": self._summary("B"),
                    "project": project,
                    "session_id": session_b,
                },
            )
            self.assertEqual(project, summary_a["project"])
            self.assertEqual(project, summary_b["project"])

        self.assertEqual("", client_a.stderr)
        self.assertEqual("", client_b.stderr)
        self._assert_persisted_attribution(
            project, session_a, session_b, content_a, content_b
        )

    @staticmethod
    def _summary(label):
        return (
            "## Goal\nFixture "
            + label
            + " attribution\n\n## Discoveries\n- Explicit binding verified"
            "\n\n## Accomplished\n- Saved fixture ADR"
            "\n\n## Next Steps\n- Remove temporary fixture"
            "\n\n## Relevant Files\n- docs/adr/fixture.md"
        )

    def _assert_persisted_attribution(
        self, project, session_a, session_b, content_a, content_b
    ):
        connection = sqlite3.connect(str(self.database))
        try:
            sessions = connection.execute(
                "SELECT id, project, directory FROM sessions ORDER BY id"
            ).fetchall()
            observations = connection.execute(
                "SELECT session_id, type, content, project, topic_key "
                "FROM observations ORDER BY id"
            ).fetchall()
            prompt_count = connection.execute(
                "SELECT COUNT(*) FROM user_prompts"
            ).fetchone()[0]
        finally:
            connection.close()

        sessions_by_id = {row[0]: row[1:] for row in sessions}
        self.assertEqual(project, sessions_by_id[session_a][0])
        self.assertEqual(project, sessions_by_id[session_b][0])
        self.assertTrue(Path(sessions_by_id[session_a][1]).is_relative_to(self.root))
        self.assertTrue(Path(sessions_by_id[session_b][1]).is_relative_to(self.root))

        adr_rows = [row for row in observations if row[1] != "session_summary"]
        self.assertEqual(
            {
                (session_a, "decision", content_a, project, "decision/fixture-a"),
                (
                    session_b,
                    "architecture",
                    content_b,
                    project,
                    "architecture/fixture-b",
                ),
            },
            set(adr_rows),
        )
        summary_sessions = {
            row[0] for row in observations if row[1] == "session_summary"
        }
        self.assertEqual({session_a, session_b}, summary_sessions)
        self.assertEqual(0, prompt_count)
        production_home = str(Path.home() / ".engram")
        self.assertNotIn(production_home, json.dumps(sessions + observations))


if __name__ == "__main__":
    unittest.main()
