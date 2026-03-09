################################################################################
# Pod Identity IAM Roles
# Pure IAM resources - no EKS dependency
# Pod Identity associations are created in nx-infra-tf after EKS exists
################################################################################

################################################################################
# Common Trust Policy for Pod Identity
################################################################################

data "aws_iam_policy_document" "pod_identity_trust" {
  count = var.create ? 1 : 0

  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]
    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }
  }
}

################################################################################
# EBS CSI Driver IAM Role
################################################################################

data "aws_iam_policy" "ebs_csi" {
  count = var.create ? 1 : 0
  name  = "AmazonEBSCSIDriverPolicy"
}

resource "aws_iam_role" "ebs_csi" {
  count              = var.create ? 1 : 0
  name               = "${var.cluster_name}-ebs-csi"
  assume_role_policy = data.aws_iam_policy_document.pod_identity_trust[0].json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "ebs_csi" {
  count      = var.create ? 1 : 0
  role       = aws_iam_role.ebs_csi[0].name
  policy_arn = data.aws_iam_policy.ebs_csi[0].arn
}

################################################################################
# EFS CSI Driver IAM Role
################################################################################

data "aws_iam_policy" "efs_csi" {
  count = var.create ? 1 : 0
  name  = "AmazonEFSCSIDriverPolicy"
}

resource "aws_iam_role" "efs_csi" {
  count              = var.create ? 1 : 0
  name               = "${var.cluster_name}-efs-csi"
  assume_role_policy = data.aws_iam_policy_document.pod_identity_trust[0].json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "efs_csi" {
  count      = var.create ? 1 : 0
  role       = aws_iam_role.efs_csi[0].name
  policy_arn = data.aws_iam_policy.efs_csi[0].arn
}

################################################################################
# Cluster Autoscaler IAM Role
################################################################################

resource "aws_iam_policy" "cluster_autoscaler" {
  count       = var.create && var.autoscaler_role_name != "" ? 1 : 0
  name        = "${var.cluster_name}-cluster-autoscaler"
  description = "Scoped permissions for EKS Cluster Autoscaler"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ClusterAutoscalerDescribe"
        Effect = "Allow"
        Action = [
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeAutoScalingInstances",
          "autoscaling:DescribeLaunchConfigurations",
          "autoscaling:DescribeScalingActivities",
          "autoscaling:DescribeTags",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeLaunchTemplateVersions",
          "ec2:DescribeImages",
          "ec2:GetInstanceTypesFromInstanceRequirements",
          "eks:DescribeNodegroup"
        ]
        Resource = "*"
      },
      {
        Sid    = "ClusterAutoscalerModify"
        Effect = "Allow"
        Action = [
          "autoscaling:SetDesiredCapacity",
          "autoscaling:TerminateInstanceInAutoScalingGroup"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "autoscaling:ResourceTag/k8s.io/cluster-autoscaler/${var.cluster_name}" = "owned"
          }
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role" "cluster_autoscaler" {
  count              = var.create && var.autoscaler_role_name != "" ? 1 : 0
  name               = var.autoscaler_role_name
  assume_role_policy = data.aws_iam_policy_document.pod_identity_trust[0].json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "cluster_autoscaler" {
  count      = var.create && var.autoscaler_role_name != "" ? 1 : 0
  role       = aws_iam_role.cluster_autoscaler[0].name
  policy_arn = aws_iam_policy.cluster_autoscaler[0].arn
}

################################################################################
# Load Balancer Controller IAM Role
################################################################################

data "aws_iam_policy" "lb_controller" {
  count = var.create && var.lb_controller_role_name != "" ? 1 : 0
  arn   = "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess"
}

resource "aws_iam_role" "lb_controller" {
  count              = var.create && var.lb_controller_role_name != "" ? 1 : 0
  name               = var.lb_controller_role_name
  assume_role_policy = data.aws_iam_policy_document.pod_identity_trust[0].json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "lb_controller" {
  count      = var.create && var.lb_controller_role_name != "" ? 1 : 0
  role       = aws_iam_role.lb_controller[0].name
  policy_arn = data.aws_iam_policy.lb_controller[0].arn
}

resource "aws_iam_role_policy" "lb_controller_additional" {
  count = var.create && var.lb_controller_role_name != "" ? 1 : 0
  name  = "${var.lb_controller_role_name}-additional"
  role  = aws_iam_role.lb_controller[0].name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeAccountAttributes",
          "ec2:DescribeAddresses",
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeInternetGateways",
          "ec2:DescribeVpcs",
          "ec2:DescribeVpcPeeringConnections",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeInstances",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DescribeTags",
          "ec2:DescribeCoipPools",
          "ec2:GetCoipPoolUsage",
          "ec2:DescribeVpcEndpoints",
          "ec2:DescribeVpcEndpointServiceConfigurations",
          "ec2:CreateSecurityGroup",
          "ec2:CreateTags",
          "ec2:DeleteTags",
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:RevokeSecurityGroupIngress",
          "ec2:DeleteSecurityGroup"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "cognito-idp:DescribeUserPoolClient",
          "acm:ListCertificates",
          "acm:DescribeCertificate",
          "iam:ListServerCertificates",
          "iam:GetServerCertificate",
          "waf-regional:GetWebACL",
          "waf-regional:GetWebACLForResource",
          "waf-regional:AssociateWebACL",
          "waf-regional:DisassociateWebACL",
          "wafv2:GetWebACL",
          "wafv2:GetWebACLForResource",
          "wafv2:AssociateWebACL",
          "wafv2:DisassociateWebACL",
          "shield:GetSubscriptionState",
          "shield:DescribeProtection",
          "shield:CreateProtection",
          "shield:DeleteProtection"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "iam:CreateServiceLinkedRole"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "iam:AWSServiceName" = "elasticloadbalancing.amazonaws.com"
          }
        }
      }
    ]
  })
}

