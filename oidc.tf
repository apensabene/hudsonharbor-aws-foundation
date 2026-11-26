variable "github_org" {
  type        = string
  default     = "apensabene"
  description = "GitHub user or organization name"
}

variable "github_repo" {
  type        = string
  default     = "hudsonharbor-aws-foundation"
  description = "GitHub repository name authorized via OIDC"
}

resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1",
    "1c58a3a8518e8759bf075b76b750d4f2df264fcd"
  ]
}

data "aws_iam_policy_document" "github_actions_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "repo:${var.github_org}/${var.github_repo}:ref:refs/heads/main",
        "repo:${var.github_org}/${var.github_repo}:environment:*"
      ]
    }
  }
}

resource "aws_iam_role" "github_actions_tf" {
  name               = "HudsonHarbor-GitHubActions-Terraform"
  assume_role_policy = data.aws_iam_policy_document.github_actions_assume_role.json
}

data "aws_iam_policy_document" "github_actions_foundation" {
  statement {
    sid    = "TerraformStateBucketAccess"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]
    resources = [
      "arn:aws:s3:::hudsonharborid-tfstate-716189570980-us-east-1"
    ]
  }

  statement {
    sid    = "TerraformStateObjectAndLockAccess"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]
    resources = [
      "arn:aws:s3:::hudsonharborid-tfstate-716189570980-us-east-1/foundation/aws-org-iam/*"
    ]
  }

  statement {
    sid    = "OrganizationsFoundationManagement"
    effect = "Allow"
    actions = [
      "organizations:Describe*",
      "organizations:List*",
      "organizations:CreateOrganizationalUnit",
      "organizations:UpdateOrganizationalUnit",
      "organizations:DeleteOrganizationalUnit",
      "organizations:MoveAccount",
      "organizations:CreatePolicy",
      "organizations:UpdatePolicy",
      "organizations:DeletePolicy",
      "organizations:AttachPolicy",
      "organizations:DetachPolicy",
      "organizations:TagResource",
      "organizations:UntagResource"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "IamOidcAndRoleManagement"
    effect = "Allow"
    actions = [
      "iam:GetOpenIDConnectProvider",
      "iam:CreateOpenIDConnectProvider",
      "iam:UpdateOpenIDConnectProviderThumbprint",
      "iam:AddClientIDToOpenIDConnectProvider",
      "iam:TagOpenIDConnectProvider",
      "iam:GetRole",
      "iam:CreateRole",
      "iam:DeleteRole",
      "iam:UpdateAssumeRolePolicy",
      "iam:PutRolePolicy",
      "iam:GetRolePolicy",
      "iam:DeleteRolePolicy",
      "iam:AttachRolePolicy",
      "iam:DetachRolePolicy",
      "iam:TagRole"
    ]
    resources = [
      "arn:aws:iam::${var.management_account_id}:oidc-provider/token.actions.githubusercontent.com",
      "arn:aws:iam::${var.management_account_id}:role/HudsonHarbor-GitHubActions-*"
    ]
  }
}

resource "aws_iam_role_policy" "github_actions_foundation" {
  name   = "HudsonHarbor-GitHubActions-FoundationPolicy"
  role   = aws_iam_role.github_actions_tf.id
  policy = data.aws_iam_policy_document.github_actions_foundation.json
}

output "github_actions_role_arn" {
  value = aws_iam_role.github_actions_tf.arn
}