################################################################################
# Amazon Bedrock IRSA (IAM Role for Service Accounts)
################################################################################

locals {
  # Map of capability to IAM actions
  bedrock_capability_actions = {
    invoke          = ["bedrock:InvokeModel"]
    streaming       = ["bedrock:InvokeModelWithResponseStream"]
    model_catalog   = ["bedrock:ListFoundationModels", "bedrock:GetFoundationModel"]
    agents          = ["bedrock-agent-runtime:InvokeAgent"]
    knowledge_bases = ["bedrock-agent-runtime:Retrieve", "bedrock-agent-runtime:RetrieveAndGenerate"]
    guardrails      = ["bedrock:ApplyGuardrail"]
  }

  # Provider to model ARN prefix mapping
  bedrock_provider_prefixes = {
    anthropic = "anthropic."
    amazon    = "amazon."
    ai21      = "ai21."
    cohere    = "cohere."
    meta      = "meta."
    mistral   = "mistral."
    stability = "stability."
  }

  # Determine which providers are allowed
  # If allowed_providers is specified, use only those; otherwise use all providers
  base_allowed_providers = length(var.bedrock_allowed_providers) > 0 ? var.bedrock_allowed_providers : keys(local.bedrock_provider_prefixes)

  # Filter out excluded providers
  final_allowed_providers = [
    for provider in local.base_allowed_providers :
    provider if !contains(var.bedrock_excluded_providers, provider)
  ]

  # Generate model ARNs based on provider filtering
  # This is only used when bedrock_use_custom_model_arns is false
  auto_generated_model_arns = [
    for provider in local.final_allowed_providers :
    "arn:aws:bedrock:*::foundation-model/${local.bedrock_provider_prefixes[provider]}*"
  ]

  # Determine final model ARNs to use
  # Priority: 1. Custom ARNs if enabled, 2. Legacy variable for backward compat, 3. Auto-generated
  final_model_arns = (
    var.bedrock_use_custom_model_arns ? var.bedrock_custom_model_arns :
    var.bedrock_allowed_model_arns != null ? var.bedrock_allowed_model_arns :
    local.auto_generated_model_arns
  )

  # Extract actions for each capability group
  enabled_runtime_actions = flatten([
    for cap in var.bedrock_capabilities :
    lookup(local.bedrock_capability_actions, cap, [])
    if contains(["invoke", "streaming"], cap)
  ])

  enabled_catalog_actions = flatten([
    for cap in var.bedrock_capabilities :
    lookup(local.bedrock_capability_actions, cap, [])
    if cap == "model_catalog"
  ])

  enabled_agent_actions = flatten([
    for cap in var.bedrock_capabilities :
    lookup(local.bedrock_capability_actions, cap, [])
    if contains(["agents", "knowledge_bases"], cap)
  ])

  enabled_guardrail_actions = flatten([
    for cap in var.bedrock_capabilities :
    lookup(local.bedrock_capability_actions, cap, [])
    if cap == "guardrails"
  ])

  # Build dynamic policy statements based on enabled capabilities
  bedrock_policy_statements = concat(
    # Foundation Model Runtime Access (invoke, streaming)
    length(local.enabled_runtime_actions) > 0 ? [{
      Sid    = "BedrockRuntimeAccess"
      Effect = "Allow"
      Action = local.enabled_runtime_actions
      Resource = local.final_model_arns
      Condition = {
        StringEquals = {
          "aws:RequestedRegion" = var.bedrock_allowed_regions
        }
      }
    }] : [],

    # Model Catalog Read Access
    length(local.enabled_catalog_actions) > 0 ? [{
      Sid      = "BedrockModelCatalogReadOnly"
      Effect   = "Allow"
      Action   = local.enabled_catalog_actions
      Resource = "*"
    }] : [],

    # Bedrock Agents Runtime Access
    contains(var.bedrock_capabilities, "agents") ? [{
      Sid    = "BedrockAgentRuntimeAccess"
      Effect = "Allow"
      Action = ["bedrock-agent-runtime:InvokeAgent"]
      Resource = var.bedrock_agent_arns
      Condition = {
        StringEquals = {
          "aws:RequestedRegion" = var.bedrock_allowed_regions
        }
      }
    }] : [],

    # Knowledge Bases Access
    contains(var.bedrock_capabilities, "knowledge_bases") ? [{
      Sid    = "BedrockKnowledgeBaseAccess"
      Effect = "Allow"
      Action = ["bedrock-agent-runtime:Retrieve", "bedrock-agent-runtime:RetrieveAndGenerate"]
      Resource = var.bedrock_knowledge_base_arns
      Condition = {
        StringEquals = {
          "aws:RequestedRegion" = var.bedrock_allowed_regions
        }
      }
    }] : [],

    # Guardrails Access
    contains(var.bedrock_capabilities, "guardrails") ? [{
      Sid    = "BedrockGuardrailsAccess"
      Effect = "Allow"
      Action = ["bedrock:ApplyGuardrail"]
      Resource = var.bedrock_guardrail_arns
      Condition = {
        StringEquals = {
          "aws:RequestedRegion" = var.bedrock_allowed_regions
        }
      }
    }] : []
  )

  # Generate provider list for tagging
  enabled_providers_tag = var.bedrock_use_custom_model_arns || var.bedrock_allowed_model_arns != null ? "custom" : join(",", local.final_allowed_providers)
}

# Bedrock IAM Policy with least privilege and secure access patterns
resource "aws_iam_policy" "bedrock" {
  count       = var.enable_bedrock_access && length(var.bedrock_capabilities) > 0 ? 1 : 0
  name        = "${var.cluster_name}-bedrock-access"
  description = "Bedrock access with capabilities: ${join(", ", var.bedrock_capabilities)} | providers: ${local.enabled_providers_tag}"

  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = local.bedrock_policy_statements
  })

  tags = merge(
    var.tags,
    {
      Name         = "${var.cluster_name}-bedrock-access"
      Description  = "Bedrock access policy for EKS pods"
      Capabilities = join(",", var.bedrock_capabilities)
      Providers    = local.enabled_providers_tag
      ManagedBy    = "Terraform"
    }
  )
}

# IRSA Role for Bedrock - allows Kubernetes service accounts to assume this role
module "bedrock_irsa_role" {
  count   = var.enable_bedrock_access && var.enable_irsa ? 1 : 0
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.58.0"

  role_name = var.bedrock_role_name

  role_policy_arns = {
    bedrock = aws_iam_policy.bedrock[0].arn
  }

  oidc_providers = {
    eks = {
      provider_arn               = aws_iam_openid_connect_provider.oidc_provider[0].arn
      namespace_service_accounts = var.bedrock_service_accounts
    }
  }

  tags = merge(
    var.tags,
    {
      Name        = var.bedrock_role_name
      Description = "IRSA role for Bedrock access from EKS pods"
      ManagedBy   = "Terraform"
    }
  )
}
