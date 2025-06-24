variable "enable_guardduty" {
  description = "Enable AWS GuardDuty"
  type        = bool
  default     = true
}
variable "enable_s3_data_events" {
  description = "Enable S3 data events for GuardDuty"
  type        = bool
  default     = true
}
variable "enable_eks_runtime_monitoring" {
  description = "Enable EKS runtime monitoring for GuardDuty"
  type        = bool
  default     = false
}
variable "enable_eks_audit_logs" {
  description = "Enable EKS audit logs for GuardDuty"
  type        = bool
  default     = true
}
variable "enable_runtime_monitoring" {
  description = "Enable runtime monitoring for GuardDuty"
  type        = bool
  default     = true
}
variable "enable_lambda_network_logs" {
  description = "Enable Lambda network logs for GuardDuty"
  type        = bool
  default     = true
}
variable "enable_ebs_malware_protection" {
  description = "Enable EBS malware protection for GuardDuty"
  type        = bool
  default     = true
}
variable "enable_rds_login_events" {
  description = "Enable RDS login events for GuardDuty"
  type        = bool
  default     = true
}
