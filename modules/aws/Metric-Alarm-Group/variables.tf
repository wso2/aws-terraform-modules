variable "tags" {
  type        = map(string)
  description = "Tags to be attached to the resource"
  default     = {}
}
variable "project" {
  type        = string
  description = "Name of the project"
}
variable "environment" {
  type        = string
  description = "Name of the environment"
}
variable "region" {
  type        = string
  description = "Code of the region"
}
variable "application" {
  type        = string
  description = "Purpose of the Subnet"
}
variable "globally_enabled" {
  type        = bool
  description = "Whether the metric alarms are globally enabled"
  default     = true
}
variable "dimensions" {
  type        = map(string)
  description = "Dimensions for the metric alarms"
}
variable "metric_alarms" {
  type = map(object({
    metric_name         = string
    comparison_operator = string
    threshold           = number
    evaluation_periods  = number
    period              = number
    statistic           = string
    priority            = string
    enabled             = optional(bool, true)
  }))
  description = "Map of metric alarms with their configurations"
}
variable "critical_alarm_actions" {
  type        = list(string)
  description = "Actions to take when a critical alarm is triggered"
  default     = []
}
variable "warning_alarm_actions" {
  type        = list(string)
  description = "Actions to take when a warning alarm is triggered"
  default     = []
}
variable "info_alarm_actions" {
  type        = list(string)
  description = "Actions to take when an info alarm is triggered"
  default     = []
}
variable "ok_alarm_actions" {
  type        = list(string)
  description = "Actions to take when the alarm state is OK"
  default     = []
}
variable "insufficient_data_actions" {
  type        = list(string)
  description = "Actions to take when there is insufficient data for the alarm"
  default     = []
}
variable "metric_namespace" {
  type        = string
  description = "The namespace for the CloudWatch metrics"
}
variable "resource_infix" {
  type        = string
  description = "Infix to be used in the metric usage prefix"
}
variable "resource_description" {
  type        = string
  description = "Description of the resource for which the metrics are being monitored"
}