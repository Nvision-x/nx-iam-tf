# IAM role ARN used by the EKS control plane
output "eks_cluster_iam_role_arn" {
  description = "IAM Role ARN used by the EKS cluster control plane"
  value       = module.nvisionx-iam.eks_cluster_iam_role_arn
}

# IAM role ARN used by the default auto node group (if applicable)
output "eks_auto_node_iam_role_arn" {
  description = "IAM Role ARN used by the EKS auto-generated node group (if applicable)"
  value       = module.nvisionx-iam.eks_auto_node_iam_role_arn
}

# IAM role ARNs for all user-defined managed node groups
output "eks_managed_node_group_iam_role_arns" {
  description = "IAM Role ARNs for all EKS managed node groups"
  value       = module.nvisionx-iam.eks_managed_node_group_iam_role_arns
}

output "bastion_eks_admin_role_arn" {
  description = "IAM Role ARN for Bastion EC2 to access EKS"
  value       = try(module.nvisionx-iam.bastion_eks_admin_role_arn, null)
}

output "bastion_iam_instance_profile_name" {
  value       = var.create_bastion_role ? module.nvisionx-iam.bastion_iam_instance_profile_name : null
  description = "IAM instance profile name for the Bastion EC2 instance"
}

output "lb_controller_irsa_role_arn" {
  description = "IAM Role ARN for AWS Load Balancer Controller"
  value       = try(module.nvisionx-iam.lb_controller_irsa_role_arn, null)
}

output "cluster_autoscaler_irsa_role_arn" {
  description = "IAM Role ARN for Cluster Autoscaler"
  value       = try(module.nvisionx-iam.cluster_autoscaler_irsa_role_arn, null)
}
