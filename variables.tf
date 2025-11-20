# Extracted from : https://github.com/terraform-aws-modules/terraform-aws-eks/blob/v20.37.0/variables.tf


variable "create" {
  description = "Determines whether to create EKS managed node group or not"
  type        = bool
  default     = true
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "outpost_config" {
  description = "Configuration for the AWS Outpost to provision the cluster on"
  type        = any
  default     = {}
}

variable "cluster_encryption_config" {
  description = "Configuration block with encryption configuration for the cluster. To disable secret encryption, set this value to `{}`"
  type        = any
  default = {
    resources = ["secrets"]
  }
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = ""
}

variable "prefix_separator" {
  description = "The separator to use between the prefix and the generated timestamp for resource names"
  type        = string
  default     = "-"
}

variable "attach_cluster_encryption_policy" {
  description = "Indicates whether or not to attach an additional policy for the cluster IAM role to utilize the encryption key provided"
  type        = bool
  default     = true
}

variable "cluster_compute_config" {
  description = "Configuration block for the cluster compute configuration"
  type        = any
  default     = {}
}

variable "oidc_issuer_url" {
  description = "OIDC issuer URL from the EKS cluster"
  type        = string
  default     = ""
}

################################################################################
# EKS IPV6 CNI Policy
################################################################################

variable "create_cni_ipv6_iam_policy" {
  description = "Determines whether to create an [`AmazonEKS_CNI_IPv6_Policy`](https://docs.aws.amazon.com/eks/latest/userguide/cni-iam-role.html#cni-iam-role-create-ipv6-policy)"
  type        = bool
  default     = false
}

################################################################################
# IRSA
################################################################################

variable "enable_irsa" {
  description = "Determines whether to create an OpenID Connect Provider for EKS to enable IRSA"
  type        = bool
  default     = true
}

variable "openid_connect_audiences" {
  description = "List of OpenID Connect audience client IDs to add to the IRSA provider"
  type        = list(string)
  default     = []
}

variable "include_oidc_root_ca_thumbprint" {
  description = "Determines whether to include the root CA thumbprint in the OpenID Connect (OIDC) identity provider's server certificate(s)"
  type        = bool
  default     = true
}

variable "custom_oidc_thumbprints" {
  description = "Additional list of server certificate thumbprints for the OpenID Connect (OIDC) identity provider's server certificate(s)"
  type        = list(string)
  default     = []
}

################################################################################
# Cluster IAM Role
################################################################################

variable "create_iam_role" {
  description = "Determines whether an IAM role is created for the cluster"
  type        = bool
  default     = true
}

variable "iam_role_arn" {
  description = "Existing IAM role ARN for the cluster. Required if `create_iam_role` is set to `false`"
  type        = string
  default     = null
}

variable "iam_role_name" {
  description = "Name to use on IAM role created"
  type        = string
  default     = null
}

variable "iam_role_use_name_prefix" {
  description = "Determines whether the IAM role name (`iam_role_name`) is used as a prefix"
  type        = bool
  default     = true
}

variable "iam_role_path" {
  description = "The IAM role path"
  type        = string
  default     = null
}

variable "iam_role_description" {
  description = "Description of the role"
  type        = string
  default     = null
}

variable "iam_role_permissions_boundary" {
  description = "ARN of the policy that is used to set the permissions boundary for the IAM role"
  type        = string
  default     = null
}

variable "iam_role_additional_policies" {
  description = "Additional policies to be added to the IAM role"
  type        = map(string)
  default     = {}
}

# TODO - will be removed in next breaking change; user can add the policy on their own when needed
variable "enable_security_groups_for_pods" {
  description = "Determines whether to add the necessary IAM permission policy for security groups for pods"
  type        = bool
  default     = true
}

variable "iam_role_tags" {
  description = "A map of additional tags to add to the IAM role created"
  type        = map(string)
  default     = {}
}

variable "cluster_encryption_policy_use_name_prefix" {
  description = "Determines whether cluster encryption policy name (`cluster_encryption_policy_name`) is used as a prefix"
  type        = bool
  default     = true
}

variable "cluster_encryption_policy_name" {
  description = "Name to use on cluster encryption policy created"
  type        = string
  default     = null
}

variable "cluster_encryption_policy_description" {
  description = "Description of the cluster encryption policy created"
  type        = string
  default     = "Cluster encryption policy to allow cluster role to utilize CMK provided"
}

variable "cluster_encryption_policy_path" {
  description = "Cluster encryption policy path"
  type        = string
  default     = null
}

variable "cluster_encryption_policy_tags" {
  description = "A map of additional tags to add to the cluster encryption policy created"
  type        = map(string)
  default     = {}
}

variable "dataplane_wait_duration" {
  description = "Duration to wait after the EKS cluster has become active before creating the dataplane components (EKS managed node group(s), self-managed node group(s), Fargate profile(s))"
  type        = string
  default     = "30s"
}

variable "enable_auto_mode_custom_tags" {
  description = "Determines whether to enable permissions for custom tags resources created by EKS Auto Mode"
  type        = bool
  default     = true
}

################################################################################
# EKS Auto Node IAM Role
################################################################################

variable "create_node_iam_role" {
  description = "Determines whether an EKS Auto node IAM role is created"
  type        = bool
  default     = true
}

variable "node_iam_role_name" {
  description = "Name to use on the EKS Auto node IAM role created"
  type        = string
  default     = null
}

variable "node_iam_role_use_name_prefix" {
  description = "Determines whether the EKS Auto node IAM role name (`node_iam_role_name`) is used as a prefix"
  type        = bool
  default     = true
}

variable "node_iam_role_path" {
  description = "The EKS Auto node IAM role path"
  type        = string
  default     = null
}

variable "node_iam_role_description" {
  description = "Description of the EKS Auto node IAM role"
  type        = string
  default     = null
}

variable "node_iam_role_permissions_boundary" {
  description = "ARN of the policy that is used to set the permissions boundary for the EKS Auto node IAM role"
  type        = string
  default     = null
}

variable "node_iam_role_additional_policies" {
  description = "Additional policies to be added to the EKS Auto node IAM role"
  type        = map(string)
  default     = {}
}

variable "node_iam_role_tags" {
  description = "A map of additional tags to add to the EKS Auto node IAM role created"
  type        = map(string)
  default     = {}
}

################################################################################
# EKS Managed Node Group
################################################################################

variable "eks_managed_node_groups" {
  description = "Map of EKS managed node group definitions to create"
  type        = any
  default     = {}
}

variable "eks_managed_node_group_defaults" {
  description = "Map of EKS managed node group default configurations"
  type        = any
  default     = {}
}


variable "create_bastion_role" {
  description = "Whether to create the IAM role and instance profile for Bastion"
  type        = bool
  default     = false
}

# Cluster Autoscaler and Load Balancer Controller Roles 

variable "namespace" {
  description = "Namespace where resources will be created"
  type        = string
  default     = "kube-system"
}

variable "autoscaler_role_name" {
  description = "Name of IAM role for cluster autoscaler"
  type        = string
  default     = ""
}

variable "autoscaler_service_account" {
  description = "Service account name for cluster autoscaler"
  type        = string
  default     = ""
}

variable "lb_controller_role_name" {
  description = "Name of IAM role for load balancer controller"
  type        = string
  default     = ""
}

variable "lb_controller_service_account" {
  description = "Service account name for load balancer controller"
  type        = string
  default     = ""
}

################################################################################
# OpenSearch Configuration
################################################################################

variable "enable_opensearch" {
  description = "Enable OpenSearch integration"
  type        = bool
  default     = false
}

variable "domain_name" {
  description = "OpenSearch domain name"
  type        = string
  default     = ""
}

variable "region" {
  description = "AWS region for OpenSearch domain"
  type        = string
  default     = ""
}

################################################################################
# Amazon Bedrock Configuration
################################################################################

variable "enable_bedrock_access" {
  description = "Enable Bedrock IRSA role creation for EKS pods to access Amazon Bedrock. Default is FALSE (disabled)."
  type        = bool
  default     = false
}

variable "bedrock_role_name" {
  description = "Name of IAM role for Bedrock access. Required if enable_bedrock_access is true."
  type        = string
  default     = ""
}

variable "bedrock_service_accounts" {
  description = "List of namespace:serviceaccount pairs that can assume the Bedrock role. Required if enable_bedrock_access is true. Example: ['default:bedrock-app', 'production:ai-service']"
  type        = list(string)
  default     = []
}

################################################################################
# Bedrock Capabilities - Control which API operations are allowed
################################################################################

variable "bedrock_capabilities" {
  description = <<-EOF
    List of Bedrock capabilities to enable (only applies when enable_bedrock_access = true).
    Available options:
    - "invoke"          : Basic model invocation (InvokeModel)
    - "streaming"       : Streaming responses (InvokeModelWithResponseStream)
    - "model_catalog"   : Read model information (ListFoundationModels, GetFoundationModel)
    - "agents"          : Bedrock Agents runtime (InvokeAgent)
    - "knowledge_bases" : Knowledge base access (Retrieve, RetrieveAndGenerate)
    - "guardrails"      : Apply guardrails (ApplyGuardrail)

    Default includes basic invocation, streaming, and model catalog access.
    Note: If Bedrock is disabled (enable_bedrock_access = false), this setting is ignored.
  EOF
  type        = list(string)
  default     = ["invoke", "streaming", "model_catalog"]

  validation {
    condition = alltrue([
      for cap in var.bedrock_capabilities :
      contains(["invoke", "streaming", "model_catalog", "agents", "knowledge_bases", "guardrails"], cap)
    ])
    error_message = "Invalid capability. Valid options: invoke, streaming, model_catalog, agents, knowledge_bases, guardrails"
  }
}

################################################################################
# Bedrock Model Provider Filtering (only applies when enable_bedrock_access = true)
################################################################################

variable "bedrock_excluded_providers" {
  description = <<-EOF
    List of model providers to EXCLUDE from access. Useful when you want all providers except specific ones.
    Only applies when enable_bedrock_access = true.

    Available providers:
    - "anthropic"     : Anthropic Claude models
    - "amazon"        : Amazon Titan models
    - "ai21"          : AI21 Labs Jurassic models
    - "cohere"        : Cohere Command models
    - "meta"          : Meta Llama models
    - "mistral"       : Mistral AI models
    - "stability"     : Stability AI image models

    Example: ["anthropic", "cohere"] will block Anthropic and Cohere models
    Note: This is ignored if bedrock_use_custom_model_arns = true
  EOF
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for provider in var.bedrock_excluded_providers :
      contains(["anthropic", "amazon", "ai21", "cohere", "meta", "mistral", "stability"], provider)
    ])
    error_message = "Invalid provider. Valid options: anthropic, amazon, ai21, cohere, meta, mistral, stability"
  }
}

