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

output "bastion_eks_admin_role_arn" {
  value       = var.create_bastion_role ? aws_iam_role.bastion_eks_admin[0].arn : null
  description = "ARN of the Bastion EC2 IAM role, if created"
}

output "bastion_iam_instance_profile_name" {
  value       = var.create_bastion_role ? aws_iam_instance_profile.bastion_profile[0].name : null
  description = "IAM instance profile name for the Bastion EC2 instance"
}

output "lb_controller_irsa_role_arn" {
  description = "IAM Role ARN for AWS Load Balancer Controller"
  value       = try(module.lb_controller_irsa_role[0].iam_role_arn, null)
}

output "cluster_autoscaler_irsa_role_arn" {
  description = "IAM Role ARN for Cluster Autoscaler"
  value       = try(module.cluster_autoscaler_irsa_role[0].iam_role_arn, null)
}


