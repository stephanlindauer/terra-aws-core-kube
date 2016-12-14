resource "null_resource" "discovery_url_get" {
  provisioner "local-exec" {
    command = "curl -s 'https://discovery.etcd.io/new?size=${var.etcd_node_count}' > assets/discovery/etcd_discovery_url.txt"
  }
}
