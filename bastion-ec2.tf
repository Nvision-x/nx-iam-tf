resource "aws_iam_role" "bastion_eks_admin" {
  count = var.create_bastion_role ? 1 : 0

  name = "bastion-eks-role-${var.cluster_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  count      = var.create_bastion_role ? 1 : 0
  role       = aws_iam_role.bastion_eks_admin[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "eks_service_policy" {
  count      = var.create_bastion_role ? 1 : 0
  role       = aws_iam_role.bastion_eks_admin[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
}

# Attach Amazon SSM Managed Instance Core
resource "aws_iam_role_policy_attachment" "bastion_ssm_core" {
  count      = var.create_bastion_role ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.bastion_eks_admin[0].name
}

resource "aws_iam_instance_profile" "bastion_profile" {
  count = var.create_bastion_role ? 1 : 0

  name = "bastion-profile-${var.cluster_name}"
  role = aws_iam_role.bastion_eks_admin[0].name
}

resource "aws_iam_policy" "eks_access" {
  name        = "BastionEKSCluster-${var.cluster_name}"
  path        = "/"
  description = "Allow Operations on EKS cluster"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "eks:*"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "bastion_describe_cluster" {
  role       = aws_iam_role.bastion_eks_admin[0].name
  policy_arn = aws_iam_policy.eks_access.arn
}

# IAM policy to allow bastion to manage OpenSearch snapshots
resource "aws_iam_policy" "bastion_opensearch_snapshot" {
  count       = var.create_bastion_role && var.enable_opensearch ? 1 : 0
  name        = "BastionOpenSearchSnapshot-${var.cluster_name}"
  path        = "/"
  description = "Allow bastion to manage OpenSearch snapshots"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "iam:PassRole"
        Resource = aws_iam_role.opensearch_snapshot[0].arn
      }
    ]
  })
}

# Attach OpenSearch snapshot policy to bastion role
resource "aws_iam_role_policy_attachment" "bastion_opensearch_snapshot" {
  count      = var.create_bastion_role && var.enable_opensearch ? 1 : 0
  role       = aws_iam_role.bastion_eks_admin[0].name
  policy_arn = aws_iam_policy.bastion_opensearch_snapshot[0].arn
}

