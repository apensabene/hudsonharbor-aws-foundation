# Security Policy

## Supported Versions

Only the latest state of the `main` branch is actively maintained and supported with security updates.

| Branch / Version | Supported |
| ---------------- | --------- |
| `main`           | Yes       |
| Older commits    | No        |

## Reporting a Vulnerability

Please **do not** report security vulnerabilities, exposed AWS account identifiers, IAM policy issues, or CI/CD misconfigurations through public GitHub Issues or Pull Requests.

Instead, report vulnerabilities privately via one of the following channels:

1. **GitHub Private Vulnerability Reporting:** Use the **Report a vulnerability** button under the **Security** tab of `apensabene/hudsonharbor-aws-foundation`.
2. **Direct Contact:** Email **apensabene@pm.me** with the subject line `[SECURITY] hudsonharbor-aws-foundation - <Brief Summary>`.

### What to Include
* Description of the issue and affected file(s) (`main.tf`, `oidc.tf`, `.github/workflows/terraform.yml`, etc.)
* Potential impact (e.g., overly permissive IAM trust condition, SCP bypass, or state exposure)
* Steps to reproduce or suggested remediation

### Response Timeline
* **Initial Acknowledgment:** Within 48 hours
* **Triage & Remediation Assessment:** Within 5 business days

## Security Architecture & Baseline Controls

This repository enforces the following security practices:
* **Zero Static Cloud Credentials:** GitHub Actions authenticates to AWS exclusively via short-lived OpenID Connect (OIDC) federation (`sts:AssumeRoleWithWebIdentity`) scoped to `repo:apensabene/hudsonharbor-aws-foundation`.
* **State & Secret Isolation:** Terraform state (`*.tfstate*`), `.terraform/` plugin caches, and local `*.tfvars` files are excluded from version control via `.gitignore` and stored in encrypted remote S3 state.
* **Preventive Organization Guardrails:** AWS Organizations Service Control Policies (SCPs) enforce baseline security boundaries across Organizational Units.
