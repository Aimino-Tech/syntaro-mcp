# PUBLISHING — ship a release to every marketplace

`package.json` is the version source of truth (currently `1.1.0`).
`server.json`, `.mcp.json`, and `smithery.yaml` must carry the same version —
`ci.yml` fails the build on drift.

## 1. Cut the release

```bash
# bump versions in package.json + server.json + .mcp.json + smithery.yaml (same number)
git tag v1.2.0 && git push origin v1.2.0
```

Tagging fires `publish-npm.yml` (needs the `NPM_TOKEN` repo secret once)
and `docker.yml` (publishes `ghcr.io/aimino-tech/syntaro-mcp:<tag>`).

Verify: `npm view @aimino/syntaro-mcp version`.

## 2. MCP registry (registry.modelcontextprotocol.io)

One-time setup, then per release:

```bash
mcp-publisher login github          # GitHub OIDC, no long-lived keys
mcp-publisher publish               # reads server.json
```

`server.json` is the manifest: name `@aimino/syntaro-mcp`, transport
entries for stdio + hosted SSE/HTTP, env schema, deployment block.

## 3. Smithery (smithery.ai)

```bash
npx -y @smithery/cli login
npx -y @smithery/cli deploy   # reads smithery.yaml + Dockerfile.smithery
```

Or connect the GitHub repo in the Smithery dashboard for auto-deploy on tags.
Verify: `https://smithery.ai/server/@aimino/syntaro-mcp`.

## 4. Glama (glama.ai) — manual web submit, ~1–3 days review

1. Go to <https://glama.ai/mcp/servers> → "Add Server".
2. Enter exactly:

   | Field | Value |
   |-------|-------|
   | Name | `@aimino/syntaro-mcp` |
   | Description | SYNTARO — label a GitHub issue and get an automated fix PR. Open-source AI bot backed by OpenCode. |
   | Homepage | <https://github.com/Aimino-Tech/syntaro-mcp> |
   | License | AGPL-3.0 |
   | Categories | Developer Tools, Code Quality, Automation |

3. Transport — stdio:

   ```json
   { "mcpServers": { "syntaro": {
     "command": "npx", "args": ["-y", "@aimino/syntaro-mcp", "stdio"] } } }
   ```

   and/or remote SSE: `{ "mcpServers": { "syntaro": { "url": "https://mcp.syntaro.io/sse" } } }`.
4. Submit, wait for approval, then verify by searching "syntaro".

Full walkthrough with tool table: [glama-listing.md](glama-listing.md).

## 5. Skills (Claude marketplace + OpenCode)

- `.claude-plugin/marketplace.json` lists every `skills/*/SKILL.md` —
  add new skills there or they don't ship.
- `skill-registry.json` carries the `installUrl` (raw GitHub URL in this
  repo). Keep `license: AGPL-3.0-only` on all frontmatter.
- No publish step: marketplaces pull from `main` via these manifests.

## Post-publish checklist

- [ ] `npm view` shows the new version
- [ ] MCP registry page resolves `@aimino/syntaro-mcp`
- [ ] Smithery page shows the new version + deploy green
- [ ] Glama listing approved (or submitted, with date logged)
- [ ] `server.json` hosted URLs answer: `curl https://mcp.syntaro.io/health`
