# AWS Orphan Resource Scanner

A serverless Lambda that scans one or more AWS accounts weekly and emails a report
of orphaned resources (unused EBS volumes, idle NAT Gateways, empty S3 buckets, and
more). It scans the **hub** account it's deployed into, and any other accounts via a
read-only cross-account role.

## Architecture

Hub-and-spoke: this module is deployed once, into the **hub** account. The hub owns
all the infrastructure - the Lambda, its EventBridge schedule, the S3 report bucket,
and SES sending. **Spoke** (target) accounts don't run anything themselves; each one
just has a lightweight read-only IAM role that trusts the hub's Lambda execution role.
On each run, the hub Lambda assumes into every configured spoke role (plus optionally
scans itself) and rolls all findings into a single report.

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

## Testing

The schedule triggers the scan automatically; to trigger it manually:
```bash
aws lambda invoke --region us-east-1 --cli-read-timeout 900 \
  --function-name $(terraform output -raw lambda_function_name) /tmp/out.json
```
Reports land in the S3 bucket under `weekly/` and are emailed to the recipients.

## Scanning other accounts

In each target account, create a read-only IAM role that:
- **trusts** the hub Lambda role-`terraform output -raw hub_lambda_execution_role_arn`
- **grants** the read policy-`terraform output -raw target_role_policy_json`

Then add its ARN to `target_role_arns` and re-deploy.

## Exclusions

Skip specific resources via `excluded_resource_ids` in the conf (stored in SSM), or
tag the resource `orphan-scan-ignore = true`.

## Adding a new resource check

Adding a check for a new orphaned resource type touches four places, in this order:

**1. Write the scanner function** - in `scripts/lambda_function.py`, following the
existing naming pattern:
- `find_<resource>(session, account, region)` for a per-region service (most AWS
  services), or
- `find_<resource>(session, account)` for a global service (S3, Route53, IAM).

It should call the read-only boto3 API(s) for that resource and call
`add_finding(...)` once for each orphan it finds.

**2. Register it** - in `lambda_handler`, add the function to `regional_scanners` or
`global_scanners` (matching whichever signature you used in step 1). Skipping this
means the function is never called.

**3. Grant it permission** - in `locals.tf`, add any new IAM action(s) the function
calls to `discovery_actions`. This one list feeds both the hub Lambda's own IAM
policy and the `target_role_policy_json` output, so a single edit covers both.

**4. Update spoke accounts** - step 3 changes `target_role_policy_json`, so re-apply
the updated policy to each existing target-account IAM role; otherwise the new check
will fail with an access-denied error in every spoke account.
