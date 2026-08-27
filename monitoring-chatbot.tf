# Service role for Amazon Q Developer in chat applications (AWS Chatbot).
#
# Moved out of nx-infra-tf, which still owns the SNS topics, the alarms and the
# aws_chatbot_slack_channel_configuration itself — it takes this role's ARN as
# an input, the same as every other role it consumes from here.

data "aws_iam_policy_document" "monitoring_chatbot_assume" {
  count = local.monitoring_chatbot_create ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["chatbot.amazonaws.com"]
    }
  }
}

locals {
  monitoring_chatbot_create = local.create && var.enable_monitoring_chatbot_role
  monitoring_chatbot_name   = var.monitoring_chatbot_role_name != "" ? var.monitoring_chatbot_role_name : "${var.cluster_name}-chatbot-alarms"
}

resource "aws_iam_role" "monitoring_chatbot" {
  count              = local.monitoring_chatbot_create ? 1 : 0
  name               = local.monitoring_chatbot_name
  assume_role_policy = data.aws_iam_policy_document.monitoring_chatbot_assume[0].json
  tags               = var.tags

  lifecycle {
    precondition {
      condition     = var.monitoring_chatbot_role_name != "" || var.cluster_name != ""
      error_message = "enable_monitoring_chatbot_role needs either monitoring_chatbot_role_name or cluster_name set."
    }
  }
}

# Notifications-only: read-only visibility, no mutating actions from chat.
resource "aws_iam_role_policy_attachment" "monitoring_chatbot_readonly" {
  count      = local.monitoring_chatbot_create ? 1 : 0
  role       = aws_iam_role.monitoring_chatbot[0].name
  policy_arn = "arn:${local.partition}:iam::aws:policy/CloudWatchReadOnlyAccess"
}
