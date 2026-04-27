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
    "anthropic": {
      "options": {
        "apiKey": "{env:ANTHROPIC_API_KEY}"
      }
    }
  }
}
```

Then set in your shell profile or `.env.local` (which is gitignored):

```bash
export ANTHROPIC_API_KEY="your-api-key-here"
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

### Context7 MCP

The `context7` MCP server uses the remote Context7 endpoint for up-to-date library documentation.

Create a free API key at <https://context7.com/dashboard>, then set:

```bash
export CONTEXT7_API_KEY="your-api-key-here"
```

Restart OpenCode, then ask for current docs with prompts like `use context7 for Next.js middleware docs` or `use context7 with /supabase/supabase for auth docs`.

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
