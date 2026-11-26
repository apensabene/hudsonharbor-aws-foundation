data "aws_organizations_organization" "current" {}

output "organization_arn" {
  value = data.aws_organizations_organization.current.arn
}

output "organization_master_account_id" {
  value = data.aws_organizations_organization.current.master_account_id
}

locals {
  org_root_id = data.aws_organizations_organization.current.roots[0].id

  org_accounts_by_id = {
    for acct in data.aws_organizations_organization.current.accounts : acct.id => acct
  }

  account_ou_map = merge(
    {
      for id in var.security_shared_services_account_ids :
      id => aws_organizations_organizational_unit.security_shared_services.id
    },
    {
      for id in var.workloads_account_ids :
      id => aws_organizations_organizational_unit.workloads.id
    }
  )
}

resource "aws_organizations_organizational_unit" "security_shared_services" {
  name      = "Security-Shared-Services"
  parent_id = local.org_root_id
}

resource "aws_organizations_organizational_unit" "workloads" {
  name      = "Workloads"
  parent_id = local.org_root_id
}

resource "aws_organizations_policy" "baseline_guardrails" {
  name        = "HudsonHarbor-Baseline-Guardrails"
  description = "Prevent leaving organization and protect core audit/identity controls on member accounts"
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "DenyLeaveOrganization"
        Effect   = "Deny"
        Action   = "organizations:LeaveOrganization"
        Resource = "*"
      },
      {
        Sid    = "DenyStopCloudTrailOrDeleteTrails"
        Effect = "Deny"
        Action = [
          "cloudtrail:StopLogging",
          "cloudtrail:DeleteTrail"
        ]
        Resource = "*"
      },
      {
        Sid      = "DenyRootAccountCreation"
        Effect   = "Deny"
        Action   = "iam:CreateVirtualMFADevice"
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:PrincipalType" = "Root"
          }
        }
      }
    ]
  })
}

resource "aws_organizations_policy_attachment" "guardrails_security_ou" {
  policy_id = aws_organizations_policy.baseline_guardrails.id
  target_id = aws_organizations_organizational_unit.security_shared_services.id
}

resource "aws_organizations_policy_attachment" "guardrails_workloads_ou" {
  policy_id = aws_organizations_policy.baseline_guardrails.id
  target_id = aws_organizations_organizational_unit.workloads.id
}

resource "aws_organizations_account" "managed_members" {
  for_each = local.account_ou_map

  name      = local.org_accounts_by_id[each.key].name
  email     = local.org_accounts_by_id[each.key].email
  parent_id = each.value

  lifecycle {
    ignore_changes = [
      name,
      email,
      role_name,
      iam_user_access_to_billing
    ]
  }
}