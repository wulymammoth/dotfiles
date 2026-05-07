import { strict as assert } from "node:assert"
import { TmuxAlertPlugin } from "../plugins/opencode-tmux-alert.ts"

const calls: string[] = []

const fakeShell = ((strings: TemplateStringsArray, ...values: unknown[]) => {
  calls.push(`${strings[0]}${values.join("")}`)
  return Promise.resolve()
}) as unknown as Parameters<typeof TmuxAlertPlugin>[0]["$"]

async function dispatch(event: unknown) {
  const plugin = await TmuxAlertPlugin({ $: fakeShell } as Parameters<
    typeof TmuxAlertPlugin
  >[0])

  assert(plugin.event, "plugin should expose an event hook")
  await plugin.event({ event } as never)
}

async function createPlugin() {
  const plugin = await TmuxAlertPlugin({ $: fakeShell } as Parameters<
    typeof TmuxAlertPlugin
  >[0])

  assert(plugin.event, "plugin should expose an event hook")
  return plugin
}

async function wait(ms: number) {
  await new Promise((resolve) => setTimeout(resolve, ms))
}

async function recordsAlert(event: unknown) {
  calls.length = 0
  await dispatch(event)
  return calls.some((call) => call.endsWith("alert.sh"))
}

async function recordsClear(event: unknown) {
  calls.length = 0
  await dispatch(event)
  return calls.some((call) => call.endsWith("clear.sh"))
}

process.env.TMUX = "/tmp/tmux-test"
process.env.OPENCODE_ALERT_DELAY_MS = "10"
delete process.env.OPENCODE_ALERT_SCRIPT
delete process.env.OPENCODE_CLEAR_SCRIPT

assert.equal(await recordsAlert({ type: "session.idle" }), false)
assert.equal(await recordsAlert({ type: "permission.asked" }), false)

calls.length = 0
const permissionPlugin = await createPlugin()
await permissionPlugin.event({ event: { type: "permission.asked" } } as never)
await wait(15)
assert.equal(calls.some((call) => call.endsWith("alert.sh")), true)

calls.length = 0
const resolvedPermissionPlugin = await createPlugin()
await resolvedPermissionPlugin.event({
  event: { type: "permission.asked" },
} as never)
await resolvedPermissionPlugin.event({
  event: { type: "permission.updated" },
} as never)
await wait(15)
assert.equal(calls.some((call) => call.endsWith("alert.sh")), false)

calls.length = 0
const continuedWorkPlugin = await createPlugin()
await continuedWorkPlugin.event({ event: { type: "permission.asked" } } as never)
await continuedWorkPlugin.event({
  event: {
    type: "message.part.updated",
    properties: {
      part: { type: "tool", state: { status: "pending" } },
    },
  },
} as never)
await wait(15)
assert.equal(calls.some((call) => call.endsWith("alert.sh")), false)

assert.equal(await recordsAlert({ type: "permission.updated" }), false)
assert.equal(
  await recordsAlert({
    type: "message.part.updated",
    properties: {
      part: { type: "tool", state: { status: "pending" } },
    },
  }),
  false,
)
assert.equal(await recordsAlert({ type: "tui.prompt.append" }), false)
assert.equal(
  await recordsClear({
    type: "message.updated",
    properties: { info: { role: "user" } },
  }),
  true,
)

console.log("opencode-tmux-alert event behavior ok")
