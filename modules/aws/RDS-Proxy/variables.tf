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
  description = "AWS Code of the region"
}

variable "application" {
  type        = string
  description = "Purpose of the DB Subnet group"
}

variable "tags" {
  description = "A mapping of tags to assign to all resources"
  type        = map(string)
  default     = {}
}

variable "engine" {
  description = "The database engine to use"
  type        = string
}

variable "vpc_security_group_ids" {
  description = "List of VPC security groups to associate"
  type        = list(string)
}

variable "role_arn" {
  description = "The Role arn for RDS Proxy assume role"
  type        = string
}

variable "auth_list" {
  type = list(object({
    auth_scheme               = optional(string, "SECRETS")
    iam_auth                  = optional(string, "DISABLED")
    client_password_auth_type = optional(string)
    secret_arn                = optional(string)
    username                  = optional(string, null)
    description               = optional(string, null)
  }))
}

variable "vpc_subnets" {
  description = "vpc subnet ids"
  type        = list(string)
}

variable "require_tls" {
  type        = bool
  default     = true
  description = "Specifies whether TLS is required"
}