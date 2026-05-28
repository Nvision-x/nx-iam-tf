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

################################################################################
# Pod Identity IAM Role Outputs
################################################################################

output "ebs_csi_iam_role_arn" {
  description = "EBS CSI IAM role ARN"
  value       = try(aws_iam_role.ebs_csi[0].arn, null)
}

output "efs_csi_iam_role_arn" {
  description = "EFS CSI IAM role ARN"
  value       = try(aws_iam_role.efs_csi[0].arn, null)
}

output "cluster_autoscaler_iam_role_arn" {
  description = "Cluster Autoscaler IAM role ARN"
  value       = try(aws_iam_role.cluster_autoscaler[0].arn, null)
}

output "lb_controller_iam_role_arn" {
  description = "AWS Load Balancer Controller IAM role ARN"
  value       = try(aws_iam_role.lb_controller[0].arn, null)
}

output "postgres_backup_iam_role_arn" {
  description = "Postgres backup IAM role ARN"
  value       = try(aws_iam_role.postgres_backup[0].arn, null)
}

output "app_s3_iam_role_arn" {
  description = "Application S3 Access IAM role ARN"
  value       = try(aws_iam_role.app_s3[0].arn, null)
}

output "cross_account_s3_iam_role_arn" {
  description = "Receiver IAM role ARN assumed by NvisionX for cross-account S3 access"
  value       = try(aws_iam_role.cross_account_s3[0].arn, null)
}

output "bedrock_iam_role_arn" {
  description = "Bedrock IAM role ARN"
  value       = try(aws_iam_role.bedrock[0].arn, null)
}

output "bedrock_iam_policy_arn" {
  description = "Bedrock IAM policy ARN"
  value       = try(aws_iam_policy.bedrock[0].arn, null)
}

################################################################################
# ArgoCD Cross-Account Roles
################################################################################

output "argocd_caller_iam_role_arn" {
  description = "ArgoCD cross-account caller IAM role ARN (Pod Identity for argocd-server / argocd-application-controller)"
  value       = try(aws_iam_role.argocd_caller[0].arn, null)
}

output "argocd_caller_iam_role_name" {
  description = "ArgoCD cross-account caller IAM role name"
  value       = try(aws_iam_role.argocd_caller[0].name, null)
}

output "argocd_target_iam_role_arn" {
  description = "ArgoCD cross-account target IAM role ARN (assumed by remote ArgoCD)"
  value       = try(aws_iam_role.argocd_target[0].arn, null)
}

output "argocd_target_iam_role_name" {
  description = "ArgoCD cross-account target IAM role name"
  value       = try(aws_iam_role.argocd_target[0].name, null)
}

################################################################################
# VPC Flow Logs
################################################################################

output "vpc_flow_logs_role_arn" {
  value       = try(aws_iam_role.vpc_flow_logs[0].arn, null)
  description = "IAM Role ARN for VPC flow logs"
}
