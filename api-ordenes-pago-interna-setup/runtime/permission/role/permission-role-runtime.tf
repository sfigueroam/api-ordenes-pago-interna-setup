variable "prefix" {
  type = "string"
}

variable "appName" {
  type = "string"
}

variable "env" {
  type = "string"
}

variable "cloudwatchPolicy" {
  type = "string"
}

variable "s3Policy" {
  type = "string"
}

variable "lambdaPolicy" {
  type = "string"
}

data "aws_iam_policy_document" "lambdaDataRole" {
  statement {
    actions = [
      "sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = [
        "lambda.amazonaws.com"]
    }
  }

  // TODO: esto es necesario temporalmente para permitir que desde prod2 de la cuenta 080540609156 se llame a la funcion de produccion
  statement {
    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::080540609156:root"
      ]
    }
  }
}

resource "aws_iam_role" "lambdaRole" {
  name = "${var.prefix}-back-lambda"
  assume_role_policy = "${data.aws_iam_policy_document.lambdaDataRole.json}"
  tags = {
    Application = "${var.appName}"
    Env = "${var.env}"
  }
}

resource "aws_iam_role_policy_attachment" "cloudwatchRoleAttach" {
  role = "${aws_iam_role.lambdaRole.name}"
  policy_arn = "${var.cloudwatchPolicy}"
  depends_on = [
    "aws_iam_role.lambdaRole"]
}

resource "aws_iam_role_policy_attachment" "s3RoleAttach" {
  role = "${aws_iam_role.lambdaRole.name}"
  policy_arn = "${var.s3Policy}"
  depends_on = [
    "aws_iam_role.lambdaRole"]
}

resource "aws_iam_role_policy_attachment" "lambdaRoleAttach" {
  role = "${aws_iam_role.lambdaRole.name}"
  policy_arn = "${var.lambdaPolicy}"
  depends_on = [
    "aws_iam_role.lambdaRole"]
}

output "outArnLambdaRole" {
  value = "${aws_iam_role.lambdaRole.arn}"
}

