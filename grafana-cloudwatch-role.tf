# Cross-account CloudWatch read role for Grafana running on the Mimir cluster in
# a separate account. Grafana's service account assumes a hub role there via
# IRSA, and the hub role chains into this one — no static keys in the cluster.
#
# Off by default. The role name is load-bearing: the hub role's policy allows
# sts:AssumeRole on arn:aws:iam::*:role/grafana-cloudwatch-read, so keep the
# default unless the hub policy is changed to match.

locals {
  grafana_cloudwatch_create = local.create && var.enable_grafana_cloudwatch_read_role
}

data "aws_iam_policy_document" "grafana_cloudwatch_assume" {
  count = local.grafana_cloudwatch_create ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = var.grafana_cloudwatch_hub_role_arns
    }
  }
}

resource "aws_iam_role" "grafana_cloudwatch_read" {
  count                = local.grafana_cloudwatch_create ? 1 : 0
  name                 = var.grafana_cloudwatch_read_role_name
  assume_role_policy   = data.aws_iam_policy_document.grafana_cloudwatch_assume[0].json
  max_session_duration = var.grafana_cloudwatch_max_session_duration
  tags                 = var.tags

  lifecycle {
    precondition {
      condition     = length(var.grafana_cloudwatch_hub_role_arns) > 0
      error_message = "enable_grafana_cloudwatch_read_role needs grafana_cloudwatch_hub_role_arns set to the Grafana hub role ARN(s) allowed to assume this role."
    }
  }
}

data "aws_iam_policy_document" "grafana_cloudwatch_read" {
  count = local.grafana_cloudwatch_create ? 1 : 0

  statement {
    sid    = "CloudWatchRead"
    effect = "Allow"
    actions = [
      "cloudwatch:DescribeAlarms",
      "cloudwatch:DescribeAlarmsForMetric",
      "cloudwatch:DescribeAlarmHistory",
      "cloudwatch:ListMetrics",
      "cloudwatch:GetMetricData",
      "cloudwatch:GetMetricStatistics",
      "cloudwatch:GetInsightRuleReport",
    ]
    resources = ["*"]
  }

  # Dimension autocomplete in the Grafana CloudWatch datasource.
  statement {
    sid    = "DimensionAutocomplete"
    effect = "Allow"
    actions = [
      "tag:GetResources",
      "ec2:DescribeTags",
      "ec2:DescribeInstances",
      "ec2:DescribeRegions",
      "resource-groups:ListGroups",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "grafana_cloudwatch_read" {
  count  = local.grafana_cloudwatch_create ? 1 : 0
  name   = var.grafana_cloudwatch_read_role_name
  role   = aws_iam_role.grafana_cloudwatch_read[0].id
  policy = data.aws_iam_policy_document.grafana_cloudwatch_read[0].json
}
