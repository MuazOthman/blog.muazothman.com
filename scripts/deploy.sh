#!/bin/bash
set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# verify the environment variable CERTIFICATE_ARN is set
if [ -z "$CERTIFICATE_ARN" ]; then
  echo -e "${RED}🚨 CERTIFICATE_ARN is not set${NC}"
  exit 1
fi

echo -e "${BLUE}🚀 Starting blog deployment...${NC}"

# Step 1: Build the blog
echo -e "${BLUE}📦 Building the blog...${NC}"
pnpm run build

# Step 2: Deploy infrastructure with SAM

echo -e "${BLUE}☁️  Deploying infrastructure with SAM...${NC}"
sam deploy --parameter-overrides CertificateArn=$CERTIFICATE_ARN --no-confirm-changeset --no-fail-on-empty-changeset

# Step 3: Get the bucket name from CloudFormation outputs
BUCKET_NAME=$(aws cloudformation describe-stacks \
  --stack-name blog-muazothman-com \
  --query 'Stacks[0].Outputs[?OutputKey==`BucketName`].OutputValue' \
  --output text)

echo -e "${BLUE}📤 Uploading files to S3 bucket: ${BUCKET_NAME}${NC}"

# Step 4: Sync the dist folder to S3
aws s3 sync dist/ "s3://${BUCKET_NAME}" \
  --delete \
  --cache-control "public, max-age=31536000, immutable" \
  --exclude "*.html" \
  --exclude "pagefind/*"

# Upload HTML files with shorter cache
aws s3 sync dist/ "s3://${BUCKET_NAME}" \
  --exclude "*" \
  --include "*.html" \
  --cache-control "public, max-age=0, must-revalidate" \
  --content-type "text/html; charset=utf-8"

# Upload pagefind files with shorter cache
aws s3 sync dist/ "s3://${BUCKET_NAME}" \
  --exclude "*" \
  --include "pagefind/*" \
  --cache-control "public, max-age=3600"

# Step 5: Get the CloudFront distribution ID
DISTRIBUTION_ID=$(aws cloudformation describe-stacks \
  --stack-name blog-muazothman-com \
  --query 'Stacks[0].Outputs[?OutputKey==`DistributionId`].OutputValue' \
  --output text)

echo -e "${BLUE}🔄 Invalidating CloudFront cache...${NC}"

# Step 6: Invalidate CloudFront cache
INVALIDATION_ID=$(aws cloudfront create-invalidation \
  --distribution-id "${DISTRIBUTION_ID}" \
  --paths "/*" \
  --query 'Invalidation.Id' \
  --output text)

echo -e "${BLUE}🔄 Invalidation ID: ${INVALIDATION_ID}${NC}"

echo -e "${GREEN}✅ Deployment complete!${NC}"
