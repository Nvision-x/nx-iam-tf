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
  value       = try(module.irsa[0].lb_controller_iam_role_arn, null)
}

output "cluster_autoscaler_irsa_role_arn" {
  description = "IAM Role ARN for Cluster Autoscaler"
  value       = try(module.irsa[0].cluster_autoscaler_iam_role_arn, null)
}

output "ebs_csi_irsa_role_arn" {
  value       = try(module.irsa[0].ebs_csi_iam_role_arn, null)
  description = "EBS CSI IRSA role ARN (only when enable_irsa=true)"
}

output "bedrock_irsa_role_arn" {
  description = "IAM Role ARN for Amazon Bedrock access from EKS pods"
  value       = try(module.irsa[0].bedrock_iam_role_arn, null)
}

output "bedrock_iam_policy_arn" {
  description = "IAM Policy ARN for Amazon Bedrock access (contains capability and provider filtering). Only created when enable_bedrock_access=true and enable_irsa=true."
  value       = try(module.irsa[0].bedrock_iam_policy_arn, null)
}

output "oidc_provider_arn" {
  description = "OIDC Provider ARN (only when enable_irsa=true in IAM separation deployment pattern)"
  value       = try(aws_iam_openid_connect_provider.oidc_provider[0].arn, null)
}

output "postgres_backup_role_arn" {
  value       = try(module.irsa[0].postgres_backup_iam_role_arn, null)
  description = "Postgres backup IAM role ARN (only when enable_irsa=true and enable_postgres=true)"
}


