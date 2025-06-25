module "nx-iam" {
  source = "../.."
  # source = "git::https://github.com/Nvision-x/nx-iam-tf.git"
  cluster_name                  = var.cluster_name
  enable_irsa                   = var.enable_irsa
  oidc_issuer_url               = var.oidc_issuer_url
  eks_managed_node_groups       = var.eks_managed_node_groups
  create_bastion_role           = var.create_bastion_role
  autoscaler_role_name          = var.autoscaler_role_name
  autoscaler_service_account    = var.autoscaler_service_account
  lb_controller_role_name       = var.lb_controller_role_name
  lb_controller_service_account = var.lb_controller_service_account
}

