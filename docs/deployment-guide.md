# 部署指南

## 前置条件

1. **华为云账号** — 已完成实名认证
2. **AK/SK** — 在「我的凭证」页面创建 Access Key
3. **Terraform** — 已安装 >= 1.5 版本
4. **kubectl** — 已安装（用于部署 Kubernetes 清单）
5. **Docker** — 已安装（用于构建容器镜像）
6. **Auth0 账号** — 已创建应用，获取 Client ID / Secret / Domain

## 部署步骤

### 1. 配置凭证

```bash
export HW_ACCESS_KEY="your-access-key"
export HW_SECRET_KEY="your-secret-key"
```

### 2. 部署基础设施

```bash
cd infra

# 初始化 Terraform
terraform init

# 查看部署计划
terraform plan \
  -var="auth0_domain=your-tenant.auth0.com" \
  -var="auth0_client_id=your-client-id" \
  -var="auth0_client_secret=your-client-secret"

# 确认无误后执行部署
terraform apply \
  -var="auth0_domain=your-tenant.auth0.com" \
  -var="auth0_client_id=your-client-id" \
  -var="auth0_client_secret=your-client-secret"
```

### 3. 获取输出信息

```bash
terraform output
# 记录以下输出：
# - elb_public_ip: ELB 公网 IP
# - rds_endpoint: RDS 连接地址
# - swr_organization: SWR 组织名称
# - app_secret_key: 应用密钥
```

### 4. 构建并推送容器镜像

```bash
cd ../src/app

# 登录 SWR
# 在华为云控制台获取 SWR 登录指令
docker login -u <HW_DOMAIN> -p <SWR_TOKEN> swr.<REGION>.myhuaweicloud.com

# 构建镜像
docker build -t fastapi-app .

# 打标签并推送
docker tag fastapi-app swr.<REGION>.myhuaweicloud.com/<SWR_ORG>/fastapi-app:latest
docker push swr.<REGION>.myhuaweicloud.com/<SWR_ORG>/fastapi-app:latest
```

### 5. 配置 Kubernetes 清单

```bash
cd ../manifests

# 获取 CCE 集群凭证
# 在华为云控制台 → CCE → 集群 → 连接信息 → 获取 kubeconfig
# 将 kubeconfig 保存到 ~/.kube/config

# 编辑 deployment.yaml，替换以下占位符：
# - <SWR_IMAGE_URL>: swr.<REGION>.myhuaweicloud.com/<SWR_ORG>/fastapi-app:latest
# - <RDS_ENDPOINT>: terraform output 的 rds_endpoint
# - <ELB_PUBLIC_IP>: terraform output 的 elb_public_ip
# - <AUTH0_DOMAIN>: 你的 Auth0 域名

# 编辑 secret.yaml，替换以下占位符：
# - <DB_PASSWORD>: 数据库密码（从 CSMS 或 terraform output 获取）
# - <AUTH0_CLIENT_SECRET>: Auth0 Client Secret
# - <APP_SECRET_KEY>: terraform output 的 app_secret_key

# 部署到 CCE
kubectl apply -f secret.yaml
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
```

### 6. 配置 ELB 后端

在华为云控制台 → ELB → 负载均衡器：

1. 选择创建的 ELB 实例
2. 添加后端服务器 — 选择 CCE 节点
3. 配置健康检查 — 路径 `/health`，端口 8000

### 7. 更新 Auth0 回调 URL

在 Auth0 控制台更新应用设置：

- **回调 URL**: `http://<ELB_PUBLIC_IP>/auth/callback`
- **登出 URL**: `http://<ELB_PUBLIC_IP>`

### 8. 验证部署

```bash
# 健康检查
curl http://<ELB_PUBLIC_IP>/health
# 预期: {"message": "Healthy"}

# 访问应用（会重定向到 Auth0 登录）
curl -I http://<ELB_PUBLIC_IP>/
# 预期: 302 Redirect to /login
```

## 清理

```bash
cd infra
terraform destroy \
  -var="auth0_domain=your-tenant.auth0.com" \
  -var="auth0_client_id=your-client-id" \
  -var="auth0_client_secret=your-client-secret"
```
