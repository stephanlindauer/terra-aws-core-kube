output "master" {
  value = "ssh -i ssh/${var.aws_key_name}.pem core@${ aws_instance.k8s-master.public_ip }"
}

/*
output "workers" {
  value = "${join("", formatlist("\n ssh -i ssh/${var.aws_key_name}.pem core@%s", aws_instance.k8s-worker.*.public_ip))}"
}*/

