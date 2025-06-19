output "node_group_iam_role_arn" {
  description = "The ARN of the IAM role used by the EKS node group"
  value       = local.create_iam_role ? aws_iam_role.this[0].arn : null
}
