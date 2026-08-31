# Knowledge Hub workload role — single Pod Identity role bound to the
# knowledge-hub service account.
#
# Capabilities:
#   - Bedrock invoke: attaches the existing aws_iam_policy.bedrock here
#     (so enable_bedrock_access must be true alongside this role).
#   - S3 Vectors r/w: scoped to a specific vector bucket by NAME, which the
#     env passes as a plain variable rather than an nx-infra-tf output.
#   - Neptune connect and text-cache read: knowledge-hub-data-access.tf.

################################################################################
# S3 Vectors policy
################################################################################

locals {
  knowledge_hub_create         = var.create && var.enable_knowledge_hub_role
  knowledge_hub_s3v_bucket     = var.knowledge_hub_s3_vectors_bucket_name
  knowledge_hub_s3v_create     = local.knowledge_hub_create && local.knowledge_hub_s3v_bucket != ""
  knowledge_hub_s3v_bucket_arn = local.knowledge_hub_s3v_create ? "arn:aws:s3vectors:${var.region}:${data.aws_caller_identity.current[0].account_id}:bucket/${local.knowledge_hub_s3v_bucket}" : ""
}

data "aws_iam_policy_document" "knowledge_hub_s3_vectors" {
  count = local.knowledge_hub_s3v_create ? 1 : 0

  # ListVectorBuckets is an account-level action — IAM rejects it when scoped
  # to a single bucket ARN, so it lives in its own *-scoped statement.
  statement {
    sid       = "S3VectorsAccountList"
    effect    = "Allow"
    actions   = ["s3vectors:ListVectorBuckets"]
    resources = ["*"]
  }

  statement {
    sid    = "S3VectorsBucketReadWrite"
    effect = "Allow"
    actions = [
      "s3vectors:GetVectorBucket",
      "s3vectors:CreateIndex",
      "s3vectors:DeleteIndex",
      "s3vectors:GetIndex",
      "s3vectors:ListIndexes",
      "s3vectors:PutVectors",
      "s3vectors:GetVectors",
      "s3vectors:DeleteVectors",
      "s3vectors:ListVectors",
      "s3vectors:QueryVectors"
    ]
    resources = [
      local.knowledge_hub_s3v_bucket_arn,
      "${local.knowledge_hub_s3v_bucket_arn}/*"
    ]
  }
}

resource "aws_iam_policy" "knowledge_hub_s3_vectors" {
  count  = local.knowledge_hub_s3v_create ? 1 : 0
  name   = "${var.knowledge_hub_role_name}-s3-vectors"
  policy = data.aws_iam_policy_document.knowledge_hub_s3_vectors[0].json
  tags   = var.tags
}

################################################################################
# Role and attachments
################################################################################

resource "aws_iam_role" "knowledge_hub" {
  count              = local.knowledge_hub_create ? 1 : 0
  name               = var.knowledge_hub_role_name
  assume_role_policy = data.aws_iam_policy_document.pod_identity_trust[0].json
  tags               = var.tags

  lifecycle {
    precondition {
      condition     = var.enable_bedrock_access
      error_message = "enable_knowledge_hub_role requires enable_bedrock_access = true (knowledge-hub bundles Bedrock invoke)."
    }
    precondition {
      condition     = var.knowledge_hub_role_name != ""
      error_message = "knowledge_hub_role_name must be set when enable_knowledge_hub_role = true."
    }
  }
}

resource "aws_iam_role_policy_attachment" "knowledge_hub_bedrock" {
  count      = local.knowledge_hub_create && var.enable_bedrock_access ? 1 : 0
  role       = aws_iam_role.knowledge_hub[0].name
  policy_arn = aws_iam_policy.bedrock[0].arn
}

resource "aws_iam_role_policy_attachment" "knowledge_hub_s3_vectors" {
  count      = local.knowledge_hub_s3v_create ? 1 : 0
  role       = aws_iam_role.knowledge_hub[0].name
  policy_arn = aws_iam_policy.knowledge_hub_s3_vectors[0].arn
}
