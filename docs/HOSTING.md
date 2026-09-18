# HOSTING — run `mcp.syntaro.io` yourself or deploy it

The server speaks SSE and streamable HTTP on one port, with `GET /health`
for probes. Any host that can run the Docker image works; the reference
target is **Cloud Run** (scale-to-zero, regional EU) behind the custom
domain `mcp.syntaro.io`.

## Option A — Docker (any VM)

```bash
docker build -t syntaro-mcp .
docker run -d --name syntaro-mcp -p 4095:4095 \
  -e SYNTARO_API_URL=https://api.syntaro.io \
  -e SYNTARO_API_KEY="$SYNTARO_API_KEY" \
  -e GITHUB_TOKEN="$GITHUB_TOKEN" \
  -e MCP_API_KEY="$MCP_API_KEY" \
  syntaro-mcp
curl localhost:4095/health
```

## Option B — Cloud Run (reference)

Prerequisites: a GCP project with billing, Artifact Registry, and a verified
domain in Cloud DNS / your registrar.

```bash
export PROJECT_ID=... REGISTRY_REGION=europe-west1 SERVICE_REGION=europe-west1
bash deploy/deploy.sh
```

`deploy.sh` builds the image, pushes it, and deploys `deploy/cloudrun.yaml`
(min instances 0, max 3, 512 Mi memory, `$PORT` wiring, `/health` probes).
Then map the custom domain once:

```bash
gcloud run domain-mappings create --service syntaro-mcp \
  --domain mcp.syntaro.io --region "$SERVICE_REGION"
```

Point DNS at the Cloud Run endpoint and verify:

```bash
curl https://mcp.syntaro.io/health
```

## Env vars (hosted)

| Variable | Required | Purpose |
|----------|----------|---------|
| `SYNTARO_API_URL` | yes | Backend for fix runs (`https://api.syntaro.io`) |
| `SYNTARO_API_KEY` | yes | Backend auth |
| `MCP_API_KEY` | yes | Shared secret — remote clients send `Authorization: Bearer <key>` |
| `GITHUB_TOKEN` | for `label_issue` | GitHub auth |
| `LINEAR_API_KEY` | for `linear_*` | Linear auth |
| `SLACK_BOT_TOKEN` | for `slack_send` | Slack auth |
| `MEMORY_DIR` | no | Back with a persistent volume if `memory_*` must survive restarts |

## Client config (hosted)

```json
{ "mcpServers": { "syntaro": {   <!-- use after DNS is live -->
  "url": "https://mcp.syntaro.io/sse",
  "headers": { "Authorization": "Bearer $MCP_API_KEY" }
} } }
```

## Notes

- **No in-cluster assumptions.** DNS-rebinding protection is disabled in
  `server.py` so reverse proxies work; `MCP_API_KEY` is the auth boundary.
- **Stateless.** Scale horizontally; per-tenant memory isolation is the
  operator's job (`MEMORY_DIR` per tenant).
- **Cost.** min-instances 0: idle SSE costs ~nothing; each connected client
  holds an instance warm while streaming.
