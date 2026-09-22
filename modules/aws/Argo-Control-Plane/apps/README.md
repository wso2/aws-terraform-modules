# Argo-Control-Plane/apps

Installs the Kubernetes-level workload the Argo control plane actually
runs: NATS (the mTLS message bus every data plane dials into for
dispatch), Argo Workflows/Events (the dispatcher itself), cert-manager
(bootstraps the NATS client-CA and issues per-identity client certs),
Traefik (the portal gateway), and External Secrets Operator.

This module assumes the caller has already configured the
`kubernetes`/`helm`/`kubectl` providers against the cluster built by the
sibling [`../cluster`](../cluster) module. It does not take cluster
credentials as input - it inherits the providers implicitly, like any
other Terraform child module.

## What it provisions

- The primary namespace (`var.namespace`, default `"argo"`) plus any extra
  namespaces and ConfigMaps the caller supplies - e.g. for components that
  live alongside Argo but aren't part of its own Helm release, such as
  oauth2-proxy, gateway, or dispatch-tier namespaces.
- Per-identity SSH keypairs (`tls_private_key`) for the reverse-tunnel
  clients, and a `tunnel-server-authorized-keys` Secret built from them,
  if `tunnel_client_identities` is non-empty.
- cert-manager (opt-in via `install_cert_manager`) plus a self-signed
  bootstrap `Issuer`, a `nats-client-ca` `Certificate`/`ClusterIssuer`, a
  `nats-server-cert` `Certificate`, and one client `Certificate` per entry
  in `nats_client_identities`. This is the mTLS PKI every data plane's
  NATS connection depends on.
- A `gp3` `StorageClass` (default), backed by the EBS CSI driver addon the
  `cluster` module installs.
- Helm releases for `nats`, `argo-workflows`, `argo-events`, and (opt-in)
  `traefik` and `external-secrets`.
