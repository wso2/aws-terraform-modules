# Argo-Control-Plane/cluster

Provisions the EKS cluster, VPC, and supporting IAM/networking the Argo
control plane runs on. The control plane itself holds no cloud credentials
and runs no deploy workloads - this module builds the cluster it lives on,
not anything that reaches out to a data plane's own cloud account.

Raw `aws_*`/`tls_*` resource blocks, no dependency on any other WSO2 module
repo.

## What it provisions

- VPC with per-AZ public and private subnets, an Internet Gateway, and one
  NAT Gateway per AZ (each with its own EIP).
- Optional VPC Flow Logs (own CloudWatch Log Group + IAM role), opt-in via
  `enable_vpc_flow_logs`.
- A security group for cluster nodes with caller-supplied ingress/egress
  rules, plus a separate security group and NSG rule for the optional
  bastion.
- The EKS cluster itself (API-based access entries, private/optional-public
  endpoint, optional KMS envelope encryption of Kubernetes Secrets, optional
  control-plane log types), its EKS-managed node group (launch template,
  scaling config, one shared "system" node group), and the standard
  worker/CNI/ECR-readonly IAM policy attachments.
- The cluster's OIDC provider, plus IRSA roles for the EBS CSI driver
  (needed since the in-tree `gp2` provisioner doesn't work on modern k8s),
  External Secrets Operator's controller ServiceAccount, and (opt-in) the
  workflow-controller's artifact-archiving role.
- Core EKS addons (`vpc-cni`, `coredns`, `kube-proxy` by default) plus the
  `aws-ebs-csi-driver` addon wired to its IRSA role.
- EKS access entries/policy associations for admin IAM principals (native
  IAM cluster access, no unified cross-cloud identity layer).
- An optional S3 bucket (+ public-access block, SSE, lifecycle expiration)
  for Argo Workflows' artifact archiving, gated by `enable_artifact_archiving`.
- An optional bastion instance (SSM Session Manager only - no inbound
  security group rules, no open port) for admin access.

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `project` | `string` | required | Name of the project (used for resource naming/tagging) |
| `environment` | `string` | `"prod"` | Name of the environment |
| `region` | `string` | required | Code of the AWS region |
| `application` | `string` | `"argo-controlplane"` | Purpose tag for the resources created by this module |
| `tags` | `map(string)` | `{}` | Tags applied to all resources created by this module |
| `vpc_cidr_block` | `string` | required | CIDR block for the control plane's VPC |
| `availability_zones` | `list(string)` | required | AZs for the control plane's multi-AZ layout. At least 2 required - NATS JetStream runs 3 replicas regardless of AZ count (set via the `apps` module); fewer than 3 AZs means a single-AZ outage can take out a RAFT quorum majority |
| `private_subnet_cidr_blocks` | `list(string)` | required | One CIDR per AZ for the private (node) subnets, same order as `availability_zones` |
| `public_subnet_cidr_blocks` | `list(string)` | required | One CIDR per AZ for the public (NAT Gateway) subnets, same order as `availability_zones` |
| `kubernetes_version` | `string` | required | Kubernetes version for the EKS cluster |
| `endpoint_public_access` | `bool` | `false` | Whether the EKS API server has a public endpoint |
| `public_access_cidrs` | `list(string)` | `[]` | CIDRs allowed to reach the public API endpoint, if enabled |
| `admin_principal_arns` | `list(string)` | `[]` | IAM principal ARNs (users/roles) granted EKS cluster-admin access entries (native-IAM cluster access path) |
| `enable_secrets_encryption` | `bool` | `false` | Whether to create a dedicated KMS CMK and envelope-encrypt Kubernetes Secrets with it |
| `enabled_cluster_log_types` | `list(string)` | `[]` | Cluster log types to enable - when non-empty, a matching CloudWatch Log Group is also created with retention set by `log_retention_in_days` |
| `log_retention_in_days` | `number` | `90` | Retention for any CloudWatch Log Groups this module creates (EKS cluster logs, VPC flow logs) and the S3 artifact bucket's expiration, if enabled |
| `enable_vpc_flow_logs` | `bool` | `false` | Whether to create a VPC Flow Log for this module's own VPC, published to a dedicated CloudWatch Log Group |
| `enable_artifact_archiving` | `bool` | `false` | Whether to create an S3 bucket + IRSA role for Argo Workflows to archive workflow logs/artifacts to. The caller still wires the resulting outputs into `argo_workflows_values`' `artifactRepository` Helm config |
| `argo_namespace` | `string` | `"argo"` | Kubernetes namespace Argo Workflows runs in - only used to scope the workflow-controller's IRSA trust policy when `enable_artifact_archiving` is true |
| `workflow_controller_service_account_name` | `string` | `"argo-workflows-workflow-controller"` | ServiceAccount name the argo-workflows Helm chart creates for workflow-controller - only used to scope the IRSA trust policy when `enable_artifact_archiving` is true |
| `eks_addons` | `list(object({ name = string, version = optional(string) }))` | `[vpc-cni, coredns, kube-proxy]` | Core EKS addons to install alongside the EBS CSI driver |
| `node_instance_types` | `list(string)` | required | Instance types for the shared node group |
| `node_min_size` | `number` | `2` | |
| `node_max_size` | `number` | `4` | |
| `node_desired_size` | `number` | `2` | |
| `node_capacity_type` | `string` | `"ON_DEMAND"` | |
| `security_group_rules` | `list(object({ direction, to_port, from_port, protocol, cidr_blocks, security_groups }))` | `[]` | Additional security group rules, beyond the EKS-managed cluster security group |
| `enable_bastion` | `bool` | `true` | Whether to provision a bastion instance for admin access, via AWS Systems Manager Session Manager - no inbound security group rules, no open port |
| `bastion_instance_type` | `string` | `"t3.micro"` | |
| `eso_secretsmanager_key_prefix` | `string` | `"argo/control-plane/*"` | Secrets Manager key-name prefix (glob) the ESO IAM role may read - scoped to this control plane's own secrets |

## Outputs

| Name | Description |
|---|---|
| `eks_cluster_name` | |
| `eks_cluster_arn` | |
| `eks_cluster_endpoint` | |
| `eks_base64_encoded_ca_cert` | |
| `oidc_provider_arn` | |
| `oidc_provider_url` | |
| `vpc_id` | |
| `private_subnet_ids` | |
| `nat_gateway_public_ips` | Map of AZ to NAT Gateway public IP |
| `bastion_instance_id` | `aws ssm start-session --target <this>` to reach the bastion; `null` unless `enable_bastion` |
| `eso_role_arn` | IRSA role ARN for External Secrets Operator's own controller ServiceAccount (`external-secrets/external-secrets`) |
| `workflow_controller_artifacts_role_arn` | IRSA role ARN for the workflow-controller ServiceAccount to write to `artifact_bucket_name` - `null` unless `enable_artifact_archiving` is true |
| `artifact_bucket_name` | S3 bucket Argo Workflows should archive logs/artifacts to - `null` unless `enable_artifact_archiving` is true |

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
  node_min_size        = 2
  node_desired_size     = 2
  node_max_size          = 4

  enable_secrets_encryption = true
  enabled_cluster_log_types = ["api", "audit"]
  enable_vpc_flow_logs      = true
  enable_artifact_archiving = true
}
```