variable "bedrock_allowed_providers" {
  description = <<-EOF
    List of model providers to ALLOW access to. If empty, all providers are allowed (except those in excluded_providers).
    If specified, ONLY these providers will be accessible.
    Only applies when enable_bedrock_access = true.

    Available providers: anthropic, amazon, ai21, cohere, meta, mistral, stability

    Example: ["amazon", "ai21"] will ONLY allow Amazon and AI21 models
    Note: bedrock_excluded_providers is applied after this filter
    Note: This is ignored if bedrock_use_custom_model_arns = true
  EOF
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for provider in var.bedrock_allowed_providers :
      contains(["anthropic", "amazon", "ai21", "cohere", "meta", "mistral", "stability"], provider)
    ])
    error_message = "Invalid provider. Valid options: anthropic, amazon, ai21, cohere, meta, mistral, stability"
  }
}

variable "bedrock_use_custom_model_arns" {
  description = "Set to true to use bedrock_custom_model_arns instead of auto-generated ARNs based on provider filters. Use this for advanced scenarios requiring specific model versions."
  type        = bool
  default     = false
}

variable "bedrock_custom_model_arns" {
  description = <<-EOF
    Custom list of Bedrock model ARNs (only used if bedrock_use_custom_model_arns = true). Examples:
    - All models in all regions: ["arn:aws:bedrock:*::foundation-model/*"]
    - All models in specific region: ["arn:aws:bedrock:us-east-1::foundation-model/*"]
    - Specific model family: ["arn:aws:bedrock:*::foundation-model/anthropic.claude*"]
    - Specific model version: ["arn:aws:bedrock:us-east-1::foundation-model/anthropic.claude-3-sonnet-20240229-v1:0"]
  EOF
  type        = list(string)
  default     = ["arn:aws:bedrock:*::foundation-model/*"]
}

