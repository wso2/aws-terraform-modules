resource "aws_guardduty_detector" "guardduty_detector" {
  enable = var.enable_guardduty
}

resource "aws_guardduty_detector_feature" "eks_runtime_monitoring" {
  count       = var.enable_eks_runtime_monitoring ? 1 : 0
  detector_id = aws_guardduty_detector.guardduty_detector.id
  name        = "EKS_RUNTIME_MONITORING"
  status      = "ENABLED"

  additional_configuration {
    name   = "EKS_ADDON_MANAGEMENT"
    status = "ENABLED"
  }
}

#EKS_AUDIT_LOGS
resource "aws_guardduty_detector_feature" "eks_audit_logs" {
  count       = var.enable_eks_audit_logs ? 1 : 0
  detector_id = aws_guardduty_detector.guardduty_detector.id
  name        = "EKS_AUDIT_LOGS"
  status      = "ENABLED"
}

#RUNTIME_MONITORING
resource "aws_guardduty_detector_feature" "runtime_monitoring" {
  count       = var.enable_runtime_monitoring ? 1 : 0
  detector_id = aws_guardduty_detector.guardduty_detector.id
  name        = "RUNTIME_MONITORING"
  status      = "ENABLED"

  additional_configuration {
    name   = "EKS_ADDON_MANAGEMENT"
    status = "ENABLED"
  }
  additional_configuration {
    name   = "EC2_AGENT_MANAGEMENT"
    status = "ENABLED"
  }
}

resource "aws_guardduty_detector_feature" "s3_data_events" {
  count       = var.enable_s3_data_events ? 1 : 0
  detector_id = aws_guardduty_detector.guardduty_detector.id
  name        = "S3_DATA_EVENTS"
  status      = "ENABLED"
}

resource "aws_guardduty_detector_feature" "lambda_network_logs" {
  count       = var.enable_lambda_network_logs ? 1 : 0
  detector_id = aws_guardduty_detector.guardduty_detector.id
  name        = "LAMBDA_NETWORK_LOGS"
  status      = "ENABLED"
}

resource "aws_guardduty_detector_feature" "rds_login_events" {
  count       = var.enable_rds_login_events ? 1 : 0
  detector_id = aws_guardduty_detector.guardduty_detector.id
  name        = "RDS_LOGIN_EVENTS"
  status      = "ENABLED"
}

#EBS_MALWARE_PROTECTION
resource "aws_guardduty_detector_feature" "ebs_malware_protection" {
  count       = var.enable_ebs_malware_protection ? 1 : 0
  detector_id = aws_guardduty_detector.guardduty_detector.id
  name        = "EBS_MALWARE_PROTECTION"
  status      = "ENABLED"
}
