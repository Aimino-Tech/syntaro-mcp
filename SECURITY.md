# Security policy

## Supported versions

Latest `main` and the most recent `v*` release. Older tags are not patched —
upgrade to the newest release.

## Reporting a vulnerability

Email **team@aimino.com** with "[syntaro-mcp security]" in the subject.
Include reproduction steps, impact, and affected version/commit.

We acknowledge receipt within 2 business days and aim to ship a fix within
14 days for confirmed issues. Please do not open public issues for
unpatched vulnerabilities.

## Scope notes

- This repo ships **no credentials**. All tokens/keys arrive via env vars
  at runtime (`GITHUB_TOKEN`, `LINEAR_API_KEY`, `SLACK_BOT_TOKEN`,
  `SYNTARO_API_KEY`, `MCP_API_KEY`).
- The hosted endpoint (`https://mcp.syntaro.io`) authenticates callers with
  `MCP_API_KEY` — FastMCP host-header checks are disabled by design so the
  server works behind proxies (see `docs/HOSTING.md`), so never deploy it
  without a secret.
- Memory tools read/write markdown files under `MEMORY_DIR` — mount an
  isolated volume per tenant when hosting for others.
