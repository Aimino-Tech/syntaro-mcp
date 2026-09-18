#!/usr/bin/env bash
# Deploy the hosted SYNTARO MCP server to Cloud Run.
# Required env: PROJECT_ID, REGISTRY_REGION (e.g. europe-west1),
# SERVICE_REGION (e.g. europe-west1). Optional: IMAGE_TAG (default v1.1.0).
set -euo pipefail

PROJECT_ID="${PROJECT_ID:?set PROJECT_ID}"
REGISTRY_REGION="${REGISTRY_REGION:?set REGISTRY_REGION}"
SERVICE_REGION="${SERVICE_REGION:?set SERVICE_REGION}"
IMAGE_TAG="${IMAGE_TAG:-v1.1.0}"
IMAGE="$REGISTRY_REGION-docker.pkg.dev/$PROJECT_ID/syntaro/syntaro-mcp:$IMAGE_TAG"

gcloud config set project "$PROJECT_ID" >/dev/null
gcloud services enable run.googleapis.com artifactregistry.googleapis.com secretmanager.googleapis.com

gcloud artifacts repositories create syntaro --repository-format=docker \
  --location="$REGISTRY_REGION" 2>/dev/null || true

docker build -t "$IMAGE" .
docker push "$IMAGE"

sed "s|REGION-docker.pkg.dev/PROJECT_ID|$REGISTRY_REGION-docker.pkg.dev/$PROJECT_ID|" \
  deploy/cloudrun.yaml | \
  gcloud run services replace - --region="$SERVICE_REGION"

echo "Deployed. Map DNS once:"
echo "  gcloud run domain-mappings create --service syntaro-mcp --domain mcp.syntaro.io --region $SERVICE_REGION"
echo "Verify: curl https://mcp.syntaro.io/health"
