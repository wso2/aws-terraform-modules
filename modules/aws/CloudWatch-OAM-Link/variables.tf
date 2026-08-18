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

variable "sink_identifier" {
  description = "ARN of the OAM sink in the central monitoring account to link this account to."
  type        = string
}
variable "resource_types" {
  description = "Telemetry resource types to share with the monitoring account. Valid values: AWS::Logs::LogGroup, AWS::CloudWatch::Metric, AWS::XRay::Trace, AWS::ApplicationInsights::Application, AWS::InternetMonitor::Monitor."
  type        = list(string)
  default     = ["AWS::Logs::LogGroup"]
}
variable "label_template" {
  description = "Template for the label shown for this source account in the monitoring account. Supports $AccountName, $AccountEmail and $AccountEmailNoDomain placeholders."
  type        = string
  default     = "$AccountName"
}
variable "log_group_filter" {
  description = "Optional filter expression selecting which log groups are shared, e.g. \"LogGroupName LIKE '/aws/eks/%'\". Requires AWS::Logs::LogGroup in resource_types. When null, all log groups are shared."
  type        = string
  default     = null
}
variable "metric_filter" {
  description = "Optional filter expression selecting which metric namespaces are shared, e.g. \"Namespace IN ('AWS/EKS', 'ContainerInsights')\". Requires AWS::CloudWatch::Metric in resource_types. When null, all metrics are shared."
  type        = string
  default     = null
}
variable "tags" {
  description = "Default tags for resources."
  type        = map(string)
  default     = {}
}
