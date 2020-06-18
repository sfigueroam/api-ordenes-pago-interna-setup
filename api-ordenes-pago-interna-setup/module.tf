provider "aws" {
  region = "us-east-1"
  version = "~> 1.57"
}
variable "account" {
  type = "string"
  description = "Numero de la cuenta donde se crean los recursos."
}

variable "env" {
  type = "string"
  description = "El ambiente donde se trabaja dev,qa,prod,lab."
}

variable "apiName" {
  type = "string"
  description = "Nombre de la aplicacion."
}

variable "apiKnownName" {
  type = "string"
  description = "Nombre de la aplicacion."
}

variable "apiVersion" {
  type = "string"
}

variable "apiDomainName" {
  type = "string"
}

variable "cognitoPoolArn" {
  type = "string"
}

variable "cognitoPoolId" {
  type = "string"
}

variable "envMulti" {
  type = "map"
  default = {
    "prod2" = "prod2"
    "prod" = "prod"
    "dev" = "dev"
    "qa" = "qa"
    "env" = "env"
    "env123" = "dev"
    "qfpe" = "qa"
  }
}

locals {
  appName = "api-${var.apiName}"
  appPrefix = "tgr-${var.env}-${local.appName}"
  repositoryBack = "${local.appName}-impl"
}

data "terraform_remote_state" "coreOrdenesPagoInterna" {
  backend = "s3"
  config {
    bucket = "tgr-${var.envMulti[var.env]}-terraform-state"
    key = "tgr-${var.env}-core-ordenes-pago-setup"
    region = "us-east-1"
  }
}

module "runtime" {
  source = "./runtime"
  account = "${var.account}"
  appName = "${local.appName}"
  apiName = "${var.apiName}"
  apiKnownName = "${var.apiKnownName}"
  env = "${var.env}"
  apiVersion = "${var.apiVersion}"
  apiDomainName = "${var.apiDomainName}"
  cognitoPoolId = "${var.cognitoPoolId}"
  inputBucketID = "${data.terraform_remote_state.coreOrdenesPagoInterna.dataBucketId}"
}

module "governance" {
  source = "./governance"
  account = "${var.account}"
  appPrefix = "${local.appPrefix}"
  appName = "${local.appName}"
  env = "${var.env}"
  repositoryBack = "${local.repositoryBack}"
  apiGatewayId = "${module.runtime.apiGatewayID}"
  s3PolicyArn = "${module.runtime.s3PolicyArn}"
}

module "deployment" {
  source = "./deployment"
  appPrefix = "${local.appPrefix}"
  appName = "${local.appName}"
  env = "${var.env}"
  arnLambdaRole = "${module.runtime.arnLambdaRole}"
  apiGatewayID = "${module.runtime.apiGatewayID}"
  apiGatewayRootID = "${module.runtime.apiGatewayRootID}"
  account = "${var.account}"
  repositoryBack = "${local.repositoryBack}"
  apiVersion = "${var.apiVersion}"
  cognitoPoolArn = "${var.cognitoPoolArn}"
}

terraform {
  backend "s3" {
    encrypt = false
   // bucket = "tgr-${var.env}-terraform-state"
    //key = "tgr-${var.env}-core-ordenes-pago-interna-setup"
    region = "us-east-1"
  }
}