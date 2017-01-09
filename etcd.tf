data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
  }
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "etcd" {
    ami = "${data.aws_ami.ubuntu.id}"
    count = 3
    subnet_id = "${element(aws_subnet.fromMainVpc.*.id, count.index)}"
    instance_type = "t2.micro"
    tags {
        Name = "Etcd Jean-Marie"
        Owner = "Jean-Marie"
    }
}
