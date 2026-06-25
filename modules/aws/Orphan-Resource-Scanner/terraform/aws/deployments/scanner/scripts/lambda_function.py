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
import csv
import html
import io
import json
import os
import re
import urllib.parse
from datetime import datetime, timedelta, timezone
from email.mime.application import MIMEApplication
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
import boto3  # Every API call goes through this

# Configuration - all values come from Lambda environment variables so the
# same code works across environments without changes.

REPORT_BUCKET    = os.environ["REPORT_BUCKET"]
SENDER_EMAIL     = os.environ["SENDER_EMAIL"]
RECIPIENT_EMAILS = [x.strip() for x in os.environ["RECIPIENT_EMAILS"].split(",") if x.strip()]
# Explicit region allowlist. When set, only these regions are scanned. When
# empty/unset, the scanner discovers all enabled regions in each account.
REGIONS          = [
    x.strip() for x in os.environ.get("REGIONS", "").split(",") if x.strip()
]
# Whether to scan the account the Lambda runs in (the hub) with its own credentials.
SCAN_HUB_ACCOUNT = os.environ.get("SCAN_HUB_ACCOUNT", "true").strip().lower() in (
    "1", "true", "yes",
)
# Display name for the hub account in the report (defaults to its account ID).
HUB_ACCOUNT_NAME = os.environ.get("HUB_ACCOUNT_NAME", "").strip()
# Comma-separated ARNs of read-only roles to assume in other (spoke) accounts.
# Each spoke is scanned in addition to the hub account.
TARGET_ROLE_ARNS = [
    x.strip() for x in os.environ.get("TARGET_ROLE_ARNS", "").split(",") if x.strip()
]
# SSM parameter (managed by Terraform) holding the JSON array of resource IDs to skip.
EXCLUSIONS_PARAM_NAME = os.environ.get("EXCLUSIONS_PARAM_NAME", "")
# Embed the full table only below this many findings; otherwise link to the S3 CSV
EMAIL_DETAIL_LIMIT = int(os.environ.get("EMAIL_DETAIL_LIMIT", "50"))
# Attach CSV up to this size; larger → presigned S3 link instead (keeps the message
# under recipient mailbox limits).
EMAIL_ATTACH_MAX_BYTES = int(os.environ.get("EMAIL_ATTACH_MAX_BYTES", str(5 * 1024 * 1024)))
PRESIGNED_URL_TTL = int(os.environ.get("PRESIGNED_URL_TTL", str(12 * 3600)))
LAMBDA_REGION = os.environ.get("AWS_REGION", "us-east-1")
SES_REGION = os.environ.get("SES_REGION", LAMBDA_REGION)

# Reusable boto3 clients

s3_client  = boto3.client("s3")
ses_client = boto3.client("ses", region_name=SES_REGION)

excluded_ids = set()  # runs at the start of each Lambda invocation


# Tag helpers (To convert AWS tags to dict )


def tags_to_dict(tags):

    if not tags:
        return {}
    return {tag.get("Key"): tag.get("Value") for tag in tags}


def get_tag_value(tags, key):
    return tags_to_dict(tags).get(key, "")

# Fetch the exclusion list from SSM Parameter Store (managed by Terraform).
# The parameter holds a JSON array of resource IDs, e.g. ["vol-0abc", "eipalloc-0def"].
def load_exclusions():
    if not EXCLUSIONS_PARAM_NAME:
        print("load_exclusions: EXCLUSIONS_PARAM_NAME not set, skipping")
        return set(), None
    try:
        ssm   = boto3.client("ssm", region_name=LAMBDA_REGION)
        value = ssm.get_parameter(Name=EXCLUSIONS_PARAM_NAME)["Parameter"]["Value"]
        ids   = {str(x) for x in json.loads(value)}
        print(f"load_exclusions: loaded {len(ids)} exclusions: {ids}")
        return ids, None
    except Exception as e:
        msg = f"load_exclusions: failed - {e}"
        print(msg)
        return set(), str(e)



# Cross-account access

# Assume the read-only role in the target account (Account B) and return a boto3
# Session backed by the temporary credentials. Every scanner call then runs with
# that session, so all resource discovery happens inside the target account.
def assume_role(role_arn):

    sts      = boto3.client("sts")
    response = sts.assume_role(
        RoleArn=role_arn,
        RoleSessionName="weekly-orphan-resource-scan",
    )
    creds = response["Credentials"]
    return boto3.Session(
        aws_access_key_id=creds["AccessKeyId"],
        aws_secret_access_key=creds["SecretAccessKey"],
        aws_session_token=creds["SessionToken"],
    )

# list of regions enabled for a given account
def get_enabled_regions(session):

# If user give regions scan them if not discover them
    if REGIONS:
        return REGIONS

    try:
        # Region is hardcoded bcz we have to pass a value to get all the regions
        ec2      = session.client("ec2", region_name="us-east-1")
        response = ec2.describe_regions(
            Filters=[{"Name": "opt-in-status", "Values": ["opt-in-not-required", "opted-in"]}]
        )
        return [r["RegionName"] for r in response.get("Regions", [])]
    except Exception:
        # No allowlist set and discovery failed - fall back to us-east-1 so a
        # discovery failure never means "scan zero regions".
        return ["us-east-1"]


# Add to findings if it is not in the exclusion list

def add_finding(findings, account, region, resource_type, resource_id, reason, tags=None, extra=""):

    tags = tags or []
    if resource_id in excluded_ids:
        return
    findings.append({
        "AccountId":         account["AccountId"],
        "AccountName":       account["AccountName"],
        "Region":            region,
        "ResourceType":      resource_type,
        "ResourceId":        resource_id,
        "Reason":            reason,
        "Owner":             get_tag_value(tags, "Owner"),
        "Environment":       get_tag_value(tags, "Environment"),
        "CostCenter":        get_tag_value(tags, "CostCenter"),
        "RecommendedAction": "Review manually. Do not delete without owner confirmation.",
        "Extra":             extra,
    })


# Scanner functions --> one per resource type.

# Finding EBS volumes
# Logic --> if status is available

def find_unattached_ebs_volumes(session, account, region):

    ec2      = session.client("ec2", region_name=region)
    findings = []

    paginator = ec2.get_paginator("describe_volumes")
    for page in paginator.paginate(Filters=[{"Name": "status", "Values": ["available"]}]):
        for volume in page.get("Volumes", []):
            tags = volume.get("Tags", [])
            add_finding(
                findings, account, region,
                "EBS Volume", volume["VolumeId"],
                "Volume is available and not attached to an EC2 instance.",
                tags,
                f"SizeGiB={volume.get('Size')}, Created={volume.get('CreateTime')}",
            )
    return findings

