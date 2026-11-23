# SSO 集成说明

本应用使用 Auth0 作为身份认证提供商，通过 OAuth 2.0 / OpenID Connect 协议实现单点登录（SSO）。

## Auth0 配置

1. 登录 [Auth0 控制台](https://manage.auth0.com/)
2. 创建新的应用（Regular Web Application）
3. 配置以下 URL：
   - **回调 URL**: `http://<ELB_PUBLIC_IP>/auth/callback`
   - **登出 URL**: `http://<ELB_PUBLIC_IP>`
4. 记录以下信息：
   - **Domain**: `your-tenant.auth0.com`
   - **Client ID**: `your-client-id`
   - **Client Secret**: `your-client-secret`

## 环境变量

以下环境变量需要在 Kubernetes Deployment 中配置：

| 变量名 | 说明 | 示例 |
|--------|------|------|
| `AUTH0_DOMAIN` | Auth0 租户域名 | `your-tenant.auth0.com` |
| `AUTH0_CLIENT_ID` | Auth0 应用 Client ID | `abc123...` |
| `AUTH0_CLIENT_SECRET` | Auth0 应用 Client Secret | `xyz789...` |
| `AUTH0_CALLBACK_URL` | 认证回调 URL | `http://<ELB_IP>/auth/callback` |
| `AUTH0_LOGOUT_URL` | 登出返回 URL | `http://<ELB_IP>` |
| `APP_SECRET_KEY` | Session 加密密钥 | 随机 64 字符串 |

## 认证流程

1. 用户访问应用根路径 `/`
2. 应用检查 Session 中是否有用户信息
3. 若无 → 重定向到 `/login` → Auth0 登录页
4. 用户登录后 → Auth0 回调 `/auth/callback`
5. 应用存储用户信息到 Session → 重定向到原始 URL
6. 后续请求携带 Session Cookie，已认证

## 环境变量传入方式

环境变量通过 Kubernetes Secret + Deployment 传入容器：

1. 将 Auth0 相关配置存入 Kubernetes Secret
2. Deployment 通过 `envFrom` 引用 Secret
3. 应用启动时从环境变量读取配置
