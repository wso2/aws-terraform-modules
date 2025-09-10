variable "sns_arn" {
  description = "The ARN of the SNS topic to subscribe to."
  type        = string
}
variable "function_arn" {
  description = "The ARN of the Lambda function to be invoked."
  type        = string
}
variable "function_name" {
  description = "The name of the Lambda function to be invoked."
  type        = string
}