variable "bedrock_allowed_regions" {
  description = "List of AWS regions where Bedrock API calls are allowed. Provides additional security control beyond model ARNs."
  type        = list(string)
  default     = ["us-east-1", "us-west-2"]
}

################################################################################
# Bedrock Advanced Features - ARNs for Agents, Knowledge Bases, Guardrails
################################################################################

variable "bedrock_agent_arns" {
  description = <<-EOF
    List of Bedrock Agent ARNs allowed for access (required if 'agents' capability is enabled).
    Examples:
    - All agents: ["arn:aws:bedrock:*:*:agent/*"]
    - Specific agent: ["arn:aws:bedrock:us-east-1:123456789012:agent/AGENT123"]
  EOF
  type        = list(string)
  default     = ["arn:aws:bedrock:*:*:agent/*"]
}

variable "bedrock_knowledge_base_arns" {
  description = <<-EOF
    List of Bedrock Knowledge Base ARNs allowed for access (required if 'knowledge_bases' capability is enabled).
    Examples:
    - All knowledge bases: ["arn:aws:bedrock:*:*:knowledge-base/*"]
    - Specific KB: ["arn:aws:bedrock:us-east-1:123456789012:knowledge-base/KB123"]
  EOF
  type        = list(string)
  default     = ["arn:aws:bedrock:*:*:knowledge-base/*"]
}

variable "bedrock_guardrail_arns" {
  description = <<-EOF
    List of Bedrock Guardrail ARNs (required if 'guardrails' capability is enabled).
    Examples:
    - All guardrails: ["arn:aws:bedrock:*:*:guardrail/*"]
    - Specific guardrail: ["arn:aws:bedrock:us-east-1:123456789012:guardrail/GUARD123"]
  EOF
  type        = list(string)
  default     = ["arn:aws:bedrock:*:*:guardrail/*"]
}

variable "enable_postgres" {
  description = "Flag to enable/disable PostgreSQL and related resources"
  type        = bool
  default     = true
}

variable "db_identifier" {
  description = "The identifier for the RDS instance"
  type        = string
  default     = ""
}

variable "postgres_backup_service_account" {
  description = "Kubernetes service account name for PostgreSQL backup"
  type        = string
  default     = "databases-postgres-backup-sa"
}

variable "postgres_backup_namespace" {
  description = "Kubernetes namespace for PostgreSQL backup service account"
  type        = string
  default     = "default"
}
