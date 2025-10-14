# Load Balancer Controller
module "lb_controller_irsa_role" {
  count   = var.enable_irsa ? 1 : 0
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.58.0"

  role_name                              = var.lb_controller_role_name
  attach_load_balancer_controller_policy = true

  oidc_providers = {
    eks = {
      provider_arn               = aws_iam_openid_connect_provider.oidc_provider[0].arn
      namespace_service_accounts = ["${var.namespace}:${var.lb_controller_service_account}"]
    }
  }
}

# Scoped policy for Cluster Autoscaler
resource "aws_iam_policy" "cluster_autoscaler" {
  count       = var.enable_irsa ? 1 : 0
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
}

module "cluster_autoscaler_irsa_role" {
  count   = var.enable_irsa ? 1 : 0
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.58.0"

  role_name = var.autoscaler_role_name

  # Attach scoped autoscaler policy
  role_policy_arns = {
    autoscaling = aws_iam_policy.cluster_autoscaler[0].arn
  }

  oidc_providers = {
    eks = {
      provider_arn               = aws_iam_openid_connect_provider.oidc_provider[0].arn
      namespace_service_accounts = ["${var.namespace}:${var.autoscaler_service_account}"]
    }
  }
}