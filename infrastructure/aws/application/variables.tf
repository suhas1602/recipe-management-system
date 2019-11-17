variable "profile" {
  default = "dev"
}

variable "region" {
  default = "us-east-1"
}

variable "public_key_value"{
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC1+tMAQX4aXG+ST6zMHAcSAmpujO1cAp2rI+b0ogx3/6pBjDgbNJPINX3PUSymUaRe3apIxcvTlQ1MGG5jnuwH6ZWiU4RKk29QgsRRIEUwfLjUX5LGYOiXGW0Fvix8VNDBcr+ouvhmVWJ/Tl5xLL0/s7Js0c7q2F574c6oh0f05nLfdtU4lcFuw1rviFrwd05H8BlAhkaEenShkjfhBTUSQkem3s4j9eOZzDvn1ijfXgZ6uTmZgeF+ra8UOFB9MxbsFvdpDx68BBXcZB79YRZl7hOLdXVgCGfBiAQOKcag1SLQwhI7z4CRmCJdIMj2Y5zwLUINMWCmRtAnJgpiXP2p suhas1602@ubuntu"
}

variable "amiId" {
  default = "ami-01f672ef287e11e36"
}

variable "passwd" {
    default = "suhabhi71"
}

variable "bucketName" {
    default = "webapp.suhaspasricha.com"
}

variable "subnetIds" {
  default = ["subnet-01098b21238209ca8","subnet-09de0b7b8ebc6fb0e","subnet-0e298bc02e5dfdad9"]
}

variable "vpcId" {
  default = "vpc-051e27af679c7b395"
}

variable "codedeployBucketName" {
  default = "codedeploy.suhaspasricha.com"
}

variable "lambdaBucketName" {
  default = "lambda.suhaspasricha.com"
}