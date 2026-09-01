# -------------------------------------------------------------------------------------
#
# Copyright (c) 2026, WSO2 LLC. (http://www.wso2.com). All Rights Reserved.
#
# This software is the property of WSO2 LLC. and its suppliers, if any.
# Dissemination of any information or reproduction of any material contained
# herein in any form is strictly forbidden, unless permitted by WSO2 expressly.
# You may not alter or remove any copyright or other notice from copies of this content.
#
# --------------------------------------------------------------------------------------

output "nats_client_cert_pems" {
  value = {
    for identity in var.nats_client_identities :
    identity => try(data.kubernetes_secret_v1.nats_client_certificate[identity].data["tls.crt"], null)
  }
  sensitive = true
}

output "nats_client_key_pems" {
  value = {
    for identity in var.nats_client_identities :
    identity => try(data.kubernetes_secret_v1.nats_client_certificate[identity].data["tls.key"], null)
  }
  sensitive = true
}

output "nats_client_ca_pems" {
  value = {
    for identity in var.nats_client_identities :
    identity => try(data.kubernetes_secret_v1.nats_client_certificate[identity].data["ca.crt"], null)
  }
  sensitive = true
}
