variable "region" {
  description = "华为云区域"
  type        = string
  default     = "cn-north-4"
}

variable "project_name" {
  description = "项目名称，用于资源命名前缀"
  type        = string
  default     = "cce-fastapi-starter"
}

variable "cce_flavor_id" {
  description = "CCE 集群规格"
  type        = string
  default     = "cce.s1.small"
}

variable "cce_node_flavor" {
  description = "CCE 节点规格"
  type        = string
  default     = "s6.large.2"
}

variable "cce_node_count" {
  description = "CCE 节点初始数量"
  type        = number
  default     = 2
}

variable "rds_flavor" {
  description = "RDS 实例规格"
  type        = string
  default     = "rds.pg.n1.large.2"
}

variable "rds_volume_size" {
  description = "RDS 存储卷大小（GB）"
  type        = number
  default     = 40
}

variable "db_username" {
  description = "数据库管理员用户名"
  type        = string
  default     = "app"
}

variable "db_name" {
  description = "数据库名称"
  type        = string
  default     = "appdb"
}

variable "container_port" {
  description = "应用容器端口"
  type        = number
  default     = 8000
}

variable "app_image" {
  description = "容器镜像地址（SWR 仓库）"
  type        = string
  default     = ""
}

# Auth0 配置
variable "auth0_domain" {
  description = "Auth0 租户域名（如 your-tenant.auth0.com）"
  type        = string
}

variable "auth0_client_id" {
  description = "Auth0 应用 Client ID"
  type        = string
}

variable "auth0_client_secret" {
  description = "Auth0 应用 Client Secret"
  type        = string
  sensitive   = true
}

variable "auth0_callback_url" {
  description = "Auth0 回调 URL（部署后更新）"
  type        = string
  default     = "https://your-app-url/auth/callback"
}

variable "auth0_logout_url" {
  description = "Auth0 登出 URL（部署后更新）"
  type        = string
  default     = "https://your-app-url"
}
