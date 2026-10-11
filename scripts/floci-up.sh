#!/usr/bin/env bash
# Local "EKS" with Floci (https://floci.io) - a local AWS emulator whose
# `eks create-cluster` spins up a real k3s node you can kubectl against.
# This lets the EKS workflow be exercised end-to-end at zero cost.
set -euo pipefail

export AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID:-test}"
export AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY:-test}"
export AWS_ENDPOINT_URL="${AWS_ENDPOINT_URL:-http://localhost:4566}"
export AWS_REGION="${AWS_REGION:-ap-south-1}"

CLUSTER="${CLUSTER:-gitops-demo-dev}"

echo "==> Creating EKS cluster '${CLUSTER}' via Floci (real k3s under the hood)"
aws eks create-cluster \
  --name "${CLUSTER}" \
  --role-arn arn:aws:iam::000000000000:role/eks \
  --resources-vpc-config '{}' \
  --endpoint-url "${AWS_ENDPOINT_URL}"

echo "==> Updating kubeconfig"
aws eks update-kubeconfig --name "${CLUSTER}" --endpoint-url "${AWS_ENDPOINT_URL}"

echo "==> Cluster nodes:"
kubectl get nodes

echo
echo "Now install Argo CD and the app-of-apps exactly as in scripts/kind-up.sh:"
echo "  kubectl create namespace argocd"
echo "  kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml"
echo "  kubectl apply -f argocd/root-app.yaml"
