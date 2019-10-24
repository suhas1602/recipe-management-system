provider "aws" {
  profile = var.profile
  region  = var.region
}

module "networking" {
  source = "./networking"

  cidrBlock   = var.cidrBlock
  vpcName     = var.vpcName
  subnetBlock = var.subnetBlock
  region      = var.region
}

module "application" {
  source = "./application"

  public_key_value = var.public_key_value
  amiId = var.amiId
  passwd = var.passwd
  bucketName = var.bucketName
  subnetIds = module.networking.subnetIds
  vpcId = module.networking.vpcId
}