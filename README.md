# Hudson Harbor AWS Foundation

Multi-account **AWS Organizations** landing zone and identity/security foundation managed with **Terraform**, featuring Organizational Units (OUs), Service Control Policy (SCP) guardrails, remote S3 state management, and keyless **GitHub Actions OIDC** authentication.

## Architecture Overview

```mermaid
flowchart TB
    subgraph GH["GitHub Actions (apensabene/hudsonharbor-aws-foundation)"]
        CI["Terraform Plan / Validate Workflow<br/>(Keyless OIDC Token)"]
    end

    subgraph AWS_ORG["AWS Organization"]
        MGT["Management Account<br/>(Organization Root & OIDC Provider)"]
        S3[("Terraform State & Lock Store<br/>(S3 / Backend)")]

        subgraph ROOT["Organization Root"]
            SEC_OU["Security-Shared-Services OU<br/>(Security & Shared Accounts)"]
            WL_OU["Workloads OU<br/>(Application & Sandbox Accounts)"]
            SCP["Service Control Policies (SCPs)<br/>Preventive Guardrails"]
        end
    end

    CI -->|"1. OIDC Web Identity Federation<br/>(sts:AssumeRoleWithWebIdentity)"| MGT
    MGT -->|"2. Read / Write State"| S3
    MGT -->|"3. Manage OUs, Accounts & SCPs"| ROOT
    SCP -.->|"Enforces Guardrails Across"| SEC_OU
    SCP -.->|"Enforces Guardrails Across"| WL_OU
