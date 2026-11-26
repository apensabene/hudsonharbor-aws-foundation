variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "Primary AWS region for IAM Identity Center and state resources"
}

variable "environment" {
  type        = string
  default     = "foundation"
  description = "Environment or foundation stage tag"
}

variable "management_account_id" {
  type        = string
  default     = "545983213937"
  description = "AWS Organizations Management Account ID"
}

variable "delegated_admin_account_id" {
  type        = string
  default     = "716189570980"
  description = "IAM Identity Center Delegated Admin / Security Shared Services Account ID"
}

variable "organization_id" {
  type        = string
  default     = "o-gnt5pa3hyr"
  description = "AWS Organization ID"
}

variable "security_shared_services_account_ids" {
  type        = list(string)
  default     = ["716189570980"]
  description = "Account IDs placed under the Security-Shared-Services OU"
}

variable "workloads_account_ids" {
  type        = list(string)
  default     = []
  description = "Account IDs placed under the Workloads OU"
}