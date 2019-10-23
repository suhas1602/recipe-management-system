variable "region" {
  default = "us-east-1"
}

variable "amiId" {
  default = "ami-0c58cc3411e7b3de4"
}
variable "public_key_value"{
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCURwQHOvNeWfqXndsmTBCAb7RNKuBPCx5gvaouqZsosdmyWY9vUSr9Tx9p4qkw/nyhtMujIKxjrLzM8bGKjkNF6++HT3oLm1Cp/3NJOT5ISodsbFQ7KGiofNApUOKr6I/uDuLdkE0omkVbUWjVPF+2mNJUHZn7x79rFodZKGX3P0GAL749y91/w1i0MGpu2OrtW4Jjnonjk/OqZ9EoOv90I2b2wJ9dZ/CPODdKzFBuZDLq4thdDEvyofRvcnbpcFQJscFlyp2RGc3CV1OSkGVrLVMXhJiOKXMi4Zhf0aS73BlvWBajkzkM/de96Qpr43kKpbMfrxJH096QMqTTezKZ abhishek@abhishek-Inspiron-7773"
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