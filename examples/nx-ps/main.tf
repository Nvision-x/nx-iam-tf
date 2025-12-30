module "nx-iam" {
  source = "../.."
  cluster_name = "eks-ps"
  # Note: When enable_irsa = true, you must provide the oidc_issuer_url, which can be obtained from the output of the nx-infra-tf module.
  enable_irsa     = false
  oidc_issuer_url = "https://oidc.eks.us-east-2.amazonaws.com/id/E3BEA3ABE704F0CC8B5609ED8B1EDA61"

  eks_managed_node_groups = {
    node_group_1 = {
      name                     = "eks-ps-1"
      iam_role_use_name_prefix = false
    }
    node_group_2 = {
      name                     = "eks-ps-2"
      iam_role_use_name_prefix = false
    }
  }
  create_bastion_role = true
  iam_role_use_name_prefix = false
  # Autoscaler & ALB Controller
  autoscaler_role_name          = "cluster-autoscaler-ps"
  autoscaler_service_account    = "cluster-autoscaler"
  lb_controller_role_name       = "aws-load-balancer-controller-ps"
  lb_controller_service_account = "aws-load-balancer-controller"


}

