resource "aws_key_pair" "publicKey" {
  key_name   = "csye_app1"
  public_key = var.public_key_value
}

resource "aws_db_instance" "db_instance" {
  allocated_storage = 20
  engine = "postgres"
  engine_version = "10.10"
  instance_class = "db.t2.medium"
  multi_az = false
  identifier = "csye6225-fall2019"
  username = "dbuser"
  password = var.passwd
  publicly_accessible = true
  name = "csye6225"
  port = "5432"
  
}

resource "aws_instance" "instance" {
  ami           = var.amiId
  instance_type = "t2.micro"
  key_name = "${aws_key_pair.publicKey.key_name}"
  security_groups = ["${aws_security_group.applicationSc.name}"]
  disable_api_termination = false 
  root_block_device {
    volume_size = "20"
    volume_type = "gp2"
  }
}


resource "aws_security_group" "applicationSc" {
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
