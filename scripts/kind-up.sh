#!/usr/bin/env bash
# Spin up a local Kubernetes cluster (kind), install Argo CD, and bootstrap
# the app-of-apps so Argo CD syncs the dev/qa/prod overlays from Git.
#
# This is the zero-cost, local-first equivalent of the EKS cluster the
# Terraform in terraform/ provisions. For a local "EKS" specifically, see
# scripts/floci-up.sh.
set -euo pipefail

CLUSTER="${CLUSTER:-gitops-demo}"

echo "==> Creating kind cluster '${CLUSTER}'"
kind create cluster --name "${CLUSTER}" --wait 120s || true

echo "==> Installing Argo CD"
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "==> Waiting for Argo CD server"
kubectl -n argocd rollout status deploy/argocd-server --timeout=300s

echo "==> Applying app-of-apps (root)"
kubectl apply -f argocd/root-app.yaml

cat <<'EOF'

Argo CD is installed and the root application is applied. It will now sync the
dev/qa/prod overlays from Git automatically.

Useful next steps:
  kubectl -n argocd get applications
  kubectl get pods -A -l app.kubernetes.io/part-of=gitops-demo

Open the Argo CD UI:
  kubectl -n argocd port-forward svc/argocd-server 8080:443
  # user: admin
  # password:
  kubectl -n argocd get secret argocd-initial-admin-secret \
    -o jsonpath='{.data.password}' | base64 -d; echo
EOF
