# Runbook — AWS Orphan Resource Scanner

**Audience:** cloud operations engineers who own a deployment of this module, and the
teams who receive its weekly report.
**Scope:** day-to-day operation, triage, troubleshooting, and change management for a
deployed scanner. For module inputs and first-time deployment, see [README.md](README.md).

> **Safety property:** the scanner is **strictly read-only**. It calls only `Describe*`,
> `List*`, and `Get*` APIs. It never deletes, detaches, stops, releases, or modifies any
> scanned resource. Every cleanup action described here is a human decision executed
> outside the scanner.

---

## 1. At a glance

| | |
|---|---|
| **What it does** | Scans one or more AWS accounts for orphaned/idle resources, writes a CSV to S3, emails an HTML summary |
| **Trigger** | EventBridge Scheduler, default `cron(30 3 ? * MON *)` — **Mondays 03:30 UTC** |
| **Compute** | One Lambda function, default 1024 MB / 900 s timeout |
| **Outputs** | `s3://<report_bucket>/weekly/aws-orphans-<YYYY-MM-DD-HH-MM-SS>.csv` + one SES email |
| **Resource types checked** | 18 regional + 4 global (see [§9](#9-detection-logic-and-false-positive-risk)) |
| **Blast radius if it breaks** | **None to production.** Worst case is a missing or incomplete report |
| **Typical fix time** | Config change + `terraform apply` (< 10 min) |

### Run flow

```
EventBridge Scheduler  ──invokes──▶  Lambda (hub account)
                                        │
                                        ├─ 1. read exclusions from SSM Parameter Store
                                        ├─ 2. build account list:
                                        │      • hub account (own credentials)      [if scan_hub_account]
                                        │      • each spoke  (sts:AssumeRole)       [target_role_arns]
                                        ├─ 3. per account: discover enabled regions
                                        ├─ 4. run 18 regional scanners × every region
                                        ├─ 5. run 4 global scanners once per account
                                        ├─ 6. write consolidated CSV ──▶ S3 (weekly/)
                                        └─ 7. send one HTML email  ──▶ SES ──▶ recipients
```

Every scanner call is individually wrapped in `try/except`. A failure in one scanner, one
region, or one account **does not abort the run** — it is recorded as a row with
`ResourceType = "Scanner Error"` and the run continues. This is the single most important
operational fact in this runbook: **the report tells you when it is incomplete.**

---

## 2. Resource inventory and naming

All names derive from three inputs:

```
service_id  = <project>-<deployment_layer>
location_id = <deployment_environment>-<aws_region>
name_prefix = <service_id>-<location_id>
```

Example with `project=aws-orphan-scanner`, `deployment_layer=scanner`,
`deployment_environment=rnd`, `aws_region=us-east-1`
→ `name_prefix = aws-orphan-scanner-scanner-rnd-us-east-1`

| Resource | Name | Terraform |
|---|---|---|
| Lambda function | `<name_prefix>-lambda-function` | [lambda.tf:40](lambda.tf#L40) |
| Log group | `/aws/lambda/<name_prefix>-lambda-function` | [lambda.tf:66](lambda.tf#L66) |
| Lambda role | `<name_prefix>-lambda-iam-role` | [iam.tf:26](iam.tf#L26) |
| Lambda policies | `<service_id>-{s3-write,ses-send,discovery,read-exclusions,assume-target}-<location_id>-iam-policy` | [iam.tf:47](iam.tf#L47) |
| Schedule | `<name_prefix>-weekly-scan-schedule` | [s3.tf:67](s3.tf#L67) |
| Scheduler role | `<service_id>-scheduler-<location_id>-iam-role` | [iam.tf:64](iam.tf#L64) |
| Exclusions parameter | `/orphan-scanner/<deployment_environment>-<aws_region>/exclusions` | [lambda.tf:26](lambda.tf#L26) |
| Report bucket | `<report_bucket_name>` (verbatim, you choose it) | [s3.tf:23](s3.tf#L23) |

**Spoke accounts contain nothing created by this module** — only a read-only IAM role you
create yourself, out of band. Nothing to operate there.

### Lambda environment variables

| Variable | Source | Notes |
|---|---|---|
| `REPORT_BUCKET` | `report_bucket_name` | |
| `SENDER_EMAIL` | `sender_email` | must be SES-verified |
| `RECIPIENT_EMAILS` | `recipient_emails` | comma-separated |
| `SES_REGION` | `ses_region` or `aws_region` | |
| `REGIONS` | `regions` | empty ⇒ auto-discover all enabled regions |
| `SCAN_HUB_ACCOUNT` | `scan_hub_account` | |
| `HUB_ACCOUNT_NAME` | `hub_account_name` or `account_name` | display label only |
| `TARGET_ROLE_ARNS` | `target_role_arns` | comma-joined |
| `EXCLUSIONS_PARAM_NAME` | derived | SSM parameter path |

Three further knobs are read by the code but **not exposed as Terraform variables**, so they
always run at their defaults ([lambda_function.py:58-62](scripts/lambda_function.py#L58-L62)):
`EMAIL_DETAIL_LIMIT=50` (inline table cutoff), `EMAIL_ATTACH_MAX_BYTES=5 MiB` (attach vs.
presigned link), `PRESIGNED_URL_TTL=43200` (12 h). Changing them requires a module change,
not a tfvars change.

---

## 3. Quick reference

Set these once per shell; every command below uses them.

```bash
cd <your-deployment-directory>          # where you call the module from

export AWS_REGION=us-east-1             # the hub region (var.aws_region)
export FN=$(terraform output -raw lambda_function_name)
export BUCKET=$(terraform output -raw report_bucket_name)
export LOG_GROUP="/aws/lambda/$FN"
```

| Task | Command |
|---|---|
| Trigger a run now | `aws lambda invoke --function-name $FN --cli-read-timeout 900 /tmp/out.json && cat /tmp/out.json` |
| Tail live logs | `aws logs tail $LOG_GROUP --follow` |
| Logs from last run | `aws logs tail $LOG_GROUP --since 24h` |
| List reports | `aws s3 ls s3://$BUCKET/weekly/` |
| Download latest report | see [§4.3](#43-fetch-the-latest-report) |
| Read exclusions | `aws ssm get-parameter --name "/orphan-scanner/<env>-<region>/exclusions" --query Parameter.Value --output text` |
| Show schedule | `aws scheduler get-schedule --name $(terraform output -raw schedule_name)` |
| Hub role ARN (for spoke trust policies) | `terraform output -raw hub_lambda_execution_role_arn` |
| Policy for spoke roles | `terraform output -raw target_role_policy_json` |

A successful invoke returns:

```json
{"statusCode": 200, "findingCount": 137, "accounts": ["prod-account", "111122223333"]}
```

`statusCode: 200` means **the run completed and the email was sent** — it does *not* mean
every scanner succeeded. Check the CSV for `Scanner Error` rows ([§5.2](#52-check-for-scanner-errors)).

---

## 4. Routine operations

### 4.1 Weekly report review (report recipients)

1. **Read the header.** "Total findings" and "Accounts with findings" tell you whether the
   run covered what you expect. An account you onboarded that is missing from the list
   either has zero findings or failed to be assumed — confirm via the CSV.
2. **Check the red banner.** An "Exclusions list could not be loaded" banner means
   previously-excluded resources may be back in the report. Treat exclusion-list findings
   as noise for that run and fix per [TS-06](#ts-06-exclusions-banner-in-the-email).
3. **Scan the per-account summary tables** to see where the weight is.
4. **Work the detail table**, or the attached `orphan-report.csv` when findings exceed 50.
   Use **View in Console** to open each resource directly.
5. **Before deleting anything**, read [§9](#9-detection-logic-and-false-positive-risk) for
   that resource type. Several checks have well-understood false positives.
6. **Confirm with the owner.** Use the `Owner`, `Environment`, and `CostCenter` columns
   (populated from resource tags). Blank owner ⇒ trace via CloudTrail before acting.
7. **Suppress what is intentional** so it stops appearing — see [OP-03](#op-03-suppress-a-resource-from-the-report).

### 4.2 Cleanup decision protocol

The scanner never deletes. Recommended discipline for the team acting on findings:

| Step | Action |
|---|---|
| 1 | Confirm the finding is not a known false positive for that resource type ([§9](#9-detection-logic-and-false-positive-risk)) |
| 2 | Identify the owner from tags, CloudTrail, or the originating Terraform state |
| 3 | Get explicit owner sign-off, in writing, per resource |
| 4 | For stateful resources (EBS, RDS, EFS, S3, ECR), snapshot/back up before deleting |
| 5 | Delete via the owning IaC (Terraform) where one exists — never click-delete a Terraform-managed resource |
| 6 | If keeping it, tag `orphan-scan-ignore = true` so next week's report is clean |

### 4.3 Fetch the latest report

```bash
LATEST=$(aws s3api list-objects-v2 --bucket "$BUCKET" --prefix weekly/ \
  --query 'sort_by(Contents,&LastModified)[-1].Key' --output text)
aws s3 cp "s3://$BUCKET/$LATEST" ./orphan-report.csv
```

CSV columns: `AccountId, AccountName, Region, ResourceType, ResourceId, Reason, Owner,
Environment, CostCenter, RecommendedAction, Extra`.

Cells are sanitized against CSV formula injection (leading `=`, `+`, `-`, `@`, tab get an
apostrophe prefix) and truncated at 512 characters — a leading `'` in a spreadsheet cell is
expected, not corruption.

### 4.4 Retention

Reports auto-expire after `report_retention_days` (default **30**). Logs auto-expire after
`log_retention_days` (default **7**). If you need a report older than that, it is gone —
copy anything you need for audit into long-term storage at review time.

---

## 5. Verification and health checks

There are no alarms on this module. Verification is manual and weekly.

### 5.1 Confirm the scheduled run happened

```bash
aws logs tail $LOG_GROUP --since 7d --format short | head -50
aws s3 ls s3://$BUCKET/weekly/ | tail -5     # a new object each Monday
```

### 5.2 Check for scanner errors

`Scanner Error` rows are counted in the email total, so a sudden jump in findings may be
failures rather than new orphans. Always check:

```bash
grep -c "Scanner Error" orphan-report.csv
grep "Scanner Error" orphan-report.csv | cut -d, -f1,3,6,11 | sort | uniq -c | sort -rn
```

Three shapes of error row, in increasing severity:

| Reason contains | Meaning | Action |
|---|---|---|
| `find_*_ failed.` for one region | One scanner failed in one region | [TS-04](#ts-04-scanner-error-rows-in-the-report) |
| `Failed to discover regions.` | Whole account produced nothing | [TS-04](#ts-04-scanner-error-rows-in-the-report) |
| `Failed to assume target role <arn>.` | **Entire spoke account was skipped** | [TS-03](#ts-03-failed-to-assume-target-role) |

### 5.3 CloudWatch Logs Insights

Errors and exceptions in the last week:

```
fields @timestamp, @message
| filter @message like /ERROR|Task timed out|Traceback|failed/
| sort @timestamp desc
| limit 100
```

Run duration and memory headroom (feeds the tuning decisions in [§8](#8-capacity-and-tuning)):

```
filter @type = "REPORT"
| stats max(@duration/1000) as max_seconds,
        max(@maxMemoryUsed/1024/1024) as max_mb,
        max(@memorySize/1024/1024) as configured_mb
```

### 5.4 Weekly health checklist

- [ ] A new object exists under `s3://$BUCKET/weekly/` dated this Monday
- [ ] The email arrived at every address in `recipient_emails`
- [ ] `Scanner Error` count is zero (or unchanged and understood)
- [ ] Every account you expect appears in the report
- [ ] `max_seconds` is comfortably below `lambda_timeout`
- [ ] `max_mb` is comfortably below `lambda_memory_size`

---

## 6. Operational procedures

All procedures are Terraform-first. Change tfvars → `terraform plan` → review →
`terraform apply`. **Never edit the Lambda, its env vars, the SSM parameter, or the
schedule directly in the console** — the next apply reverts it, silently and confusingly.

### OP-01 Change the scan schedule

```hcl
schedule_expression = "cron(0 6 ? * MON *)"   # Mondays 06:00 UTC
```

Expression is always evaluated in **UTC**. Verify after apply:

```bash
aws scheduler get-schedule --name $(terraform output -raw schedule_name) \
  --query '{expr:ScheduleExpression,tz:ScheduleExpressionTimezone,state:State}'
```

### OP-02 Add or remove report recipients

```hcl
recipient_emails = "cloudops@example.com,finops@example.com"
```

Comma-separated, no spaces required. **If the SES account is still in sandbox mode, every
new recipient must be individually verified in SES first** or the entire send fails and
*nobody* gets the report. Confirm your sandbox status before adding recipients:

```bash
aws sesv2 get-account --region <ses_region> --query ProductionAccessEnabled
```

### OP-03 Suppress a resource from the report

Two mechanisms, with different ownership:

**A. Tag the resource** (preferred — the resource owner controls it, no Terraform change):

```bash
aws ec2 create-tags --resources vol-0abc123 --tags Key=orphan-scan-ignore,Value=true
```

Works for any resource type where the scanner reads tags. Case-insensitive on the value.
Not available for CloudWatch Log Groups or Route53 zones, whose findings are reported with
an empty tag set.

**B. Add the ID to the exclusion list** (central, ops-owned, works for every type):

```hcl
excluded_resource_ids = [
  "vol-0abc123",          # staging spare, keep until Q3 — ticket OPS-482
  "eipalloc-0def456",
]
```

`terraform apply` writes the JSON array into SSM; the next run reads it. Match is exact
string equality against the `ResourceId` column in the CSV — copy the value from there, not
from the console (some types report the *name*, e.g. Target Group, Load Balancer, ECS
Cluster). Always leave a comment with a reason and an owner; an unexplained exclusion is
permanent invisible drift.

Verify what the scanner will actually load:

```bash
aws ssm get-parameter --name "/orphan-scanner/<env>-<region>/exclusions" \
  --query Parameter.Value --output text
```

### OP-04 Onboard a new spoke account

Perform steps 1–3 **in the target account**, step 4 in the hub.

1. Collect the hub values:
   ```bash
   terraform output -raw hub_lambda_execution_role_arn > /tmp/hub-role.txt
   terraform output -raw target_role_policy_json      > /tmp/spoke-policy.json
   ```
2. In the target account, create a role — e.g. `orphan-scanner-readonly` — with this trust
   policy (substitute the hub role ARN):
   ```json
   {
     "Version": "2012-10-17",
     "Statement": [{
       "Effect": "Allow",
       "Principal": { "AWS": "<hub_lambda_execution_role_arn>" },
       "Action": "sts:AssumeRole"
     }]
   }
   ```
   Add an `sts:ExternalId` condition if your organization requires one — note the scanner
   does **not** send an external ID ([lambda_function.py:115](scripts/lambda_function.py#L115)),
   so such a condition will block it.
3. Attach `/tmp/spoke-policy.json` to that role as an inline or managed policy.
4. In the hub, add the ARN and apply:
   ```hcl
   target_role_arns = [
     "arn:aws:iam::111122223333:role/orphan-scanner-readonly",
   ]
   ```
5. Verify **before** the next scheduled run:
   ```bash
   aws lambda invoke --function-name $FN --cli-read-timeout 900 /tmp/out.json
   cat /tmp/out.json     # the new account ID must appear in "accounts"
   ```
   Then confirm the report has no `Failed to assume target role` row for it.

The account is labelled by its **account ID** in the report; only the hub account gets a
friendly name (via `hub_account_name`).

### OP-05 Offboard a spoke account

Remove the ARN from `target_role_arns`, `terraform apply`, then delete the role in the
target account. Order matters — deleting the role first produces a `Failed to assume target
role` error row on any run in between. If you remove the *last* entry, the `assume-target`
IAM policy is destroyed automatically ([locals.tf:108](locals.tf#L108)).

### OP-06 Restrict or expand the scanned regions

Empty `regions` means **every enabled region in every account**, which is the main driver of
runtime ([§8](#8-capacity-and-tuning)). To pin:

```hcl
regions = "us-east-1,eu-west-1,ap-southeast-1"
```

The list applies to **all** accounts uniformly — there is no per-account region setting. If
discovery is enabled and `ec2:DescribeRegions` fails for an account, that account falls back
to `us-east-1` only ([lambda_function.py:143-146](scripts/lambda_function.py#L143-L146)) —
so a quietly under-reporting account can look "clean" when it is actually unscanned. Global
scanners (S3, Route53, IAM) always run regardless of this setting.

### OP-07 Change the sender address

1. Verify the new address (or its domain) in SES, in `ses_region`:
   ```bash
   aws ses verify-email-identity --email-address alerts@example.com --region <ses_region>
   aws ses get-identity-verification-attributes --identities alerts@example.com --region <ses_region>
   ```
2. Only once it shows `Success`, set `sender_email` and apply. Applying first means the next
   run's email send fails outright.

### OP-08 Pause the scanner

The schedule is hardcoded `ENABLED` ([s3.tf:70](s3.tf#L70)), so there is no `terraform`
switch. Options, best first:

| Method | Effect | Caveat |
|---|---|---|
| Set `schedule_expression = "at(2099-01-01T00:00:00)"` and apply | Terraform-native pause | Remember to restore the cron |
| Disable the schedule in the EventBridge Scheduler console | Immediate | **Drifts** — the next `terraform apply` re-enables it |
| `terraform destroy` | Full removal | Loses reports unless `force_destroy_bucket = false` protects them |

For an *urgent* stop mid-incident, the console toggle is fine — just record it, because the
next apply undoes it.

### OP-09 Add a new resource-type check

Four coordinated edits; skipping step 4 breaks every spoke account. The procedure is
documented in [README.md § Adding a new resource check](README.md#adding-a-new-resource-check).
The operational point for this runbook: **step 3 changes
`target_role_policy_json`, so every existing spoke role must be updated with the new policy
before the next run**, or that run produces an access-denied `Scanner Error` per spoke.
Sequence it as: update all spoke roles → apply the hub → manual invoke → confirm zero
`Scanner Error` rows.

### OP-10 Decommission

1. Copy any reports you must retain out of the bucket.
2. Delete the read-only roles in every spoke account.
3. `terraform destroy` in the hub. If the bucket is non-empty and `force_destroy_bucket =
   false` (the default), destroy fails by design — empty the bucket deliberately, or set
   `force_destroy_bucket = true` and re-apply first, understanding it permanently deletes
   every stored report.

---

## 7. Troubleshooting

### TS-01 No email arrived

Work the pipeline backwards.

| Check | Command / where | If it fails |
|---|---|---|
| Did the function run? | `aws logs tail $LOG_GROUP --since 8d` | → TS-02 |
| Did it write a report? | `aws s3 ls s3://$BUCKET/weekly/ \| tail -3` | S3 write failed — check the `s3-write` policy and bucket encryption (TS-08) |
| Did SES accept it? | look for a `MessageRejected` / `Email address not verified` traceback in the logs | verify sender/recipients ([OP-07](#op-07-change-the-sender-address), [OP-02](#op-02-add-or-remove-report-recipients)) |
| Did SES deliver it? | recipient's spam/quarantine; SES suppression list | remove from suppression list, ask mail admin to allowlist the sender |

Note the ordering in the code: the CSV is written to S3 **before** the email is sent
([lambda_function.py:1438-1447](scripts/lambda_function.py#L1438-L1447)). A report in S3 with
no email in the inbox therefore isolates the fault to SES or mail delivery.

### TS-02 The scheduled run never fired

```bash
aws scheduler get-schedule --name $(terraform output -raw schedule_name)
```

- `State: DISABLED` → someone paused it ([OP-08](#op-08-pause-the-scanner)); re-apply Terraform.
- Correct state but no log stream at the expected time → the scheduler role lost
  `lambda:InvokeFunction`. Re-apply; confirm `<service_id>-sched-invoke-<location_id>-iam-policy`
  is attached to `<service_id>-scheduler-<location_id>-iam-role`.
- Expression looks an hour off → it is **UTC**, not local time, and there is no DST shift.

Recovery is always safe: just invoke manually ([§3](#3-quick-reference)). The scan is
idempotent and read-only; running it twice only produces a second report object and a second
email.

### TS-03 `Failed to assume target role`

That entire spoke account was skipped. In order of likelihood:

1. **Trust policy doesn't name the current hub role.** The hub Lambda role ARN changes if
   `project`, `deployment_layer`, `deployment_environment`, or `aws_region` changed — the
   role is renamed and recreated, and every spoke trust policy silently goes stale. Compare:
   ```bash
   terraform output -raw hub_lambda_execution_role_arn
   aws iam get-role --role-name orphan-scanner-readonly --profile <spoke> \
     --query 'Role.AssumeRolePolicyDocument'
   ```
2. **`assume-target` policy missing on the hub role** — happens if `target_role_arns` was
   empty at the last apply. Re-apply.
3. **Role doesn't exist / ARN typo** in `target_role_arns`.
4. **An `sts:ExternalId` or MFA condition** on the spoke trust policy. The scanner sends
   neither; remove the condition or the account cannot be scanned.
5. **SCP** in the spoke's OU denying `sts:AssumeRole` from outside the account.

Reproduce the exact failure directly:

```bash
aws sts assume-role --role-arn <spoke-role-arn> --role-session-name diag
```

### TS-04 `Scanner Error` rows in the report

Read the `Extra` column — it carries the raw exception string.

| Extra contains | Cause | Fix |
|---|---|---|
| `AccessDenied` / `not authorized to perform` | Spoke role policy is older than the hub's `discovery_actions` list | Re-attach `terraform output -raw target_role_policy_json` to every spoke role ([OP-09](#op-09-add-a-new-resource-type-check)) |
| `UnrecognizedClientException`, `EndpointConnectionError` | Service not available in that region, or region not really enabled | Usually benign; pin `regions` ([OP-06](#op-06-restrict-or-expand-the-scanned-regions)) to silence it |
| `Throttling`, `RequestLimitExceeded` | API rate limits on a very large account | Split the scan: pin fewer regions, or run fewer accounts per deployment |
| `Failed to discover regions.` | `ec2:DescribeRegions` denied in that account | Add it to the spoke role policy |

A handful of the same error every week in the same region is a real gap, not noise —
that resource type is simply not being checked there.

### TS-05 `Task timed out after 900.00 seconds`

The report was **never written and never sent** — the run is a total loss for that week.
900 s is the AWS Lambda maximum, so raising `lambda_timeout` further is not possible. Reduce
the work instead:

1. Pin `regions` to the ones you actually use ([OP-06](#op-06-restrict-or-expand-the-scanned-regions)) — usually the biggest win, since scanning is sequential across regions.
2. Split accounts across multiple deployments of this module (different
   `deployment_layer`), each with its own bucket prefix and schedule.
3. Raise `lambda_memory_size` — more memory means proportionally more CPU, which speeds up
   the many small API round-trips.

### TS-06 Exclusions banner in the email

Red banner "Exclusions list could not be loaded" means the SSM read failed
([lambda_function.py:93-106](scripts/lambda_function.py#L93-L106)). The scan still ran, but
**every excluded resource is back in the report**. Check:

```bash
aws ssm get-parameter --name "/orphan-scanner/<env>-<region>/exclusions"
```

- `ParameterNotFound` → the parameter was deleted out of band; `terraform apply` recreates it.
- `AccessDenied` → the `read-exclusions` policy is detached; re-apply.
- Note the parameter is read from the **Lambda's own region** — if you moved the deployment
  to a new `aws_region`, the old parameter is orphaned in the old region and a new one is
  created; re-populate `excluded_resource_ids`.

### TS-07 Report is empty / an account is missing

| Symptom | Cause |
|---|---|
| `accounts: []` in the invoke response | `scan_hub_account = false` **and** `target_role_arns = []` — nothing is configured to be scanned |
| Hub account absent | `scan_hub_account = false` |
| One spoke absent, no error row | Genuinely zero findings, or its regions all failed discovery and fell back to a clean `us-east-1` |
| All accounts present, suspiciously few findings | `regions` pinned too narrowly, or a large exclusion list — check both |

An account only appears in the email's "Accounts with findings" list if it produced at least
one finding. Absence is not proof it was scanned; the CSV and the invoke response are.

### TS-08 S3 write fails / encryption mismatch

The Lambda writes objects with `ServerSideEncryption="AES256"` hardcoded
([lambda_function.py:1443](scripts/lambda_function.py#L1443)), while the bucket default is
`var.sse_algorithm`. **Setting `sse_algorithm = "aws:kms"` will break uploads** — the request
explicitly asks for AES256, and the Lambda role has no `kms:GenerateDataKey` permission
either. Keep `sse_algorithm = "AES256"` (the default) unless you also change the code and
grant KMS access.

### TS-09 `terraform apply` errors

| Error | Cause | Fix |
|---|---|---|
| `BucketAlreadyExists` | `report_bucket_name` is taken globally | Choose a globally unique name |
| `BucketNotEmpty` on destroy | Reports still stored | See [OP-10](#op-10-decommission) |
| `EntityAlreadyExists` on an IAM role/policy | A previous deployment with the same `project`/`layer`/`env`/`region` left resources | Import them, or change one of the naming inputs |
| Role/policy name too long | IAM names cap at 64 chars; `name_prefix` is built from four inputs | Shorten `project` or `deployment_layer` |
| `ValidationException` on the schedule | Malformed cron — EventBridge Scheduler cron has **6** fields | e.g. `cron(30 3 ? * MON *)` |

### TS-10 Out-of-memory

Log line `Runtime exited with error: signal: killed`, or `@maxMemoryUsed` at `@memorySize`.
All findings are held in memory until the CSV is generated. Raise `lambda_memory_size` to
2048 and re-apply. The 128 MB default of a bare Lambda is known to OOM on multi-account
scans — this module defaults to 1024 for that reason.

---

## 8. Capacity and tuning

Cost per week is a few Lambda GB-seconds, a handful of S3 PUTs, and one SES message —
effectively negligible. The binding constraint is **wall-clock time against the 900 s
timeout**, and it scales as:

```
runtime ≈ accounts × regions × (time for 18 sequential regional scanners)
        + accounts × (time for 4 global scanners)
```

Scanning is fully sequential — no parallelism across accounts, regions, or scanners. Rough
planning figures, which you should replace with your own from the Logs Insights query in
[§5.3](#53-cloudwatch-logs-insights):

| Shape | Typical runtime | Verdict |
|---|---|---|
| 1 account, 3 pinned regions | under 1 min | comfortable |
| 1 account, all ~17 enabled regions | 3–6 min | comfortable |
| 3 accounts, all regions | 10–15 min | **at the limit** |
| 5+ accounts, all regions | exceeds 900 s | split the deployment |

The expensive scanners are those making per-resource follow-up calls: `find_idle_ec2_instances`
(3 CloudWatch calls per running instance), `find_idle_lambda_functions` (1 per function),
`find_unused_ecr_repositories` (pages images per repo), and `find_unused_iam_roles`
(`get_role` per role). Accounts heavy in those services dominate runtime.

**Rule of thumb:** past three accounts, deploy a second copy of the module rather than
enlarging one. Each deployment needs its own `deployment_layer` (for unique names) and its
own bucket, and can carry its own schedule.

---

## 9. Detection logic and false-positive risk

Read this before acting on a finding. "Flagged when" is the literal rule in the code.

### Regional checks

| Resource type | Flagged when | Known false positives |
|---|---|---|
| EC2 Instance | Stopped > 30 days; **or** running ≥ 14 days with peak CPU < 5% *and* < 100 MB total network over 14 days | DR/standby hosts; batch workers idle between runs; instances whose stop-reason string can't be parsed are treated as long-stopped |
| EBS Volume | State is `available` | Volumes staged for imminent attach; ASG/DR spares |
| Elastic IP | No `AssociationId` | EIPs reserved for allowlisting at a partner, deliberately unattached |
| Network Interface | State is `available` | Pre-provisioned ENIs held for fixed IPs |
| Target Group | Zero registered targets | Scale-to-zero services; blue/green slots between deploys |
| NAT Gateway | Available, and no route table routes to it | Rare — this check is precise |
| Security Group | Not attached to any ENI (`default` SGs skipped) | **Common FP:** SGs referenced by *other* SGs' rules, or by launch templates / ASGs, are still flagged |
| Load Balancer | Active with zero listeners | Mid-deployment states |
| RDS Instance | Status `stopped` | Deliberately paused dev DBs (note AWS auto-restarts stopped RDS after 7 days) |
| EBS Snapshot | Older than 30 days and not backing a self-owned AMI | **Common FP:** compliance/backup snapshots, DLM-managed retention sets — tag these |
| AMI | Self-owned, older than 90 days, not used by any *currently described* instance in that region | **Common FP:** golden AMIs referenced by launch templates/ASGs, or shared to other accounts |
| Lambda Function | Zero invocations in 30 days (the scanner itself is skipped) | DR/break-glass functions; quarterly jobs |
| CloudWatch Log Group | No `retentionInDays` set | Not an orphan at all — a cost-hygiene finding. Set retention rather than delete |
| ECR Repository | No images; **or** no push/pull in 30 days | Release-artifact repos for slow-moving services |
| ECS Cluster | Zero running tasks, zero active services, zero container instances | Clusters awaiting a deploy |
| SNS Topic | Zero subscriptions | Topics wired as alarm targets whose subscription was never added — genuinely broken, worth fixing |
| EKS Cluster | No managed node groups **and** no Fargate profiles | **Common FP:** clusters using self-managed nodes via plain ASGs, or Karpenter-provisioned capacity |
| EFS File System | No mount targets | Cross-region replica targets |

### Global checks (once per account)

| Resource type | Flagged when | Known false positives |
|---|---|---|
| S3 Bucket | `list_objects_v2` returns zero keys | Buckets holding only noncurrent versions behind delete markers; freshly lifecycle-emptied log buckets that refill |
| Route53 Hosted Zone | Only `NS` and `SOA` records | Zones staged ahead of a migration |
| IAM Policy | Customer-managed, `AttachmentCount == 0` | **FP:** policies used only as permissions boundaries are not counted as attached |
| IAM Role | Never used, or unused > 90 days (service-linked roles skipped) | Break-glass/incident roles; `RoleLastUsed` only covers the trailing 400 days and is not populated for every access pattern |

The `RecommendedAction` column is deliberately constant: *"Review manually. Do not delete
without owner confirmation."* The scanner asserts that a resource *looks* unused; it cannot
know intent.

---

## 10. Security notes

- **Read-only by construction.** The spoke role policy is generated from the same
  `discovery_actions` list the hub uses ([locals.tf:29](locals.tf#L29)) — all `Describe*`,
  `List*`, `Get*`. Review that list on every module upgrade; it is the whole blast radius of
  the cross-account trust.
- **The reports are an inventory of your estate.** Resource IDs, account IDs, owner tags,
  and cost centres for every account scanned. Treat the report bucket and the recipient list
  as sensitive. The bucket is created without a public-access-block resource in this module,
  so it relies on **account-level S3 Block Public Access** — confirm that is enabled in the
  hub account.
- **Presigned links.** When the CSV exceeds 5 MiB it is not attached; the email carries a
  presigned S3 URL valid for **12 hours**. Anyone who receives a forwarded copy of that mail
  can download the report within the window, with no further authentication. Keep the
  recipient list tight.
- **CSV injection** is mitigated at write time (formula prefixes escaped, control characters
  stripped, cells truncated) since tag values are attacker-influenceable in a shared account.
- **Least privilege on the hub role**: five scoped policies (`s3-write` to the report bucket
  prefix only, `ses-send`, `discovery`, `read-exclusions` to the one parameter,
  `assume-target` to the listed ARNs only). `ses-send` is `Resource: "*"`, which is the usual
  shape for SES send permissions.
- **No secrets** are handled by this module. Nothing sensitive is in the Lambda environment
  variables or the SSM parameter (which is a plain `String`, holding only resource IDs).

---

## 11. Escalation

| Situation | Severity | Who |
|---|---|---|
| Report missing one week | Low — no production impact | Owning cloud-ops engineer, next business day |
| Report missing repeatedly, or a spoke account unscanned for 2+ weeks | Medium — cost/hygiene visibility gap | Owning team, this sprint |
| Anything suggesting the scanner modified a resource | **High** — contradicts the module's design | Security on-call. Pull the run's CloudTrail events; the role has no mutating permissions, so this indicates a policy tampering, not a scanner bug |
| Report bucket or presigned link exposed externally | **High** — inventory disclosure | Security on-call |

**Before escalating, gather:** the invoke response JSON, the last 500 log lines
(`aws logs tail $LOG_GROUP --since 24h`), the latest CSV, and `terraform plan` output showing
whether the deployment has drifted.

---

## 12. Change log discipline

Every change to a deployment of this scanner should be traceable:

- Config changes go through tfvars and version control — never console edits.
- Exclusions carry an inline comment with a reason and a ticket ([OP-03](#op-03-suppress-a-resource-from-the-report)).
- After any change to `target_role_arns`, `regions`, `discovery_actions`, or the runtime,
  do a **manual invoke and verify zero `Scanner Error` rows** rather than waiting for Monday.
- Record any temporary console-side pause, because the next `terraform apply` silently
  reverts it.
