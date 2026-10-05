# Argo-Data-Plane/cluster

Provisions the EKS cluster and tier-isolated networking an AWS Argo data
plane runs on. Stage and prod each get their own subnets, NAT Gateway
(own outbound IP), security group, and EKS node group. The prod node
group also carries an `env=<value>:NoSchedule` taint, so only workloads
that explicitly tolerate it land there.

Raw `aws_*` resource blocks. No dependency on any other WSO2
module repo.

## What it provisions

- A shared VPC with per-tier (stage/prod) public subnets (NAT Gateway
  placement only), private subnets (EKS nodes), route tables, and one NAT
  Gateway per tier.
- Per-tier security groups, extending (not replacing) the EKS-managed
  cluster security group, with caller-supplied ingress/egress rules.
- The EKS cluster (API-based access entries, optional control-plane log
  types), its OIDC provider, and core addons (`vpc-cni`, `coredns`, `kube-proxy` by default)
  plus the `aws-ebs-csi-driver` addon.
- Optional VPC Flow Logs and an optional S3 bucket (+ IRSA role) for Argo
  Workflows' artifact archiving, same shape as `Argo-Control-Plane/cluster`.
- IRSA roles for the EBS CSI driver and External Secrets Operator's
  controller ServiceAccount.
- Two EKS node groups (`stage`, `prod`) each with their own launch
  template, IAM role, and scaling config. `prod` additionally carries a
  taint and matching node label.
- EKS access entries/policy associations for admin IAM principals (native
  IAM cluster access, no unified cross-cloud identity layer).
- An optional bastion instance, reachable only via SSM Session Manager,
  through the stage subnet's NAT egress.
- Per-env IRSA identities (`deploy_identities`) for pipeline pods - one
  IAM role per map entry, trust scoped to exactly one `(namespace,
  ServiceAccount)` pair, policy caller-supplied.
- Optional extra IAM policy attached directly to the stage/prod node role
  (`stage_node_extra_policy_json`/`prod_node_extra_policy_json`), for a
  pipeline step that deliberately authenticates via the node's own
  instance-profile role over IMDS instead of per-pod IRSA.

## Notes

- Kubernetes Secrets are envelope-encrypted by EKS itself with an AWS owned
  key (default on Kubernetes 1.28 and later), so this module creates no KMS
  key.
- The OIDC provider sets no `thumbprint_list`. IAM validates EKS OIDC
  issuers against its own trusted CAs, so there is no certificate thumbprint
  to rotate. This needs AWS provider 5.81 or later.
- `eso_secretsmanager_key_prefix` has no default. `"*"` lets ESO read every
  secret in the account; pass it only if the ExternalSecrets reference
  bare, unprefixed key names, and narrow it once those keys follow a path
  convention.
- Stage and prod are built from one set of resource blocks that iterate
  over `local.tiers` (see `locals.tf`). Tier-scoped resources are addressed
  by tier, e.g. `aws_eks_node_group.node["prod"]`.
