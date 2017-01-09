resource "aws_vpc" "main" {
    cidr_block = "10.0.0.0/16"

    tags {
        Name = "VPC Jean-Marie"
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
