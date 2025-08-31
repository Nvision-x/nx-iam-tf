# IAM role for OpenSearch snapshots
resource "aws_iam_role" "opensearch_snapshot" {
  count = var.enable_opensearch ? 1 : 0
  name  = "${var.domain_name}-snapshot-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "es.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = var.tags
}

# IAM policy for OpenSearch snapshot role - includes S3 and OpenSearch permissions
resource "aws_iam_policy" "opensearch_snapshot" {
  count = var.enable_opensearch ? 1 : 0
  name  = "${var.domain_name}-snapshot-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # S3 bucket permissions for snapshots
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetBucketLocation",
          "s3:ListBucketMultipartUploads"
        ]
        Resource = "arn:aws:s3:::nvisionx*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:AbortMultipartUpload",
          "s3:ListMultipartUploadParts"
        ]
        Resource = "arn:aws:s3:::nvisionx*/*"
      },
      # OpenSearch domain permissions
      {
        Effect = "Allow"
        Action = [
          "es:ESHttpPost",
          "es:ESHttpPut",
          "es:ESHttpGet",
          "es:ESHttpDelete"
        ]
        Resource = [
          "arn:aws:es:${var.region}:${data.aws_caller_identity.current[0].account_id}:domain/${var.domain_name}/*",
        ]
      }
    ]
  })
}

# Attach policy to role
resource "aws_iam_role_policy_attachment" "opensearch_snapshot" {
  count      = var.enable_opensearch ? 1 : 0
  role       = aws_iam_role.opensearch_snapshot[0].name
  policy_arn = aws_iam_policy.opensearch_snapshot[0].arn
}