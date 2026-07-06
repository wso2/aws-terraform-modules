# -------------------------------------------------------------------------------------
#
# Copyright (c) 2023, WSO2 LLC. (http://www.wso2.com). All Rights Reserved.
#
# This software is the property of WSO2 LLC. and its suppliers, if any.
# Dissemination of any information or reproduction of any material contained
# herein in any form is strictly forbidden, unless permitted by WSO2 expressly.
# You may not alter or remove any copyright or other notice from copies of this content.
#
# --------------------------------------------------------------------------------------

locals {
  # Custom stateful rule groups evaluated BEFORE AWS-managed groups.
  # Suricata and domain rule groups typically encode specific block/pass rules
  # that should take precedence over generic AWS-managed signature drops.
  this_stateful_group_arn = concat(
    aws_networkfirewall_rule_group.suricata_stateful_group[*].arn,
    aws_networkfirewall_rule_group.domain_stateful_group[*].arn,
  )

  # 5-tuple stateful rule groups evaluated AFTER AWS-managed groups.
  # Reserved for pass-all catch-alls — the pattern that lets a policy run
  # with stateful_default_actions = ["aws:drop_strict"] while still allowing
  # traffic that no drop rule matched (typical use: eliminate alert_strict
  # log noise while preserving a nominal default-deny posture).
  this_stateful_group_arn_catchall = aws_networkfirewall_rule_group.fivetuple_stateful_group[*].arn

  this_stateless_group_arn = concat(aws_networkfirewall_rule_group.stateless_group[*].arn)
}
