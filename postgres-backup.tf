# IAM role for PostgreSQL/RDS backups
resource "aws_iam_role" "postgres_backup" {
  count = var.enable_postgres ? 1 : 0
  name  = "${var.postgres_identifier}-backup-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "rds.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = var.tags
}

# IAM policy for PostgreSQL backup role - includes S3 and RDS permissions
resource "aws_iam_policy" "postgres_backup" {
  count = var.enable_postgres ? 1 : 0
  name  = "${var.postgres_identifier}-backup-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # S3 bucket permissions for backups
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
      # RDS backup permissions
      {
        Effect = "Allow"
        Action = [
          "rds:DescribeDBSnapshots",
          "rds:CreateDBSnapshot",
          "rds:DeleteDBSnapshot",
          "rds:ModifyDBSnapshotAttribute",
          "rds:DescribeDBInstances",
          "rds:CopyDBSnapshot"
        ]
        Resource = [
          "arn:aws:rds:${var.region}:${data.aws_caller_identity.current[0].account_id}:db:${var.postgres_identifier}",
          "arn:aws:rds:${var.region}:${data.aws_caller_identity.current[0].account_id}:snapshot:*"
        ]
      },
      # KMS permissions for encrypted backups (if needed)
      {
        Effect = "Allow"
        Action = [
          "kms:CreateGrant",
          "kms:DescribeKey",
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:GenerateDataKey"
        ]
        Resource = "*"
        Condition = {
          StringLike = {
            "kms:ViaService" = [
              "rds.${var.region}.amazonaws.com",
              "s3.${var.region}.amazonaws.com"
            ]
          }
        }
      }
    ]
  })
}

# Attach policy to role
resource "aws_iam_role_policy_attachment" "postgres_backup" {
  count      = var.enable_postgres ? 1 : 0
  role       = aws_iam_role.postgres_backup[0].name
  policy_arn = aws_iam_policy.postgres_backup[0].arn
}
