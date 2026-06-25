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

**1. Configure** — edit `terraform/aws/conf/rnd/orphan-scanner.rnd.conf.tfvars`:

| Variable | What to put |
|---|---|
| `account_name` / `hub_account_name` | labels shown in tags / report |
| `report_bucket_name` | globally-unique, **lowercase** S3 bucket name |
| `sender_email` / `recipient_emails` | SES-verified sender / comma-separated recipients |
| `scan_hub_account` | `true` to scan the account the Lambda runs in |
| `target_role_arns` | read-only role ARNs in other accounts (leave empty for hub-only) |

**2. Add the secrets file:**
```bash
cp terraform/aws/conf/rnd/orphan-scanner.rnd.conf.secrets.tfvars.sample \
   terraform/aws/conf/rnd/orphan-scanner.rnd.conf.secrets.tfvars
# set aws_profile (or leave "" for default credentials)
```

**3. Deploy:**
```bash
bash env-create.sh -c terraform/aws/conf/rnd/orphan-scanner.rnd.conf.tfvars -l scanner
```

**4. Run it** (the weekly schedule is automatic; to trigger manually):
```bash
cd terraform/aws/deployments/scanner
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
