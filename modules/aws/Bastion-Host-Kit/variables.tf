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

variable "project" {
  type        = string
  description = "Name of the project"
}

variable "application" {
  type        = string
  description = "Purpose of the bastion, part of every resource name (e.g. cp)"
}

variable "environment" {
  type        = string
  description = "Name of the environment"
}

variable "region" {
  type        = string
  description = "Code of the region, used in names"
}

variable "vpc_id" {
  type        = string
  description = "VPC the bastion is placed in"
}

variable "subnet_id" {
  type        = string
  description = "A private subnet: the bastion has no public address and is reached only through Session Manager"
}

variable "instance_type" {
  type        = string
  description = "Instance type. One operator at a time running terraform, kubectl and helm needs no more than t3.small"
  default     = "t3.small"
}

variable "ami_id" {
  type        = string
  description = "AMI. Empty resolves the latest Amazon Linux 2023 through its public SSM parameter, which ships the SSM agent and the AWS CLI"
  default     = ""
}

variable "root_volume_size" {
  type        = number
  description = "Root volume size in GiB"
  default     = 30
}

variable "operator_emails" {
  type        = list(string)
  description = "The people who may open a session. Each gets an OS user named from the local part of the address and a session document that runs the session as that user, so the transcript is attributable before any command is typed. Restricting each operator to their own document is the caller's IAM policy (see the session_document comment)"

  validation {
    condition     = length(distinct([for e in var.operator_emails : split("@", e)[0]])) == length(var.operator_emails)
    error_message = "Two operators share a local part; the OS user and session document are named from it, so local parts must be distinct."
  }

  validation {
    condition     = alltrue([for e in var.operator_emails : can(regex("^[a-z][a-z0-9_-]{0,30}$", split("@", e)[0]))])
    error_message = "A local part must be a valid Linux user name: lowercase, starting with a letter, up to 31 characters of [a-z0-9_-]."
  }

  validation {
    condition     = length(setintersection(toset([for e in var.operator_emails : split("@", e)[0]]), toset(["root", "ec2-user", "ssm-user", "admin", "nobody", "sync", "shutdown", "halt", "daemon", "bin", "sys", "adm", "operator", "games", "ftp", "mail", "systemd-network", "dbus", "sshd", "chrony", "rpc", "rpcuser", "tss"]))) == 0
    error_message = "A local part collides with a system account; a session document must never run as one."
  }
}

variable "user_data" {
  type        = string
  description = "Shell script the project wants run on its bastion (tool installation and the like), delivered as a State Manager association: it runs as root when the association is created and again whenever the script changes, with no reboot and no session lost; a replaced instance receives it as a new target. It must be safe to repeat, and installs must be atomic (download, then install), because it may run while operators are working. Empty means no association"
  default     = ""
}

variable "suspension" {
  type = object({
    enabled            = bool
    timezone           = optional(string, "UTC")
    suspend_expression = optional(string, "cron(0 20 ? * MON-FRI *)")
    resume_expression  = optional(string, "cron(0 7 ? * MON-FRI *)")
  })
  description = "Stop the bastion outside working hours and start it again (EventBridge Scheduler cron expressions, evaluated in timezone). Stopping ends every session on it. Disabled by default"
  default = {
    enabled = false
  }
}

variable "session_log_retention_days" {
  type        = number
  description = "How long session transcripts stay in CloudWatch Logs"
  default     = 365
}

variable "session_idle_timeout_minutes" {
  type        = number
  description = "Idle minutes before a session is ended"
  default     = 20
}

variable "session_max_duration_minutes" {
  type        = number
  description = "Longest a single session may last"
  default     = 480
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to every resource"
  default     = {}
}
