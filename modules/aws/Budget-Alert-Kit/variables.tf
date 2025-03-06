variable "cost" {
  type        = number
  description = "Total monthly budget amount in USD"
}

variable "tag_key" {
  type        = string
  description = "Tag key used to identify Choreo PDP resources"
  default     = "Managed-By"
}

variable "tag_value" {
  type        = string
  description = "Tag value used to identify Choreo PDP resources"
  default     = "Choreo-PDP-Terraform-Bot"
}

variable "critical_sns_arn" {
  type        = string
  description = "ARN for critical alerts SNS topic"
}

variable "warning_sns_arn" {
  type        = string
  description = "ARN for warning alerts SNS topic"
}

variable "ec2_percentage" {
  type        = number
  description = "Percentage of total cost allocated for EC2 instances"
  default     = 60
}

variable "logs_percentage" {
  type        = number
  description = "Percentage of total cost allocated for Cloudwatcg"
  default     = 20
}

variable "networking_percentage" {
  type        = number
  description = "Percentage of total cost allocated for networking"
  default     = 20
}
