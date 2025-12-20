#!/bin/bash

# MathLab Backend - GCP Cloud Run 배포 스크립트

set -e

# Configuration
PROJECT_ID="your-gcp-project-id"
REGION="asia-northeast3"  # Seoul region
SERVICE_NAME="mathlab-api"
IMAGE_NAME="gcr.io/${PROJECT_ID}/${SERVICE_NAME}"

echo "🚀 Starting deployment to GCP Cloud Run..."

# 1. Build Docker image
echo "📦 Building Docker image..."
docker build -t ${IMAGE_NAME}:latest -t ${IMAGE_NAME}:$(git rev-parse --short HEAD) .

# 2. Push to Google Container Registry
echo "📤 Pushing image to GCR..."
docker push ${IMAGE_NAME}:latest
docker push ${IMAGE_NAME}:$(git rev-parse --short HEAD)

# 3. Deploy to Cloud Run
echo "🌐 Deploying to Cloud Run..."
gcloud run deploy ${SERVICE_NAME} \
  --image ${IMAGE_NAME}:latest \
  --platform managed \
  --region ${REGION} \
  --allow-unauthenticated \
  --set-env-vars="NODE_ENV=production" \
  --set-env-vars="API_VERSION=v1" \
  --memory 512Mi \
  --cpu 1 \
  --max-instances 10 \
  --min-instances 0 \
  --timeout 60s \
  --port 8080 \
  --project ${PROJECT_ID}

echo "✅ Deployment complete!"
echo "🔗 Service URL:"
gcloud run services describe ${SERVICE_NAME} \
  --platform managed \
  --region ${REGION} \
  --format 'value(status.url)' \
  --project ${PROJECT_ID}
