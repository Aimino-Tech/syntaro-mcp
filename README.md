# SYNTARO MCP — label a GitHub issue, get a fix PR

Open-source MCP server + agent skills for [SYNTARO](https://syntaro.io):
an AI bot that investigates a labeled GitHub issue, writes a fix with
regression tests, and opens a pull request. Any MCP-capable agent
(OpenCode, Claude Code, Cursor, Codex) can drive it.

- **Hosted endpoint (target, pending deploy):** `https://mcp.syntaro.io/sse` (SSE) and
  `https://mcp.syntaro.io/mcp` (streamable HTTP) — DNS is not live yet, so run
  it yourself below or deploy with [docs/HOSTING.md](docs/HOSTING.md), then update
  `server.json` transports to the live URLs.
- **npm:** `@aimino/syntaro-mcp` (see [docs/PUBLISHING.md](docs/PUBLISHING.md))
- **Skills:** [`skills/`](skills/) — `syntaro` (submit→poll loop) plus
  `cavecrew` / `caveman` / `ponytail` (plan-first + verification-tail
  discipline) and `automation-testing`.
- **License:** AGPL-3.0-only ([LICENSE](LICENSE)).

## 30-second start (local stdio)

```bash
pip install -r requirements.txt
python -m syntaro_mcp.server stdio
```

Or via npm (runs the same Python server under the hood):

```bash
npm install -g @aimino/syntaro-mcp
npx syntaro-mcp stdio
```

Register with your agent — `bash install.sh --opencode` (also `--claude`,
`--cursor`, `--codex`), or point a remote client at the hosted endpoint:

```json
{ "mcpServers": { "syntaro": { "url": "http://localhost:4095/sse" } } }
```

Remote (after deploy): replace the URL with `https://mcp.syntaro.io/sse`.

Full client matrix: [docs/INSTALL.md](docs/INSTALL.md).

## Tools

| Tool | What it does |
|------|--------------|
| `syntaro_label_issue` | Label a GitHub issue (`syntaro:fix` or custom) |
| `syntaro_run_fix` | Trigger the fix pipeline for an issue URL → `run_id` |
| `syntaro_check_status` | Poll a fix run by `run_id` |
| `syntaro_get_pr` | PR URL + details for a completed run |
| `syntaro_list_issues` | Tracked issues with fix status |
| `syntaro_search_codebase` | Symbol/file/pattern search |
| `syntaro_linear_ticket` / `syntaro_linear_create_ticket` | Linear ticket check + create |
| `syntaro_memory_read` / `syntaro_memory_write` | Persistent agent memory files |
| `syntaro_slack_send` | Post to a Slack channel/thread |
| `syntaro_session_resume` | Rehydrate a conversation's `MEMORY.md` |

Resources: `syntaro://runs/{run_id}`, `syntaro://issues/{issue_id}`.

## Configuration

| Variable | Purpose | Default |
|----------|---------|---------|
| `SYNTARO_API_URL` | Syntaro backend for fix runs | `https://api.syntaro.io` |
| `SYNTARO_API_KEY` | Backend auth (remote SSE clients send it as a header) | — |
| `GITHUB_TOKEN` | GitHub auth for labeling | — |
| `LINEAR_API_KEY` | Enables `linear_*` tools | — (tools report "not configured") |
| `SLACK_BOT_TOKEN` | Enables `slack_send` | — |
| `MEMORY_DIR` | `memory_*` storage | `/tmp/symphony-workspaces/memory` |
| `SYNTARO_MCP_PORT` | SSE port | `4095` |
| `MCP_API_KEY` | Optional shared secret for the hosted endpoint | — |

No secrets ship in this repo — everything arrives via env at runtime.

## Hosted mode

```bash
docker build -t syntaro-mcp .
docker run -p 4095:4095 -e SYNTARO_API_KEY=... syntaro-mcp
curl localhost:4095/health   # {"status":"ok","service":"syntaro-mcp"}
```

Cloud Run + custom domain: [docs/HOSTING.md](docs/HOSTING.md).
Marketplace releases (npm, MCP registry, Smithery, Glama): [docs/PUBLISHING.md](docs/PUBLISHING.md).

## Repo layout

```
syntaro_mcp/        Python MCP server (FastMCP): server, handlers, agent_handlers
workers/            Pipeline client (hosted API first, embedded engine fallback)
skills/             Agent skills (syntaro + workflow skills)
.claude-plugin/     Claude marketplace manifest
server.json         MCP registry manifest
smithery.yaml       Smithery deploy config (+ Dockerfile.smithery)
index.js            npm wrapper (spawns the Python server)
deploy/             Cloud Run service + deploy script
docs/               HOSTING / PUBLISHING / INSTALL / Glama listing
```

## Contributing / Security

See [CONTRIBUTING.md](CONTRIBUTING.md) and [SECURITY.md](SECURITY.md).
The commercial platform (webhook server, billing, dashboard) lives in the
private monorepo; this repo is the full open-source distribution surface.
