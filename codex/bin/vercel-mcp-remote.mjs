#!/usr/bin/env node
import { existsSync, realpathSync } from "node:fs";
import { createRequire } from "node:module";
import path from "node:path";
import { pathToFileURL } from "node:url";

function resolveFromPath(command) {
  const pathEntries = (process.env.PATH || "").split(path.delimiter).filter(Boolean);

  for (const entry of pathEntries) {
    const candidate = path.join(entry, command);
    if (existsSync(candidate)) {
      return realpathSync(candidate);
    }
  }

  throw new Error(`Unable to find ${command} on PATH`);
}

const proxyPath = resolveFromPath("mcp-remote");
const packageRoot = path.dirname(path.dirname(proxyPath));
const requireFromPackage = createRequire(path.join(packageRoot, "package.json"));
const undiciPath = requireFromPackage.resolve("undici");
const undici = await import(pathToFileURL(undiciPath).href);

// mcp-remote's bundle changes Node 26 global fetch behavior before OAuth
// discovery, causing Vercel JSON metadata to be parsed while still compressed.
// Its bundled undici fetch handles the same responses correctly.
globalThis.fetch = undici.fetch;
globalThis.Headers = undici.Headers;
globalThis.Request = undici.Request;
globalThis.Response = undici.Response;

process.argv = [process.argv[0], proxyPath, ...process.argv.slice(2)];
await import(pathToFileURL(proxyPath).href);
