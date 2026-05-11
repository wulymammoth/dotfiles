#!/usr/bin/env node
import { spawn } from "node:child_process";
import { realpathSync } from "node:fs";
import { fileURLToPath } from "node:url";

const REF_PLACEHOLDER = { type: "object", additionalProperties: true };

export function sanitizeSchema(value) {
  if (Array.isArray(value)) {
    return value.map(sanitizeSchema);
  }

  if (!value || typeof value !== "object") {
    return value;
  }

  if (typeof value.$ref === "string") {
    return { ...REF_PLACEHOLDER };
  }

  const sanitized = {};
  for (const [key, child] of Object.entries(value)) {
    if (key === "$defs" || key === "definitions") {
      continue;
    }
    sanitized[key] = sanitizeSchema(child);
  }
  return sanitized;
}

export function sanitizeJsonRpcMessage(message) {
  if (!message?.result?.tools || !Array.isArray(message.result.tools)) {
    return message;
  }

  return {
    ...message,
    result: {
      ...message.result,
      tools: message.result.tools.map((tool) => {
        const sanitized = {
          ...tool,
          inputSchema: sanitizeSchema(tool.inputSchema),
        };
        delete sanitized.outputSchema;
        return sanitized;
      }),
    },
  };
}

export function sanitizeLine(line) {
  try {
    return JSON.stringify(sanitizeJsonRpcMessage(JSON.parse(line)));
  } catch {
    return line;
  }
}

export function isMainModule(argvPath, moduleUrl, resolvePath = realpathSync) {
  if (!argvPath) {
    return false;
  }

  try {
    return resolvePath(argvPath) === fileURLToPath(moduleUrl);
  } catch {
    return false;
  }
}

function main() {
  const child = spawn("npx", ["-y", "@_davideast/stitch-mcp", "proxy"], {
    env: process.env,
    stdio: ["pipe", "pipe", "pipe"],
  });

  let stdoutBuffer = "";

  process.stdin.pipe(child.stdin);
  child.stderr.pipe(process.stderr);

  child.stdout.on("data", (chunk) => {
    stdoutBuffer += chunk.toString("utf8");

    let newlineIndex;
    while ((newlineIndex = stdoutBuffer.indexOf("\n")) !== -1) {
      const line = stdoutBuffer.slice(0, newlineIndex);
      stdoutBuffer = stdoutBuffer.slice(newlineIndex + 1);
      process.stdout.write(`${sanitizeLine(line)}\n`);
    }
  });

  child.on("exit", (code, signal) => {
    if (stdoutBuffer.length > 0) {
      process.stdout.write(sanitizeLine(stdoutBuffer));
    }
    if (signal) {
      process.kill(process.pid, signal);
    }
    process.exit(code ?? 0);
  });

  for (const signal of ["SIGINT", "SIGTERM"]) {
    process.on(signal, () => child.kill(signal));
  }
}

if (isMainModule(process.argv[1], import.meta.url)) {
  main();
}
