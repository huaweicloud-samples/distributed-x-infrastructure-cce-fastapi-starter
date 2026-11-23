# 输出

output "cce_cluster_name" {
  description = "CCE 集群名称"
  value       = huaweicloud_cce_cluster.main.name
}

output "cce_cluster_id" {
  description = "CCE 集群 ID"
  value       = huaweicloud_cce_cluster.main.id
}

output "rds_endpoint" {
  description = "RDS 数据库连接地址"
  value       = huaweicloud_rds_instance.main.fixed_ip
  sensitive   = true
}

output "rds_port" {
  description = "RDS 数据库端口"
  value       = 5432
}

output "swr_organization" {
  description = "SWR 组织名称"
  value       = huaweicloud_swr_organization.main.name
}

output "elb_public_ip" {
  description = "ELB 公网 IP 地址"
  value       = huaweicloud_elb_loadbalancer.main.ipv4_address
}

output "app_endpoint" {
  description = "应用访问地址"
  value       = "http://${huaweicloud_elb_loadbalancer.main.ipv4_address}"
}

output "db_password_secret_name" {
  description = "数据库密码凭据名称（CSMS）"
  value       = huaweicloud_csms_secret.db_password.name
}

output "app_secret_key" {
  description = "应用密钥（用于 Session 加密）"
  value       = random_password.app_secret.result
  sensitive   = true
}
