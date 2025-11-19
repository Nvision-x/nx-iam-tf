################################################################################
# Amazon Bedrock IRSA (IAM Role for Service Accounts)
################################################################################

# Bedrock IAM Policy with least privilege and secure access patterns
resource "aws_iam_policy" "bedrock" {
  count       = var.enable_bedrock_access ? 1 : 0
  name        = "${var.cluster_name}-bedrock-access"
  description = "Scoped permissions for Amazon Bedrock runtime access with least privilege"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "BedrockRuntimeAccess"
        Effect = "Allow"
        Action = [
          "bedrock:InvokeModel",
          "bedrock:InvokeModelWithResponseStream"
        ]
        Resource = var.bedrock_allowed_model_arns
        Condition = {
          StringEquals = {
            "aws:RequestedRegion" = var.bedrock_allowed_regions
          }
        }
      },
      {
        Sid    = "BedrockModelCatalogReadOnly"
        Effect = "Allow"
        Action = [
          "bedrock:ListFoundationModels",
          "bedrock:GetFoundationModel"
        ]
        Resource = "*"
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name        = "${var.cluster_name}-bedrock-access"
      Description = "Bedrock access policy for EKS pods"
      ManagedBy   = "Terraform"
    }
  )
}

# IRSA Role for Bedrock - allows Kubernetes service accounts to assume this role
module "bedrock_irsa_role" {
  count   = var.enable_bedrock_access && var.enable_irsa ? 1 : 0
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.58.0"

  role_name = var.bedrock_role_name

  role_policy_arns = {
    bedrock = aws_iam_policy.bedrock[0].arn
  }

  oidc_providers = {
    eks = {
      provider_arn               = aws_iam_openid_connect_provider.oidc_provider[0].arn
      namespace_service_accounts = var.bedrock_service_accounts
    }
  }

  tags = merge(
    var.tags,
    {
      Name        = var.bedrock_role_name
      Description = "IRSA role for Bedrock access from EKS pods"
      ManagedBy   = "Terraform"
    }
  )
}
