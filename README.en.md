# distributed-x-infrastructure-cce-fastapi-starter

![License: MIT No Attribution](https://img.shields.io/badge/License-MIT_No_Attribution-blue.svg)
> A FastAPI cloud-native starter kit on Huawei Cloud CCE, integrated with RDS PostgreSQL and Auth0 SSO.

## 1. Overview

### Introduction

This project is a FastAPI cloud-native starter example based on Huawei Cloud CCE (Cloud Container Engine), using RDS for PostgreSQL as the database and Auth0 for SSO single sign-on. The project includes complete Terraform infrastructure code, container image build files, and Kubernetes deployment manifests.

---

## 2. Table of Contents

- [1. Overview](#1-overview)
- [2. Table of Contents](#2-table-of-contents)
- [3. Architecture Diagram](#3-architecture-diagram)
- [4. Highlights](#4-highlights)
- [5. Cloud Services Used](#5-cloud-services-used)
- [6. Prerequisites](#6-prerequisites)
- [7. Quick Start](#7-quick-start)
- [8. Step-by-Step Deployment](#8-step-by-step-deployment)
- [9. Usage / Verification](#9-usage--verification)
- [10. Cleanup](#10-cleanup)
- [11. Detailed Explanation](#11-detailed-explanation)
- [12. Dependencies](#12-dependencies)
- [13. FAQ / Troubleshooting](#13-faq--troubleshooting)
- [14. Contributing](#14-contributing)
- [15. License](#15-license)
- [16. Contact / Maintainers](#16-contact--maintainers)

### Directory structure

```
.
├── infra/                    # Terraform infrastructure code
│   ├── main.tf               # Provider config + random passwords
│   ├── variables.tf          # Input variables
│   ├── network.tf            # VPC + subnets + EIP
│   ├── security.tf           # Security group rules
│   ├── cce.tf                # CCE cluster + node pool + ELB + SWR
│   ├── rds.tf                # RDS PostgreSQL + CSMS
│   ├── iam.tf                # IAM agency
│   └── outputs.tf            # Output variables
├── src/
│   ├── app/                  # Application code
│   │   ├── hello-world.py    # FastAPI application
│   │   ├── Dockerfile        # Container build
│   │   └── requirements.txt  # Python dependencies
│   └── manifests/            # Kubernetes deployment manifests
│       ├── deployment.yaml   # Deployment
│       ├── service.yaml      # Service
│       └── secret.yaml       # Secret
├── docs/
│   ├── architecture.md       # Architecture documentation
│   ├── deployment-guide.md   # Deployment guide
│   └── sso-integration.md    # SSO integration guide
└── LICENSE                   # MIT No Attribution
```

---

## 3. Architecture Diagram

```
User → EIP → ELB → CCE (FastAPI container) → RDS PostgreSQL
                                    ↘ CSMS (credential management)
                                    ↘ SWR (image repository)
                                    ↘ IAM agency
```

See the [Architecture Documentation](docs/architecture.md) for details.

---

## 4. Highlights

- **Cloud-native deployment**: CCE managed Kubernetes cluster with containerized FastAPI application
- **Managed database**: RDS for PostgreSQL with built-in backup and high availability
- **Credential management**: CSMS securely stores the database password, no need to write it into code or configuration files
- **SSO integration**: Auth0 OAuth 2.0 / OIDC protocol for single sign-on
- **Infrastructure as Code**: Terraform one-click deployment of all cloud resources
- **Network isolation**: VPC + public/private subnets + security groups, least-privilege access

---

## 5. Cloud Services Used

| Service | Purpose | Flavor |
|-|-|-|
| CCE (Cloud Container Engine) | Managed Kubernetes cluster | cce.s1.small |
| RDS for PostgreSQL | Managed database | rds.pg.n1.large.2 |
| CSMS (Credential Management) | Database password storage | — |
| ELB (Elastic Load Balance) | Expose the application externally | — |
| SWR (Image Repository) | Container image storage | — |
| VPC + Subnets + Security Groups | Network isolation | — |
| EIP | Public network access | — |
| IAM agency | CCE cluster permissions | — |

---

## 6. Prerequisites

- Huawei Cloud account (real-name verified)
- AK/SK (created on the "My Credentials" page)
- Terraform >= 1.5
- kubectl
- Docker
- Auth0 account

---

## 7. Quick Start

```bash
# 1. Configure credentials
export HW_ACCESS_KEY="your-access-key"
export HW_SECRET_KEY="your-secret-key"

# 2. Deploy infrastructure
cd infra
terraform init
terraform apply \
  -var="auth0_domain=your-tenant.auth0.com" \
  -var="auth0_client_id=your-client-id" \
  -var="auth0_client_secret=your-client-secret"

# 3. Build and push image
# 4. Deploy K8s manifests
# 5. Configure ELB backend
```

See the [Deployment Guide](docs/deployment-guide.md) for detailed steps.

---

## 8. Step-by-Step Deployment

See the [Deployment Guide](docs/deployment-guide.md), which includes the following steps:

1. Configure Huawei Cloud credentials
2. Deploy Terraform infrastructure
3. Retrieve output information
4. Build and push the container image
5. Configure Kubernetes manifests
6. Configure the ELB backend
7. Update the Auth0 callback URL
8. Verify deployment

---

## 9. Usage / Verification

### Usage

After deployment, access the application via the ELB public IP:

```bash
# Health check
curl http://<ELB_PUBLIC_IP>/health
# Expected: {"message": "Healthy"}

# Access the app (will redirect to Auth0 login)
curl -I http://<ELB_PUBLIC_IP>/
# Expected: 302 Redirect to /login

# After login, the following endpoints are available:
# GET  /         — Home page (requires authentication)
# GET  /health   — Health check
# POST /create   — Create database table
# GET  /query    — Query database
```

For SSO integration details, see the [SSO Documentation](docs/sso-integration.md).

After deployment, follow these steps to verify that the business functionality works before considering the delivery complete.

---

## 10. Cleanup

```bash
cd infra
terraform destroy \
  -var="auth0_domain=your-tenant.auth0.com" \
  -var="auth0_client_id=your-client-id" \
  -var="auth0_client_secret=your-client-secret"
```

To avoid leftover resources, follow this section to clean up.

---

## 11. Detailed Explanation

- [Architecture Documentation](docs/architecture.md) — Huawei Cloud architecture design and component description
- [Deployment Guide](docs/deployment-guide.md) — Complete step-by-step deployment guide
- [SSO Integration](docs/sso-integration.md) — Auth0 single sign-on configuration guide

---

## 12. Dependencies

| Dependency | Version requirement | Description |
|-|-|-|
| Terraform | >= 1.5 | Infrastructure deployment |
| kubectl | Latest | Kubernetes manifest deployment |
| Docker | Latest | Container image build |
| Python | 3.12 | FastAPI application runtime |

---

## 13. FAQ / Troubleshooting

### FAQ

**Q: Why use an SSH key pair instead of a password to log into CCE nodes?**
A: On ARM64 architecture the crypt tool is unavailable and password setting fails, so an SSH key pair is used instead.

**Q: Why is the IAM agency commented out?**
A: The agency was created during the first deployment; subsequent deployments cannot recreate it due to a name conflict. To recreate it, first delete the corresponding agency in the IAM console, then uncomment it.

**Q: Why does RDS use a single availability zone?**
A: This sample is for introductory demonstration; for production, enable cross-AZ disaster recovery.

---

## 14. Contributing

Issues and Pull Requests are welcome. Please ensure all verification checks pass before submitting.

---

## 15. License

[MIT No Attribution](LICENSE)

---

## 16. Contact / Maintainers
| Item | Content |
|---|---|
| **Creator** | [dgc-git](https://github.com/dgc-git) |
| **Maintainer** | [dgc-git](https://github.com/dgc-git) |
| **Contact** | GitHub Issues / PR (see [Section 14](#14-contributing)) |
