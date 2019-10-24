variable "region" {
  default = "us-east-1"
}

variable "profile" {
  default = "dev"
}

variable "cidrBlock" {
  default = "192.168.0.0/16"
}

variable "vpcName" {
  default = "vpc-dev-1"
}

variable "subnetBlock" {
  default = ["192.168.1.0/24", "192.168.2.0/24", "192.168.3.0/24"]
}

variable "public_key_value"{
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC1+tMAQX4aXG+ST6zMHAcSAmpujO1cAp2rI+b0ogx3/6pBjDgbNJPINX3PUSymUaRe3apIxcvTlQ1MGG5jnuwH6ZWiU4RKk29QgsRRIEUwfLjUX5LGYOiXGW0Fvix8VNDBcr+ouvhmVWJ/Tl5xLL0/s7Js0c7q2F574c6oh0f05nLfdtU4lcFuw1rviFrwd05H8BlAhkaEenShkjfhBTUSQkem3s4j9eOZzDvn1ijfXgZ6uTmZgeF+ra8UOFB9MxbsFvdpDx68BBXcZB79YRZl7hOLdXVgCGfBiAQOKcag1SLQwhI7z4CRmCJdIMj2Y5zwLUINMWCmRtAnJgpiXP2p suhas1602@ubuntu"
}

variable "amiId" {
  default = "ami-0b138ed392f1a8a6e"
}

variable "passwd" {
    default = "suhabhi71"
}

variable "bucketName" {
    default = "webapp.suhaspasricha.com"
}