# Finding Elastic IPs
# Logic --> if AssociationId is not there

def find_unused_elastic_ips(session, account, region):

    ec2      = session.client("ec2", region_name=region)
    findings = []

    for address in ec2.describe_addresses().get("Addresses", []):
        tags = address.get("Tags", [])
        if "AssociationId" not in address:
            add_finding(
                findings, account, region,
                "Elastic IP", address.get("AllocationId", address.get("PublicIp")),
                "Elastic IP is not associated with an instance or network interface.",
                tags,
                f"PublicIp={address.get('PublicIp')}",
            )
    return findings

    # check with paginator

# Finding Elastic Network Interfaces
# Logic --> if status is available

def find_detached_enis(session, account, region):

    ec2      = session.client("ec2", region_name=region)
    findings = []

    paginator = ec2.get_paginator("describe_network_interfaces")
    for page in paginator.paginate(Filters=[{"Name": "status", "Values": ["available"]}]):
        for eni in page.get("NetworkInterfaces", []):
            tags = eni.get("TagSet", [])   # ENIs use TagSet
            add_finding(
                findings, account, region,
                "Network Interface", eni["NetworkInterfaceId"],
                "Network interface is available and not attached.",
                tags,
                f"VpcId={eni.get('VpcId')}, SubnetId={eni.get('SubnetId')}",
            )
    return findings

# Finding Target Groups
# Logic --> if there're no target groups

def find_empty_target_groups(session, account, region):

    elbv2    = session.client("elbv2", region_name=region)
    findings = []

    paginator = elbv2.get_paginator("describe_target_groups")
    for page in paginator.paginate():
        for tg in page.get("TargetGroups", []):
            tg_arn = tg["TargetGroupArn"]

            try:
                tag_resp = elbv2.describe_tags(ResourceArns=[tg_arn])
                descriptions = tag_resp["TagDescriptions"]
                tags = descriptions[0].get("Tags", []) if descriptions else []
            except Exception:
                tags = []


            health = elbv2.describe_target_health(TargetGroupArn=tg_arn)
            if not health.get("TargetHealthDescriptions"):
                add_finding(
                    findings, account, region,
                    "Target Group", tg["TargetGroupName"],
                    "Target group has no registered targets.",
                    tags,
                    f"TargetGroupArn={tg_arn}",
                )
    return findings

# Finding Nat Gateways
# Logic --> Checking if it is used in the route table

def find_idle_nat_gateways(session, account, region):

    ec2      = session.client("ec2", region_name=region)
    findings = []

    paginator = ec2.get_paginator("describe_nat_gateways")
    for page in paginator.paginate(Filters=[{"Name": "state", "Values": ["available"]}]):
        for ngw in page.get("NatGateways", []):
            tags = ngw.get("Tags", [])

            ngw_id    = ngw["NatGatewayId"]
            subnet_id = ngw.get("SubnetId", "")
            vpc_id    = ngw.get("VpcId", "")

            rt_response = ec2.describe_route_tables(
                Filters=[{"Name": "route.nat-gateway-id", "Values": [ngw_id]}]
            )
            if rt_response.get("RouteTables"):
                continue  # actively used

            add_finding(
                findings, account, region,
                "NAT Gateway", ngw_id,
                "NAT Gateway has no route table routing traffic through it.",
                tags,
                f"VpcId={vpc_id}, SubnetId={subnet_id}",
            )
    return findings

# Finding Security Groups
# Logic --> If ENIs are not attached to security groups

def find_unused_security_groups(session, account, region):

    ec2      = session.client("ec2", region_name=region)
    findings = []

    security_groups = ec2.describe_security_groups().get("SecurityGroups", [])

    # Build the set of in-use SG IDs by scanning all ENIs
    used_sg_ids = set()
    paginator   = ec2.get_paginator("describe_network_interfaces")
    for page in paginator.paginate():
        for eni in page.get("NetworkInterfaces", []):
            for group in eni.get("Groups", []):
                used_sg_ids.add(group["GroupId"])

    for sg in security_groups:
        tags = sg.get("Tags", [])
        if sg.get("GroupName") == "default":
            continue
        if sg["GroupId"] not in used_sg_ids:
            add_finding(
                findings, account, region,
                "Security Group", sg["GroupId"],
                "Security group is not attached to any network interface.",
                tags,
                f"GroupName={sg.get('GroupName')}, VpcId={sg.get('VpcId')}",
            )
    return findings

# Finding Load Balancers
# Logic --> If LB is active but no listeners

def find_idle_load_balancers(session, account, region):

    elbv2    = session.client("elbv2", region_name=region)
    findings = []

    paginator = elbv2.get_paginator("describe_load_balancers")
    for page in paginator.paginate():
        for lb in page.get("LoadBalancers", []):
            if lb.get("State", {}).get("Code") != "active":
                continue

            lb_arn  = lb["LoadBalancerArn"]
            lb_name = lb["LoadBalancerName"]
            lb_type = lb.get("Type", "")

            try:
                tag_resp = elbv2.describe_tags(ResourceArns=[lb_arn])
                descriptions = tag_resp["TagDescriptions"]
                tags = descriptions[0].get("Tags", []) if descriptions else []
            except Exception:
                tags = []


            listeners = elbv2.describe_listeners(LoadBalancerArn=lb_arn).get("Listeners", [])
            if not listeners:
                add_finding(
                    findings, account, region,
                    "Load Balancer", lb_name,
                    "Load balancer has no listeners configured.",
                    tags,
                    f"Type={lb_type}, Arn={lb_arn}",
                )
    return findings


# Finding RDS Instances
# Logic --> If the status is stopped

def find_stopped_rds_instances(session, account, region):

    rds      = session.client("rds", region_name=region)
    findings = []

    paginator = rds.get_paginator("describe_db_instances")
    for page in paginator.paginate():
        for db in page.get("DBInstances", []):
            if db.get("DBInstanceStatus") != "stopped":
                continue

            tags = db.get("TagList", [])

            add_finding(
                findings, account, region,
                "RDS Instance", db["DBInstanceIdentifier"],
                "RDS instance is stopped (still incurs storage costs).",
                tags,
                f"Engine={db.get('Engine')}, Class={db.get('DBInstanceClass')}",
            )
    return findings


