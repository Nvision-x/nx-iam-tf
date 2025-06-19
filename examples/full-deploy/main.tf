module "nx-iam" {
  # source = "git::https://github.com/Nvision-x/nx-iam-tf.git"
  source = "../.."

  # -------------
  cluster_name = "umg-nx"
  enable_irsa  = true
  # when enable_irsa = true, you should provide oidc_issuer_url, get this from nx-infra-tf output
  oidc_issuer_url = "https://oidc.eks.us-east-2.amazonaws.com/id/66BD7E133FDB052805F0AD3591A0223C"
  eks_managed_node_groups = {
    node_group_1 = {
      name = "umg-nx-1"
    }
    node_group_2 = {
      name = "umg-nx-2"
    }
  }
}

module "nx-iam" {
  source = "../.."
# source = "git::https://github.com/Nvision-x/nx-iam-tf.git"
  cluster_name           = var.cluster_name
  enable_irsa            = var.enable_irsa
  oidc_issuer_url        = var.oidc_issuer_url
  eks_managed_node_groups = var.eks_managed_node_groups
}

