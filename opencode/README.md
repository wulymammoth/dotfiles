# OpenCode Configuration

This directory contains OpenCode configuration managed via GNU Stow.

## Structure

```
opencode/.config/opencode/
├── opencode.json      # Main config (safe to commit)
├── tui.json           # TUI settings (safe to commit)
├── .gitignore         # Ignores sensitive files
├── agents/            # Custom agent definitions
├── commands/          # Custom commands
├── themes/            # Custom themes
├── plugins/           # Custom plugins
└── skills/            # Custom skills
```

## Setup

From your dotfiles directory:

```bash
stow opencode
```

This symlinks the config to `~/.config/opencode/`.

## Configuration Strategy

### ✅ Safe to commit (version-controlled)
- Model preferences
- Theme settings
- Keybindings
- Tool permissions
- Formatter configurations
- Custom commands and agents (without secrets)
- General preferences

### ❌ Keep private (not committed)
- API keys
- MCP server credentials
- Sensitive file paths
- Private instruction files

### Using Environment Variables

Reference secrets via environment variables in your configs:

```json
{
  "provider": {
    "openai": {
      "options": {
        "apiKey": "{env:OPENAI_API_KEY}"
      }
    }
  }
}
```

Then set in your shell profile or `.env.local` (which is gitignored):

```bash
export OPENAI_API_KEY="your-api-key-here"
```

### Google Search Console MCP

The `gsc` MCP server uses [`mcp-search-console`](https://github.com/AminForou/mcp-gsc) through `uvx`.

For OAuth, set an absolute path to the Google OAuth desktop client JSON:

```bash
export GSC_OAUTH_CLIENT_SECRETS_FILE="/Users/you/path/to/client_secrets.json"
```

For a service account, set both variables:

```bash
export GSC_CREDENTIALS_PATH="/Users/you/path/to/service_account.json"
export GSC_SKIP_OAUTH="true"
```

After updating credentials, restart OpenCode and ask it to `call get_capabilities using gsc` or `list my GSC properties using gsc`.

### Supabase MCP

The `supabase` MCP server is a remote MCP endpoint. Keep the project URL and access token in the shell environment that launches OpenCode:

```bash
export SUPABASE_MCP_URL="https://mcp.supabase.com/mcp?project_ref=your-project-ref&features=storage%2Cbranching%2Cfunctions%2Cdevelopment%2Cdebugging%2Cdatabase%2Cdocs"
export SUPABASE_ACCESS_TOKEN="your-supabase-access-token"
```

The committed config sends `SUPABASE_ACCESS_TOKEN` as the `Authorization` bearer token. If `opencode mcp list` reports `Invalid MCP URL for "supabase"`, `SUPABASE_MCP_URL` is missing or empty. If it reports `needs authentication`, check `SUPABASE_ACCESS_TOKEN`.

### Context7 MCP

The `context7` MCP server uses the remote Context7 endpoint for up-to-date library documentation.

Create a free API key at <https://context7.com/dashboard>, then set:

```bash
export CONTEXT7_API_KEY="your-api-key-here"
```

Restart OpenCode, then ask for current docs with prompts like `use context7 for Next.js middleware docs` or `use context7 with /supabase/supabase for auth docs`.

### Stitch MCP

The `stitch` MCP server follows the Stitch MCP setup docs by running the local [`@_davideast/stitch-mcp`](https://www.npmjs.com/package/@_davideast/stitch-mcp) stdio proxy.

Set your Stitch API key in the shell that launches OpenCode:

```bash
export STITCH_API_KEY="your-api-key-here"
```

Then restart OpenCode and verify with:

```bash
opencode mcp list
```

If the server fails, run:

```bash
npx -y @_davideast/stitch-mcp doctor --verbose
```

### Using File References

Reference secrets from private files:

```json
{
  "provider": {
    "openai": {
      "options": {
        "apiKey": "{file:~/.secrets/openai-key}"
      }
    }
  }
}
```

## Sensitive Files

The `.gitignore` in this directory prevents committing:
- `.env.local` and `.env` files
- Key files (`.key`, `.pem`, `.p12`)
- Backup files
- Local configurations (`local.json`)

## Extending

Add custom configurations to:
- `agents/` - Custom agent markdown files
- `commands/` - Custom command definitions
- `themes/` - Custom theme files
- `plugins/` - Custom plugins
- `skills/` - Custom skills

See [OpenCode documentation](https://opencode.ai/docs/config) for details.
