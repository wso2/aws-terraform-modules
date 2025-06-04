# -------------------------------------------------------------------------------------
#
# Copyright (c) 2025, WSO2 LLC. (http://www.wso2.com). All Rights Reserved.
#
# This software is the property of WSO2 LLC. and its suppliers, if any.
# Dissemination of any information or reproduction of any material contained
# herein in any form is strictly forbidden, unless permitted by WSO2 expressly.
# You may not alter or remove any copyright or other notice from copies of this content.
#
# --------------------------------------------------------------------------------------

resource "aws_codebuild_project" "ci_project_build" {
  name         = "${var.project}-${var.build_name}-build"
  description  = var.description
  service_role = var.codebuild_role_arn

  artifacts {
    type                   = var.artifacts.type
    artifact_identifier    = lookup(var.artifacts, "artifact_identifier", null)
    bucket_owner_access    = lookup(var.artifacts, "bucket_owner_access", null)
    encryption_disabled    = lookup(var.artifacts, "encryption_disabled", false)
    location               = lookup(var.artifacts, "location", null)
    name                   = lookup(var.artifacts, "name", null)
    namespace_type         = lookup(var.artifacts, "namespace_type", null)
    override_artifact_name = lookup(var.artifacts, "override_artifact_name", null)

    packaging = lookup(var.artifacts, "packaging", null)
    path      = lookup(var.artifacts, "path", null)
  }

  environment {
    compute_type    = var.compute_type
    image           = var.image
    type            = var.environment_type
    privileged_mode = var.privileged_mode

    dynamic "environment_variable" {
      for_each = var.environment_variables
      content {
        name  = environment_variable.value.name
        value = environment_variable.value.value
        type  = lookup(environment_variable.value, "type", null)
      }
    }
  }

  source {
    type                = var.codebuild_source.type
    location            = lookup(var.codebuild_source, "location", null)
    buildspec           = lookup(var.codebuild_source, "buildspec", null)
    git_clone_depth     = lookup(var.codebuild_source, "git_clone_depth", null)
    insecure_ssl        = lookup(var.codebuild_source, "insecure_ssl", null)
    report_build_status = lookup(var.codebuild_source, "report_build_status", null)

    dynamic "auth" {
      for_each = var.codebuild_source.auth != null ? [var.codebuild_source.auth] : []
      content {
        type     = auth.value.type
        resource = auth.value.resource
      }
    }

    dynamic "git_submodules_config" {
      for_each = var.codebuild_source.git_submodules_config != null ? [var.codebuild_source.git_submodules_config] : []
      content {
        fetch_submodules = git_submodules_config.value.fetch_submodules
      }
    }

    dynamic "build_status_config" {
      for_each = var.codebuild_source.build_status_config != null ? [var.codebuild_source.build_status_config] : []
      content {
        context    = build_status_config.value.context
        target_url = build_status_config.value.target_url
      }
    }
  }

  tags = var.tags
}
