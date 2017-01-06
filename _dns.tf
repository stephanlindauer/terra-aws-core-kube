resource "aws_route53_record" "kubernetes" {
  zone_id = "${var.route53_zone_id}"
  name    = "${var.subdomain_name}"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.k8s-master.public_ip}"]
}

resource "aws_route53_record" "ingress" {
  zone_id = "${var.route53_zone_id}"
  name    = "ingress"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.k8s-ingress.public_ip}"]
}

resource "aws_route53_record" "api" {
  zone_id = "${var.route53_zone_id}"
  name    = "api"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.k8s-ingress.public_ip}"]
}

resource "aws_route53_record" "web" {
  zone_id = "${var.route53_zone_id}"
  name    = "web"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.k8s-ingress.public_ip}"]
}

resource "aws_route53_record" "grafana" {
  zone_id = "${var.route53_zone_id}"
  name    = "grafana"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.k8s-admin.public_ip}"]
}

resource "aws_route53_record" "kibana" {
  zone_id = "${var.route53_zone_id}"
  name    = "kibana"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.k8s-admin.public_ip}"]
}
