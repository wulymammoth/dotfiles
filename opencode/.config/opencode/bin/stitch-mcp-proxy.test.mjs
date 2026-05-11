import assert from "node:assert/strict";
import test from "node:test";

import { isMainModule, sanitizeJsonRpcMessage, sanitizeLine } from "./stitch-mcp-proxy.mjs";

test("sanitizes Stitch tool schemas that contain local refs", () => {
  const message = {
    jsonrpc: "2.0",
    id: 2,
    result: {
      tools: [
        {
          name: "generate_variants",
          inputSchema: {
            type: "object",
            $defs: {
              VariantOptions: {
                type: "object",
                properties: {
                  style: { type: "string" },
                },
              },
            },
            properties: {
              variantOptions: { $ref: "#/$defs/VariantOptions" },
            },
          },
          outputSchema: {
            type: "object",
            $defs: {
              ScreenInstance: {
                type: "object",
                properties: {
                  variantScreenInstance: { $ref: "#/$defs/ScreenInstance" },
                },
              },
            },
            properties: {
              screenInstances: {
                type: "array",
                items: { $ref: "#/$defs/ScreenInstance" },
              },
            },
          },
        },
      ],
    },
  };

  const sanitized = sanitizeJsonRpcMessage(message);
  const [tool] = sanitized.result.tools;

  assert.equal(tool.outputSchema, undefined);
  assert.equal(tool.inputSchema.$defs, undefined);
  assert.deepEqual(tool.inputSchema.properties.variantOptions, {
    type: "object",
    additionalProperties: true,
  });
  assert.equal(JSON.stringify(sanitized).includes("$ref"), false);
});

test("leaves non-tool JSON-RPC messages unchanged", () => {
  const message = { jsonrpc: "2.0", id: 1, result: { protocolVersion: "2024-11-05" } };

  assert.deepEqual(sanitizeJsonRpcMessage(message), message);
});

test("passes through non-JSON stdout lines", () => {
  assert.equal(sanitizeLine("not json"), "not json");
});

test("detects main module when executed through a symlink", () => {
  const resolvePath = (filePath) =>
    filePath === "/Users/me/.config/opencode/bin/stitch-mcp-proxy.mjs"
      ? "/Users/me/dotfiles/opencode/.config/opencode/bin/stitch-mcp-proxy.mjs"
      : filePath;

  assert.equal(
    isMainModule(
      "/Users/me/.config/opencode/bin/stitch-mcp-proxy.mjs",
      "file:///Users/me/dotfiles/opencode/.config/opencode/bin/stitch-mcp-proxy.mjs",
      resolvePath,
    ),
    true,
  );
});
