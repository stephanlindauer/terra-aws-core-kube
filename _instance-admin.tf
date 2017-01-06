data "template_file" "k8s-admin" {
  template = "${file("assets/cloud-config/worker/cloud-config.yml")}"

  vars {
    ETCD_ENDPOINTS = "${join(",", formatlist("http://%s:%s", aws_instance.k8s-etcd.*.private_ip, "2379")  ) }"

    discovery_url = "${file("assets/discovery/etcd_discovery_url.txt")}"

    tls-root-ca     = "${file("assets/tls/ca.pem")}"
    tls-root-ca-key = "${file("assets/tls/ca-key.pem")}"
    tls-client-conf = "${file("assets/tls/api-client.cnf")}"

    MASTER_HOST = "${ aws_instance.k8s-master.private_ip }"

    node_label = "admin"
  }
}

resource "aws_instance" "k8s-admin" {
  count                       = "1"
  ami                         = "${lookup(var.amis, var.region)}"
  instance_type               = "t2.medium"
  subnet_id                   = "${aws_subnet.k8s-public.id}"
  key_name                    = "${var.aws_key_name}"
  private_ip                  = "${var.subnet_prefix}${var.admin_ip_suffix}"
  user_data                   = "${data.template_file.k8s-admin.rendered}"
  associate_public_ip_address = true
  iam_instance_profile        = "${aws_iam_instance_profile.worker_instance_profile.id}"

  tags {
    Name = "k8s-admin"
  }

  vpc_security_group_ids = [
    "${aws_security_group.k8s-admin.id}",
  ]

  depends_on = [
    "aws_instance.k8s-etcd",
    "null_resource.generate-tls",
  ]
}
