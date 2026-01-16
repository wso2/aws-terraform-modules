# -------------------------------------------------------------------------------------
#
# Copyright (c) 2025, WSO2 LLC. (http://www.wso2.com). All Rights Reserved.
#
# This software is the property of WSO2 LLC. and its suppliers, if any.
# Dissemination of any information or reproduction of any material contained
# herein in any form is strictly forbidden, unless permitted by WSO2 expressly.
# You may not alter or remove any copyright or other notice from copies of this content.
#
# --------------------------------------------------------------------------------------

variable "name" {
  description = "The name of the query definition"
  type        = string
}

variable "log_group_names" {
  description = "List of CloudWatch Log Group names to query"
  type        = list(string)
}

variable "query_string" {
  description = "The CloudWatch Logs Insights query string"
  type        = string
}
