module "nvisionx-iam" {

  # This Terraform module provisions IAM roles and policies required to support Amazon EKS clusters and managed node groups. https://github.com/Nvision-x/nx-iam-tf
  source = "git::https://github.com/Nvision-x/nx-iam-tf.git?ref=ea9f4698e2de2f859a44a585af81bc9a695c5773"


  cluster_name = "nvisionx-eks"

  # Note: When enable_irsa = true, you must provide the oidc_issuer_url, which can be obtained from the output of the nx-infra-tf module.
  enable_irsa     = false
  oidc_issuer_url = "https://oidc.eks.<region>.amazonaws.com/id/<id>"

  eks_managed_node_groups = {
    node_group_1 = {
      name                     = "nvisionx-node-1"
      iam_role_use_name_prefix = false
    }
    node_group_2 = {
      name                     = "nvisionx-node-2"
      iam_role_use_name_prefix = false
    }
  }
  create_bastion_role      = true
  iam_role_use_name_prefix = false

  # Autoscaler & ALB Controller
  autoscaler_role_name          = "nvisionx-cluster-autoscaler"
  autoscaler_service_account    = "cluster-autoscaler"
  lb_controller_role_name       = "nvisionx-aws-load-balancer-controller"
  lb_controller_service_account = "aws-load-balancer-controller"

}