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
  name = join("-", compact([var.project, var.application, var.environment, var.region, var.name, "ib-component"]))

  # Reference to the latest version of this component. Built from values known at plan
  # time, not from the component's ARN: a recipe that uses it stays unchanged when a new
  # component version replaces the old one. Image Builder lower-cases names in ARNs.
  latest_version_arn = format(
    "arn:%s:imagebuilder:%s:%s:component/%s/x.x.x",
    data.aws_partition.current.partition,
    data.aws_region.current.name,
    data.aws_caller_identity.current.account_id,
    lower(local.name),
  )
}