# Finding EBS Snapshots
# Logic --> older than 30 days and no AMI assinged

def find_old_ebs_snapshots(session, account, region):

    ec2      = session.client("ec2", region_name=region)
    findings = []
    cutoff   = datetime.now(timezone.utc) - timedelta(days=30)

    # Collect snapshot IDs that back an owned AMI - these must not be flagged
    ami_snapshot_ids = set()
    ami_paginator    = ec2.get_paginator("describe_images")
    # Self means the snapshots that belong to the account
    for page in ami_paginator.paginate(Owners=["self"]):
        for image in page.get("Images", []):
            for mapping in image.get("BlockDeviceMappings", []):
                snap_id = mapping.get("Ebs", {}).get("SnapshotId")
                if snap_id:
                    ami_snapshot_ids.add(snap_id)

    snap_paginator = ec2.get_paginator("describe_snapshots")
    for page in snap_paginator.paginate(OwnerIds=["self"]):
        for snap in page.get("Snapshots", []):
            if snap["SnapshotId"] in ami_snapshot_ids:
                continue
            if snap.get("StartTime") and snap["StartTime"] > cutoff:
                continue  # too recent

            tags = snap.get("Tags", [])

            add_finding(
                findings, account, region,
                "EBS Snapshot", snap["SnapshotId"],
                "Snapshot is older than 30 days and not referenced by any AMI.",
                tags,
                f"SizeGiB={snap.get('VolumeSize')}, Created={snap.get('StartTime')}",
            )
    return findings

# Finding AMIs
# Logic --> Older than 90 days and not used by any instance

def find_old_amis(session, account, region):

    ec2      = session.client("ec2", region_name=region)
    findings = []
    cutoff   = datetime.now(timezone.utc) - timedelta(days=90)

    # Collect all ImageIds currently in use by instances
    used_ami_ids  = set()
    inst_paginator = ec2.get_paginator("describe_instances")
    for page in inst_paginator.paginate():
        for reservation in page.get("Reservations", []):
            for instance in reservation.get("Instances", []):
                used_ami_ids.add(instance["ImageId"])

    ami_paginator = ec2.get_paginator("describe_images")
    for page in ami_paginator.paginate(Owners=["self"]):
        for image in page.get("Images", []):
            if image["ImageId"] in used_ami_ids:
                continue

            try:
                created_at = datetime.fromisoformat(image["CreationDate"].replace("Z", "+00:00"))
            except Exception:
                continue

            if created_at > cutoff:
                continue  # too recent

            tags = image.get("Tags", [])

            add_finding(
                findings, account, region,
                "AMI", image["ImageId"],
                "AMI is older than 90 days and not used by any instance.",
                tags,
                f"Name={image.get('Name')}, Created={image.get('CreationDate')}",
            )
    return findings


# Finding Idle / Forgotten EC2 Instances
# Logic --> stopped for more than 30 days , OR
#           running but idle (peak CPU under 5% and almost no network for 14 days)

def _parse_stop_time(reason):
    # StateTransitionReason looks like: "User initiated (2024-01-15 10:00:00 GMT)"
    match = re.search(r"\(([\d-]+ [\d:]+) GMT\)", reason or "")
    if not match:
        return None
    try:
        return datetime.strptime(match.group(1), "%Y-%m-%d %H:%M:%S").replace(tzinfo=timezone.utc)
    except ValueError:
        return None


def find_idle_ec2_instances(session, account, region):

    ec2      = session.client("ec2", region_name=region)
    cw       = session.client("cloudwatch", region_name=region)
    findings = []
    now      = datetime.now(timezone.utc)

    stopped_cutoff = now - timedelta(days=30)   # stopped longer than this = forgotten
    idle_start     = now - timedelta(days=14)   # window for the running-but-idle check

    paginator = ec2.get_paginator("describe_instances")
    for page in paginator.paginate():
        for reservation in page.get("Reservations", []):
            for inst in reservation.get("Instances", []):
                inst_id   = inst["InstanceId"]
                state     = inst.get("State", {}).get("Name", "")
                tags      = inst.get("Tags", [])
                inst_type = inst.get("InstanceType", "")

                # Case A - stopped and forgotten
                if state == "stopped":
                    stopped_at = _parse_stop_time(inst.get("StateTransitionReason", ""))
                    if stopped_at and stopped_at > stopped_cutoff:
                        continue   # stopped only recently - leave it alone
                    add_finding(
                        findings, account, region,
                        "EC2 Instance", inst_id,
                        "EC2 instance has been stopped for over 30 days "
                        "(attached EBS volumes still incur cost).",
                        tags,
                        f"Type={inst_type}, Reason={inst.get('StateTransitionReason', '')}",
                    )
                    continue

                # Case B - running but idle
                if state != "running":
                    continue   # pending / stopping / terminated - nothing to judge
                if inst.get("LaunchTime") and inst["LaunchTime"] > idle_start:
                    continue   # launched too recently to call it idle

                try:
                    cpu = cw.get_metric_statistics(
                        Namespace="AWS/EC2",
                        MetricName="CPUUtilization",
                        Dimensions=[{"Name": "InstanceId", "Value": inst_id}],
                        StartTime=idle_start, EndTime=now,
                        Period=86400, Statistics=["Maximum"],
                    )
                    max_cpu = max(
                        (p["Maximum"] for p in cpu.get("Datapoints", [])),
                        default=None,
                    )

                    net_bytes = 0
                    for metric in ("NetworkIn", "NetworkOut"):
                        resp = cw.get_metric_statistics(
                            Namespace="AWS/EC2",
                            MetricName=metric,
                            Dimensions=[{"Name": "InstanceId", "Value": inst_id}],
                            StartTime=idle_start, EndTime=now,
                            Period=86400, Statistics=["Sum"],
                        )
                        net_bytes += sum(p.get("Sum", 0) for p in resp.get("Datapoints", []))
                except Exception:
                    continue   # metrics unavailable - skip rather than false-flag

                if max_cpu is None:
                    continue   # no CPU data at all - can't judge

                # Peak CPU under 5% AND under ~100 MB total traffic over 14 days = idle.
                if max_cpu < 5.0 and net_bytes < 100 * 1024 * 1024:
                    add_finding(
                        findings, account, region,
                        "EC2 Instance", inst_id,
                        "EC2 instance is running but idle - peak CPU under 5% and "
                        "almost no network traffic over the last 14 days.",
                        tags,
                        f"Type={inst_type}, MaxCPU={round(max_cpu, 1)}%, "
                        f"NetworkBytes14d={net_bytes}",
                    )
    return findings


