# Give SNS permission to invoke the Lambda function
resource "aws_lambda_permission" "sns_lambda_permission" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = var.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = var.sns_arn
}

# Subscribe the Lambda function to the SNS topic
resource "aws_sns_topic_subscription" "lambda_subscription" {
  topic_arn = var.sns_arn
  protocol  = "lambda"
  endpoint  = var.function_arn
}
