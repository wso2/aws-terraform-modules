# AWS Orphan Resource Scanner

A serverless Lambda that scans one or more AWS accounts weekly and emails a report
of orphaned resources (unused EBS volumes, idle NAT Gateways, empty S3 buckets, and
more). It scans the **hub** account it's deployed into, and any other accounts via a
read-only cross-account role.

## Prerequisites

- Terraform **1.3.8+**, AWS CLI **v2**
- AWS credentials for the **hub** account (Lambda, IAM, S3, SES, EventBridge, SSM)
- A sender email **verified in SES** (in sandbox mode, verify recipients too)

## Usage

**1. Reference the module** and set the inputs:

```hcl
module "orphan_scanner" {
  source = "github.com/wso2/aws-terraform-modules//modules/aws/Orphan-Resource-Scanner"

  project                = "aws-orphan-scanner"
  deployment_layer       = "scanner"
  deployment_environment = "rnd"
  account_name           = "my-hub-account"          # label shown in tags / report
  report_bucket_name     = "my-org-orphan-reports"   # globally-unique, lowercase S3 bucket
  sender_email           = "alerts@example.com"      # SES-verified sender
  recipient_emails       = "team@example.com"        # comma-separated recipients

  scan_hub_account = true   # scan the account the Lambda runs in
  target_role_arns = []     # read-only role ARNs in other accounts (empty = hub-only)
}
```

Credentials come from your standard AWS provider configuration (profile or environment).
See [variables.tf](variables.tf) for the full list of optional inputs (schedule,
retention, Lambda sizing, tags, etc.).

**2. Deploy:**
```bash
terraform init
terraform apply
```

**3. Run it** (the weekly schedule is automatic; to trigger manually):
```bash
aws lambda invoke --region us-east-1 --cli-read-timeout 900 \
  --function-name $(terraform output -raw lambda_function_name) /tmp/out.json
```
Reports land in the S3 bucket under `weekly/` and are emailed to the recipients.

## Scanning other accounts

In each target account, create a read-only IAM role that:
- **trusts** the hub Lambda role — `terraform output -raw hub_lambda_execution_role_arn`
- **grants** the read policy — `terraform output -raw target_role_policy_json`

Then add its ARN to `target_role_arns` and re-deploy.

## Exclusions

Skip specific resources via `excluded_resource_ids` in the conf (stored in SSM), or
tag the resource `orphan-scan-ignore = true`.
