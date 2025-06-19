cluster_name = "eks-nx"
# Note: When enable_irsa = true, you must provide the oidc_issuer_url, which can be obtained from the output of the nx-infra-tf module.
enable_irsa     = true
oidc_issuer_url = "https://oidc.eks.<region>.amazonaws.com/id/<id>"

eks_managed_node_groups = {
  node_group_1 = {
    name = "eks-nx-1"
  }
  node_group_2 = {
    name = "eks-nx-2"
  }
}
region = "us-east-1"