# Finding Idle Lambda Functions

def find_idle_lambda_functions(session, account, region):

    lambda_client = session.client("lambda", region_name=region)
    cw            = session.client("cloudwatch", region_name=region)
    findings      = []
    now           = datetime.now(timezone.utc)
    start         = now - timedelta(days=30)

    own_function = os.environ.get("AWS_LAMBDA_FUNCTION_NAME", "")

    paginator = lambda_client.get_paginator("list_functions")
    for page in paginator.paginate():
        for fn in page.get("Functions", []):
            fn_name = fn["FunctionName"]

            if fn_name == own_function:
                continue  # skip the scanner itself - it would flag itself

            try:
                tags_resp = lambda_client.list_tags(Resource=fn["FunctionArn"])
                tags = [{"Key": k, "Value": v} for k, v in tags_resp.get("Tags", {}).items()]
            except Exception:
                tags = []


            # Sum this function's invocations over the last 30 days
            try:
                metrics = cw.get_metric_statistics(
                    Namespace="AWS/Lambda",
                    MetricName="Invocations",
                    Dimensions=[{"Name": "FunctionName", "Value": fn_name}],
                    StartTime=start,
                    EndTime=now,
                    Period=86400,
                    Statistics=["Sum"],
                )
                total = sum(p.get("Sum", 0) for p in metrics.get("Datapoints", []))
            except Exception:
                continue  # skip if CloudWatch metric is unavailable

            if total == 0:
                add_finding(
                    findings, account, region,
                    "Lambda Function", fn_name,
                    "Lambda function has had zero invocations in the last 30 days.",
                    tags,
                    f"Runtime={fn.get('Runtime')}, LastModified={fn.get('LastModified')}",
                )
    return findings


# Finding Log Groups without retention
# Logic --> if there's no retention in days

def find_log_groups_without_retention(session, account, region):

    logs     = session.client("logs", region_name=region)
    findings = []

    paginator = logs.get_paginator("describe_log_groups")
    for page in paginator.paginate():
        for lg in page.get("logGroups", []):
            if "retentionInDays" not in lg:
                add_finding(
                    findings, account, region,
                    "CloudWatch Log Group", lg["logGroupName"],
                    "Log group has no retention policy - logs are stored indefinitely.",
                    [],
                    f"StoredBytes={lg.get('storedBytes', 0)}",
                )
    return findings

# Finding Unused ECR repositories
# Logic --> empty repo, OR no image pulled/pushed in the last 30 days

def find_unused_ecr_repositories(session, account, region):

    ecr      = session.client("ecr", region_name=region)
    findings = []
    cutoff   = datetime.now(timezone.utc) - timedelta(days=30)

    repo_paginator = ecr.get_paginator("describe_repositories")
    for page in repo_paginator.paginate():
        for repo in page.get("repositories", []):
            repo_name = repo["repositoryName"]

            try:
                tags_resp = ecr.list_tags_for_resource(resourceArn=repo["repositoryArn"])
                raw_tags  = tags_resp.get("tags", [])
                tags      = [{"Key": t["Key"], "Value": t["Value"]} for t in raw_tags]
            except Exception:
                tags = []

            # Newest activity per image: last pull, else push time.
            last_activity = None
            image_count   = 0
            img_paginator = ecr.get_paginator("describe_images")
            for img_page in img_paginator.paginate(repositoryName=repo_name):
                for img in img_page.get("imageDetails", []):
                    image_count += 1
                    activity = img.get("lastRecordedPullTime") or img.get("imagePushedAt")
                    if activity and (last_activity is None or activity > last_activity):
                        last_activity = activity

            if image_count == 0:
                add_finding(
                    findings, account, region,
                    "ECR Repository", repo_name,
                    "ECR repository has no images.",
                    tags,
                    f"Uri={repo.get('repositoryUri')}",
                )
            elif last_activity and last_activity < cutoff:
                add_finding(
                    findings, account, region,
                    "ECR Repository", repo_name,
                    "ECR repository has not been pulled or pushed to in over 30 days.",
                    tags,
                    f"Images={image_count}, LastActivity={last_activity}",
                )
    return findings

# Finding Idle ECS Clusters
# Logic --> if there's no running tasks and no services and no container instances

def find_idle_ecs_clusters(session, account, region):

    ecs      = session.client("ecs", region_name=region)
    findings = []

    cluster_arns = []
    paginator    = ecs.get_paginator("list_clusters")
    for page in paginator.paginate():
        cluster_arns.extend(page.get("clusterArns", []))

    if not cluster_arns:
        return findings

    # describe_clusters accepts up to 100 ARNs per call
    for i in range(0, len(cluster_arns), 100):
        batch    = cluster_arns[i:i + 100]
        response = ecs.describe_clusters(clusters=batch)
        for cluster in response.get("clusters", []):
            if (cluster.get("runningTasksCount", 0)              == 0 and
                cluster.get("activeServicesCount", 0)            == 0 and
                cluster.get("registeredContainerInstancesCount", 0) == 0):

                # ECS tags use lowercase "key"/"value" instead of "Key"/"Value"
                raw_tags = cluster.get("tags", [])
                tags     = [{"Key": t["key"], "Value": t["value"]} for t in raw_tags]

                add_finding(
                    findings, account, region,
                    "ECS Cluster", cluster["clusterName"],
                    "ECS cluster has no running tasks, active services, or registered instances.",
                    tags,
                    f"Status={cluster.get('status')}",
                )
    return findings



# Finding Unsubscribed SNS Topics
# Logic --> if topic has no subscription

def find_unsubscribed_sns_topics(session, account, region):

    sns      = session.client("sns", region_name=region)
    findings = []

    paginator = sns.get_paginator("list_topics")
    for page in paginator.paginate():
        for topic in page.get("Topics", []):            # Topic --> a broadcast channel
            topic_arn  = topic["TopicArn"]
            topic_name = topic_arn.split(":")[-1]

            try:
                tags_resp = sns.list_tags_for_resource(ResourceArn=topic_arn)
                tags      = tags_resp.get("Tags", [])
            except Exception:
                tags = []


            subs = sns.list_subscriptions_by_topic(TopicArn=topic_arn)
            if not subs.get("Subscriptions"):
                add_finding(
                    findings, account, region,
                    "SNS Topic", topic_name,
                    "SNS topic has no subscriptions - messages are delivered to nobody.",
                    tags,
                    f"Arn={topic_arn}",
                )
    return findings


