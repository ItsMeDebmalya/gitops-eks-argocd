#!/usr/bin/env bash
# One-time creation of the S3 bucket + DynamoDB table used for Terraform
# remote state and state locking (see terraform/environments/dev/backend.tf).
set -euo pipefail

REGION="${REGION:-ap-south-1}"
BUCKET="${BUCKET:-itsmedebmalya-tfstate}"
TABLE="${TABLE:-terraform-locks}"

echo "==> Creating state bucket ${BUCKET}"
aws s3api create-bucket \
  --bucket "${BUCKET}" \
  --region "${REGION}" \
  --create-bucket-configuration LocationConstraint="${REGION}"

aws s3api put-bucket-versioning \
  --bucket "${BUCKET}" \
  --versioning-configuration Status=Enabled

aws s3api put-bucket-encryption \
  --bucket "${BUCKET}" \
  --server-side-encryption-configuration \
  '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'

echo "==> Creating lock table ${TABLE}"
aws dynamodb create-table \
  --table-name "${TABLE}" \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region "${REGION}"

echo "==> Backend ready. Now: cd terraform/environments/dev && terraform init"
