variable "region" {}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "enable_irsa" {
  description = "Enable IAM Roles for Service Accounts (IRSA)"
  type        = bool
}

variable "oidc_issuer_url" {
  description = "OIDC issuer URL for the EKS cluster"
  type        = string
}

variable "eks_managed_node_groups" {
  description = "Map of EKS managed node groups and their properties"
  type = map(object({
    name = string
  }))
}

variable "create_bastion_role" {
  description = "Whether to create the IAM role and instance profile for Bastion"
  type        = bool
  default     = false
}

variable "autoscaler_role_name" {
  description = "Name of IAM role for cluster autoscaler"
  type        = string
}

variable "autoscaler_service_account" {
  description = "Service account name for cluster autoscaler"
  type        = string
}

variable "lb_controller_role_name" {
  description = "Name of IAM role for load balancer controller"
  type        = string
}

variable "lb_controller_service_account" {
  description = "Service account name for load balancer controller"
  type        = string
}