- Arbitrary caller-supplied Kubernetes manifests, in two flavors: plain
  `manifest_files` (via the `alekc/kubectl` provider, not
  `kubernetes_manifest` - see the module's own header comment on why) and
  `kubectl_manifest_files` for anything backed by a CRD installed in the
  same apply (e.g. External Secrets Operator's `ClusterSecretStore`).

## Notes

- Every data plane connects to this NATS broker over its own external
  LoadBalancer hostname, not an internal cluster name. If you don't add
  that hostname to `nats_server_external_dns_names`, cross-cluster mTLS
  fails x509 SAN verification.
- If the gateway's backends are `ExternalName` Services, set
  `providers.kubernetesCRD.allowExternalNameServices: true` in
  `traefik_values`. Traefik otherwise silently drops the whole
  `IngressRoute`.
- `argo_workflows_values` should set `workflow-controller` `replicas>=2`
  with leader election for HA.
- `nats_values` should set JetStream `replicas=3` with pod
  anti-affinity/topology spread across AZs, and a PVC-backed persistent
  store.

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `namespace` | `string` | `"argo"` | Namespace for the control plane's Argo Workflows + Argo Events release |
| `extra_namespaces` | `list(string)` | `[]` | Additional namespaces to create beyond `namespace` |
| `config_maps` | `map(object({ namespace, data }))` | `{}` | ConfigMaps to create before `manifest_files`/`kubectl_manifest_files` are applied, e.g. scripts a Deployment in `manifest_files` mounts. Map key is the ConfigMap name |
| `tunnel_client_identities` | `list(string)` | `[]` | One reverse-tunnel SSH keypair per data-plane identity, e.g. `["aws", "azure"]`. Resulting private keys come back via `tunnel_client_private_keys` for manual, out-of-band distribution |
| `argo_workflows_chart_version` | `string` | `null` | |
| `argo_events_chart_version` | `string` | `null` | |
| `nats_chart_version` | `string` | `null` | |
| `argo_helm_repo` | `string` | `"https://argoproj.github.io/argo-helm"` | |
| `nats_helm_repo` | `string` | `"https://nats-io.github.io/k8s/helm/charts/"` | |
| `argo_workflows_values` | `list(string)` | `[]` | Helm values overrides (YAML strings, later entries win). See Notes above |
| `argo_events_values` | `list(string)` | `[]` | Helm values overrides (YAML strings, later entries win) for argo-events |
| `nats_values` | `list(string)` | `[]` | Helm values overrides (YAML strings, later entries win) for the nats chart. See Notes above |
| `install_cert_manager` | `bool` | `true` | Installs cert-manager and bootstraps a private client-CA for NATS mTLS |
| `cert_manager_chart_version` | `string` | `null` | |
| `cert_manager_helm_repo` | `string` | `"https://charts.jetstack.io"` | |
| `cert_manager_namespace` | `string` | `"cert-manager"` | |
| `install_traefik` | `bool` | `true` | Installs the Traefik controller. The portal gateway's `IngressRoute`/`Middleware`/`ServersTransport` CRDs need a running Traefik controller to register them |
| `traefik_chart_version` | `string` | `null` | |
| `traefik_helm_repo` | `string` | `"https://traefik.github.io/charts"` | |
| `traefik_values` | `list(string)` | `[]` | Helm values overrides for traefik. See Notes above |
| `traefik_namespace` | `string` | `"gateway"` | |
| `nats_server_external_dns_names` | `list(string)` | `[]` | Extra `dnsNames` for the `nats-server-cert` `Certificate`, beyond the two internal cluster-DNS names it already gets. See Notes above |
| `nats_client_identities` | `list(string)` | `[]` | `commonName` for each data-plane NATS client certificate cert-manager issues, e.g. `["azure-stage", "aws-prod"]`. One `Certificate` per entry, resulting in a Secret named `nats-client-<entry>` in `namespace`, readable via `nats_client_cert_pems`/`nats_client_key_pems` |
| `manifest_files` | `list(object({ location, content, template_map }))` | `[]` | Additional Kubernetes manifests to apply - dispatch-namespace RBAC, the SSO gateway, Ingress/Service for the real Load Balancer. Content and ordering are entirely caller-supplied |
| `install_external_secrets` | `bool` | `true` | Installs External Secrets Operator |
| `eso_role_arn` | `string` | `null` | IRSA role ARN for ESO's own controller ServiceAccount, from the `cluster` module's `eso_role_arn` output. Required when `install_external_secrets` is true |
| `eso_chart_version` | `string` | `null` | |
| `eso_helm_repo` | `string` | `"https://charts.external-secrets.io"` | |
| `eso_namespace` | `string` | `"external-secrets"` | |
| `kubectl_manifest_files` | `list(object({ location, content, template_map, namespace }))` | `[]` | Manifests applied via the `alekc/kubectl` provider - required for anything backed by a CRD installed in this same apply. `namespace`, if set, overrides every object's own embedded `metadata.namespace` |

## Outputs

| Name | Description |
|---|---|
| `nats_client_cert_pems` | Map of identity to client cert PEM (sensitive) |
| `nats_client_key_pems` | Map of identity to client key PEM (sensitive) |
| `nats_client_ca_pems` | Map of identity to the client-CA's own cert PEM, same value for every identity (sensitive) |
| `tunnel_client_private_keys` | OpenSSH-formatted private key per identity in `tunnel_client_identities`. Copy into that data plane's own `terraform.tfvars` `tunnel_client_private_key` (sensitive) |

## Example

```hcl
module "apps" {
  source = "git::https://github.com/wso2/aws-terraform-modules.git//modules/aws/Argo-Control-Plane/apps?ref=v1.0.0"

  namespace        = "argo"
  extra_namespaces = ["oauth2-proxy", "gateway"]

  install_cert_manager     = true
  nats_client_identities    = ["control-plane", "aws-stage", "aws-prod"]
  tunnel_client_identities  = ["aws"]

  nats_values = [<<-EOT
    config:
      jetstream:
        enabled: true
    statefulSet:
      replicas: 3
  EOT
  ]

  install_external_secrets = true
  eso_role_arn              = module.cluster.eso_role_arn

  depends_on = [module.cluster]
}
```
