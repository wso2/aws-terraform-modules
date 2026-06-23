# AWS Orphan Resource Scanner - Setup Guide

A serverless Lambda that scans one or more AWS accounts on a weekly schedule and
emails a report of orphaned resources (unused EBS volumes, idle NAT Gateways,
empty S3 buckets, and many other types). All infrastructure is managed with
Terraform and deployed through the `env-create.sh` wrapper.

## How it works

The scanner is deployed into a single **hub** account. From there it can scan:

- **The hub account itself** - using the Lambda's own execution role (`scan_hub_account = true`).
- **Any number of other accounts** - by assuming a read-only IAM role you create
  in each target account and list in `target_role_arns` (the **IAM-ARN approach**).

Each weekly run writes a CSV to the report S3 bucket (under `weekly/`) and emails
an HTML summary to the configured recipients.

---

## Prerequisites

| Tool | Minimum version | Check |
|---|---|---|
| [Terraform](https://developer.hashicorp.com/terraform/install) | 1.10+ | `terraform -version` |
| [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) | v2 | `aws --version` |

You also need an AWS CLI profile (or default credentials) for the **hub** account
with permission to create Lambda, IAM, S3, SES, EventBridge Scheduler, and SSM
resources.

---

## Step 1 - Verify the sender email in SES

The Lambda sends the weekly report from a verified SES email address.

1. Go to **AWS Console → SES → Verified identities** (in the same region as `aws_region`).
2. **Create identity → Email address**, enter the sender address, and click the
   verification link that arrives in that inbox.

> If your SES account is in **sandbox mode**, every *recipient* address must also
> be verified the same way. To send to unverified addresses,
> [request production access](https://docs.aws.amazon.com/ses/latest/dg/request-production-access.html).

---

## Step 2 - Configure the scanner

### 2a. Edit the config file

Open [`terraform/aws/conf/rnd/orphan-scanner.rnd.conf.tfvars`](terraform/aws/conf/rnd/orphan-scanner.rnd.conf.tfvars)
and set the values:

| Variable | What to put |
|---|---|
| `project` | Resource-name prefix (default `aws-orphan-scanner`) |
| `deployment_environment` | e.g. `rnd`, `staging`, `prod` |
| `aws_region` | Region where the scanner resources are deployed |
| `account_name` | Friendly label for the hub account (tagging only) |
| `report_bucket_name` | Name for the S3 report bucket (**must be globally unique**) |
| `sender_email` | The SES-verified sender from Step 1 |
| `recipient_emails` | Comma-separated recipient list |
| `regions` | `""` to auto-discover all enabled regions (recommended), or a comma-separated list to restrict |
| `excluded_resource_ids` | Resource IDs to never report (see [Managing Exclusions](#managing-exclusions)) |
| `scan_hub_account` | `true` to scan the account the Lambda runs in |
| `hub_account_name` | Display name for the hub account in the report |
| `target_role_arns` | Cross-account role ARNs to scan (see [Step 4](#step-4--add-other-accounts-iam-arn-approach)) - leave empty for hub-only |

### 2b. Create the secrets file

```bash
cp terraform/aws/conf/rnd/orphan-scanner.rnd.conf.secrets.tfvars.sample \
   terraform/aws/conf/rnd/orphan-scanner.rnd.conf.secrets.tfvars
```

Open the new file and set `aws_profile` to your hub-account CLI/SSO profile, or
leave it `""` to use your default credentials.

> **Never commit the `.secrets.tfvars` file** - it is gitignored.

---

## Step 3 - Deploy the scanner

Run `env-create.sh` from the `aws-orphan-resources` directory:

```bash
bash env-create.sh -c terraform/aws/conf/rnd/orphan-scanner.rnd.conf.tfvars -l scanner
```

The script verifies your AWS identity, runs `terraform init`, validates and
formats, then runs `terraform apply`. State is local by default; the resource
layer declares no backend, so a consuming module can supply its own.

Terraform creates: the scanner Lambda, an EventBridge weekly schedule, the S3
report bucket, SES send permission, the SSM exclusions parameter, and the IAM
execution role.

This first deploy gives you a working **hub-only** scan. To add other accounts,
continue to Step 4.

---

## Step 4 - Add other accounts (IAM-ARN approach)

For each additional account you want to scan, create a read-only role in **that**
account and hand its ARN to the scanner.

### 4a. Get the two values the role needs

From the scanner deployment directory:

```bash
cd terraform/aws/deployments/scanner
terraform output -raw hub_lambda_execution_role_arn   # trusted principal
terraform output -raw target_role_policy_json         # read-only permissions
```

### 4b. Create the role in the target account

Create an IAM role (e.g. `orphan-scanner-readonly`) in the target account with:

- **Trust policy** - principal = the `hub_lambda_execution_role_arn` above, action `sts:AssumeRole`:
  ```json
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": { "AWS": "<hub_lambda_execution_role_arn>" },
        "Action": "sts:AssumeRole"
      }
    ]
  }
  ```
- **Permissions policy** - the JSON from `target_role_policy_json`.

### 4c. Register the role and re-deploy

Add the new role's ARN to `target_role_arns` in the conf file:

```hcl
target_role_arns = [
  "arn:aws:iam::<TARGET_ACCOUNT_ID>:role/orphan-scanner-readonly",
]
```

Re-run the deploy. Adding an ARN attaches the `assume-target` policy to the
Lambda so it can assume that role:

```bash
bash env-create.sh -c terraform/aws/conf/rnd/orphan-scanner.rnd.conf.tfvars -l scanner
```

Repeat 4b–4c for each additional account.

---

## Step 5 - Test the scanner

Trigger a manual run instead of waiting for the weekly schedule. From the
deployment directory:

```bash
cd terraform/aws/deployments/scanner
aws lambda invoke --region <aws_region> --profile <hub-profile> \
  --function-name $(terraform output -raw lambda_function_name) \
  /tmp/scan-out.json
cat /tmp/scan-out.json
```

Then check:

- **CloudWatch Logs** for the function - scan output and any assume-role errors.
- **Your inbox** for the HTML report email.
- **The report bucket** for the CSV:
  ```bash
  aws s3 ls "s3://$(terraform output -raw report_bucket_name)/weekly/" --region <aws_region> --profile <hub-profile>
  ```

If a cross-account scan fails with `AccessDenied`/`AssumeRole`, re-check that the
target role's trust policy names the exact `hub_lambda_execution_role_arn` and
that the ARN in `target_role_arns` is correct.

---

## Managing Exclusions

Resources the scanner must never report are configured in two ways.

**1. `excluded_resource_ids` in the conf file** (audit-trailed, central):

```hcl
excluded_resource_ids = [
  "vol-0abc1234567890def",   # keep - DR snapshot source
  "eipalloc-0abc1234567890", # keep - reserved for failover
]
```

Add an ID and re-apply to exclude it; remove it and re-apply to undo. The list is
stored in SSM Parameter Store and read by the Lambda at runtime.

**2. Tag the resource directly** (self-service, no Terraform change):

| Tag key | Tag value |
|---|---|
| `orphan-scan-ignore` | `true` |

Use the tag for resources you own. Use `excluded_resource_ids` for exceptions
that need a reviewed, version-controlled record.

---

## Project Structure

```
aws-orphan-resources/
├── env-create.sh                      # Terraform wrapper - use this to deploy
├── lambda/
│   └── scanner/
│       └── lambda_function.py         # All scanner logic (single file)
└── terraform/
    └── aws/
        ├── deployments/
        │   └── scanner/               # The one and only deployment layer
        │       ├── providers.tf       # AWS provider (hub)
        │       ├── data.tf            # IAM policy documents
        │       ├── iam.tf             # Lambda execution role + policies
        │       ├── lambda.tf          # Lambda function + packaging
        │       ├── s3.tf              # Report bucket
        │       ├── scheduler.tf       # EventBridge weekly schedule
        │       ├── ssm.tf             # Exclusions parameter
        │       ├── locals.tf          # Naming + discovery actions
        │       ├── variables.tf
        │       ├── outputs.tf
        │       └── versions.tf
        └── conf/
            └── rnd/
                ├── orphan-scanner.rnd.conf.tfvars           # Config - edit and commit
                ├── orphan-scanner.rnd.conf.secrets.tfvars   # Secrets - never commit
                └── orphan-scanner.rnd.conf.secrets.tfvars.sample
```

---

## Key Terraform Outputs

| Output | Use |
|---|---|
| `lambda_function_name` | Manual invoke / console lookup |
| `report_bucket_name` | Where CSV reports land (`weekly/` prefix) |
| `hub_lambda_execution_role_arn` | Trusted principal for target-account roles |
| `target_role_policy_json` | Read-only policy to attach to target-account roles |
| `schedule_name` | The EventBridge weekly schedule |
