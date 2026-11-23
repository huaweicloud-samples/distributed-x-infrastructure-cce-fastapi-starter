# CCE 集群 + 节点池 + SWR 容器镜像仓库

# SWR 组织（容器镜像仓库）
resource "huaweicloud_swr_organization" "main" {
  name = var.project_name
}

# CCE 集群
resource "huaweicloud_cce_cluster" "main" {
  name                   = "${var.project_name}-cluster"
  cluster_type           = "VirtualMachine"
  flavor_id              = var.cce_flavor_id
  vpc_id                 = huaweicloud_vpc.main.id
  subnet_id              = huaweicloud_vpc_subnet.private[0].id
  container_network_type = "vpc-router"
  charging_mode          = "postPaid"

  tags = {
    project = var.project_name
  }
}

# CCE 节点池（使用 SSH 密钥对认证，规避 ARM64 crypt 不可用问题）
resource "huaweicloud_cce_node_pool" "main" {
  cluster_id         = huaweicloud_cce_cluster.main.id
  name               = "${var.project_name}-nodepool"
  flavor_id          = var.cce_node_flavor
  initial_node_count = var.cce_node_count
  subnet_id          = huaweicloud_vpc_subnet.private[0].id
  availability_zone  = local.availability_zones[0]
  key_pair           = huaweicloud_kps_keypair.main.name
  os                  = "Ubuntu 22.04"

  root_volume {
    size       = 40
    volumetype = "SAS"
  }

  data_volumes {
    size       = 100
    volumetype = "SAS"
  }

  tags = {
    project = var.project_name
  }
}

# ELB 负载均衡器（用于对外暴露应用）
resource "huaweicloud_elb_loadbalancer" "main" {
  name                  = "${var.project_name}-elb"
  vpc_id                = huaweicloud_vpc.main.id
  ipv4_subnet_id        = huaweicloud_vpc_subnet.public[0].subnet_id
  availability_zone     = [local.availability_zones[0]]
  charging_mode         = "postPaid"
  bandwidth_size        = 5
  bandwidth_charge_mode = "traffic"
  iptype                = "5_bgp"
  sharetype             = "PER"

  tags = {
    project = var.project_name
  }
}

# ELB 监听器（HTTP）
resource "huaweicloud_elb_listener" "http" {
  name            = "${var.project_name}-listener"
  protocol        = "HTTP"
  protocol_port   = 80
  loadbalancer_id = huaweicloud_elb_loadbalancer.main.id

  default_pool_id = huaweicloud_elb_pool.app.id
}

# ELB 后端服务器组
resource "huaweicloud_elb_pool" "app" {
  name            = "${var.project_name}-pool"
  protocol        = "HTTP"
  lb_method       = "ROUND_ROBIN"
  loadbalancer_id = huaweicloud_elb_loadbalancer.main.id
}

# ELB 健康检查
resource "huaweicloud_elb_monitor" "app" {
  protocol    = "HTTP"
  port        = var.container_port
  interval    = 10
  timeout     = 5
  max_retries = 3
  url_path    = "/health"
  enabled     = true
  pool_id     = huaweicloud_elb_pool.app.id
}
