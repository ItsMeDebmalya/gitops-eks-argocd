# CI Results

Two jobs run on every push/PR.

## 1. Validate Terraform, Kustomize & manifests ✅
- `terraform fmt -check` and `terraform validate` (module + dev env) pass
- `tfsec` passes on this repo's Terraform (HIGH/CRITICAL; vendored modules excluded)
- every Kustomize overlay builds and passes `kubeconform`
- Argo CD manifests validate

## 2. GitOps e2e (kind + Argo CD sync) ✅

CI creates a kind cluster, installs Argo CD, applies the app-of-apps, and waits
for convergence:

```
attempt 1: 0/1 applications Synced+Healthy
attempt 2: 4/4 applications Synced+Healthy
demo-dev    Synced   Healthy
demo-prod   Synced   Healthy
demo-qa     Synced   Healthy
ALL APPLICATIONS SYNCED & HEALTHY
```

Replica counts deployed by Argo CD from the overlays (as declared in Git):

```
demo-dev: 1
demo-qa: 2
demo-prod: 3
```

The root app-of-apps synced the three environment Applications, each of which
deployed its Kustomize overlay to its own namespace with the correct replica
count — a full declarative GitOps flow, verified end to end.

See the live run history under the repository's **Actions** tab.
