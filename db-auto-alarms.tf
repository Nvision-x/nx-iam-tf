# Execution role for nx-infra-tf's database auto-alarms Lambda, passed in as
# db_auto_alarms_role_arn (same pattern as bastion-heartbeat).
#
# The Lambda finds every RDS-API database instance in the account (RDS, Aurora,
# Neptune, DocumentDB) and creates the standard CloudWatch alarms for any that
# lack them. Writes are limited to alarms carrying its own name prefix, so it
# can never modify or delete the Terraform-managed alarms.

locals {
  db_auto_alarms_create = local.create && var.enable_db_auto_alarms_role
  db_auto_alarms_name   = var.db_auto_alarms_role_name != "" ? var.db_auto_alarms_role_name : "${var.cluster_name}-db-auto-alarms"
}

data "aws_iam_policy_document" "db_auto_alarms_assume" {
  count = local.db_auto_alarms_create ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "db_auto_alarms" {
  count = local.db_auto_alarms_create ? 1 : 0

  statement {
    sid    = "WriteLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    # Log group name is fixed by the Lambda's function name in nx-infra-tf.
    resources = ["arn:${local.partition}:logs:*:${local.account_id}:log-group:/aws/lambda/${local.db_auto_alarms_name}*"]
  }

  statement {
    sid       = "ReadDatabases"
    effect    = "Allow"
    actions   = ["rds:DescribeDBInstances"]
    resources = ["*"]
  }

  statement {
    sid    = "ReadAlarmsAndMetrics"
    effect = "Allow"
    actions = [
      "cloudwatch:DescribeAlarms",
      "cloudwatch:DescribeAlarmsForMetric",
      "cloudwatch:ListMetrics",
    ]
    resources = ["*"] # read APIs support no resource-level scoping
  }

  # Writes only to alarms named "<function name>.<instance>.<check>"
  statement {
    sid    = "ManageOwnAlarms"
    effect = "Allow"
    actions = [
      "cloudwatch:PutMetricAlarm",
      "cloudwatch:DeleteAlarms",
      "cloudwatch:TagResource",
    ]
    resources = ["arn:${local.partition}:cloudwatch:*:${local.account_id}:alarm:${local.db_auto_alarms_name}.*"]
  }
}

resource "aws_iam_role" "db_auto_alarms" {
  count              = local.db_auto_alarms_create ? 1 : 0
  name               = local.db_auto_alarms_name
  assume_role_policy = data.aws_iam_policy_document.db_auto_alarms_assume[0].json
  tags               = var.tags

  lifecycle {
    precondition {
      condition     = var.db_auto_alarms_role_name != "" || var.cluster_name != ""
      error_message = "enable_db_auto_alarms_role needs either db_auto_alarms_role_name or cluster_name set."
    }
  }
}

resource "aws_iam_role_policy" "db_auto_alarms" {
  count  = local.db_auto_alarms_create ? 1 : 0
  name   = local.db_auto_alarms_name
  role   = aws_iam_role.db_auto_alarms[0].id
  policy = data.aws_iam_policy_document.db_auto_alarms[0].json
}
