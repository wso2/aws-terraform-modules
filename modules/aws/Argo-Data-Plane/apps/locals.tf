# -------------------------------------------------------------------------------------
#
# Copyright (c) 2026, WSO2 LLC. (https://www.wso2.com) All Rights Reserved.
#
# WSO2 LLC. licenses this file to you under the Apache License,
# Version 2.0 (the "License"); you may not use this file except
# in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied. See the License for the
# specific language governing permissions and limitations
# under the License.
#
# --------------------------------------------------------------------------------------

locals {
  # kubectl_manifest: kubernetes_manifest doesn't work reliably with exec auth.
  # Documents are keyed by what they are (<kind>/<namespace>/<name>, "_" for
  # cluster-scoped), not by their position in the list. A positional key
  # shifts when a manifest is added or removed, and Terraform then deletes
  # and recreates every object after it.
  manifest_documents = flatten([
    for idx, m in var.manifest_files : [
      for doc_idx, doc in [
        for chunk in split("\n---\n", "\n${m.content != null ? m.content : templatefile(m.location, m.template_map)}") : chunk
        if trimspace(chunk) != ""
        ] : {
        key = try(join("/", [
          yamldecode(doc).kind,
          coalesce(try(m.namespace, null), try(yamldecode(doc).metadata.namespace, null), "_"),
          yamldecode(doc).metadata.name,
        ]), "${idx}-${doc_idx}")
        body        = doc
        is_sa_token = try(yamldecode(doc).type, "") == "kubernetes.io/service-account-token"
        namespace   = m.namespace
      }
    ]
  ])

  kubectl_manifest_documents = flatten([
    for idx, m in var.kubectl_manifest_files : [
      for doc_idx, doc in [
        for chunk in split("\n---\n", "\n${m.content != null ? m.content : templatefile(m.location, m.template_map)}") : chunk
        if trimspace(chunk) != ""
        ] : {
        key = try(join("/", [
          yamldecode(doc).kind,
          coalesce(try(m.namespace, null), try(yamldecode(doc).metadata.namespace, null), "_"),
          yamldecode(doc).metadata.name,
        ]), "${idx}-${doc_idx}")
        body        = doc
        is_sa_token = try(yamldecode(doc).type, "") == "kubernetes.io/service-account-token"
        namespace   = m.namespace
      }
    ]
  ])

  # One entry per tiered namespace, carrying the namespaces of every other
  # tier - those are the ones its NetworkPolicy keeps out.
  tier_namespaces = merge([
    for tier, namespaces in var.namespace_tiers : {
      for ns in namespaces : ns => flatten([
        for other_tier, other_namespaces in var.namespace_tiers : other_namespaces if other_tier != tier
      ])
    }
  ]...)
}
