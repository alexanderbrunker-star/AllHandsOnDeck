#!/usr/bin/env bash
# deploy.sh — All Hands on Deck full deployment
# Deploys:
#   WebSocket server  → Google Cloud Run  (free tier)
#   Web viewer        → Firebase Hosting  (free tier CDN)
#
# Prerequisites:
#   gcloud auth login && gcloud auth configure-docker
#   firebase login
#   npm i -g firebase-tools
#
# Usage:
#   ./deploy.sh <gcp-project-id> <firebase-project-id> [region]
#
# Example:
#   ./deploy.sh my-gcp-project my-firebase-project europe-west3

set -euo pipefail

GCP_PROJECT="${1:?Usage: ./deploy.sh <gcp-project-id> <firebase-project-id> [region]}"
FIREBASE_PROJECT="${2:?Usage: ./deploy.sh <gcp-project-id> <firebase-project-id> [region]}"
REGION="${3:-europe-west3}"

SERVICE_NAME="allhands-server"
IMAGE="gcr.io/${GCP_PROJECT}/${SERVICE_NAME}"

echo "==> [1/4] Setting GCP project to ${GCP_PROJECT}"
gcloud config set project "${GCP_PROJECT}"

echo "==> [2/4] Building & pushing Docker image"
gcloud builds submit --tag "${IMAGE}" .

echo "==> [3/4] Deploying to Cloud Run (region: ${REGION})"
gcloud run deploy "${SERVICE_NAME}" \
  --image "${IMAGE}" \
  --region "${REGION}" \
  --allow-unauthenticated \
  --port 8787 \
  --memory 256Mi \
  --timeout 3600 \
  --min-instances 0 \
  --max-instances 3 \
  --set-env-vars "PORT=8787,NODE_ENV=production"

SERVER_URL=$(gcloud run services describe "${SERVICE_NAME}" \
  --region "${REGION}" \
  --format "value(status.url)")

WS_URL="${SERVER_URL/https/wss}"
echo "   Cloud Run URL : ${SERVER_URL}"
echo "   WebSocket URL : ${WS_URL}"

echo "==> [4/4] Building webapp and deploying to Firebase Hosting"
# Update .firebaserc with the correct project
sed -i.bak "s/FIREBASE_PROJECT_ID/${FIREBASE_PROJECT}/" .firebaserc && rm .firebaserc.bak

cd webapp
VITE_SERVER_URL="${WS_URL}" npm run build
cd ..

firebase use "${FIREBASE_PROJECT}"
firebase deploy --only hosting

HOSTING_URL="https://${FIREBASE_PROJECT}.web.app"
echo ""
echo "✅ Deployment complete!"
echo ""
echo "   WebSocket server : ${WS_URL}"
echo "   Web viewer       : ${HOSTING_URL}"
echo ""
echo "   Set these in your iOS Xcode scheme (Run → Arguments → Launch Arguments):"
echo "     -webSocketServerURL ${WS_URL}"
echo "     -joinBaseURL        ${HOSTING_URL}"
echo ""
echo "   Update server/public/.well-known/apple-app-site-association with:"
echo "     domain: ${HOSTING_URL#https://}"
