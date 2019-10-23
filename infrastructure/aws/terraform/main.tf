provider "aws" {
    profile = var.profile
    region  = var.region
}

module "networking" {
    source="./networking"

    cidrBlock = var.cidrBlock
    vpcName = var.vpcName
    subnetBlock = var.subnetBlock
    region = var.region
}

module "application"{
    source="./application"
}