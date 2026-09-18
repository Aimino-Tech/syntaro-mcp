# INSTALL — connect an agent to SYNTARO

## Fastest: hosted endpoint (no install, after DNS is live)

`https://mcp.syntaro.io` DNS is not live yet — until then use the local
installs below. Once deployed ([docs/HOSTING.md](HOSTING.md)):

```json
{ "mcpServers": { "syntaro": { "url": "https://mcp.syntaro.io/sse" } } }
```

If the operator set `MCP_API_KEY`, add
`"headers": { "Authorization": "Bearer <key>" }`.

## Local: npm wrapper

```bash
npm install -g @aimino/syntaro-mcp
```

### OpenCode (`opencode.json`)

```json
{ "mcpServers": { "syntaro": {
  "command": "npx", "args": ["-y", "@aimino/syntaro-mcp", "stdio"] } } }
```

Or from a checkout: `bash install.sh --opencode`.

### Claude Code / Claude Desktop

```bash
bash install.sh --claude
```

### Cursor

Settings → Features → MCP Servers → add command
`python3 -m syntaro_mcp.server stdio` (or `bash install.sh --cursor`).

### Codex CLI (`.codex/config.json`)

```json
{ "mcpServers": { "syntaro": {
  "command": "python3", "args": ["-m", "syntaro_mcp.server", "stdio"] } } }
```

## Local: Python directly

```bash
pip install -r requirements.txt
python -m syntaro_mcp.server stdio          # local agents
python -m syntaro_mcp.server sse --port 4095  # remote agents (SSE + /health)
```

## Skills

Agents that support skills get the submit→poll loop plus plan/verify
discipline for free:

| Skill | Use |
|-------|-----|
| `skills/syntaro/SKILL.md` | Submit issue → poll run → read PR |
| `skills/cavecrew/SKILL.md` | Plan-first discipline before any fix code |
| `skills/ponytail/SKILL.md` | Deterministic verification tail (tests/lint/build) |
| `skills/caveman/SKILL.md` | Terse final gate before the PR |
| `skills/automation-testing/SKILL.md` | PyTest + Playwright patterns |

## Env

`SYNTARO_API_URL` (default `https://api.syntaro.io`), `SYNTARO_API_KEY`,
`GITHUB_TOKEN`, `LINEAR_API_KEY`, `SLACK_BOT_TOKEN`, `MEMORY_DIR`.
Missing optional keys don't crash — the dependent tools answer
"not configured".
