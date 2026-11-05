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

resource "aws_acm_certificate" "cert" {
  domain_name = var.domain_name

  key_algorithm = var.key_algorithm

  subject_alternative_names = var.subject_alternative_names

  validation_method = var.validation_method

  validation_option {
    domain_name       = var.domain_name
    validation_domain = var.validation_domain
  }

  tags = var.tags
}