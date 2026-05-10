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
  const alertDelay = Number(process.env.OPENCODE_ALERT_DELAY_MS ?? 1500)
  let alertTimer: ReturnType<typeof setTimeout> | undefined

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
    if (alertTimer) {
      clearTimeout(alertTimer)
      alertTimer = undefined
    }
    await $`${clearScript}`
  }

  const scheduleAlert = () => {
    if (alertTimer) {
      clearTimeout(alertTimer)
    }

    alertTimer = setTimeout(async () => {
      alertTimer = undefined
      await alert()
    }, alertDelay)
  }

  const isPendingQuestion = (event: unknown) => {
    if (!event || typeof event !== "object" || !("type" in event)) {
      return false
    }

    if (event.type !== "message.part.updated") {
      return false
    }

    const part = (event as { properties?: { part?: unknown } }).properties?.part
    if (!part || typeof part !== "object") {
      return false
    }

    return (
      (part as { type?: string }).type === "tool" &&
      (part as { tool?: string }).tool === "question" &&
      (part as { state?: { status?: string } }).state?.status === "pending"
    )
  }

  return {
    event: async ({ event }) => {
      try {
        // Notify only if OpenCode is blocked waiting for user input. Generic
        // idle events can fire between subagent/task phases while the main run
        // continues. Permission and question events are the canonical
        // user-blocking states; the message-part check keeps the older
        // question tool fallback working if the bus event is missed.
        if (
          event.type === "permission.asked" ||
          event.type === "question.asked" ||
          isPendingQuestion(event)
        ) {
          scheduleAlert()
        }

        if (
          event.type === "permission.updated" ||
          event.type === "permission.replied" ||
          event.type === "question.replied" ||
          event.type === "question.rejected"
        ) {
          await clear()
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
