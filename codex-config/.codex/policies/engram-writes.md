# Engram attribution and decision capture

- An enabled Engram MCP can advertise proactive saves, summaries, and project
  context even with shell-plugin hooks disabled. Do not describe it as manual-only
  or instruction-free, or invent a new memory mode, proxy, or wrapper.
- At the first memory write, call `mem_session_start` with the actual runtime
  thread ID and physical startup directory, retain its returned canonical
  project, and pass that explicit project and `session_id` to every `mem_save`
  and `mem_session_summary`. Attribution is not an ownership, isolation, security,
  readiness, or coding-startup boundary. Never manufacture an ID or treat a
  parent's ID as a distinct subagent identity.
- Prefer direct `mem_save(capture_prompt:false)` for established architecture,
  policy, decision, root-cause, or verified-lesson records. Include the source path
  and decision status; distinguish verified outcomes from pending work. Topic-key
  upserts are project-shared, regardless of session identity.
- An unknown or mismatched session/project stops that memory write. Do not retry
  by dropping identifiers or selecting the latest session. Subagents without
  verified identity return candidate durable learnings to their owner. Disclose
  pending capture; memory unavailability does not block unrelated coding unless
  a higher-priority requirement says to stop.

When Engram capture is appropriate, use a stable topic
key and record the authoritative path under `Where`; require existing explicit
decision authority before recording a superseding or conflicting relationship
between architecture, policy, or decision memories.
