#!/bin/bash
set -e

STACK=fichier-tendanci-eu

# Create the config
outputs=$(aws cloudformation describe-stacks --stack-name $STACK | jq '.Stacks[0].Outputs|map({key: .OutputKey, value: .OutputValue})|from_entries')

website_bucket=$(echo $outputs | jq -r .WebsiteBucket)
cloudfront_distribution=$(echo $outputs | jq -r .CloudFrontDistributionId)

# Sync to S3
aws s3 sync web/ s3://${website_bucket}/

# Invalidate CloudFront
aws cloudfront create-invalidation --distribution-id ${cloudfront_distribution} --paths "/*"