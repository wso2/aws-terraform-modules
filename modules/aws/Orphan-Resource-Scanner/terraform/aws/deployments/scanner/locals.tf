# -------------------------------------------------------------------------------------
#
# Copyright (c) 2026, WSO2 LLC. (https://www.wso2.com) All Rights Reserved.
#
# WSO2 LLC. licenses this file to you under the Apache License,
# Version 2.0 (the "License"); you may not use this file except
# in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied. See the License for the
# specific language governing permissions and limitations
# under the License.
#
# --------------------------------------------------------------------------------------

locals {
  project     = var.project
  application = var.deployment_layer
  environment = var.deployment_environment

  # Resource-name building blocks (project-application-environment-region).
  iam_name_head = "${local.project}-${local.application}"         # aws-orphan-scanner-scanner
  iam_name_tail = "${local.environment}-${var.aws_region}"        # rnd-us-east-1
  name_prefix   = "${local.iam_name_head}-${local.iam_name_tail}" # aws-orphan-scanner-scanner-rnd-us-east-1

  # Suffix inserted into the Lambda resource names.
  lambda_function_name = "fn"

  # Read-only actions the scanner needs. Used by the hub's discovery policy and
  # emitted via the target_role_policy_json output for target-account roles.
  discovery_actions = [
    # EC2 / VPC
    "ec2:DescribeRegions",
    "ec2:DescribeVolumes",
    "ec2:DescribeAddresses",
    "ec2:DescribeNetworkInterfaces",
    "ec2:DescribeSecurityGroups",
    "ec2:DescribeNatGateways",
    "ec2:DescribeRouteTables",
    "ec2:DescribeSnapshots",
    "ec2:DescribeImages",
    "ec2:DescribeInstances",

    # Elastic Load Balancing
    "elasticloadbalancing:DescribeTargetGroups",
    "elasticloadbalancing:DescribeTargetHealth",
    "elasticloadbalancing:DescribeLoadBalancers",
    "elasticloadbalancing:DescribeListeners",
    "elasticloadbalancing:DescribeTags",

    # RDS
    "rds:DescribeDBInstances",
    "rds:ListTagsForResource",

    # Lambda
    "lambda:ListFunctions",
    "lambda:ListTags",

    # CloudWatch (metric statistics only - used by the EC2/Lambda idle checks)
    "cloudwatch:GetMetricStatistics",

    # CloudWatch Logs
    "logs:DescribeLogGroups",

    # ECR
    "ecr:DescribeRepositories",
    "ecr:DescribeImages",
    "ecr:ListTagsForResource",

    # ECS
    "ecs:ListClusters",
    "ecs:DescribeClusters",

    # SNS
    "sns:ListTopics",
    "sns:ListSubscriptionsByTopic",
    "sns:ListTagsForResource",

    # S3
    "s3:ListAllMyBuckets",
    "s3:ListBucket",
    "s3:GetBucketLocation",
    "s3:GetBucketTagging",

    # Route53
    "route53:ListHostedZones",
    "route53:ListResourceRecordSets",

    # EKS
    "eks:ListClusters",
    "eks:DescribeCluster",
    "eks:ListNodegroups",
    "eks:ListFargateProfiles",

    # EFS
    "elasticfilesystem:DescribeFileSystems",
    "elasticfilesystem:DescribeMountTargets",

    # IAM (global)
    "iam:ListPolicies",
    "iam:ListPolicyTags",
    "iam:ListRoles",
    "iam:GetRole",

    # STS
    "sts:GetCallerIdentity",
  ]

  # Cross-account role ARNs the Lambda assumes into.
  effective_target_role_arns = var.target_role_arns

  # True when at least one target exists. Gates the assume-target policy.
  has_target = length(local.effective_target_role_arns) > 0

  # Policies attached to the Lambda role (key -> policy JSON; key becomes the
  # policy sub-name). assume-target is added only when a target is configured.
  lambda_policies = merge(
    {
      "s3-write"        = data.aws_iam_policy_document.allow_s3_write.json
      "ses-send"        = data.aws_iam_policy_document.allow_ses_send.json
      "discovery"       = data.aws_iam_policy_document.allow_orphan_discovery.json
      "read-exclusions" = data.aws_iam_policy_document.allow_read_exclusions_param.json
    },
    local.has_target ? {
      "assume-target" = data.aws_iam_policy_document.allow_assume_target_role[0].json
    } : {}
  )

  tags = {
    Project     = local.project
    Environment = local.environment
    AccountName = var.account_name
    ManagedBy   = "terraform"
  }
}
