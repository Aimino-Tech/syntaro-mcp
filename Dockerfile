# Hosted SYNTARO MCP server (SSE). Cloud Run-ready: listens on $PORT.
FROM python:3.12-slim

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY syntaro_mcp/ ./syntaro_mcp/
COPY workers/ ./workers/

EXPOSE 4095

# Cloud Run injects $PORT; default to 4095 for local `docker run`.
CMD ["sh", "-c", "python -m syntaro_mcp.server sse --host 0.0.0.0 --port ${PORT:-4095}"]
