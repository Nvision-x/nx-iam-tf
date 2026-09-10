# Execution role for nx-infra-tf's bastion heartbeat Lambda, passed in as
# bastion_heartbeat_role_arn (same pattern as monitoring-chatbot).

locals {
  bastion_heartbeat_create = local.create && var.enable_bastion_heartbeat_role
  bastion_heartbeat_name   = var.bastion_heartbeat_role_name != "" ? var.bastion_heartbeat_role_name : "${var.cluster_name}-bastion-heartbeat"
  account_id               = try(data.aws_caller_identity.current[0].account_id, "")
}

data "aws_iam_policy_document" "bastion_heartbeat_assume" {
  count = local.bastion_heartbeat_create ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "bastion_heartbeat" {
  count = local.bastion_heartbeat_create ? 1 : 0

  statement {
    sid    = "WriteLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    # Log group name is fixed by the Lambda's function name in nx-infra-tf.
    resources = ["arn:${local.partition}:logs:*:${local.account_id}:log-group:/aws/lambda/${local.bastion_heartbeat_name}*"]
  }

  statement {
    sid       = "PublishHeartbeatMetrics"
    effect    = "Allow"
    actions   = ["cloudwatch:PutMetricData"]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "cloudwatch:namespace"
      values   = [var.bastion_heartbeat_metric_namespace]
    }
  }

  statement {
    sid       = "ReadSsmAgentStatus"
    effect    = "Allow"
    actions   = ["ssm:DescribeInstanceInformation"]
    resources = ["*"] # API supports no resource-level scoping
  }

  # SendCommand pinned to AWS-RunShellScript, targets narrowed by Name tag —
  # not a fleet-wide remote-exec grant
  dynamic "statement" {
    for_each = var.enable_bastion_heartbeat_send_command ? [1] : []
    content {
      sid       = "RunTailscaledServiceCheckDocument"
      effect    = "Allow"
      actions   = ["ssm:SendCommand"]
      resources = ["arn:${local.partition}:ssm:*::document/AWS-RunShellScript"]
    }
  }

  dynamic "statement" {
    for_each = var.enable_bastion_heartbeat_send_command ? [1] : []
    content {
      sid       = "RunTailscaledServiceCheckTargets"
      effect    = "Allow"
      actions   = ["ssm:SendCommand"]
      resources = ["arn:${local.partition}:ec2:*:${local.account_id}:instance/*"]
      condition {
        test     = "StringLike"
        variable = "ssm:resourceTag/Name"
        values   = [var.bastion_heartbeat_instance_name_tag]
      }
    }
  }

  dynamic "statement" {
    for_each = var.enable_bastion_heartbeat_send_command ? [1] : []
    content {
      sid       = "ReadTailscaledServiceCheckResult"
      effect    = "Allow"
      actions   = ["ssm:GetCommandInvocation"]
      resources = ["*"]
    }
  }

  dynamic "statement" {
    for_each = var.bastion_heartbeat_tailscale_secret_arn != "" ? [1] : []
    content {
      sid       = "ReadTailscaleCredentials"
      effect    = "Allow"
      actions   = ["secretsmanager:GetSecretValue"]
      resources = [var.bastion_heartbeat_tailscale_secret_arn]
    }
  }
}

resource "aws_iam_role" "bastion_heartbeat" {
  count              = local.bastion_heartbeat_create ? 1 : 0
  name               = local.bastion_heartbeat_name
  assume_role_policy = data.aws_iam_policy_document.bastion_heartbeat_assume[0].json
  tags               = var.tags

  lifecycle {
    precondition {
      condition     = var.bastion_heartbeat_role_name != "" || var.cluster_name != ""
      error_message = "enable_bastion_heartbeat_role needs either bastion_heartbeat_role_name or cluster_name set."
    }
  }
}

resource "aws_iam_role_policy" "bastion_heartbeat" {
  count  = local.bastion_heartbeat_create ? 1 : 0
  name   = local.bastion_heartbeat_name
  role   = aws_iam_role.bastion_heartbeat[0].id
  policy = data.aws_iam_policy_document.bastion_heartbeat[0].json
}

# ENI management for the VPC-attached Lambda (SSH reachability dial).
resource "aws_iam_role_policy_attachment" "bastion_heartbeat_vpc_access" {
  count      = local.bastion_heartbeat_create && var.enable_bastion_heartbeat_vpc_access ? 1 : 0
  role       = aws_iam_role.bastion_heartbeat[0].name
  policy_arn = "arn:${local.partition}:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}
