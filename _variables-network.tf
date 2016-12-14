variable "subnet_cidr" {
  default = "10.0.1.0/24"
}

variable "subnet_prefix" {
  default = "10.0.1."
}

variable "etcd_first_ip_suffix" {
  default = "4"
}

variable "master_ip_suffix" {
  default = "9"
}

variable "worker_first_ip_suffix" {
  default = "10"
}
