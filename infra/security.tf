# 安全组：CCE 应用安全组 + RDS 数据库安全组

resource "huaweicloud_networking_secgroup" "app" {
  name        = "${var.project_name}-app-sg"
  description = "安全组 for CCE 应用节点"
}

# 应用安全组：入站允许容器端口
resource "huaweicloud_networking_secgroup_rule" "app_ingress" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = var.container_port
  port_range_max    = var.container_port
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = huaweicloud_networking_secgroup.app.id
}

# 应用安全组：入站允许健康检查
resource "huaweicloud_networking_secgroup_rule" "app_health" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = huaweicloud_networking_secgroup.app.id
}

# 应用安全组：出站全部允许
resource "huaweicloud_networking_secgroup_rule" "app_egress" {
  direction         = "egress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 1
  port_range_max    = 65535
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = huaweicloud_networking_secgroup.app.id
}

# 数据库安全组
resource "huaweicloud_networking_secgroup" "db" {
  name        = "${var.project_name}-db-sg"
  description = "安全组 for RDS 数据库"
}

# 数据库安全组：允许 VPC 子网访问 5432 端口
resource "huaweicloud_networking_secgroup_rule" "db_ingress" {
  direction            = "ingress"
  ethertype            = "IPv4"
  protocol             = "tcp"
  port_range_min       = 5432
  port_range_max       = 5432
  remote_ip_prefix     = "10.0.0.0/16"
  security_group_id    = huaweicloud_networking_secgroup.db.id
}

# 数据库安全组：允许 CCE 容器网络访问 5432 端口
# CCE vpc-router 模式下 Pod IP 在 172.16.0.0/16，需要单独放通
resource "huaweicloud_networking_secgroup_rule" "db_ingress_container" {
  direction            = "ingress"
  ethertype            = "IPv4"
  protocol             = "tcp"
  port_range_min       = 5432
  port_range_max       = 5432
  remote_ip_prefix     = "172.16.0.0/16"
  security_group_id    = huaweicloud_networking_secgroup.db.id
}
