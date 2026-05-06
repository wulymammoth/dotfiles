import type { Plugin } from "@opencode-ai/plugin"
import { resolve, dirname } from "path"
import { fileURLToPath } from "url"

/**
 * Frozen local fork of seanhalberthal/opencode-tmux-alert.
 * Upstream commit: eb1a6fabd5fe495f4d7121133fbcfde05ca8792a
 *
 * Local OpenCode plugins are auto-loaded from ~/.config/opencode/plugins,
 * so the only functional change from upstream is the scripts directory path.
 */
export const TmuxAlertPlugin: Plugin = async ({ $ }) => {
  const pluginDir = dirname(fileURLToPath(import.meta.url))
  const scriptsDir = resolve(pluginDir, "opencode-tmux-alert")

  const alertScript =
    process.env.OPENCODE_ALERT_SCRIPT ?? resolve(scriptsDir, "alert.sh")
  const clearScript =
    process.env.OPENCODE_CLEAR_SCRIPT ?? resolve(scriptsDir, "clear.sh")

  if (!process.env.TMUX) {
    console.error(
      "[opencode-tmux-alert] Not running inside tmux — plugin disabled",
    )
    return {}
  }

  const alert = async () => {
    await $`${alertScript}`
  }

  const clear = async () => {
    await $`${clearScript}`
  }

  return {
    event: async ({ event }) => {
      try {
        // Notify only for explicit user-blocking prompts. Generic idle events
        // can fire between subagent/task phases while the main run continues.
        if (event.type === "permission.asked") {
          await alert()
        }

        if (
          event.type === "message.updated" &&
          event.properties.info.role === "user"
        ) {
          await clear()
        }
      } catch (error) {
        console.error("[opencode-tmux-alert] Error:", error)
      }
    },
  }
}