# Finding Orphan EKS Clusters
# Logic --> if no Nodegroup and fargate profiles

def find_orphan_eks_clusters(session, account, region):

    eks      = session.client("eks", region_name=region)
    findings = []

    paginator = eks.get_paginator("list_clusters")
    for page in paginator.paginate():
        for cluster_name in page.get("clusters", []):
            try:
                cluster = eks.describe_cluster(name=cluster_name)["cluster"]
            except Exception:
                continue

            tags = [{"Key": k, "Value": v} for k, v in cluster.get("tags", {}).items()]

            try:
                node_groups = eks.list_nodegroups(clusterName=cluster_name).get("nodegroups", [])
            except Exception:
                node_groups = []

            try:
                fargate_profiles = eks.list_fargate_profiles(
                    clusterName=cluster_name
                ).get("fargateProfileNames", [])
            except Exception:
                fargate_profiles = []

            if not node_groups and not fargate_profiles:
                add_finding(
                    findings, account, region,
                    "EKS Cluster", cluster_name,
                    "EKS cluster has no node groups and no Fargate profiles - "
                    "no workloads can run.",
                    tags,
                    f"Version={cluster.get('version')}, Status={cluster.get('status')}",
                )
    return findings

# Finding Unmounted EFS Filesystems
# Logic --> if efs has no mount targets

def find_unmounted_efs_filesystems(session, account, region):

    efs      = session.client("efs", region_name=region)
    findings = []

    paginator = efs.get_paginator("describe_file_systems")
    for page in paginator.paginate():
        for fs in page.get("FileSystems", []):
            tags = fs.get("Tags", [])

            fs_id = fs["FileSystemId"]

            try:
                mount_targets = efs.describe_mount_targets(
                    FileSystemId=fs_id
                ).get("MountTargets", [])
            except Exception:
                continue

            if not mount_targets:
                add_finding(
                    findings, account, region,
                    "EFS File System", fs_id,
                    "EFS file system has no mount targets - "
                    "it cannot be accessed by any workload.",
                    tags,
                    f"SizeBytes={fs.get('SizeInBytes', {}).get('Value', 0)}, "
                    f"State={fs.get('LifeCycleState')}",
                )
    return findings


# Global scanner functions --> S3 and Route53 are global AWS services.

# Finding Empty S3 Buckets
# Logic --> if s3 bucket has no objects

def find_empty_s3_buckets(session, account):

    s3       = session.client("s3", region_name="us-east-1")
    findings = []

    for bucket in s3.list_buckets().get("Buckets", []):
        bucket_name = bucket["Name"]

        try:
            location = s3.get_bucket_location(Bucket=bucket_name)
            region   = location.get("LocationConstraint") or "us-east-1"
            # Legacy buckets in eu-west-1 return "EU" instead of the region code
            if region == "EU":
                region = "eu-west-1"
        except Exception:
            region = "us-east-1"

        # Use a client in the bucket's own region if cross-region calls fail
        regional_s3 = s3 if region == "us-east-1" else session.client("s3", region_name=region)

        try:
            tags_resp = regional_s3.get_bucket_tagging(Bucket=bucket_name)
            tags      = tags_resp.get("TagSet", [])
        except Exception:
            tags = []

        try:
            objects = regional_s3.list_objects_v2(Bucket=bucket_name, MaxKeys=1)
        except Exception:
            continue

        if objects.get("KeyCount", 0) == 0:
            add_finding(
                findings, account, region,
                "S3 Bucket", bucket_name,
                "S3 bucket is empty (no objects).",
                tags,
                f"Created={bucket.get('CreationDate')}",
            )
    return findings


# Finding Empty Route53 Zones

def find_empty_route53_zones(session, account):

    r53      = session.client("route53", region_name="us-east-1")
    findings = []

    paginator = r53.get_paginator("list_hosted_zones")
    for page in paginator.paginate():
        for zone in page.get("HostedZones", []):
            zone_id   = zone["Id"].split("/")[-1]
            zone_name = zone["Name"]

            try:
                records     = r53.list_resource_record_sets(
                    HostedZoneId=zone_id
                ).get("ResourceRecordSets", [])
                non_default = [r for r in records if r["Type"] not in ("NS", "SOA")]
            except Exception:
                continue

            if not non_default:
                is_private = zone.get("Config", {}).get("PrivateZone", False)
                add_finding(
                    findings, account, "global",
                    "Route53 Hosted Zone", zone_name,
                    "Hosted zone contains only default NS and SOA records.",
                    [],
                    f"ZoneId={zone_id}, Private={is_private}",
                )
    return findings


# Finding Unattached IAM Policies (global)
# Logic --> customer-managed policy attached to no users, groups, or roles

def find_unattached_iam_policies(session, account):

    iam      = session.client("iam")
    findings = []

    paginator = iam.get_paginator("list_policies")
    # Scope=Local --> only customer-managed policies (never AWS-managed ones).
    for page in paginator.paginate(Scope="Local", OnlyAttached=False):
        for policy in page.get("Policies", []):
            if policy.get("AttachmentCount", 0) != 0:
                continue  # attached to at least one entity

            try:
                tags = iam.list_policy_tags(PolicyArn=policy["Arn"]).get("Tags", [])
            except Exception:
                tags = []

            add_finding(
                findings, account, "global",
                "IAM Policy", policy["PolicyName"],
                "Customer-managed IAM policy is not attached to any user, group, or role.",
                tags,
                f"Arn={policy['Arn']}, Created={policy.get('CreateDate')}",
            )
    return findings


# Finding Unused IAM Roles (global)
# Logic --> role never used, or not used in over 90 days (service-linked roles skipped)

