# 网络基础设施：VPC + 子网

resource "huaweicloud_vpc" "main" {
  name = "${var.project_name}-vpc"
  cidr = "10.0.0.0/16"
}

resource "huaweicloud_vpc_subnet" "private" {
  count             = 2
  name              = "${var.project_name}-private-subnet-${count.index}"
  vpc_id            = huaweicloud_vpc.main.id
  cidr              = "10.0.${count.index}.0/24"
  gateway_ip        = "10.0.${count.index}.1"
  availability_zone = local.availability_zones[count.index]
}

resource "huaweicloud_vpc_subnet" "public" {
  count             = 2
  name              = "${var.project_name}-public-subnet-${count.index}"
  vpc_id            = huaweicloud_vpc.main.id
  cidr              = "10.0.${count.index + 10}.0/24"
  gateway_ip        = "10.0.${count.index + 10}.1"
  availability_zone = local.availability_zones[count.index]
}
