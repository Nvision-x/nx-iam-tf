module "nx-iam" {
  source = "../.."
  # source = "git::https://github.com/Nvision-x/nx-iam-tf.git"
  cluster_name            = var.cluster_name
  enable_irsa             = var.enable_irsa
  oidc_issuer_url         = var.oidc_issuer_url
  eks_managed_node_groups = var.eks_managed_node_groups
}

