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
