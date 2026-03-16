# nx-iam-tf

Terraform module that provisions IAM roles and policies for Amazon EKS clusters using **EKS Pod Identity**. Creates pure IAM resources with no EKS cluster dependency, allowing IAM to be applied independently before infrastructure.

Pod Identity associations (linking roles to Kubernetes service accounts) are created separately by [nx-infra-tf](https://github.com/Nvision-x/nx-infra-tf).

---

## Features

### Cluster and Node Roles
- EKS cluster IAM role (with EKS Auto Mode support)
- EKS Auto node IAM role
- Managed node group IAM roles

### Pod Identity Roles
All Pod Identity roles use the `pods.eks.amazonaws.com` service principal trust policy.

| Role | Condition | Naming |
|------|-----------|--------|
| EBS CSI Driver | Always created | `{cluster_name}-ebs-csi` |
| EFS CSI Driver | Always created | `{cluster_name}-efs-csi` |
| Cluster Autoscaler | `autoscaler_role_name != ""` | `{autoscaler_role_name}` |
| Load Balancer Controller | `lb_controller_role_name != ""` | `{lb_controller_role_name}` |
| Postgres Backup | `enable_postgres = true` | `{db_identifier}-backup-role` |
| App S3 Access | `enable_app_s3_access = true` | `{app_s3_role_name}` |
| Bedrock | `enable_bedrock_access = true` | `{bedrock_role_name}` |

### Other Roles
- Bastion EC2 instance role and profile (EKS admin access + SSM)
- OpenSearch snapshot role
- VPC Flow Logs role

---

## Usage

```hcl
module "nx-iam" {
  source       = "git::https://github.com/Nvision-x/nx-iam-tf.git?ref=v2026.03.16-3"
  cluster_name = "eks-production"
  region       = "us-east-1"

  eks_managed_node_groups = {
    node_group_1 = {
      name                     = "production-node-1"
      iam_role_use_name_prefix = false
    }
  }

  iam_role_use_name_prefix = false
  create_bastion_role      = true
  enable_opensearch        = true
  domain_name              = "production-os"

  # Pod Identity role names
  autoscaler_role_name    = "cluster-autoscaler-production"
  lb_controller_role_name = "aws-load-balancer-controller-production"

  # Postgres backup
  enable_postgres = true
  db_identifier   = "production-postgres"

  # App S3 access
  enable_app_s3_access      = true
  app_s3_role_name          = "eks-production-app-s3-access"
  app_s3_bucket_arn_pattern = "arn:aws:s3:::nvisionx*"
}
```

---

## Key Inputs

### Cluster
| Name | Description | Default |
|------|-------------|---------|
| `cluster_name` | EKS cluster name | `""` |
| `region` | AWS region | - |
| `create` | Enable/disable all resource creation | `true` |
| `iam_role_use_name_prefix` | Use name as prefix | `true` |
| `eks_managed_node_groups` | Map of node group definitions | `{}` |

### Pod Identity Roles
| Name | Description | Default |
|------|-------------|---------|
| `autoscaler_role_name` | Cluster Autoscaler role name | `""` |
| `lb_controller_role_name` | Load Balancer Controller role name | `""` |
| `enable_postgres` | Create postgres backup role | `true` |
| `db_identifier` | RDS instance identifier (for backup role naming) | - |
| `enable_app_s3_access` | Create app S3 access role | `false` |
| `app_s3_role_name` | App S3 role name | `""` |
| `app_s3_bucket_arn_pattern` | S3 bucket ARN pattern for access | `arn:aws:s3:::nvisionx*` |
| `enable_bedrock_access` | Create Bedrock access role | `false` |
| `bedrock_role_name` | Bedrock role name | `""` |

### Other
| Name | Description | Default |
|------|-------------|---------|
| `create_bastion_role` | Create bastion EC2 role | `false` |
| `enable_opensearch` | Create OpenSearch snapshot role | `false` |
| `create_vpc_flow_logs_role` | Create VPC flow logs role | `false` |

---

## Outputs

| Name | Description |
|------|-------------|
| `eks_cluster_iam_role_arn` | EKS cluster IAM role ARN |
| `eks_auto_node_iam_role_arn` | EKS Auto node role ARN |
| `eks_managed_node_group_iam_role_arns` | Map of node group role ARNs |
| `ebs_csi_iam_role_arn` | EBS CSI driver role ARN |
| `efs_csi_iam_role_arn` | EFS CSI driver role ARN |
| `cluster_autoscaler_iam_role_arn` | Cluster Autoscaler role ARN |
| `lb_controller_iam_role_arn` | Load Balancer Controller role ARN |
| `postgres_backup_iam_role_arn` | Postgres backup role ARN |
| `app_s3_iam_role_arn` | App S3 access role ARN |
| `bedrock_iam_role_arn` | Bedrock access role ARN |
| `bastion_eks_admin_role_arn` | Bastion EC2 role ARN |
| `bastion_iam_instance_profile_name` | Bastion instance profile name |
| `vpc_flow_logs_role_arn` | VPC Flow Logs role ARN |

---

## Requirements

| Name | Version |
|------|---------|
| Terraform | >= 1.5.7 |
| AWS Provider | ~> 6.0 |
