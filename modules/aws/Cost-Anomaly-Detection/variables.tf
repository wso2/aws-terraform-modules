variable "monitor_name" {
  description = "Name for the anomaly monitor."
  type        = string
}

variable "monitor_type" {
  description = "Type of anomaly monitor (e.g., DIMENSIONAL, CUSTOM)."
  type        = string
  default     = "DIMENSIONAL"
}

variable "monitor_dimension" {
  description = "Dimension for the anomaly monitor (e.g., SERVICE)."
  type        = string
  default     = "SERVICE"
}

variable "subscription_name" {
  description = "Name for the anomaly subscription."
  type        = string
}

variable "threshold" {
  description = "Threshold for anomaly alerts."
  type        = number
  default     = 100
}

variable "frequency" {
  description = "Notification frequency (e.g., IMMEDIATE, DAILY)."
  type        = string
  default     = "IMMEDIATE"
}

variable "subscriber_type" {
  description = "Type of subscriber (e.g., EMAIL)."
  type        = string
  default     = "EMAIL"
}

variable "subscriber_address" {
  description = "Address for anomaly notifications."
  type        = string
}
