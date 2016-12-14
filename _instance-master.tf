data "template_file" "k8s-master" {
  template = "${file("assets/cloud-config/master/cloud-config.yml")}"

  vars {
    ETCD_ENDPOINTS = "${join(",", formatlist("http://%s:%s", aws_instance.k8s-etcd.*.private_ip, "2379")  ) }"

    discovery_url = "${file("assets/discovery/etcd_discovery_url.txt")}"

    tls-root-ca       = "${file("assets/tls/ca.pem")}"
    tls-apiserver     = "${file("assets/tls/apiserver.pem")}"
    tls-apiserver-key = "${file("assets/tls/apiserver-key.pem")}"
  }
}

resource "aws_instance" "k8s-master" {
  count         = "1"
  ami           = "${lookup(var.amis, var.region)}"
  instance_type = "t2.medium"
  subnet_id     = "${aws_subnet.k8s-public.id}"
  key_name      = "${var.aws_key_name}"
  private_ip    = "${var.subnet_prefix}${var.master_ip_suffix}"
  user_data     = "${data.template_file.k8s-master.rendered}"

  tags {
    Name = "k8s-master"
  }

  vpc_security_group_ids = [
    "${aws_security_group.k8s-master.id}",
  ]

  depends_on = [
    "aws_instance.k8s-etcd",
    "null_resource.generate-tls",
  ]
}
