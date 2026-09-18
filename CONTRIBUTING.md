# Contributing

## What belongs here

- `syntaro_mcp/` server + tools, `workers/` pipeline client
- `skills/` agent skills (markdown-only, repo-agnostic)
- Manifests: `server.json`, `.mcp.json`, `smithery.yaml`,
  `.claude-plugin/marketplace.json`, `skill-registry.json`, `package.json`
- Docs + deploy configs

The commercial platform (webhook server, billing, dashboard) is developed
in the private monorepo and is out of scope here.

## Rules

1. **No secrets in the repo.** Env-only credentials; CI fails on
   `gitleaks`-style patterns (see `ci.yml`).
2. **Version sync.** `package.json` is the source of truth; `server.json`,
   `.mcp.json`, and `smithery.yaml` must carry the same version.
3. **Skills stay AGPL-3.0-only** and must be listed in
   `.claude-plugin/marketplace.json`.
4. **Test before PR:** `pip install -r requirements.txt`,
   `python -m syntaro_mcp.server stdio` (Ctrl-C to exit),
   `python -m syntaro_mcp.server sse --port 4095` + `curl localhost:4095/health`.
5. Small, reviewable PRs with evidence (command output, not claims).

## Releases

Maintainers cut releases with `git tag v1.2.0 && git push origin v1.2.0`.
`publish-npm.yml` publishes `@aimino/syntaro-mcp`; `docker.yml` pushes the
hosted image. Then follow [docs/PUBLISHING.md](docs/PUBLISHING.md) for the
MCP registry, Smithery, and Glama.
