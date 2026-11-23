# SSH 密钥对：用于 CCE 节点登录（替代密码，规避 ARM64 crypt 问题）
resource "huaweicloud_kps_keypair" "main" {
  name     = "${var.project_name}-keypair"
  key_file = "${path.module}/id_rsa.pub"
}
