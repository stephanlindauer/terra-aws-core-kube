resource "aws_route53_record" "kubernetes" {
  zone_id = "${var.route53_zone_id}"
  name    = "${var.subdomain_name}"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.k8s-master.public_ip}"]
}
