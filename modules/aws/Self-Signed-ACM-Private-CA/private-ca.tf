# -------------------------------------------------------------------------------------
#
# Copyright (c) 2023, WSO2 LLC. (http://www.wso2.com). All Rights Reserved.
#
# This software is the property of WSO2 LLC. and its suppliers, if any.
# Dissemination of any information or reproduction of any material contained
# herein in any form is strictly forbidden, unless permitted by WSO2 expressly.
# You may not alter or remove any copyright or other notice from copies of this content.
#
# --------------------------------------------------------------------------------------

data "aws_partition" "current" {}

resource "aws_acmpca_certificate" "acmpca_certificate" {
  certificate_authority_arn   = aws_acmpca_certificate_authority.acmpca_certificate_authority.arn
  certificate_signing_request = aws_acmpca_certificate_authority.acmpca_certificate_authority.certificate_signing_request
  signing_algorithm           = var.signing_algorithm

  template_arn = "arn:${data.aws_partition.current.partition}:acm-pca:::template/RootCACertificate/V1"

  validity {
    type  = var.validity_unit
    value = var.validity
  }
}

resource "aws_acmpca_certificate_authority_certificate" "acmpca_certificate_authority_certificate" {
  certificate_authority_arn = aws_acmpca_certificate_authority.acmpca_certificate_authority.arn

  certificate       = aws_acmpca_certificate.acmpca_certificate.certificate
  certificate_chain = aws_acmpca_certificate.acmpca_certificate.certificate_chain
}

resource "aws_acmpca_certificate_authority" "acmpca_certificate_authority" {

  type = var.type

  certificate_authority_configuration {
    key_algorithm     = var.key_algorithm
    signing_algorithm = var.signing_algorithm

    subject {
      common_name         = var.common_name
      state               = var.state
      country             = var.country
      locality            = var.locality
      organization        = var.organization
      organizational_unit = var.organizational_unit
    }
  }

  permanent_deletion_time_in_days = var.permanent_deletion_time_in_days

  tags = var.tags
}