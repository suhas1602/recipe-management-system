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