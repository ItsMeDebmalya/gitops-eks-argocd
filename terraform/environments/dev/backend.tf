###############################################################################
# Remote state with locking. The S3 bucket and DynamoDB lock table are created
# once by scripts/bootstrap-backend.sh. For offline validation the backend is
# skipped with `terraform init -backend=false`.
###############################################################################

terraform {
  backend "s3" {
    bucket         = "itsmedebmalya-tfstate"
    key            = "gitops-eks-argocd/dev/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
