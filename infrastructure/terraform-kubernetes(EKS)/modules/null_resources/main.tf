resource "null_resource" "install_nginx_ingress" {
  provisioner "local-exec" {
    command = var.command
  }
}