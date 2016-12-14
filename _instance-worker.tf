data "template_file" "k8s-worker" {
  template = "${file("assets/cloud-config/worker/cloud-config.yml")}"
  count    = "${var.worker_count}"

  vars {
    ETCD_ENDPOINTS = "${join(",", formatlist("http://%s:%s", aws_instance.k8s-etcd.*.private_ip, "2379")  ) }"

    discovery_url = "${file("assets/discovery/etcd_discovery_url.txt")}"

    tls-root-ca     = "${file("assets/tls/ca.pem")}"
    tls-root-ca-key = "${file("assets/tls/ca-key.pem")}"
    tls-client-conf = "${file("assets/tls/api-client.cnf")}"

    COUNTER     = "${count.index}"
    MASTER_HOST = "${ aws_instance.k8s-master.private_ip }"
  }
}

resource "aws_instance" "k8s-worker" {
  count         = "${var.worker_count}"
  ami           = "${lookup(var.amis, var.region)}"
  instance_type = "t2.medium"
  subnet_id     = "${aws_subnet.k8s-public.id}"
  key_name      = "${var.aws_key_name}"
  private_ip    = "${var.subnet_prefix}${var.worker_first_ip_suffix+count.index}"
  user_data     = "${element(data.template_file.k8s-worker.*.rendered, count.index)}"

  tags {
    Name = "k8s-worker-${count.index}"
  }

  root_block_device {
    volume_size = 16
  }

  vpc_security_group_ids = [
    "${aws_security_group.k8s-worker.id}",
  ]
}
