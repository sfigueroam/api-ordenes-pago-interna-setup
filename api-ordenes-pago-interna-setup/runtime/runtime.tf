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

variable "appName" {
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

variable "cognitoPoolId" {
  type = "string"
}

variable "inputBucketID" {
  type = "string"
}

locals {
  appPrefix = "tgr-${var.env}-${var.appName}"
}

module "runtimeApiGateway" {
  source = "./resource/api-gateway"
  appPrefix = "${local.appPrefix}"
  apiVersion = "${var.apiVersion}"
  apiDomainName = "${var.apiDomainName}"
  apiKnownName = "${var.apiKnownName}"
  env = "${var.env}"
}

module "runtimePermissionPolicy" {
  source = "./permission/policy"
  env = "${var.env}"
  appPrefix = "${local.appPrefix}"
  account = "${var.account}"
  inputBucketID = "${var.inputBucketID}"
}

module "runtimePermissionRole" {
  source = "./permission/role"
  prefix = "${local.appPrefix}"
  appName = "${var.appName}"
  env = "${var.env}"
  cloudwatchPolicy = "${module.runtimePermissionPolicy.outArnCloudwatchPolicy}"
  s3Policy = "${module.runtimePermissionPolicy.s3PolicyArn}"
  lambdaPolicy = "${module.runtimePermissionPolicy.lambdaPolicyArn}"
}

module "runtimeCognito" {
  source = "./resource/cognito"
  appFullName = "${local.appPrefix}"
  appName = "${var.appName}"
  apiKnownName = "${var.apiKnownName}"
  env = "${var.env}"
  cognitoPoolID = "${var.cognitoPoolId}"
}

output "arnLambdaRole" {
  value = "${module.runtimePermissionRole.outArnLambdaRole}"
}

output "apiGatewayID" {
  value = "${module.runtimeApiGateway.outApigatewayID}"
}

output "apiGatewayRootID" {
  value = "${module.runtimeApiGateway.outApigatewayRootID}"
}

output "s3PolicyArn" {
  value = "${module.runtimePermissionPolicy.s3PolicyArn}"
}

output "lambdaPolicyArn" {
  value = "${module.runtimePermissionPolicy.lambdaPolicyArn}"
}
