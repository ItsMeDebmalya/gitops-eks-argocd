# Changelog

All notable changes to this project are documented here.
The format is based on [Keep a Changelog](https://keepachangelog.com/).

## [Unreleased]

### Added
- Reusable Terraform `eks` module (VPC + EKS + managed node group) and a `dev`
  environment with S3 remote state and DynamoDB locking.
- Argo CD app-of-apps with per-environment Applications (dev/qa/prod) and
  automated prune + self-heal.
- Kustomize base and dev/qa/prod overlays (namespace + replica differences).
- Helper scripts: local kind cluster, Floci-based local "EKS", and remote-state
  backend bootstrap.
- CI: Terraform fmt/validate/tfsec, Kustomize build + kubeconform validation,
  and a kind + Argo CD end-to-end sync test.
- README and architecture documentation.
