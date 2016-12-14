resource "null_resource" "generate-tls" {
  provisioner "local-exec" {
    command = "MASTER_IP=${var.subnet_prefix}${var.master_ip_suffix} MASTER_FQDN=${var.subdomain_name}.${var.domain_name} ./assets/tls/gen_certs.sh"
  }
}
