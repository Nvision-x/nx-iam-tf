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
# Pod Identity Outputs (migrated from IRSA)
################################################################################

output "lb_controller_iam_role_arn" {
  description = "IAM Role ARN for AWS Load Balancer Controller (Pod Identity)"
  value       = try(module.pod_identity[0].lb_controller_iam_role_arn, null)
}

# Backward compatibility alias
output "lb_controller_irsa_role_arn" {
  description = "DEPRECATED: Use lb_controller_iam_role_arn instead. IAM Role ARN for AWS Load Balancer Controller"
  value       = try(module.pod_identity[0].lb_controller_iam_role_arn, null)
}

output "cluster_autoscaler_iam_role_arn" {
  description = "IAM Role ARN for Cluster Autoscaler (Pod Identity)"
  value       = try(module.pod_identity[0].cluster_autoscaler_iam_role_arn, null)
}

# Backward compatibility alias
output "cluster_autoscaler_irsa_role_arn" {
  description = "DEPRECATED: Use cluster_autoscaler_iam_role_arn instead. IAM Role ARN for Cluster Autoscaler"
  value       = try(module.pod_identity[0].cluster_autoscaler_iam_role_arn, null)
}

output "ebs_csi_iam_role_arn" {
  description = "EBS CSI IAM role ARN (Pod Identity)"
  value       = try(module.pod_identity[0].ebs_csi_iam_role_arn, null)
}

# Backward compatibility alias
output "ebs_csi_irsa_role_arn" {
  description = "DEPRECATED: Use ebs_csi_iam_role_arn instead. EBS CSI IAM role ARN"
  value       = try(module.pod_identity[0].ebs_csi_iam_role_arn, null)
}

output "bedrock_iam_role_arn" {
  description = "IAM Role ARN for Amazon Bedrock access from EKS pods (Pod Identity)"
  value       = try(module.pod_identity[0].bedrock_iam_role_arn, null)
}

# Backward compatibility alias
output "bedrock_irsa_role_arn" {
  description = "DEPRECATED: Use bedrock_iam_role_arn instead. IAM Role ARN for Amazon Bedrock access"
  value       = try(module.pod_identity[0].bedrock_iam_role_arn, null)
}

output "bedrock_iam_policy_arn" {
  description = "IAM Policy ARN for Amazon Bedrock access (contains capability and provider filtering)"
  value       = try(module.pod_identity[0].bedrock_iam_policy_arn, null)
}

output "postgres_backup_iam_role_arn" {
  description = "Postgres backup IAM role ARN (Pod Identity)"
  value       = try(module.pod_identity[0].postgres_backup_iam_role_arn, null)
}

# Backward compatibility alias
output "postgres_backup_role_arn" {
  description = "DEPRECATED: Use postgres_backup_iam_role_arn instead. Postgres backup IAM role ARN"
  value       = try(module.pod_identity[0].postgres_backup_iam_role_arn, null)
}

################################################################################
# Application S3 Access Outputs
################################################################################

output "app_s3_iam_role_arn" {
  description = "Application S3 Access IAM role ARN (Pod Identity)"
  value       = try(module.pod_identity[0].app_s3_iam_role_arn, null)
}

output "app_s3_iam_role_name" {
  description = "Application S3 Access IAM role name"
  value       = try(module.pod_identity[0].app_s3_iam_role_name, null)
}

output "app_s3_iam_policy_arn" {
  description = "Application S3 Access IAM policy ARN"
  value       = try(module.pod_identity[0].app_s3_iam_policy_arn, null)
}

output "app_s3_pod_identity_associations" {
  description = "Map of Application S3 Access Pod Identity associations"
  value       = try(module.pod_identity[0].app_s3_pod_identity_associations, {})
}

################################################################################
# OIDC Provider Output (kept for backward compatibility, may be removed in future)
################################################################################

output "oidc_provider_arn" {
  description = "DEPRECATED: OIDC Provider ARN. Pod Identity doesn't require OIDC. Kept for backward compatibility."
  value       = try(aws_iam_openid_connect_provider.oidc_provider[0].arn, null)
}

################################################################################
# VPC Flow Logs
################################################################################

output "vpc_flow_logs_role_arn" {
  value       = try(aws_iam_role.vpc_flow_logs[0].arn, null)
  description = "IAM Role ARN for VPC flow logs"
}
