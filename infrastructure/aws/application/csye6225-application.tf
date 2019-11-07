provider "aws" {
  profile = var.profile
  region = var.region
}

resource "aws_key_pair" "publicKey" {
  key_name   = "csye_app1"
  public_key = var.public_key_value
}

resource "aws_db_subnet_group" "rdsSubnetGrp" {
  name       = "main"
  subnet_ids = var.subnetIds
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
  db_subnet_group_name = "${aws_db_subnet_group.rdsSubnetGrp.name}"
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

resource "aws_s3_bucket" "Codedeploy_instance" {
  bucket = var.codedeployBucketName
  acl = "private"
  force_destroy = true
  lifecycle_rule {
    enabled = true
    expiration {
      days = 60
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

resource "aws_iam_role" "CodeDeployEC2ServiceRole" {
  name = "CodeDeployEC2ServiceRole"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
      }
    ]
  }
  EOF
}
resource "aws_iam_role" "CodeDeployServiceRole" {
  name = "CodeDeployServiceRole"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
        "Service": "codedeploy.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
      }
    ]
  }
  EOF
}

resource "aws_iam_role_policy_attachment" "codedeploy-EC2-role-policy-attach" {
  role       = "${aws_iam_role.CodeDeployEC2ServiceRole.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}
resource "aws_iam_role_policy_attachment" "codedeploy-role-policy-attach" {
  role       = "${aws_iam_role.CodeDeployServiceRole.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
}

resource "aws_iam_instance_profile" "CodeDeployEC2ServiceProfile" {
  name = "CodeDeployEC2ServiceProfile"
  role = "${aws_iam_role.CodeDeployEC2ServiceRole.name}"
}

resource "aws_codedeploy_app" "csye6225-webapp" {
  name = "csye6225-webapp"
}

resource "aws_codedeploy_deployment_group" "example" {
  app_name              = "${aws_codedeploy_app.csye6225-webapp.name}"
  deployment_group_name = "csye6225-webapp-deployment"
  service_role_arn      = "${aws_iam_role.CodeDeployServiceRole.arn}"

  ec2_tag_set {
    ec2_tag_filter {
      key   = "Name"
      type  = "KEY_AND_VALUE"
      value = "Webserver"
    }
  }

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }
}

resource "aws_instance" "instance" {
  ami           = var.amiId
  instance_type = "t2.micro"
  key_name = "${aws_key_pair.publicKey.key_name}"
  vpc_security_group_ids = ["${aws_security_group.applicationSc.id}"]
  disable_api_termination = false 
  root_block_device {
    volume_size = "20"
    volume_type = "gp2"
  }
  subnet_id = var.subnetIds[0]
  iam_instance_profile="${aws_iam_instance_profile.CodeDeployEC2ServiceProfile.name}"
  user_data = <<-EOT
#! /bin/bash
cd /home/centos
echo "export DB_USER=dbuser" >> .bashrc
echo "export DB_PASSWORD=suhabhi71" >> .bashrc
echo "export DB_DATABASE_NAME=csye6225" >> .bashrc
echo "export DB_HOST_NAME=${aws_db_instance.db_instance.address}" >> .bashrc
echo "export DB_PORT=5432" >> .bashrc
echo "export S3_BUCKET=${var.bucketName}" >> .bashrc
EOT
  tags = {
    Name = "Webserver"
  }
  depends_on = [aws_db_instance.db_instance]
}

resource "aws_eip" "lb" {
  instance = "${aws_instance.instance.id}"
  vpc      = true
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
  vpc_id = var.vpcId
}

resource "aws_security_group" "applicationSc" {
  name = "application_security_group"
  vpc_id = var.vpcId
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
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}