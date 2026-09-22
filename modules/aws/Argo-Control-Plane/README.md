# Argo-Control-Plane

Provisions the Argo control plane on AWS: the single, cloud-agnostic hub that
holds no cloud credentials and runs no deploy workloads itself, but issues
NATS mTLS dispatch tasks to independent per-cloud data planes and waits for
their results. This composite module is the AWS home for that control
plane's own infrastructure and Kubernetes-level install.

## Structure

This directory contains two independently-callable submodules, plus an
optional composite entrypoint that wires them together for you:

- [`cluster/`](./cluster) - the EKS cluster, VPC, IAM/IRSA roles, KMS, and
  optional bastion the control plane runs on.
- [`apps/`](./apps) - the Kubernetes-level install onto that cluster: NATS
  (JetStream, mTLS via cert-manager), Argo Workflows, Argo Events,
  cert-manager, Traefik, External Secrets Operator, and whatever
  project-specific manifests the caller supplies.
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
`cluster`'s outputs, matching exactly what `environments/control-plane`'s
own `main.tf` does today. `outputs.tf` re-exposes the outputs a downstream
caller (e.g. a data-plane environment consuming NATS client certs) would
actually need.

## How the two compose

There is no dependency between the two submodules expressed in Terraform
code inside this directory - `apps` does not take cluster credentials as
an input variable. Instead, the calling root module:

1. Calls `cluster/`, then configures the `kubernetes`/`helm`/`kubectl`
   providers against that cluster's outputs
   (`eks_cluster_endpoint`, `eks_base64_encoded_ca_cert`, `eks_cluster_name`).
2. Calls `apps/`, which inherits those provider configurations implicitly
   (as any Terraform child module does), and additionally wires a few of
   `cluster`'s outputs directly into `apps`' own variables (`eso_role_arn`
   for External Secrets Operator's IRSA annotation,
   `workflow_controller_artifacts_role_arn`/`artifact_bucket_name` for
   Argo Workflows' S3 artifact archiving).

Because `cluster`'s EKS cluster must exist before the `kubernetes`/`helm`
providers used by `apps` can authenticate against it, a caller applying
both in one root module needs a two-step apply:
`terraform apply -target=module.cluster` first, then a plain
`terraform apply`. See `cloud-sre-common`'s `environments/control-plane`
for a real, wired-up example of this pattern (`apps` is called with
`depends_on = [module.cluster]` and every relevant cluster output passed
through explicitly).

## Example

```hcl
module "cluster" {
  source = "git::https://github.com/wso2/aws-terraform-modules.git//modules/aws/Argo-Control-Plane/cluster?ref=v1.0.0"

  project     = "asgardeo"
  environment = "prod"
  region      = "us-east-1"

  vpc_cidr_block             = "10.4.0.0/16"
  availability_zones         = ["us-east-1a", "us-east-1b"]
  private_subnet_cidr_blocks = ["10.4.1.0/24", "10.4.2.0/24"]
  public_subnet_cidr_blocks  = ["10.4.10.0/26", "10.4.10.64/26"]

  kubernetes_version   = "1.31"
  admin_principal_arns = ["arn:aws:iam::123456789012:role/platform-admin"]

  node_instance_types = ["m6i.large"]

  enable_secrets_encryption = true
  enable_artifact_archiving = true
}

provider "kubernetes" {
  host                   = module.cluster.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(module.cluster.eks_base64_encoded_ca_cert)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.cluster.eks_cluster_name, "--region", "us-east-1"]
  }
}

module "apps" {
  source = "git::https://github.com/wso2/aws-terraform-modules.git//modules/aws/Argo-Control-Plane/apps?ref=v1.0.0"

  nats_client_identities   = ["control-plane", "aws-stage", "aws-prod"]
  tunnel_client_identities = ["aws"]

  install_external_secrets = true
  eso_role_arn              = module.cluster.eso_role_arn

  depends_on = [module.cluster]
}
```

See [`cluster/README.md`](./cluster/README.md) and
[`apps/README.md`](./apps/README.md) for each submodule's full inputs and
outputs.
