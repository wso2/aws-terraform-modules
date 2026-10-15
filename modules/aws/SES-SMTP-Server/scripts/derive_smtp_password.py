#!/usr/bin/env python3
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

# Derives an SES SMTP password from an IAM secret access key, per AWS's published algorithm:
# https://docs.aws.amazon.com/ses/latest/dg/smtp-credentials.html#smtp-credentials-convert
# Invoked by Terraform's `external` data source (smtp-credentials.tf) — reads a JSON query
# object on stdin, writes a JSON result object on stdout, per that data source's protocol.

import base64
import hashlib
import hmac
import json
import sys

_DATE = "11111111"
_SERVICE = "ses"
_TERMINAL = "aws4_request"
_MESSAGE = "SendRawEmail"
_VERSION = bytes([0x04])


def _sign(key, msg):
    return hmac.new(key, msg.encode("utf-8"), hashlib.sha256).digest()


def derive_smtp_password(secret_access_key, region):
    signing_key = _sign(("AWS4" + secret_access_key).encode("utf-8"), _DATE)
    signing_key = _sign(signing_key, region)
    signing_key = _sign(signing_key, _SERVICE)
    signing_key = _sign(signing_key, _TERMINAL)
    signature = _sign(signing_key, _MESSAGE)
    return base64.b64encode(_VERSION + signature).decode("utf-8")


def main():
    query = json.load(sys.stdin)
    password = derive_smtp_password(query["secret_access_key"], query["region"])
    json.dump({"password": password}, sys.stdout)


if __name__ == "__main__":
    main()
