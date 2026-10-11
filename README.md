# gitops-eks-argocd

[![CI](https://github.com/ItsMeDebmalya/gitops-eks-argocd/actions/workflows/ci.yml/badge.svg)](https://github.com/ItsMeDebmalya/gitops-eks-argocd/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

> **EKS provisioned with reusable Terraform modules** (remote state + locking),
> with **all deployments driven declaratively through Argo CD** syncing from
> Git, **per-environment Kustomize overlays**, and **automated self-heal /
> rollback** — so every cluster change is auditable in Git and self-correcting.

Push a change to `main`, and Argo CD reconciles the cluster to match Git. No
`kubectl apply` by hand, no drift: if something changes the cluster out of band,
Argo CD heals it back to the declared state.

---

## How it fits together

```
 Terraform (modules/eks)              Argo CD (app-of-apps)
 ┌──────────────────────┐            ┌───────────────────────────┐
 │ VPC + EKS + nodegroup│            │ root ─┬─ demo-dev  (1 pod) │
 │ remote state (S3) +  │  cluster   │       ├─ demo-qa   (2 pods)│
 │ locking (DynamoDB)   │──────────▶ │       └─ demo-prod (3 pods)│
 └──────────────────────┘            └───────────┬───────────────┘
                                                  │ syncs from Git
                                      ┌───────────▼───────────────┐
                                      │ kustomize/overlays/{env}   │
                                      │  (base + per-env patches)  │
                                      └────────────────────────────┘
```

## Repository layout

```
terraform/
  modules/eks/          # reusable VPC + EKS module (inputs: env, sizing, CIDRs)
  environments/dev/     # dev env; S3 remote state + DynamoDB locking
argocd/
  root-app.yaml         # app-of-apps
  apps/{dev,qa,prod}.yaml  # one Argo CD Application per environment
kustomize/
  base/                 # Deployment + Service
  overlays/{dev,qa,prod}/  # namespace + replica differences
scripts/
  kind-up.sh            # local cluster + Argo CD (zero cost)
  floci-up.sh           # local "EKS" via Floci (real k3s)
  bootstrap-backend.sh  # create the S3/DynamoDB state backend
```

## Provision the cluster (Terraform)

```bash
# one-time: create the remote-state backend
./scripts/bootstrap-backend.sh

cd terraform/environments/dev
terraform init
terraform plan
terraform apply
aws eks update-kubeconfig --name gitops-demo-dev --region ap-south-1
```

The `modules/eks` module is reusable — a `qa` or `prod` environment is just
another folder under `terraform/environments/` passing different sizing/CIDRs.

## Drive deployments (Argo CD / GitOps)

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl apply -f argocd/root-app.yaml      # app-of-apps
kubectl -n argocd get applications          # dev/qa/prod sync automatically
```

Each environment's Application has `automated: { prune: true, selfHeal: true }`,
so Argo CD **rolls back any manual drift** and prunes removed resources. Changing
an overlay in Git (e.g. bumping replicas) is the *only* way to change the cluster.

## Run it locally at zero cost

No AWS account needed:

```bash
./scripts/kind-up.sh        # kind cluster + Argo CD + app-of-apps
# or, for a local "EKS" specifically (real k3s under the hood):
./scripts/floci-up.sh       # uses Floci (https://floci.io)
```

## What CI proves

- **Terraform**: `fmt`, `validate` (module + dev env), and a **tfsec** security scan.
- **Kustomize**: every overlay builds and the rendered manifests pass `kubeconform`.
- **GitOps end-to-end**: CI spins up a **kind** cluster, installs **Argo CD**,
  applies the app-of-apps, and waits until **all four Applications report
  `Synced` + `Healthy`** — then prints the dev/qa/prod pods (1/2/3 replicas).

## License

MIT — see [LICENSE](LICENSE).
