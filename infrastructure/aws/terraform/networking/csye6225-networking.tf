
provider "aws" {
  profile = var.profile
  region  = var.region
}

resource "aws_key_pair" "publicKey" {
  key_name   = "csye_app1"
  public_key = var.public_key_value
}

resource "aws_security_group" "application" {
  name = "application_security"
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 3000
    to_port = 3000
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_instance" "instance" {
  ami           = var.amiId
  instance_type = "t2.micro"
  key_name = "${aws_key_pair.publicKey.key_name}"
  security_groups = ["${aws_security_group.application.name}"]
}
resource "aws_vpc" "main" {
  cidr_block = var.cidrBlock

  tags = {
    Name = var.vpcName
  }
}

resource "aws_subnet" "subnet1" {
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = var.subnetBlock[0]
  availability_zone = "${var.region}a"
}
resource "aws_subnet" "subnet2" {
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = var.subnetBlock[1]
  availability_zone = "${var.region}b"
}
resource "aws_subnet" "subnet3" {
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = var.subnetBlock[2]
  availability_zone = "${var.region}c"
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.main.id}"
}

resource "aws_route_table" "r" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }
}

resource "aws_route_table_association" "a1" {
  subnet_id      = "${aws_subnet.subnet1.id}"
  route_table_id = "${aws_route_table.r.id}"
}

resource "aws_route_table_association" "a2" {
  subnet_id      = "${aws_subnet.subnet2.id}"
  route_table_id = "${aws_route_table.r.id}"
}

resource "aws_route_table_association" "a3" {
  subnet_id      = "${aws_subnet.subnet3.id}"
  route_table_id = "${aws_route_table.r.id}"
}
