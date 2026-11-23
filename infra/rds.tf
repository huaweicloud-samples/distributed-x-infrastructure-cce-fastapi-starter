# RDS for PostgreSQL + CSMS 凭据管理

# CSMS 凭据：数据库密码
resource "huaweicloud_csms_secret" "db_password" {
  name        = "${var.project_name}-db-password"
  description = "数据库管理员密码"
  secret_text = random_password.db_password.result
}

# RDS PostgreSQL 实例
resource "huaweicloud_rds_instance" "main" {
  name              = "${var.project_name}-rds"
  flavor            = var.rds_flavor
  vpc_id            = huaweicloud_vpc.main.id
  subnet_id         = huaweicloud_vpc_subnet.private[1].id
  security_group_id = huaweicloud_networking_secgroup.db.id
  availability_zone = [local.availability_zones[0]]
  charging_mode     = "postPaid"

  db {
    type    = "PostgreSQL"
    version = "14"
    password = random_password.db_password.result
    port    = 5432
  }

  volume {
    type = "CLOUDSSD"
    size = var.rds_volume_size
  }

  backup_strategy {
    start_time = "03:00-04:00"
    keep_days  = 1
  }

  tags = {
    project = var.project_name
  }
}
