data "template_file" "k8s-etcd" {
  template = "${file("assets/cloud-config/etcd/cloud-config.yml")}"

  vars {
    /*hack to wait for vpc before looking up ETCD_DISCOVERY_URL file */
    hack          = "${aws_vpc.k8s-production.id}"
    discovery_url = "${file("assets/discovery/etcd_discovery_url.txt")}"
  }
}

resource "aws_instance" "k8s-etcd" {
  count         = "${var.etcd_node_count}"
  ami           = "${lookup(var.amis, var.region)}"
  instance_type = "t2.nano"
  subnet_id     = "${aws_subnet.k8s-public.id}"
  key_name      = "${var.aws_key_name}"
  private_ip    = "${var.subnet_prefix}${var.etcd_first_ip_suffix+count.index}"
  user_data     = "${data.template_file.k8s-etcd.rendered}"

  tags {
    Name = "k8s-etcd-${count.index}"
  }

  vpc_security_group_ids = [
    "${aws_security_group.k8s-etcd.id}",
  ]
}