def find_unused_iam_roles(session, account):

    iam      = session.client("iam")
    findings = []
    cutoff   = datetime.now(timezone.utc) - timedelta(days=90)

    paginator = iam.get_paginator("list_roles")
    for page in paginator.paginate():
        for role_summary in page.get("Roles", []):
            role_name = role_summary["RoleName"]

            # Service-linked roles (path /aws-service-role/) are AWS-managed and
            # cannot be deleted manually --> never flag them.
            if role_summary.get("Path", "").startswith("/aws-service-role/"):
                continue

            # list_roles does not populate RoleLastUsed --> fetch it per role.
            try:
                role = iam.get_role(RoleName=role_name)["Role"]
            except Exception:
                continue

            last_used = role.get("RoleLastUsed", {}).get("LastUsedDate")
            if last_used and last_used > cutoff:
                continue  # used recently

            tags   = role.get("Tags", [])
            reason = (
                "IAM role has never been used."
                if not last_used else
                "IAM role has not been used in over 90 days."
            )
            add_finding(
                findings, account, "global",
                "IAM Role", role_name,
                reason,
                tags,
                f"Created={role.get('CreateDate')}, LastUsed={last_used or 'never'}",
            )
    return findings


# Console link builder --> one URL per resource type pointing to the exact
# AWS console page

def get_console_link(resource_type, resource_id, region):
    base = f"https://{region}.console.aws.amazon.com"
    if resource_type == "EC2 Instance":
        return f"{base}/ec2/home?region={region}#InstanceDetails:instanceId={resource_id}"
    if resource_type == "EBS Volume":
        return f"{base}/ec2/home?region={region}#Volumes:volumeId={resource_id}"
    if resource_type == "Elastic IP":
        return f"{base}/ec2/home?region={region}#Addresses:AllocationId={resource_id}"
    if resource_type == "Network Interface":
        return f"{base}/ec2/home?region={region}#NIC:networkInterfaceId={resource_id}"
    if resource_type == "Security Group":
        return f"{base}/ec2/home?region={region}#SecurityGroups:group-id={resource_id}"
    if resource_type == "Target Group":
        return f"{base}/elasticloadbalancing/home?region={region}#/targetgroups"
    if resource_type == "NAT Gateway":
        return f"{base}/vpc/home?region={region}#NatGateways:natGatewayId={resource_id}"
    if resource_type == "Load Balancer":
        return f"{base}/ec2/home?region={region}#LoadBalancers:search={resource_id}"
    if resource_type == "RDS Instance":
        return f"{base}/rds/home?region={region}#database:id={resource_id};is-cluster=false"
    if resource_type == "EBS Snapshot":
        return f"{base}/ec2/home?region={region}#Snapshots:snapshotId={resource_id}"
    if resource_type == "AMI":
        return f"{base}/ec2/home?region={region}#Images:imageId={resource_id}"
    if resource_type == "Lambda Function":
        return f"{base}/lambda/home?region={region}#/functions/{resource_id}"
    if resource_type == "CloudWatch Log Group":
        log_group = urllib.parse.quote(resource_id, safe="")
        return f"{base}/cloudwatch/home?region={region}#logsV2:log-groups/log-group/{log_group}"
    if resource_type == "ECR Repository":
        return f"{base}/ecr/repositories/{resource_id}?region={region}"
    if resource_type == "ECS Cluster":
        return f"{base}/ecs/home?region={region}#/clusters/{resource_id}"
    if resource_type == "SNS Topic":
        return f"{base}/sns/v3/home?region={region}#/topics"
    if resource_type == "S3 Bucket":
        return f"https://s3.console.aws.amazon.com/s3/buckets/{resource_id}"
    if resource_type == "Route53 Hosted Zone":
        return "https://console.aws.amazon.com/route53/v2/hostedzones"
    if resource_type == "EKS Cluster":
        return f"{base}/eks/home?region={region}#/clusters/{resource_id}"
    if resource_type == "EFS File System":
        return f"{base}/efs/home?region={region}#/file-systems/{resource_id}"
    if resource_type == "IAM Policy":  # IAM is global - no region in the URL
        return "https://console.aws.amazon.com/iam/home#/policies"
    if resource_type == "IAM Role":
        return f"https://console.aws.amazon.com/iam/home#/roles/details/{resource_id}"
    return f"{base}/console/home?region={region}"


# Report generation

def generate_csv(findings):

    output     = io.StringIO()
    fieldnames = [
        "AccountId", "AccountName", "Region", "ResourceType", "ResourceId",
        "Reason", "Owner", "Environment", "CostCenter", "RecommendedAction", "Extra",
    ]
    writer = csv.DictWriter(output, fieldnames=fieldnames)
    writer.writeheader()
    for finding in findings:
        writer.writerow(finding)
    return output.getvalue()

# Send Email with HTML

