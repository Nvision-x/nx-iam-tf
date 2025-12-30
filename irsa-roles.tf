################################################################################
# Unified Pod Identity Module - IAM Separation Deployment Pattern
# Migrated from IRSA to EKS Pod Identity (AWS recommended approach)
################################################################################

module "pod_identity" {
  source = "git::https://github.com/Nvision-x/nx-shared-irsa-tf.git?ref=3f7ed94"
  count  = var.create ? 1 : 0

  # Common parameters - Pod Identity only needs cluster_name
  cluster_name = var.cluster_name

  # Enable specific roles
  enable_bedrock            = var.enable_bedrock_access
  enable_postgres_backup    = var.enable_postgres
  enable_ebs_csi            = true
  enable_cluster_autoscaler = true
  enable_lb_controller      = true

  # Bedrock configuration
  bedrock_role_name             = var.bedrock_role_name
  bedrock_service_accounts      = var.bedrock_service_accounts
  bedrock_capabilities          = var.bedrock_capabilities
  bedrock_excluded_providers    = var.bedrock_excluded_providers
  bedrock_allowed_providers     = var.bedrock_allowed_providers
  bedrock_use_custom_model_arns = var.bedrock_use_custom_model_arns
  bedrock_custom_model_arns     = var.bedrock_custom_model_arns
  bedrock_allowed_regions       = var.bedrock_allowed_regions
  bedrock_agent_arns            = var.bedrock_agent_arns
  bedrock_knowledge_base_arns   = var.bedrock_knowledge_base_arns
  bedrock_guardrail_arns        = var.bedrock_guardrail_arns

  # Postgres Backup configuration
  postgres_backup_role_name       = "${var.db_identifier}-backup-role"
  postgres_db_identifier          = var.db_identifier
  postgres_backup_namespace       = var.postgres_backup_namespace
  postgres_backup_service_account = var.postgres_backup_service_account
  postgres_region                 = var.region
  postgres_account_id             = data.aws_caller_identity.current[0].account_id
  postgres_s3_bucket_arn_pattern  = "arn:aws:s3:::nvisionx*"

  # EBS CSI configuration
  ebs_csi_role_name       = "${var.cluster_name}-ebs-csi"
  ebs_csi_namespace       = "kube-system"
  ebs_csi_service_account = "ebs-csi-controller-sa"

  # Cluster Autoscaler configuration
  cluster_autoscaler_role_name       = var.autoscaler_role_name
  cluster_autoscaler_namespace       = var.namespace
  cluster_autoscaler_service_account = var.autoscaler_service_account

  # Load Balancer Controller configuration
  lb_controller_role_name       = var.lb_controller_role_name
  lb_controller_namespace       = var.namespace
  lb_controller_service_account = var.lb_controller_service_account

  # Application S3 Access configuration
  enable_app_s3_access      = var.enable_app_s3_access
  app_s3_role_name          = var.app_s3_role_name
  app_s3_service_accounts   = var.app_s3_service_accounts
  app_s3_bucket_arn_pattern = var.app_s3_bucket_arn_pattern

  tags = var.tags
}
