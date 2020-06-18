variable "account" {
  type = "string"
  description = "Numero de la cuenta donde se crean los recursos."
}

variable "env" {
  type = "string"
  description = "El ambiente donde se trabaja dev,qa,prod,lab."
}

variable "appName" {
  type = "string"
  description = "Nombre de la aplicacion."
}

variable "appPrefix" {
  type = "string"
  description = "Nombre de la aplicacion."
}

variable "repositoryBack" {
  type = "string"
}

variable "apiGatewayID" {
  type = "string"
}

variable "apiGatewayRootID" {
  type = "string"
}

variable "arnLambdaRole" {
  type = "string"
}

/*
variable "kmsKeyDevQa" {
  type = "string"
  default = "arn:aws:kms:us-east-1:080540609156:key/b97e9595-822a-4c79-8c09-3eede504a639"
}

variable "kmsKeyProd" {
  type = "string"
  default = "arn:aws:kms:us-east-1:596659627869:key/f6a54825-c0a7-4900-8eed-2807422f294d"
}*/

variable "kmsKey" {
  type = "map"
  default = {
    "prod2" = "arn:aws:kms:us-east-1:080540609156:key/b97e9595-822a-4c79-8c09-3eede504a639"
    "prod" = "arn:aws:kms:us-east-1:596659627869:key/f6a54825-c0a7-4900-8eed-2807422f294d"
    "dev" = "arn:aws:kms:us-east-1:080540609156:key/b97e9595-822a-4c79-8c09-3eede504a639"
    "qa" = "arn:aws:kms:us-east-1:080540609156:key/b97e9595-822a-4c79-8c09-3eede504a639"
    "env" = "arn:aws:kms:us-east-1:829836555627:key/f8afd226-73cf-4ec7-b3b5-3e6627606f8e"
    "env123" = "arn:aws:kms:us-east-1:080540609156:key/b97e9595-822a-4c79-8c09-3eede504a639"
    "qfpe" = "arn:aws:kms:us-east-1:080540609156:key/b97e9595-822a-4c79-8c09-3eede504a639"
    "mock" = "arn:aws:kms:us-east-1:080540609156:key/b97e9595-822a-4c79-8c09-3eede504a639"
  }
}

variable "mapEnv" {
  type = "map"
  default = {
    "prod2" = "prod2"
    "prod" = "prod"
    "dev" = "dev"
    "qa" = "qa"
    "env" = "env"
    "env123" = "env123"
    "qfpe" = "qa"
    "mock" = "qa"
  }
}


variable "roleArnGetCodecommit" {
  type = "string"
  default = "arn:aws:iam::080540609156:role/tgr-dev-codepipelines-multi-cuenta"
  description = "Rol para obtener repositorio codecommit, y luego encriptarlo y dejarlo en S3, funciona para todos los ambientes"
}

variable "apiVersion" {
  type = "string"
}
variable "cognitoPoolArn" {
  type = "string"
}




locals {
  cBuildRoleBack = "arn:aws:iam::${var.account}:role/tgr-${var.mapEnv[var.env]}-project-setup-codebuild"
  cBuildRoleFront = "arn:aws:iam::${var.account}:role/tgr-${var.mapEnv[var.env]}-project-setup-codebuild"
  cPipelineRoleBack = "arn:aws:iam::${var.account}:role/tgr-${var.mapEnv[var.env]}-project-setup-codepipeline"
  cPipelineRoleFront = "arn:aws:iam::${var.account}:role/tgr-${var.mapEnv[var.env]}-project-setup-codepipeline"
  cPipelineBucket = "tgr-${var.mapEnv[var.env]}-codepipelines"
}

module "deploymentPermissionPolicy" {
  source = "./permission/policy"
  account = "${var.account}"
  prefix = "${var.appPrefix}"
  appName = "${var.appName}"
  env = "${var.env}"
  apiGatewayID = "${var.apiGatewayID}"
}

module "deploymentPermissionRole" {
  source = "./permission/role"
  prefix = "${var.appPrefix}"
  appName = "${var.appName}"
  env = "${var.env}"
  arnServerlessPolicy = "${module.deploymentPermissionPolicy.outArnServerlessPolicy}"
}

module "deploymentCodepipelineBack" {
  source = "./codepipeline/back"
  prefix = "${var.appPrefix}"
  appName = "${var.appName}"
  env = "${var.env}"
  roleArn = "${var.arnLambdaRole}"
  //rol para archivo serverless.yml "${module.role.out_arn_role_lambda}"
  repository = "${var.repositoryBack}"
  cBuildRole = "${module.deploymentPermissionRole.outArnServerlessRole}"
  cPipelineRole = "${local.cPipelineRoleBack}"
  cPipelineBucket = "${local.cPipelineBucket}"
  apiGatewayID = "${var.apiGatewayID}"
  apiGatewayRootID = "${var.apiGatewayRootID}"
  #kmsKey = "${var.env=="prod" ? var.kmsKeyProd : var.kmsKeyDevQa}"
  kmsKey = "${var.kmsKey["${var.env}"]}"
  roleArnGetCodecommit = "${var.roleArnGetCodecommit}"
  apiVersion = "${var.apiVersion}"
  cognitoPoolArn = "${var.cognitoPoolArn}"
  account = "${var.account}"
}

output "arnServerlessPolicy" {
  value = "${module.deploymentPermissionPolicy.outArnServerlessPolicy}"
}