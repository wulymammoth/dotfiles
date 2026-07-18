#!/usr/bin/env node
import { spawn } from "node:child_process";
import { realpathSync } from "node:fs";
import { fileURLToPath } from "node:url";

const REF_PLACEHOLDER = { type: "object", additionalProperties: true };
const FALLBACK_PATH = "/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin";
const STITCH_MCP_PACKAGE = "@_davideast/stitch-mcp@0.8.0";

export function buildChildEnv(env = process.env) {
  return {
    ...env,
    PATH: env.PATH || FALLBACK_PATH,
  };
}

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

export function sanitizeStdoutBuffer(buffer) {
  let remaining = buffer;
  let output = "";

  while (remaining.length > 0) {
    if (remaining.startsWith("Content-Length:")) {
      const headerEnd = remaining.indexOf("\r\n\r\n");
      if (headerEnd === -1) {
        break;
      }

      const header = remaining.slice(0, headerEnd);
      const contentLengthMatch = /^Content-Length:\s*(\d+)/im.exec(header);
      if (!contentLengthMatch) {
        break;
      }

      const bodyStart = headerEnd + 4;
      const bodyLength = Number(contentLengthMatch[1]);
      const bodyEnd = bodyStart + bodyLength;
      if (remaining.length < bodyEnd) {
        break;
      }

      const body = remaining.slice(bodyStart, bodyEnd);
      const sanitizedBody = sanitizeLine(body);
      output += `Content-Length: ${Buffer.byteLength(sanitizedBody)}\r\n\r\n${sanitizedBody}`;
      remaining = remaining.slice(bodyEnd);
      continue;
    }

    const newlineIndex = remaining.indexOf("\n");
    if (newlineIndex === -1) {
      break;
    }

    const line = remaining.slice(0, newlineIndex);
    output += `${sanitizeLine(line)}\n`;
    remaining = remaining.slice(newlineIndex + 1);
  }

  return { output, remaining };
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
  const child = spawn("npx", ["-y", STITCH_MCP_PACKAGE, "proxy"], {
    env: buildChildEnv(process.env),
    stdio: ["pipe", "pipe", "pipe"],
  });

  let stdoutBuffer = "";

  process.stdin.pipe(child.stdin);
  child.stderr.pipe(process.stderr);

  child.stdout.on("data", (chunk) => {
    stdoutBuffer += chunk.toString("utf8");
    const sanitized = sanitizeStdoutBuffer(stdoutBuffer);
    stdoutBuffer = sanitized.remaining;
    process.stdout.write(sanitized.output);
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

  child.on("error", (error) => {
    process.stderr.write(`[stitch-mcp-proxy] Failed to start Stitch MCP child process: ${error.message}\n`);
    process.exit(1);
  });

  for (const signal of ["SIGINT", "SIGTERM"]) {
    process.on(signal, () => child.kill(signal));
  }
}

if (isMainModule(process.argv[1], import.meta.url)) {
  main();
}