def send_email(findings, csv_report, exclusions_error=None, report_s3_key=None):

    total = len(findings)

    # CSV attachment - Included with the email when it is within the mailbox size limit.
    # Download link - If the file is too large, a presigned link is provided instead.
    csv_bytes  = csv_report.encode("utf-8")
    attach_csv = report_s3_key is not None and len(csv_bytes) <= EMAIL_ATTACH_MAX_BYTES

    # Per-account resource breakdown – Shows resource counts by account
    by_account       = {}
    acct_type_counts = {}
    for f in findings:
        by_account[f["AccountName"]] = by_account.get(f["AccountName"], 0) + 1
        acct_type_counts.setdefault(f["AccountName"], {})
        acct_type_counts[f["AccountName"]][f["ResourceType"]] = \
            acct_type_counts[f["AccountName"]].get(f["ResourceType"], 0) + 1

    # Per-account resource summary – Displays resource types and counts for each account
    summary_by_account = ""
    for acct in sorted(by_account, key=lambda a: -by_account[a]):
        type_rows = ""
        for rtype, cnt in sorted(acct_type_counts[acct].items(), key=lambda kv: (-kv[1], kv[0])):
            type_rows += f"<tr><td>{html.escape(rtype)}</td><td><b>{cnt}</b></td></tr>"
        summary_by_account += f"""
        <h4 style="margin:18px 0 4px 0;color:#1a3a5c;">
            Account {html.escape(acct)}
            <span style="background:#e74c3c;color:white;padding:2px 10px;border-radius:10px;
                  font-size:12px;margin-left:8px;font-weight:normal;">{by_account[acct]} findings</span>
        </h4>
        <table class="summary-table">
            <tr><th>Resource Type</th><th>Count</th></tr>
            {type_rows}
        </table>"""

    # Two-level grouping: account --> resource type --> list of findings
    grouped = {}
    for i, f in enumerate(findings):
        grouped.setdefault(f["AccountName"], {}).setdefault(f["ResourceType"], []).append((i, f))

    finding_rows = ""
    for account_name, by_rtype in sorted(grouped.items()):
        account_total = sum(len(items) for items in by_rtype.values())
        rtypes_sorted = sorted(by_rtype.keys())

        # Outer account card header (dark navy)
        finding_rows += f"""
        <tr>
            <td colspan="6" style="background-color:#1a3a5c;color:white;font-weight:bold;
                padding:12px 16px;font-size:15px;
                border-top:2px solid #1a3a5c;border-left:2px solid #1a3a5c;border-right:2px solid #1a3a5c;">
                {html.escape(account_name)}
                <span style="background:#e74c3c;color:white;padding:2px 10px;
                    border-radius:10px;font-size:12px;margin-left:10px;font-weight:normal;">
                    {account_total} findings
                </span>
            </td>
        </tr>"""

        for rtype in rtypes_sorted:
            items        = by_rtype[rtype]
            count        = len(items)
            is_last_type = (rtype == rtypes_sorted[-1])

            # Inner resource type sub-header
            finding_rows += f"""
            <tr>
                <td colspan="6" style="background-color:#2e6da4;color:white;font-weight:bold;
                    padding:8px 14px 8px 28px;font-size:13px;
                    border-left:2px solid #1a3a5c;border-right:2px solid #1a3a5c;">
                    {html.escape(rtype)}
                    <span style="background:#e67e22;color:white;padding:2px 8px;
                        border-radius:10px;font-size:11px;margin-left:8px;font-weight:normal;">
                        {count} found
                    </span>
                </td>
            </tr>"""

            for idx, (_, f) in enumerate(items):
                is_last_row = (idx == len(items) - 1)
                connector   = "&#x2514;&#x2500;" if is_last_row else "&#x251C;&#x2500;"

                # Close the outer account card border on the very last row
                bottom = "border-bottom:2px solid #1a3a5c;" if (is_last_row and is_last_type) else ""

                console_url  = get_console_link(f["ResourceType"], f["ResourceId"], f["Region"])
                console_link = f"""<a href="{console_url}" style="color:#2e6da4;font-size:12px;
                    text-decoration:none;border:1px solid #2e6da4;padding:4px 10px;
                    border-radius:4px;white-space:nowrap;">View in Console</a>"""

                finding_rows += f"""
                <tr style="background-color:#eaf2fb;">
                    <td style="border-left:2px solid #1a3a5c;{bottom}padding-left:32px;">{html.escape(f['Region'])}</td>
                    <td style="font-family:monospace;font-size:12px;{bottom}">
                        <span style="color:#2e6da4;font-weight:bold;margin-right:4px;">{connector}</span>{html.escape(f['ResourceId'])}
                    </td>
                    <td style="{bottom}">{html.escape(f['Reason'])}</td>
                    <td style="{bottom}">{html.escape(f['Owner']) if f['Owner'] else '-'}</td>
                    <td style="font-size:12px;{bottom}">{html.escape(f['Extra']) if f['Extra'] else '-'}</td>
                    <td style="border-right:2px solid #1a3a5c;{bottom}">{console_link}</td>
                </tr>"""

        # Spacer between account cards
        finding_rows += """
        <tr><td colspan="6" style="padding:10px;background:#ffffff;border:none;"></td></tr>"""

    if not finding_rows:
        finding_rows = "<tr><td colspan='6' style='text-align:center;'>No orphan resources found</td></tr>"

    accounts_scanned = ", ".join(sorted(by_account.keys())) if by_account else "N/A"

    report_location = (
        f"s3://{REPORT_BUCKET}/{report_s3_key}" if report_s3_key
        else f"s3://{REPORT_BUCKET}/weekly/"
    )
    if attach_csv:
        report_access = (
            "The full per-resource report (all accounts, all regions) is attached as "
            "<b>orphan-report.csv</b>."
        )
    elif report_s3_key:
        download_url = s3_client.generate_presigned_url(
            "get_object",
            Params={"Bucket": REPORT_BUCKET, "Key": report_s3_key},
            ExpiresIn=PRESIGNED_URL_TTL,
        )
        report_access = (
            f"The full report is too large to attach. Download it here "
            f"(link expires in {PRESIGNED_URL_TTL // 3600}h):<br>"
            f'<a href="{html.escape(download_url)}">Download orphan-report.csv</a><br>'
            f"<small>S3 location: <code>{html.escape(report_location)}</code></small>"
        )
    else:
        report_access = f"The full report is in S3: <code>{html.escape(report_location)}</code>"

    if total <= EMAIL_DETAIL_LIMIT:
        detail_section = f"""
        <h3>Findings Detail &mdash; Count: {total}</h3>
        <table>
            <tr>
                <th>Region</th><th>Resource ID</th><th>Reason</th>
                <th>Owner</th><th>Extra</th><th>Action</th>
            </tr>
            {finding_rows}
        </table>
        <p>{report_access}</p>"""
    else:
        detail_section = f"""
        <h3>Findings Detail</h3>
        <div class="warning">
            <b>{total} findings</b> &mdash; too many to list inline. {report_access}
        </div>"""

    exclusions_banner = (
        f'<div class="exclusion-error"><b>&#9888; Exclusions list could not be loaded.</b> '
        f'This report may include resources that were previously excluded. '
        f'Error: {html.escape(exclusions_error)}</div>'
        if exclusions_error else ""
    )

    html_body = f"""
    <html>
    <head>
        <style>
            body {{ font-family: Arial, sans-serif; font-size: 14px; color: #333; }}
            h2 {{ color: #d9534f; }}
            h3 {{ color: #555; border-bottom: 1px solid #ddd; padding-bottom: 4px; }}
            table {{ border-collapse: collapse; width: 100%; margin-bottom: 24px; }}
            th {{ background-color: #2e6da4; color: white; padding: 8px 12px; text-align: left; }}
            td {{ padding: 7px 12px; border-bottom: 1px solid #eee; }}
            .summary-table {{ width: auto; min-width: 300px; }}
            .badge {{ background-color: #d9534f; color: white; padding: 4px 10px;
                      border-radius: 12px; font-size: 16px; font-weight: bold; }}
            .footer {{ font-size: 12px; color: #888; margin-top: 24px; border-top: 1px solid #eee; padding-top: 12px; }}
            .warning {{ background-color: #fcf8e3; border-left: 4px solid #f0ad4e;
                        padding: 10px 16px; margin-bottom: 16px; }}
            .exclusion-error {{ background-color: #f2dede; border-left: 4px solid #d9534f;
                                 padding: 10px 16px; margin-bottom: 16px; color: #a94442; }}
        </style>
    </head>
    <body>
        <h2>AWS Orphan Resource Weekly Report</h2>

        <p>Accounts with findings: <b>{accounts_scanned}</b></p>
        <p>Total findings: <span class="badge">{total}</span></p>

        {exclusions_banner}
        <div class="warning">
            <b>Important:</b> This report is read-only. It does not delete, detach, stop,
            release, or modify any AWS resource. All cleanup decisions are manual.
        </div>

        <h3>Summary by Account</h3>
        {summary_by_account}

        {detail_section}

        <h3>Recommended Next Steps</h3>
        <ol>
            <li>Review the findings table above.</li>
            <li>Click <b>View in Console</b> to open the resource in the AWS Console.</li>
            <li>Validate ownership - confirm with the resource owner before deleting.</li>
            <li>Manually delete resources that are confirmed orphans.</li>
            <li>Tag intentional resources with <code>orphan-scan-ignore=true</code> to suppress future alerts.</li>
        </ol>

        <div class="footer">
            Sent by AWS Orphan Resource Scanner &mdash; Cloud Operations
        </div>
    </body>
    </html>
    """

    text_body = f"AWS Orphan Resource Weekly Report - {total} findings. Accounts with findings: {accounts_scanned}"

    # Attaching the downloadable version of the CSV file
    msg = MIMEMultipart("mixed")
    msg["Subject"] = f"AWS Orphan Resource Weekly Report - {total} findings"
    msg["From"]    = SENDER_EMAIL
    msg["To"]      = ", ".join(RECIPIENT_EMAILS)

    body = MIMEMultipart("alternative")
    body.attach(MIMEText(text_body, "plain", "utf-8"))
    body.attach(MIMEText(html_body, "html", "utf-8"))
    msg.attach(body)

    if attach_csv:
        attachment = MIMEApplication(csv_bytes, _subtype="csv")
        attachment.add_header("Content-Disposition", "attachment", filename="orphan-report.csv")
        msg.attach(attachment)

    ses_client.send_raw_email(
        Source=SENDER_EMAIL,
        Destinations=RECIPIENT_EMAILS,
        RawMessage={"Data": msg.as_string()},
    )


