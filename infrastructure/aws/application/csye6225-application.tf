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

resource "aws_s3_bucket" "Lambda_instance" {
  bucket = var.lambdaBucketName
  acl = "private"
  force_destroy = true
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

  ttl {
    attribute_name = "TimeToExist"
    enabled        = true
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

resource "aws_iam_role_policy_attachment" "EC2RoleS3PolicyAttach" {
  role       = "${aws_iam_role.CodeDeployEC2ServiceRole.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}
resource "aws_iam_role_policy_attachment" "EC2RoleCloudWatchPolicyAttach" {
  role       = "${aws_iam_role.CodeDeployEC2ServiceRole.name}"
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}
resource "aws_iam_role_policy_attachment" "EC2RoleSNSPolicyAttach" {
  role       = "${aws_iam_role.CodeDeployEC2ServiceRole.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonSNSFullAccess"
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

resource "aws_sns_topic" "MyRecipesLambdaTopic" {
  name = "email_request"
}

resource "aws_lambda_function" "MyRecipesLambda" {
  filename      = "../csye6225-fa19-lambda.zip"
  function_name = "MyRecipesLinks"
  role          = "arn:aws:iam::467217763981:role/csye6225-lambda-role"
  handler       = "index.handler"

  runtime = "nodejs10.x"
}

resource "aws_sns_topic_subscription" "MyRecipesLambdaTrigger" {
  topic_arn = "${aws_sns_topic.MyRecipesLambdaTopic.arn}"
  protocol  = "lambda"
  endpoint  = "${aws_lambda_function.MyRecipesLambda.arn}"
}

resource "aws_lambda_permission" "with_sns" {
    statement_id = "AllowExecutionFromSNS"
    action = "lambda:InvokeFunction"
    function_name = "${aws_lambda_function.MyRecipesLambda.arn}"
    principal = "sns.amazonaws.com"
    source_arn = "${aws_sns_topic.MyRecipesLambdaTopic.arn}"
}


// resource "aws_instance" "instance" {
//   ami           = var.amiId
//   instance_type = "t2.micro"
//   key_name = "${aws_key_pair.publicKey.key_name}"
//   vpc_security_group_ids = ["${aws_security_group.applicationSc.id}"]
//   disable_api_termination = false 
//   root_block_device {
//     volume_size = "20"
//     volume_type = "gp2"
//   }
//   subnet_id = var.subnetIds[0]
//   iam_instance_profile="${aws_iam_instance_profile.CodeDeployEC2ServiceProfile.name}"
//   user_data = <<-EOT
// #! /bin/bash
// cd /home/centos
// echo "export DB_USER=dbuser" >> .bashrc
// echo "export DB_PASSWORD=suhabhi71" >> .bashrc
// echo "export DB_DATABASE_NAME=csye6225" >> .bashrc
// echo "export DB_HOST_NAME=${aws_db_instance.db_instance.address}" >> .bashrc
// echo "export DB_PORT=5432" >> .bashrc
// echo "export S3_BUCKET=${var.bucketName}" >> .bashrc
// EOT
//   tags = {
//     Name = "Webserver"
//   }
//   depends_on = [aws_db_instance.db_instance]
// }

resource "aws_launch_configuration" "AutoScalingLaunchConfig" {
  name_prefix   = "asg_launch_config-"
  image_id      = var.amiId
  instance_type = "t2.micro"
  key_name = "${aws_key_pair.publicKey.key_name}"
  associate_public_ip_address = true
  iam_instance_profile="${aws_iam_instance_profile.CodeDeployEC2ServiceProfile.name}"
  security_groups = ["${aws_security_group.applicationSc.id}"]
  user_data = <<-EOT
#! /bin/bash
cd /home/centos
echo "export DB_USER=dbuser" >> .bashrc
echo "export DB_PASSWORD=suhabhi71" >> .bashrc
echo "export DB_DATABASE_NAME=csye6225" >> .bashrc
echo "export DB_HOST_NAME=${aws_db_instance.db_instance.address}" >> .bashrc
echo "export DB_PORT=5432" >> .bashrc
echo "export S3_BUCKET=${var.bucketName}" >> .bashrc
echo "export AWS_REGION=${var.region}" >> .bashrc
echo "export DOMAIN_NAME=${var.domainName}" >> .bashrc
EOT

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_policy" "AutoScalingIncrementPolicy" {
  name                   = "WebServerScaleUpPolicy"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = "${aws_autoscaling_group.AutoScalingGroup.name}"
}

resource "aws_cloudwatch_metric_alarm" "HighUtilizationAlarm" {
  alarm_name          = "CPUAlarmHigh"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "90"

  dimensions = {
    AutoScalingGroupName = "${aws_autoscaling_group.AutoScalingGroup.name}"
  }

  alarm_description = "This metric monitors ec2 high cpu utilization"
  alarm_actions     = ["${aws_autoscaling_policy.AutoScalingIncrementPolicy.arn}"]
}


resource "aws_autoscaling_policy" "AutoScalingDecrementPolicy" {
  name                   = "WebServerScaleDownPolicy"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = "${aws_autoscaling_group.AutoScalingGroup.name}"
}

resource "aws_cloudwatch_metric_alarm" "LowUtilizationAlarm" {
  alarm_name          = "CPUAlarmLow"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "70"

  dimensions = {
    AutoScalingGroupName = "${aws_autoscaling_group.AutoScalingGroup.name}"
  }

  alarm_description = "This metric monitors ec2 low cpu utilization"
  alarm_actions     = ["${aws_autoscaling_policy.AutoScalingDecrementPolicy.arn}"]
}

resource "aws_autoscaling_group" "AutoScalingGroup" {
  max_size = 10
  min_size = 3
  launch_configuration = "${aws_launch_configuration.AutoScalingLaunchConfig.name}"
  vpc_zone_identifier = var.subnetIds
  tag {
    key = "Name"
    value = "Webserver"
    propagate_at_launch = true
  }

  depends_on = [aws_db_instance.db_instance]
}

// resource "aws_eip" "lb" {
//   instance = "${aws_instance.instance.id}"
//   vpc      = true
// }

resource "aws_lb_target_group" "albTargetGroup" {
  name     = "csye6225-target-group"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = var.vpcId
}

resource "aws_lb" "ApplicationLoadBalancer" {
  name               = "csye6225-elb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.elbSc.id}"]
  subnets            = var.subnetIds
}

resource "aws_autoscaling_attachment" "asg_attachment_elb" {
  autoscaling_group_name = "${aws_autoscaling_group.AutoScalingGroup.id}"
  alb_target_group_arn   = "${aws_lb_target_group.albTargetGroup.arn}"
}

resource "aws_lb_listener" "albListener" {
  load_balancer_arn = "${aws_lb.ApplicationLoadBalancer.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.sslCertificateArn

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.albTargetGroup.arn}"
  }
}

data "aws_route53_zone" "Csye6225DomainName" {
  name         = "${var.domainName}."
  private_zone = false
}

resource "aws_route53_record" "Route53AliasRecord" {
  zone_id = "${data.aws_route53_zone.Csye6225DomainName.zone_id}"
  name    = var.domainName
  type    = "A"

  alias {
    name                   = "${aws_lb.ApplicationLoadBalancer.dns_name}"
    zone_id                = "${aws_lb.ApplicationLoadBalancer.zone_id}"
    evaluate_target_health = true
  }
}


resource "aws_security_group_rule" "app_only"{
  type = "ingress"
  from_port = 5432
  to_port = 5432
  protocol = "tcp"
  security_group_id = "${aws_security_group.databaseSc.id}"
  source_security_group_id = "${aws_security_group.applicationSc.id}"
}

resource "aws_security_group" "databaseSc"{
  name = "database_security_group"
  vpc_id = var.vpcId
}

resource "aws_security_group" "elbSc" {
  name = "elb_security_group"
  vpc_id = var.vpcId
  ingress {
    from_port = 443
    to_port = 443
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

resource "aws_security_group_rule" "alb_only"{
  type = "ingress"
  from_port = 3000
  to_port = 3000
  protocol = "tcp"
  security_group_id = "${aws_security_group.applicationSc.id}"
  source_security_group_id = "${aws_security_group.elbSc.id}"
}

resource "aws_security_group" "applicationSc" {
  name = "application_security_group"
  vpc_id = var.vpcId
}