################################################################################
# Postgres Backup IAM Role (Dual Trust: RDS + Pod Identity)
################################################################################

data "aws_iam_policy_document" "postgres_backup_trust" {
  count = var.create && var.enable_postgres ? 1 : 0

  # RDS service principal trust (for RDS S3 export)
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["rds.amazonaws.com"]
    }
  }

  # Pod Identity trust for EKS pods
  statement {
    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "postgres_backup_policy" {
  count = var.create && var.enable_postgres ? 1 : 0

  # S3 bucket permissions
  statement {
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation",
      "s3:ListBucketMultipartUploads"
    ]
    resources = ["arn:aws:s3:::nvisionx*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:AbortMultipartUpload",
      "s3:ListMultipartUploadParts"
    ]
    resources = ["arn:aws:s3:::nvisionx*/*"]
  }

  # RDS backup permissions
  statement {
    effect = "Allow"
    actions = [
      "rds:DescribeDBSnapshots",
      "rds:CreateDBSnapshot",
      "rds:DeleteDBSnapshot",
      "rds:ModifyDBSnapshotAttribute",
      "rds:DescribeDBInstances",
      "rds:CopyDBSnapshot"
    ]
    resources = [
      "arn:aws:rds:${var.region}:${data.aws_caller_identity.current[0].account_id}:db:${var.db_identifier}",
      "arn:aws:rds:${var.region}:${data.aws_caller_identity.current[0].account_id}:snapshot:*"
    ]
  }

  # KMS permissions
  statement {
    effect = "Allow"
    actions = [
      "kms:CreateGrant",
      "kms:DescribeKey",
      "kms:Decrypt",
      "kms:Encrypt",
      "kms:GenerateDataKey"
    ]
    resources = ["*"]

    condition {
      test     = "StringLike"
      variable = "kms:ViaService"
      values = [
        "rds.${var.region}.amazonaws.com",
        "s3.${var.region}.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role" "postgres_backup" {
  count              = var.create && var.enable_postgres ? 1 : 0
  name               = "${var.db_identifier}-backup-role"
  assume_role_policy = data.aws_iam_policy_document.postgres_backup_trust[0].json
  tags               = var.tags
}

resource "aws_iam_policy" "postgres_backup" {
  count  = var.create && var.enable_postgres ? 1 : 0
  name   = "${var.db_identifier}-backup-role-policy"
  policy = data.aws_iam_policy_document.postgres_backup_policy[0].json
  tags   = var.tags
}

resource "aws_iam_role_policy_attachment" "postgres_backup" {
  count      = var.create && var.enable_postgres ? 1 : 0
  role       = aws_iam_role.postgres_backup[0].name
  policy_arn = aws_iam_policy.postgres_backup[0].arn
}

################################################################################
# Application S3 Access IAM Role
################################################################################

data "aws_iam_policy_document" "app_s3_policy" {
  count = var.create && var.enable_app_s3_access ? 1 : 0

  # S3 bucket-level permissions
  statement {
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation",
      "s3:ListBucketMultipartUploads"
    ]
    resources = [var.app_s3_bucket_arn_pattern]
  }

  # S3 object-level permissions
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:AbortMultipartUpload",
      "s3:ListMultipartUploadParts"
    ]
    resources = ["${var.app_s3_bucket_arn_pattern}/*"]
  }
}

resource "aws_iam_policy" "app_s3" {
  count  = var.create && var.enable_app_s3_access ? 1 : 0
  name   = var.app_s3_role_name != "" ? "${var.app_s3_role_name}-policy" : "${var.cluster_name}-app-s3-access-policy"
  policy = data.aws_iam_policy_document.app_s3_policy[0].json
  tags   = var.tags
}

resource "aws_iam_role" "app_s3" {
  count              = var.create && var.enable_app_s3_access ? 1 : 0
  name               = var.app_s3_role_name != "" ? var.app_s3_role_name : "${var.cluster_name}-app-s3-access"
  assume_role_policy = data.aws_iam_policy_document.pod_identity_trust[0].json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "app_s3" {
  count      = var.create && var.enable_app_s3_access ? 1 : 0
  role       = aws_iam_role.app_s3[0].name
  policy_arn = aws_iam_policy.app_s3[0].arn
}

################################################################################
# Bedrock IAM Role (Optional)
################################################################################

locals {
  # Provider prefix mapping
  bedrock_provider_prefixes = {
    anthropic = "anthropic."
    amazon    = "amazon."
    ai21      = "ai21."
    cohere    = "cohere."
    meta      = "meta."
    mistral   = "mistral."
    stability = "stability."
  }

  # Base allowed providers (either explicit allowlist or all providers)
  base_allowed_providers = length(var.bedrock_allowed_providers) > 0 ? var.bedrock_allowed_providers : keys(local.bedrock_provider_prefixes)

  # Final allowed providers after applying exclusions
  final_allowed_providers = [
    for provider in local.base_allowed_providers :
    provider if !contains(var.bedrock_excluded_providers, provider)
  ]

  # Generate model ARNs based on provider filtering
  bedrock_model_arns = var.bedrock_use_custom_model_arns ? var.bedrock_custom_model_arns : [
    for provider in local.final_allowed_providers :
    "arn:aws:bedrock:*::foundation-model/${local.bedrock_provider_prefixes[provider]}*"
  ]

  # Build policy statements based on capabilities
  bedrock_invoke_statement = contains(var.bedrock_capabilities, "invoke") ? [merge(
    {
      Effect   = "Allow"
      Action   = ["bedrock:InvokeModel"]
      Resource = local.bedrock_model_arns
    },
    length(var.bedrock_allowed_regions) > 0 ? {
      Condition = {
        StringEquals = {
          "aws:RequestedRegion" = var.bedrock_allowed_regions
        }
      }
    } : {}
  )] : []

  bedrock_streaming_statement = contains(var.bedrock_capabilities, "streaming") ? [merge(
    {
      Effect   = "Allow"
      Action   = ["bedrock:InvokeModelWithResponseStream"]
      Resource = local.bedrock_model_arns
    },
    length(var.bedrock_allowed_regions) > 0 ? {
      Condition = {
        StringEquals = {
          "aws:RequestedRegion" = var.bedrock_allowed_regions
        }
      }
    } : {}
  )] : []

  bedrock_model_catalog_statement = contains(var.bedrock_capabilities, "model_catalog") ? [{
    Effect = "Allow"
    Action = [
      "bedrock:ListFoundationModels",
      "bedrock:GetFoundationModel"
    ]
    Resource = "*"
  }] : []

  bedrock_agents_statement = contains(var.bedrock_capabilities, "agents") ? [{
    Effect = "Allow"
    Action = [
      "bedrock:InvokeAgent",
      "bedrock:Retrieve"
    ]
    Resource = var.bedrock_agent_arns
  }] : []

  bedrock_knowledge_bases_statement = contains(var.bedrock_capabilities, "knowledge_bases") ? [{
    Effect = "Allow"
    Action = [
      "bedrock:Retrieve",
      "bedrock:RetrieveAndGenerate"
    ]
    Resource = var.bedrock_knowledge_base_arns
  }] : []

  bedrock_guardrails_statement = contains(var.bedrock_capabilities, "guardrails") ? [{
    Effect = "Allow"
    Action = [
      "bedrock:ApplyGuardrail"
    ]
    Resource = var.bedrock_guardrail_arns
  }] : []

  # Combine all enabled statements
  bedrock_policy_statements = concat(
    local.bedrock_invoke_statement,
    local.bedrock_streaming_statement,
    local.bedrock_model_catalog_statement,
    local.bedrock_agents_statement,
    local.bedrock_knowledge_bases_statement,
    local.bedrock_guardrails_statement
  )
}

resource "aws_iam_policy" "bedrock" {
  count = var.create && var.enable_bedrock_access ? 1 : 0
  name  = "${var.cluster_name}-bedrock-access"

  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = local.bedrock_policy_statements
  })

  tags = var.tags
}

resource "aws_iam_role" "bedrock" {
  count              = var.create && var.enable_bedrock_access ? 1 : 0
  name               = var.bedrock_role_name
  assume_role_policy = data.aws_iam_policy_document.pod_identity_trust[0].json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "bedrock" {
  count      = var.create && var.enable_bedrock_access ? 1 : 0
  role       = aws_iam_role.bedrock[0].name
  policy_arn = aws_iam_policy.bedrock[0].arn
}