# Lambda entry point

def lambda_handler(event, context):
    """Main handler invoked by EventBridge Scheduler every Monday at 03:30 UTC.

    Flow:
      1. Build the account list: the hub account (own credentials, when
         SCAN_HUB_ACCOUNT) plus each spoke in TARGET_ROLE_ARNS via assume-role.
      2. For each account: discover its enabled regions
      3. Run all regional scanner functions across every region
      4. Run global scanner functions (S3, Route53, IAM) once per account
      5. Write all findings as a timestamped CSV to S3
      6. Send one consolidated HTML email grouped by account → resource type

    Each scanner function is called in its own try/except so a failure in
    one scanner does not prevent the others from running.
    """
    global excluded_ids
    excluded_ids, exclusions_error = load_exclusions()
    findings = []

    # Regional scanner functions --> called once per account per region
    regional_scanners = [
        find_idle_ec2_instances,
        find_unattached_ebs_volumes,
        find_unused_elastic_ips,
        find_detached_enis,
        find_empty_target_groups,
        find_idle_nat_gateways,
        find_unused_security_groups,
        find_idle_load_balancers,
        find_stopped_rds_instances,
        find_old_ebs_snapshots,
        find_old_amis,
        find_idle_lambda_functions,
        find_log_groups_without_retention,
        find_unused_ecr_repositories,
        find_idle_ecs_clusters,
        find_unsubscribed_sns_topics,
        find_orphan_eks_clusters,
        find_unmounted_efs_filesystems
    ]

    # Global scanner functions --> called once per account (not per region)
    global_scanners = [
        find_empty_s3_buckets,
        find_empty_route53_zones,
        find_unattached_iam_policies,
        find_unused_iam_roles,
    ]

    # Build the list of accounts to scan: optionally the hub account itself (with
    # the Lambda's own credentials) plus every configured spoke account via
    # cross-account assume-role. Each session is scanned independently below.
    sts = boto3.client("sts")
    account_sessions = []

    if SCAN_HUB_ACCOUNT:
        own_id  = sts.get_caller_identity()["Account"]
        account = {"AccountId": own_id, "AccountName": HUB_ACCOUNT_NAME or own_id}
        account_sessions.append((account, boto3.Session()))

    for role_arn in TARGET_ROLE_ARNS:
        # arn:aws:iam::<account-id>:role/<name> - account id is the 5th field.
        spoke_id = role_arn.split(":")[4]
        account  = {"AccountId": spoke_id, "AccountName": spoke_id}
        try:
            account_sessions.append((account, assume_role(role_arn)))
        except Exception as e:
            add_finding(findings, account, "N/A", "Scanner Error", "N/A",
                        f"Failed to assume target role {role_arn}.", [], str(e))

    accounts = [acct for acct, _ in account_sessions]

    # Scan each account with its own session
    for account, session in account_sessions:
        try:
            regions = get_enabled_regions(session)
        except Exception as e:
            add_finding(findings, account, "N/A", "Scanner Error", "N/A",
                        "Failed to discover regions.", [], str(e))
            continue

        # Run regional scanners across all enabled regions
        for region in regions:
            for scanner in regional_scanners:
                try:
                    findings.extend(scanner(session, account, region))
                except Exception as e:
                    add_finding(findings, account, region, "Scanner Error", "N/A",
                                f"{scanner.__name__} failed.", [], str(e))

        # Run global scanners once per account
        for scanner in global_scanners:
            try:
                findings.extend(scanner(session, account))
            except Exception as e:
                add_finding(findings, account, "global", "Scanner Error", "N/A",
                            f"{scanner.__name__} failed.", [], str(e))

    # Write CSV report to S3
    csv_report  = generate_csv(findings)
    report_time = datetime.now(timezone.utc).strftime("%Y-%m-%d-%H-%M-%S")
    s3_key      = f"weekly/aws-orphans-{report_time}.csv"

    s3_client.put_object(
        Bucket=REPORT_BUCKET,
        Key=s3_key,
        Body=csv_report.encode("utf-8"),
        ContentType="text/csv",
        ServerSideEncryption="AES256",
    )

    # Send consolidated email
    send_email(findings, csv_report, exclusions_error=exclusions_error, report_s3_key=s3_key)

    return {
        "statusCode":   200,
        "findingCount": len(findings),
        "accounts":     [a["AccountName"] for a in accounts],
    }
