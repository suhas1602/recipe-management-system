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
  vpc_security_group_ids = ["${aws_security_group.databaseSc.id}"]
  skip_final_snapshot = true
}

resource "aws_s3_bucket" "S3_instance" {
  bucket = var.bucketName
  acl = "private"
  force_destroy = true
   lifecycle_rule {
    enabled = true
    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
   }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "aws:kms"
      }
    }
 }
}

resource "aws_dynamodb_table" "app_dynamo_table"{
  name = "csye6225"
  hash_key = "Id"
  read_capacity  = 20
  write_capacity = 20
  attribute {
    name = "Id"
    type = "S"
  }

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
  depends_on = [aws_db_instance.db_instance]
}

resource "aws_security_group_rule" "app_only"{
  type = "ingress"
  from_port = 5432
  to_port = 5432
  protocol = "tcp"
  security_group_id = "${aws_security_group.databaseSc.id}"
  source_security_group_id = "${aws_security_group.applicationSc.id}"

}

resource"aws_security_group" "databaseSc"{
  name = "database_security_group"

    ingress{
    from_port = 5432
    to_port = 5432
    protocol = "tcp"
  }

}

resource "aws_security_group" "applicationSc" {
  name = "application_security_group"
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
