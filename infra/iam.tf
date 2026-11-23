# IAM 委托：CCE 集群访问 SWR 和 RDS
# 注意：此委托已通过首次部署创建，后续部署因名称冲突无法重建。
# 如需重新创建，先在 IAM 控制台删除 cce-fastapi-starter-cce-agency，再取消注释。

# resource "huaweicloud_identity_agency" "cce" {
#   name                  = "${var.project_name}-cce-agency"
#   description           = "CCE 集群访问 SWR 和 RDS 的委托"
#   duration              = "FOREVER"
#   delegated_domain_name = "GT-dgcmy"
#
#   project_role {
#     project = var.region
#     roles = [
#       "SWR Admin",
#       "RDS FullAccess",
#     ]
#   }
# }
