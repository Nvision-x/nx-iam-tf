output "eks_managed_node_group_iam_role_arns" {
  description = "IAM Role ARNs for all EKS managed node groups"
  value = {
    for k, m in module.eks_managed_node_group : k => m.node_group_iam_role_arn
  }
}

output "eks_cluster_iam_role_arn" {
  description = "IAM Role ARN used by EKS cluster"
  value       = try(aws_iam_role.this[0].arn, var.iam_role_arn)
}

output "eks_auto_node_iam_role_arn" {
  description = "IAM Role ARN used by EKS Auto Node Group"
  value       = try(aws_iam_role.eks_auto[0].arn, null)
}

output "oidc_provider_arn" {
  description = "The ARN of the OIDC Provider if `enable_irsa = true`"
  value       = try(aws_iam_openid_connect_provider.oidc_provider[0].arn, null)
}