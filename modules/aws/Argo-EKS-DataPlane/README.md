# Argo-EKS-DataPlane

Provisions an AWS-based Argo data plane: an independent EKS cluster that
pulls dispatch tasks from the control plane over NATS (mTLS) and actually
runs the deploy pipelines. Each data plane is tier-isolated internally
(stage vs. prod get their own subnets, NAT Gateways, node groups, and a
taint on the prod node group) and holds no credentials for any other
cloud's data plane or for the control plane itself beyond its NATS client
identity.

## Structure

This directory contains two independently-callable submodules, plus an
optional composite entrypoint that wires them together for you:

- [`cluster/`](./cluster) - the EKS cluster, VPC (stage/prod tiers, each
  with its own NAT Gateway and subnets), per-env IRSA identities, and
  optional bastion.
- [`apps/`](./apps) - the Kubernetes-level install: Argo Workflows, Argo
  Events, ArgoCD, External Secrets Operator, and caller-supplied
  project-specific manifests.
- `main.tf`/`variables.tf`/`outputs.tf`/`versions.tf` (this directory's own
  top level) - a composite root module calling `cluster` and `apps` for
  you, as an ALTERNATIVE to calling the two submodules separately (see
  "Composite entrypoint" below).

## Composite entrypoint

Calling this directory itself as a module (instead of `./cluster` and
`./apps` separately) gets you `module.cluster`/`module.apps` wired
together in one call: every `cluster` variable passed straight through,
every `apps` variable passed straight through EXCEPT `eso_role_arn` (wired
automatically from `module.cluster.eso_role_arn`), and the
`kubernetes`/`helm`/`kubectl` provider blocks pre-configured against
`cluster`'s outputs via the `aws_eks_cluster_auth` data source, matching
exactly what `environments/aws-dataplane`'s own `main.tf` does today.
`outputs.tf` re-exposes the outputs a caller would actually need (e.g. IRSA
role ARNs to reference from its own `argo_workflows_values`).

## How the two compose

`apps` does not take cluster credentials as an input variable - it
inherits the `kubernetes`/`helm`/`kubectl` provider configuration the
caller sets up against `cluster`'s outputs (`eks_cluster_endpoint`,
`eks_base64_encoded_ca_cert`, `eks_cluster_name`), the same implicit
pattern any Terraform child module uses. The caller additionally wires
specific `cluster` outputs into `apps` inputs directly: `eso_role_arn` for
External Secrets Operator's IRSA annotation, and
`workflow_controller_artifacts_role_arn`/`artifact_bucket_name` for Argo
Workflows' S3 artifact archiving.

Because `cluster`'s EKS cluster must exist before the `kubernetes`/`helm`
providers used by `apps` can authenticate against it, a root module calling
both needs a two-step apply: `terraform apply -target=module.cluster`
first, then a plain `terraform apply`. See `cloud-sre-common`'s
`environments/aws-dataplane` for a real, wired-up example.

## Example

```hcl
module "cluster" {
  source = "git::https://github.com/wso2/aws-terraform-modules.git//modules/aws/Argo-EKS-DataPlane/cluster?ref=v1.0.0"

  project     = "asgardeo"
  environment = "prod"
  region      = "us-east-1"

  vpc_cidr_block = "10.3.0.0/16"

  stage_availability_zones       = ["us-east-1a"]
  stage_subnet_cidr_blocks       = ["10.3.1.0/24"]
  stage_public_subnet_cidr_block = "10.3.10.0/26"
  stage_node_instance_types      = ["t3.medium"]

  prod_availability_zones       = ["us-east-1b"]
  prod_subnet_cidr_blocks       = ["10.3.2.0/24"]
  prod_public_subnet_cidr_block = "10.3.10.64/26"
  prod_node_instance_types      = ["t3.medium"]

  kubernetes_version   = "1.31"
  admin_principal_arns = ["arn:aws:iam::123456789012:role/platform-admin"]
}

module "apps" {
  source = "git::https://github.com/wso2/aws-terraform-modules.git//modules/aws/Argo-EKS-DataPlane/apps?ref=v1.0.0"

  namespaces     = ["argo-aws-stage", "argo-aws-prod"]
  install_argocd = true

  install_external_secrets = true
  eso_role_arn              = module.cluster.eso_role_arn

  depends_on = [module.cluster]
}
```

See [`cluster/README.md`](./cluster/README.md) and
[`apps/README.md`](./apps/README.md) for each submodule's full inputs and
outputs.
