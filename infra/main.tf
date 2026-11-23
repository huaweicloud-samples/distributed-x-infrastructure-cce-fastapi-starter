terraform {
  required_version = ">= 1.5"

  required_providers {
    huaweicloud = {
      source  = "huaweicloud/huaweicloud"
      version = "~> 1.70"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0"
    }
  }

  backend "local" {}
}

provider "huaweicloud" {
  region     = var.region
  domain_id  = "72f076e16a7a4eb49c97cbf59a533c3b"
  project_id = "cc2cb3d01b0c46798d77c4cd8ecf6b7e"
}

locals {
  availability_zones = ["cn-north-4a", "cn-north-4b"]
}

# RDS PostgreSQL 密码：仅使用 RDS 允许的特殊字符 ~!@#%^*-_=+?
resource "random_password" "db_password" {
  length           = 20
  special          = true
  override_special = "~!@#%^*-_=+?"
}

resource "random_password" "app_secret" {
  length  = 64
  special = false
}

# CCE 节点密码：使用 RDS 兼容字符集
resource "random_password" "node_password" {
  length           = 20
  special          = true
  override_special = "~!@#%^*-_=+?"
}
