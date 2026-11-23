# distributed-x-infrastructure-cce-fastapi-starter

![License: MIT No Attribution](https://img.shields.io/badge/License-MIT_No_Attribution-blue.svg)
> 基于 Huawei Cloud CCE 的 FastAPI 云原生入门套件，集成 RDS PostgreSQL 数据库与 Auth0 SSO 单点登录。

## 1. 简介 / Overview

### 简介


本项目是一个基于华为云 CCE（云容器引擎）的 FastAPI 云原生入门示例，使用 RDS for PostgreSQL 作为数据库，通过 Auth0 实现 SSO 单点登录。项目包含完整的 Terraform 基础设施代码、容器镜像构建文件和 Kubernetes 部署清单。

---

## 2. 目录

- [1. 简介 / Overview](#1-简介--overview)
- [2. 目录](#2-目录)
- [3. 架构图](#3-架构图)
- [4. 方案亮点](#4-方案亮点)
- [5. 涉及云服务](#5-涉及云服务)
- [6. 前置条件](#6-前置条件)
- [7. 快速开始](#7-快速开始)
- [8. 分步部署](#8-分步部署)
- [9. 使用方法 / 验证](#9-使用方法--验证)
- [10. 清理资源](#10-清理资源)
- [11. 详细说明](#11-详细说明)
- [12. 依赖](#12-依赖)
- [13. FAQ / 故障排除](#13-faq--故障排除)
- [14. 贡献指南](#14-贡献指南)
- [15. 许可证](#15-许可证)
- [16. 联系方式 / 维护者](#16-联系方式--维护者)

### 目录结构


```
.
├── infra/                    # Terraform 基础设施代码
│   ├── main.tf               # Provider 配置 + 随机密码
│   ├── variables.tf          # 输入变量
│   ├── network.tf            # VPC + 子网 + EIP
│   ├── security.tf           # 安全组规则
│   ├── cce.tf                # CCE 集群 + 节点池 + ELB + SWR
│   ├── rds.tf                # RDS PostgreSQL + CSMS
│   ├── iam.tf                # IAM 委托
│   └── outputs.tf            # 输出变量
├── src/
│   ├── app/                  # 应用代码
│   │   ├── hello-world.py    # FastAPI 应用
│   │   ├── Dockerfile        # 容器构建
│   │   └── requirements.txt  # Python 依赖
│   └── manifests/            # Kubernetes 部署清单
│       ├── deployment.yaml   # Deployment
│       ├── service.yaml      # Service
│       └── secret.yaml       # Secret
├── docs/
│   ├── architecture.md       # 架构说明
│   ├── deployment-guide.md   # 部署指南
│   └── sso-integration.md    # SSO 集成说明
└── LICENSE                   # MIT No Attribution
```

---

## 3. 架构图

```
用户 → EIP → ELB → CCE (FastAPI 容器) → RDS PostgreSQL
                                    ↘ CSMS (凭据管理)
                                    ↘ SWR (镜像仓库)
                                    ↘ IAM 委托
```

详细架构说明请参考 [架构文档](docs/architecture.md)。

---

## 4. 方案亮点

- **云原生部署**：基于 CCE 托管 Kubernetes 集群，容器化 FastAPI 应用
- **托管数据库**：RDS for PostgreSQL，内置备份与高可用
- **凭据管理**：CSMS 安全存储数据库密码，无需写入代码或配置文件
- **SSO 集成**：Auth0 OAuth 2.0 / OIDC 协议实现单点登录
- **基础设施即代码**：Terraform 一键部署全部云资源
- **网络隔离**：VPC + 公私子网 + 安全组，最小权限访问

---

## 5. 涉及云服务

| 服务 | 用途 | 规格 |
|------|------|------|
| CCE (云容器引擎) | 托管 Kubernetes 集群 | cce.s1.small |
| RDS for PostgreSQL | 托管数据库 | rds.pg.n1.large.2 |
| CSMS (凭据管理) | 数据库密码存储 | — |
| ELB (弹性负载均衡) | 对外暴露应用 | — |
| SWR (镜像仓库) | 容器镜像存储 | — |
| VPC + 子网 + 安全组 | 网络隔离 | — |
| EIP | 公网访问 | — |
| IAM 委托 | CCE 集群权限 | — |

---

## 6. 前置条件

- 华为云账号（已完成实名认证）
- AK/SK（在「我的凭证」页面创建）
- Terraform >= 1.5
- kubectl
- Docker
- Auth0 账号

---

## 7. 快速开始

```bash
# 1. 配置凭证
export HW_ACCESS_KEY="your-access-key"
export HW_SECRET_KEY="your-secret-key"

# 2. 部署基础设施
cd infra
terraform init
terraform apply \
  -var="auth0_domain=your-tenant.auth0.com" \
  -var="auth0_client_id=your-client-id" \
  -var="auth0_client_secret=your-client-secret"

# 3. 构建并推送镜像
# 4. 部署 K8s 清单
# 5. 配置 ELB 后端
```

详细部署步骤请参考 [部署指南](docs/deployment-guide.md)。

---

## 8. 分步部署

详见 [部署指南](docs/deployment-guide.md)，包含以下步骤：

1. 配置华为云凭证
2. 部署 Terraform 基础设施
3. 获取输出信息
4. 构建并推送容器镜像
5. 配置 Kubernetes 清单
6. 配置 ELB 后端
7. 更新 Auth0 回调 URL
8. 验证部署

---

## 9. 使用方法 / 验证

### 使用方法


部署完成后，通过 ELB 公网 IP 访问应用：

```bash
# 健康检查
curl http://<ELB_PUBLIC_IP>/health
# 预期: {"message": "Healthy"}

# 访问应用（会重定向到 Auth0 登录）
curl -I http://<ELB_PUBLIC_IP>/
# 预期: 302 Redirect to /login

# 登录后可使用以下端点：
# GET  /         — 首页（需认证）
# GET  /health   — 健康检查
# POST /create   — 创建数据库表
# GET  /query    — 查询数据库
```

SSO 集成说明请参考 [SSO 文档](docs/sso-integration.md)。

部署完成后请按本节步骤自行验证，确认业务功能可用，方可视为交付完成。

---

## 10. 清理资源

```bash
cd infra
terraform destroy \
  -var="auth0_domain=your-tenant.auth0.com" \
  -var="auth0_client_id=your-client-id" \
  -var="auth0_client_secret=your-client-secret"
```

为避免资源残留，请按本节执行清理。

---

## 11. 详细说明

- [架构文档](docs/architecture.md) — 华为云架构设计与组件说明
- [部署指南](docs/deployment-guide.md) — 完整分步部署指引
- [SSO 集成](docs/sso-integration.md) — Auth0 单点登录配置说明

---

## 12. 依赖

| 依赖 | 版本要求 | 说明 |
|------|---------|------|
| Terraform | >= 1.5 | 基础设施部署 |
| kubectl | 最新 | Kubernetes 清单部署 |
| Docker | 最新 | 容器镜像构建 |
| Python | 3.12 | FastAPI 应用运行时 |

---

## 13. FAQ / 故障排除

### FAQ


**Q: 为什么使用 SSH 密钥对而非密码登录 CCE 节点？**
A: ARM64 架构下 crypt 工具不可用，密码设置会失败，因此使用 SSH 密钥对替代。

**Q: IAM 委托为何被注释掉？**
A: 首次部署时委托已创建，后续部署因名称冲突无法重建。如需重新创建，先在 IAM 控制台删除对应委托，再取消注释。

**Q: RDS 为什么使用单可用区？**
A: 本示例为入门演示，生产环境建议开启跨可用区容灾。

---

## 14. 贡献指南

欢迎提交 Issue 和 Pull Request。请确保提交前通过所有验证检查。

---

## 15. 许可证

[MIT No Attribution](LICENSE)

---

## 16. 联系方式 / 维护者
| 项 | 内容 |
|---|---|
| **创建者** | [dgc-git](https://github.com/dgc-git) |
| **维护者** | [dgc-git](https://github.com/dgc-git) |
| **联系方式** | GitHub Issues / PR（见[第 14 节](#14-贡献指南)） |
