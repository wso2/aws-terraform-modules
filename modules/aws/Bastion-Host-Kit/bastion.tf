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

# A jump host reached only through Session Manager: no inbound rule, no public
# address, no SSH key. Every session belongs to a named person -- CloudTrail
# records StartSession with the caller's identity, and a per-operator session
# document runs the shell as that operator's OS user while streaming the whole
# transcript to a KMS-encrypted log group. The instance role can register with
# SSM and nothing else; whatever an operator reaches from here, they reach
# with their own AWS credentials.

data "aws_ssm_parameter" "al2023" {
  count = var.ami_id == "" ? 1 : 0
  name  = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

module "security_group" {
  source = "../Security-Group"

  project     = var.project
  application = "${var.application}-bastion"
  environment = var.environment
  region      = var.region
  vpc_id      = var.vpc_id
  description = "Bastion: no inbound; egress only"
  tags        = var.tags
  rules = [{
    direction       = "egress"
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    security_groups = []
  }]
}

module "instance" {
  source = "../EC2-Instance"

  project     = var.project
  application = "${var.application}-bastion"
  environment = var.environment
  region      = var.region
  tags        = var.tags

  ec2_vpc_id                   = var.vpc_id
  use_existing_subnet          = true
  vpc_subnet_id                = var.subnet_id
  ip_address_allocation_method = "Dynamic"
  ip_type                      = "Private"
  security_group_ids           = [module.security_group.security_group_id]

  ec2_ami           = var.ami_id != "" ? var.ami_id : data.aws_ssm_parameter.al2023[0].value
  ec2_instance_type = var.instance_type
  root_volume_size  = var.root_volume_size
  imds_enabled      = "required"

  enable_session_manager  = true
  enable_instance_connect = false
  add_ssh_key             = false

  # Static on purpose: a user_data change stops and starts the instance, which
  # ends every session on it. Anything that may change is an association below.
  user_data = file("${path.module}/scripts/user-data.sh.tftpl")
}

# Run Command and State Manager need more than the Session Manager policy the
# EC2-Instance module attaches.
resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = module.instance.ec2-instance-role-name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Configuration that may change is delivered by State Manager, not user data:
# an association runs when created, at every instance start, and whenever its
# content changes -- with no reboot, so the sessions on the bastion and any
# terraform apply running in them survive a change. Two associations: the
# kit's (operator users) and the caller's (var.user_data: tools and the like).
# Both scripts must be safe to repeat, and a tool install must be atomic
# (download to a temporary file, then install) so a binary in use by a running
# process is never overwritten underneath it.
resource "aws_ssm_association" "operators" {
  name             = "AWS-RunShellScript"
  association_name = "${local.name_prefix}-bastion-operators"

  targets {
    key    = "InstanceIds"
    values = [module.instance.ec2-instance-id]
  }

  parameters = {
    commands = templatefile("${path.module}/scripts/operators.sh.tftpl", { operators = keys(local.operators) })
  }

  compliance_severity = "HIGH"

  depends_on = [aws_iam_role_policy_attachment.ssm_core]
}

resource "aws_ssm_association" "caller" {
  count = var.user_data == "" ? 0 : 1

  name             = "AWS-RunShellScript"
  association_name = "${local.name_prefix}-bastion-provisioning"

  targets {
    key    = "InstanceIds"
    values = [module.instance.ec2-instance-id]
  }

  parameters = {
    commands = var.user_data
  }

  compliance_severity = "MEDIUM"

  depends_on = [aws_ssm_association.operators]
}

# The session document requires an encrypted log group; the group gets its own
# key, usable by the CloudWatch Logs service for this group only.
module "session_log_key" {
  source = "../Customer-Managed-Key"

  project             = var.project
  application         = "${var.application}-bastion-sessions"
  environment         = var.environment
  region              = var.region
  description         = "Bastion session transcripts for ${local.name_prefix}"
  alias_name          = "${local.name_prefix}-bastion-sessions"
  enable_key_rotation = true
  tags                = var.tags
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AccountAdministration"
        Effect    = "Allow"
        Principal = { AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root" }
        Action    = "kms:*"
        Resource  = "*"
      },
      {
        Sid       = "CloudWatchLogsForThisGroup"
        Effect    = "Allow"
        Principal = { Service = "logs.${data.aws_region.current.name}.amazonaws.com" }
        Action    = ["kms:Encrypt*", "kms:Decrypt*", "kms:ReEncrypt*", "kms:GenerateDataKey*", "kms:Describe*"]
        Resource  = "*"
        Condition = {
          ArnLike = {
            "kms:EncryptionContext:aws:logs:arn" = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:${local.log_group}"
          }
        }
      }
    ]
  })
}

module "session_logs" {
  source = "../Cloud-Watch-Log-Group"

  log_group_name    = local.log_group
  retention_in_days = var.session_log_retention_days
  kms_key_id        = module.session_log_key.key_arn
  tags              = var.tags
}

# One document per operator, <local-part>-session-manager-doc, running as that
# OS user.
module "session_document" {
  source   = "../SSM-Document"
  for_each = local.operators

  user_email             = each.value
  cloud_watch_group_name = module.session_logs.log_group_name
  session_timeout        = var.session_idle_timeout_minutes
  max_session_duration   = var.session_max_duration_minutes

  depends_on = [module.session_logs]
}
