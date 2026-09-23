# Argo-EKS-DataPlane/apps

Installs the Kubernetes-level workload an AWS Argo data plane runs: a
single shared Argo Workflows/Argo Events install, optionally ArgoCD, and
External Secrets Operator.

The workflow-controller and Argo Events controllers see every namespace
on the cluster - that's normal Kubernetes control-plane behavior. Tier
isolation is enforced via RBAC in caller-supplied manifests, not by
running separate controller instances per tier.

This module is deliberately generic: it installs the upstream Helm charts
and applies whatever project-specific manifests the caller points it at
via `manifest_files`/`kubectl_manifest_files`. It does not hardcode any
project-specific YAML itself. It assumes the caller has already
configured the `kubernetes`/`helm`/`kubectl` providers against the
cluster built by the sibling [`../cluster`](../cluster) module.

## What it provisions

- Per-tier namespaces (`namespaces`) plus the shared `system_namespace`
  and (if enabled) `argocd_namespace`.
- A `gp3` `StorageClass` (default), backed by the EBS CSI driver addon the
  `cluster` module installs.
- Helm releases for `argo-workflows` and `argo-events` (both in
  `system_namespace`), optionally `argocd`, optionally `external-secrets`.
- Arbitrary caller-supplied manifests via `manifest_files` (plain, via the
  `alekc/kubectl` provider - not `kubernetes_manifest`, which has a known
  silent-client-construction-failure bug under exec-based auth) and
  `kubectl_manifest_files` (for anything backed by a CRD installed in the
  same apply, e.g. ESO's `ClusterSecretStore`/`ExternalSecret`).
- Optional local files under `<module_path>/.rendered/` for inspecting
  rendered manifest content (`rendered_manifest_files`) - never applied to
  the cluster itself.

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `namespaces` | `list(string)` | required | Per-tier Kubernetes namespaces (e.g. `["argo-stage", "argo-prod"]`), created by this module. Argo Workflows/Events themselves install once, cluster-wide, in `system_namespace` |
| `system_namespace` | `string` | `"argo"` | Namespace for the single shared argo-server/workflow-controller/argo-events install |
| `argo_workflows_chart_version` | `string` | `null` | Null uses the chart repo's latest |
| `argo_events_chart_version` | `string` | `null` | |
| `argo_helm_repo` | `string` | `"https://argoproj.github.io/argo-helm"` | |
| `argo_workflows_values` | `list(string)` | `[]` | Helm values overrides (YAML strings, later entries win). Set `controller.workflowNamespaces` to `namespaces` (or leave cluster-wide) depending on how narrow you want the watch |
| `argo_events_values` | `list(string)` | `[]` | |
| `install_argocd` | `bool` | `true` | |
| `argocd_namespace` | `string` | `"argocd"` | |
| `argocd_chart_version` | `string` | `null` | |
| `argocd_helm_repo` | `string` | `"https://argoproj.github.io/argo-helm"` | |
| `argocd_values` | `list(string)` | `[]` | |
| `manifest_files` | `list(object({ location, content, template_map, namespace }))` | `[]` | Additional manifests applied after the Helm releases - RBAC, EventSource/Sensor definitions, ArgoCD Application/AppProject objects. `namespace`, if set, overrides every object's embedded `metadata.namespace` |
| `install_external_secrets` | `bool` | `true` | |
| `eso_role_arn` | `string` | `null` | IRSA role ARN for ESO's own controller ServiceAccount, from the `cluster` module's `eso_role_arn` output. Required when `install_external_secrets` is true |
| `eso_chart_version` | `string` | `null` | |
| `eso_helm_repo` | `string` | `"https://charts.external-secrets.io"` | |
| `eso_namespace` | `string` | `"external-secrets"` | |
| `kubectl_manifest_files` | `list(object({ location, content, template_map, namespace }))` | `[]` | Manifests applied via the `alekc/kubectl` provider - required for anything backed by a CRD installed in this same apply |
| `rendered_manifest_files` | `map(object({ file_name, content }))` | `{}` | Writes each entry's content to `<module_path>/.rendered/<file_name>`, for inspection only - never applied to the cluster |

## Outputs

None.

## Example

```hcl
module "apps" {
  source = "git::https://github.com/wso2/aws-terraform-modules.git//modules/aws/Argo-EKS-DataPlane/apps?ref=v1.0.0"

  namespaces     = ["argo-aws-stage", "argo-aws-prod"]
  install_argocd = true

  argo_workflows_values = [<<-EOT
    controller:
      serviceAccount:
        annotations:
          eks.amazonaws.com/role-arn: ${module.cluster.workflow_controller_artifacts_role_arn}
    artifactRepository:
      archiveLogs: true
      s3:
        bucket: ${module.cluster.artifact_bucket_name}
        endpoint: s3.amazonaws.com
        region: us-east-1
        useSDKCreds: true
  EOT
  ]

  install_external_secrets = true
  eso_role_arn              = module.cluster.eso_role_arn

  depends_on = [module.cluster]
}
```
