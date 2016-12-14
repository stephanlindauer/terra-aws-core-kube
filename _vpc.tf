resource "aws_vpc" "k8s-production" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = false

  tags {
    Name = "k8s-production-vpc"
  }
}

resource "aws_subnet" "k8s-public" {
  vpc_id                  = "${aws_vpc.k8s-production.id}"
  cidr_block              = "${var.subnet_cidr}"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "k8s-production" {
  vpc_id = "${aws_vpc.k8s-production.id}"
}

resource "aws_route" "k8s-internet_access" {
  route_table_id         = "${aws_vpc.k8s-production.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.k8s-production.id}"
}

resource "aws_route_table" "k8s-public" {
  vpc_id = "${aws_vpc.k8s-production.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.k8s-production.id}"
  }
}

resource "aws_route_table_association" "k8s-public" {
  subnet_id      = "${aws_subnet.k8s-public.id}"
  route_table_id = "${aws_route_table.k8s-public.id}"
}
