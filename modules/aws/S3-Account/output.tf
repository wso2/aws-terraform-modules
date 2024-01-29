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

output "s3_account_arn" {
  value = aws_s3_bucket.s3_bucket.arn
}
output "s3_account_id" {
  value = aws_s3_bucket.s3_bucket.id
}
output "s3_account_bucket_domain_name" {
  value = aws_s3_bucket.s3_bucket.bucket_domain_name
}
