# Memory retrieval checks

Use this bounded check after memory maintenance or when recall appears stale.
Do not infer effectiveness from corpus size, a running PID, or a green doctor
result. Current source and accepted decisions remain authoritative.

## ctx

1. Read status once. Record the installed version, daemon owner, generation,
   and any pending refresh. Follow the user's monitoring policy for running work.
   `ctx index wait --lexical` can report an already usable snapshot as ready
   while `readiness.refresh.request_state` is still running. Inspect refresh
   completion and verify new transcript evidence separately.
2. Through `query_events`, request the latest three assistant events with a
   bounded `since`/`until` range, `direction: descending`, and `content: none`.
   Also filter `source_format: codex_session_jsonl` when checking Codex. Compare
   those dates with actual source-session files. Recent `codex_history_jsonl`
   prompts do not establish full transcript freshness.
3. Choose three real tasks with known source sessions: a recent completed task,
   a regression/root cause, and an older decision. Search each with a concrete
   identifier, canonical workspace, `since` bound, and limit of 3–5. The MCP
   search tool has no `until` argument; use event timestamps or `query_events`
   for an upper bound. Include the relevant worktree scope when needed.
4. Open the candidate event. Require the expected literal task identifier,
   relevant decision/outcome, correct provider session, and original event
   timestamp. Tokenized numeric matches, pasted history, and this audit's own
   copies do not pass. Record misses as coverage or relevance failures.

Session search can rank the correct session while showing environment text as
its representative snippet. Narrow to that session and search the behavior or
outcome, then open the original event. Record noisy identifier matches rather
than treating them as proof; the October check needed `Forward` after
`USER_REACHED_END` returned irrelevant material.

The October 30 baseline uses LEA-473 (CI evidence reuse), LEA-470 (Current Vibe
Forward behavior), and the older ctx supervision decision. Source sessions must
predate this maintenance; the first two were missing from scoped recent search
before the upgrade. Do not turn search-result counts into an accuracy score.

## Engram

1. Resolve the canonical project and search a known durable decision. Open its
   observation and compare it with its authoritative source and recorded status.
2. Check capture freshness separately from diagnostics. A project can pass
   doctor while receiving no new observations. Read-only aggregate timestamps
   from the local store are suitable maintenance evidence; include both created
   and updated timestamps because topic-key revisions retain their original
   creation date. Preserve private data.
3. If this work establishes a verified durable lesson, register the actual
   runtime thread and physical startup directory, then save with the returned
   canonical project, explicit session ID, stable topic key, and
   `capture_prompt:false`. Do not create dummy production memories as fixtures.
4. Read back the saved observation ID. Verify its project, attribution, source,
   and outcome, then use one targeted search to prove discoverability.

Engram 3.6.0's search reminder is an in-memory activity heuristic, not a database
freshness check. Searches use a default session while attributed saves use the
runtime thread; after the project freshness window expires, the reminder can
measure from the search session's start and overstate the time since a save.
Verify persistence by observation ID and updated timestamp instead of adding
unnecessary memories to silence it. Sources:
[activity tracking](https://github.com/Gentleman-Programming/engram/blob/v3.6.0/internal/mcp/activity.go)
and [MCP handlers](https://github.com/Gentleman-Programming/engram/blob/v3.6.0/internal/mcp/mcp.go).

Record the source IDs, observed results, and remaining gaps in task-local notes.
Successful writes prove the capture path; future agent adherence to selective
capture requires observation in subsequent substantive sessions.
