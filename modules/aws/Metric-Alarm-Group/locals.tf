# -------------------------------------------------------------------------------------
#
# Copyright (c) 2025, WSO2 LLC. (https://www.wso2.com) All Rights Reserved.
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
  operation_description = {
    "GreaterThanOrEqualToThreshold" : "greater than or equal to",
    "GreaterThanThreshold" : "greater than",
    "LessThanOrEqualToThreshold" : "less than or equal to",
    "LessThanThreshold" : "less than",
    "EqualToThreshold" : "equal to",
    "LessThanLowerOrGreaterThanUpperThreshold" : "Not within the range of",
    "LessThanLowerThreshold" : "less than the lower threshold of",
    "GreaterThanUpperThreshold" : "greater than the upper threshold of",
  }
}
