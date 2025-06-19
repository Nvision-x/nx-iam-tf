# IAM role ARN used by the EKS control plane
output "eks_cluster_iam_role_arn" {
  description = "IAM Role ARN used by the EKS cluster control plane"
  value       = module.nx-iam.eks_cluster_iam_role_arn
}

# IAM role ARN used by the default auto node group (if applicable)
output "eks_auto_node_iam_role_arn" {
  description = "IAM Role ARN used by the EKS auto-generated node group (if applicable)"
  value       = module.nx-iam.eks_auto_node_iam_role_arn
}

# IAM role ARNs for all user-defined managed node groups
output "eks_managed_node_group_iam_role_arns" {
  description = "IAM Role ARNs for all EKS managed node groups"
  value       = module.nx-iam.eks_managed_node_group_iam_role_arns
}

# OIDC provider ARN used for IRSA (if enabled)
output "oidc_provider_arn" {
  description = "OIDC provider ARN for IRSA (returned only if enable_irsa = true)"
  value       = try(module.nx-iam.oidc_provider_arn, null)
}
