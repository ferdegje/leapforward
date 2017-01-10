resource "aws_vpc" "main" {
    cidr_block = "10.0.0.0/16"

    tags {
        Name = "VPC Jean-Marie"
        Owner = "${var.ownerName}"
    }
}

resource "aws_internet_gateway" "gw" {
    vpc_id = "${aws_vpc.main.id}"

    tags {
        Name = "IG Jean-Marie"
        Owner = "${var.ownerName}"
    }
}

resource "aws_route_table" "r" {
    vpc_id = "${aws_vpc.main.id}"
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.gw.id}"
    }

    tags {
        Name = "Jean-Marie"
        Owner = "${var.ownerName}"
    }
}

variable "availability_zones" {
  type    = "map"
  default = {
    eu-west-1 = "eu-west-1a,eu-west-1b,eu-west-1c"
  }
}

resource "aws_subnet" "fromMainVpc" {
  vpc_id            = "${aws_vpc.main.id}"
  count             = 3
  availability_zone = "${element(split(",", lookup(var.availability_zones, var.region)), count.index)}"
  cidr_block        = "${cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)}"
  tags {
      Name = "Subnet Jean-Marie"
      Owner = "${var.ownerName}"
  }
}

resource "aws_route_table_association" "a" {
    count = 3
    subnet_id = "${element(aws_subnet.fromMainVpc.*.id, count.index)}"
    route_table_id = "${aws_route_table.r.id}"
}

resource "aws_security_group" "etcd" {
  name = "jeanmarie_etcd"
  description = "Allow all required traffic for etcd"

  vpc_id = "${aws_vpc.main.id}"

  ingress {
    protocol = "ICMP"
    from_port = 8
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol = "TCP"
    from_port = 22
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol = "TCP"
    from_port = 80
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol = "TCP"
    from_port = 443
    to_port = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "Jean-Marie"
    Owner = "${var.ownerName}"
  }
}
