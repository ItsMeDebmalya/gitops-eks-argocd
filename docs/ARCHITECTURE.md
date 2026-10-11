# Architecture

## Goal

Make every cluster change **declarative, auditable, and self-correcting**:
infrastructure defined once in reusable Terraform, and application state owned
entirely by Git through Argo CD. Humans change Git; Argo CD changes the cluster.

## Two layers

### 1. Infrastructure — Terraform

`modules/eks` is a reusable module (VPC + EKS + managed node group) with inputs
for environment name, Kubernetes version, CIDRs, and node sizing. Each
environment under `environments/` is a thin consumer of that module.

- **Remote state** in S3 with **DynamoDB locking** (`backend.tf`) so state is
  shared and concurrent applies are serialized.
- **One module, many environments** — `qa`/`prod` differ only by the variables
  they pass, not by copied code.

Offline (`terraform init -backend=false`) the module and env both `validate`
cleanly, and `tfsec` gates the configuration for HIGH/CRITICAL misconfigurations.

### 2. Delivery — Argo CD + Kustomize

- **App-of-apps**: `argocd/root-app.yaml` is a single Application that points at
  `argocd/apps/`, so adding an environment is just dropping a new Application
  manifest in Git — no manual `argocd app create`.
- **Per-environment Applications** each track a Kustomize overlay
  (`kustomize/overlays/{env}`) and deploy into their own namespace.
- **Kustomize overlays** share one `base/` and differ only in namespace and
  replica count (dev=1, qa=2, prod=3), which keeps environment drift explicit
  and reviewable.

## Self-healing & rollback

Every Application sets:

```yaml
syncPolicy:
  automated:
    prune: true      # resources removed from Git are removed from the cluster
    selfHeal: true   # out-of-band changes are reverted to the Git state
```

So a manual `kubectl edit`/`scale` is undone automatically, and a bad change is
"rolled back" simply by reverting the commit — Argo CD reconciles to whatever
Git says. This is the auditable, self-correcting property GitOps provides.

## Why kind/Floci for local runs

Real EKS costs money, so the Terraform here is written and validated but applied
on demand. For day-to-day work and for CI, a local Kubernetes cluster gives an
identical Argo CD + Kustomize experience:

- `scripts/kind-up.sh` — a kind cluster (used by CI).
- `scripts/floci-up.sh` — Floci's local AWS emulator, whose `eks create-cluster`
  backs a real k3s node, so even the `aws eks` workflow is exercised at zero cost.

## Testing strategy

| Layer | Tool | Proves |
|-------|------|--------|
| Terraform | fmt, validate, tfsec | config is well-formed and secure |
| Manifests | kustomize build + kubeconform | overlays render to valid Kubernetes objects |
| GitOps | kind + Argo CD in CI | the app-of-apps actually syncs dev/qa/prod to Healthy |
