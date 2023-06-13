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
  this_stateful_group_arn  = concat(aws_networkfirewall_rule_group.suricata_stateful_group[*].arn, aws_networkfirewall_rule_group.domain_stateful_group[*].arn, aws_networkfirewall_rule_group.fivetuple_stateful_group[*].arn, var.aws_managed_rule_group)
  this_stateless_group_arn = concat(aws_networkfirewall_rule_group.stateless_group[*].arn)
}