- `deploy_identities` credentials are minted per-pod by AWS - there is no
  standing secret.

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `project` | `string` | required | Project name, used for resource naming/tagging |
| `environment` | `string` | required | Environment name (e.g. dev, stage, prod) |
| `application` | `string` | `"argo-dataplane"` | Purpose tag for resources this module creates |
| `tags` | `map(string)` | `{}` | |
| `vpc_cidr_block` | `string` | required | CIDR block for the data plane's VPC |
| `stage_public_subnet_cidr_block` | `string` | required | CIDR for the public subnet hosting the stage tier's NAT Gateway. Placed in the first AZ of `stage_availability_zones` |
| `prod_public_subnet_cidr_block` | `string` | required | CIDR for the public subnet hosting the prod tier's NAT Gateway. Placed in the first AZ of `prod_availability_zones` |
| `kubernetes_version` | `string` | required | |
| `endpoint_public_access` | `bool` | `false` | |
| `public_access_cidrs` | `list(string)` | `[]` | |
| `admin_principal_arns` | `list(string)` | `[]` | IAM principal ARNs granted EKS cluster-admin access entries |
| `eks_addons` | `list(object({ name, version }))` | `[vpc-cni, coredns, kube-proxy]` | |
| `stage_availability_zones` | `list(string)` | required | |
| `stage_subnet_cidr_blocks` | `list(string)` | required | One per AZ |
| `stage_node_instance_types` | `list(string)` | required | |
| `stage_node_min_size` | `number` | `1` | |
| `stage_node_max_size` | `number` | `3` | |
| `stage_node_desired_size` | `number` | `2` | |
| `stage_node_capacity_type` | `string` | `"ON_DEMAND"` | |
| `stage_security_group_rules` | `list(object({...}))` | `[]` | Additional rules for the stage tier, beyond the EKS-managed cluster SG |
| `prod_availability_zones` | `list(string)` | required | |
| `prod_subnet_cidr_blocks` | `list(string)` | required | One per AZ |
| `prod_node_instance_types` | `list(string)` | required | |
| `prod_node_min_size` | `number` | `1` | |
| `prod_node_max_size` | `number` | `3` | |
| `prod_node_desired_size` | `number` | `2` | |
| `prod_node_capacity_type` | `string` | `"ON_DEMAND"` | |
| `prod_security_group_rules` | `list(object({...}))` | `[]` | |
| `prod_node_taint_value` | `string` | `"prod"` | Value for the `env` taint applied to prod nodes (key fixed `env`, effect fixed `NO_SCHEDULE`) |
| `enable_bastion` | `bool` | `true` | |
| `bastion_instance_type` | `string` | `"t3.micro"` | |
| `eso_secretsmanager_key_prefix` | `string` | required | Secrets Manager key-name prefix (glob) the ESO IAM role may read. See Notes above |
| `eso_namespace` | `string` | `"external-secrets"` | Namespace ESO runs in; scopes the ESO IAM role's trust policy. Must match the `apps` module's `eso_namespace` |
| `deploy_identities` | `map(object({ namespace, service_account_name, policy_json }))` | `{}` | Per-env IRSA identities for pipeline pods. One IAM role per entry, scoped to exactly that `(namespace, ServiceAccount)` pair. See Notes above |
| `stage_node_extra_policy_json` | `string` | `null` | Extra IAM policy (JSON) attached directly to the stage node role, in addition to the standard EKS worker/CNI/ECR policies |
| `prod_node_extra_policy_json` | `string` | `null` | Prod counterpart of `stage_node_extra_policy_json` |
| `enabled_cluster_log_types` | `list(string)` | `[]` | |
| `log_retention_in_days` | `number` | `90` | |
| `enable_vpc_flow_logs` | `bool` | `false` | |
| `enable_artifact_archiving` | `bool` | `false` | |
| `argo_namespace` | `string` | `"argo"` | |
| `workflow_controller_service_account_name` | `string` | `"argo-workflows-workflow-controller"` | |

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
| `stage_subnet_ids` | |
| `prod_subnet_ids` | |
| `stage_nat_gateway_public_ip` | |
| `prod_nat_gateway_public_ip` | |
| `bastion_instance_id` | `null` unless `enable_bastion`. Use `aws ssm start-session --target <this>` to reach the bastion |
| `deploy_identity_role_arns` | Role ARN per `deploy_identities` entry. Annotate the matching ServiceAccount with `eks.amazonaws.com/role-arn: <this value>` |
| `eso_role_arn` | IRSA role ARN for ESO's own controller ServiceAccount |
| `workflow_controller_artifacts_role_arn` | `null` unless `enable_artifact_archiving` |
| `artifact_bucket_name` | `null` unless `enable_artifact_archiving` |

## Example

```hcl
module "cluster" {
  source = "git::https://github.com/wso2/aws-terraform-modules.git//modules/aws/Argo-Data-Plane/cluster?ref=v1.0.0"

  project     = "asgardeo"
  environment = "prod"

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

  deploy_identities = {
    "is-deploy-stage" = {
      namespace             = "argo-aws-stage"
      service_account_name  = "asgardeo-is-deploy-sa"
      policy_json            = data.aws_iam_policy_document.is_deploy_stage.json
    }
  }
}
```
