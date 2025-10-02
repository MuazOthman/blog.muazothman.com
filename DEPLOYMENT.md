# Deployment Guide

This guide explains how to deploy the blog to AWS using SAM (Serverless Application Model).

## Prerequisites

1. **AWS CLI** installed and configured
2. **SAM CLI** installed ([Installation Guide](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/install-sam-cli.html))
3. **Route53 Hosted Zone** for `muazothman.com`
4. **ACM Certificate** in `us-east-1` region for `*.muazothman.com` or `blog.muazothman.com`

## Infrastructure

The SAM template provisions:

- **S3 Bucket** - Stores static blog files
- **CloudFront Distribution** - CDN with HTTPS
- **Route53 Record** - DNS mapping for `blog.muazothman.com`
- **Origin Access Control** - Secure S3 access from CloudFront

## Setup

### 1. Configure SAM Parameters

Edit `samconfig.toml` and replace the placeholder values:

```toml
parameter_overrides = [
    "DomainName=muazothman.com",
    "SubDomain=blog",
    "CertificateArn=YOUR_CERTIFICATE_ARN"    # Replace this
]
```

**To find your Certificate ARN (must be in us-east-1):**

```bash
aws acm list-certificates --region us-east-1
```

### 2. Deploy Infrastructure

Deploy the CloudFormation stack:

```bash
sam build
sam deploy
```

Or use the guided deployment:

```bash
sam deploy --guided
```

### 3. Build and Deploy Content

Use the provided deployment script:

```bash
./scripts/deploy.sh
```

This script will:

1. Build the blog (`pnpm run build`)
2. Deploy SAM template
3. Sync files to S3 with appropriate cache headers
4. Invalidate CloudFront cache
5. Display the website URL

## Manual Deployment

If you prefer manual steps:

### Build the blog

```bash
pnpm run build
```

### Sync to S3

```bash
# Get bucket name from stack outputs
BUCKET_NAME=$(aws cloudformation describe-stacks \
  --stack-name blog-muazothman-com \
  --query 'Stacks[0].Outputs[?OutputKey==`BucketName`].OutputValue' \
  --output text)

# Upload static assets with long cache
aws s3 sync dist/ "s3://${BUCKET_NAME}" \
  --delete \
  --cache-control "public, max-age=31536000, immutable" \
  --exclude "*.html" \
  --exclude "pagefind/*"

# Upload HTML with short cache
aws s3 sync dist/ "s3://${BUCKET_NAME}" \
  --exclude "*" \
  --include "*.html" \
  --cache-control "public, max-age=0, must-revalidate" \
  --content-type "text/html; charset=utf-8"

# Upload pagefind with medium cache
aws s3 sync dist/ "s3://${BUCKET_NAME}" \
  --exclude "*" \
  --include "pagefind/*" \
  --cache-control "public, max-age=3600"
```

### Invalidate CloudFront Cache

```bash
# Get distribution ID
DISTRIBUTION_ID=$(aws cloudformation describe-stacks \
  --stack-name blog-muazothman-com \
  --query 'Stacks[0].Outputs[?OutputKey==`DistributionId`].OutputValue' \
  --output text)

# Create invalidation
aws cloudfront create-invalidation \
  --distribution-id "${DISTRIBUTION_ID}" \
  --paths "/*"
```

## Cache Strategy

- **Static Assets** (JS, CSS, images): 1 year cache (immutable)
- **HTML Files**: No cache (must-revalidate)
- **Pagefind Search**: 1 hour cache

## Cleanup

To delete all resources:

```bash
# Empty the S3 bucket first
BUCKET_NAME=$(aws cloudformation describe-stacks \
  --stack-name blog-muazothman-com \
  --query 'Stacks[0].Outputs[?OutputKey==`BucketName`].OutputValue' \
  --output text)

aws s3 rm "s3://${BUCKET_NAME}" --recursive

# Delete the stack
sam delete
```

## Troubleshooting

### Certificate Issues

- Certificate **must** be in `us-east-1` region for CloudFront
- Certificate must cover `blog.muazothman.com` or `*.muazothman.com`
- Certificate must be validated and issued

### CloudFront 403 Errors

- Check Origin Access Control is properly configured
- Verify S3 bucket policy allows CloudFront access
- Check that files exist in S3

### DNS Not Resolving

- Check that DNS record was created successfully
- DNS propagation can take a few minutes

## Notes

- CloudFront distributions can take 10-15 minutes to deploy
- Cache invalidations can take 5-10 minutes to complete
- The `samconfig.toml` file is gitignored to protect sensitive IDs
