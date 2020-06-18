variable "account" {
  type = "string"
}

variable "prefix" {
  type = "string"
}

variable "appName" {
  type = "string"
}

variable "env" {
  type = "string"
}

variable "repositoryBack" {
  type = "string"
}
variable "apiGatewayID" {
  type = "string"
}

data "aws_iam_policy_document" "codecommitDataPolicy" {
  statement {
    sid = "codecommitAccess"
    actions = [
      "codecommit:*"
    ]
    resources = [
      "arn:aws:codecommit:*:${var.account}:${var.repositoryBack}"
    ]
  }
}

resource "aws_iam_policy" "codecommitPolicy" {
  count = "${var.env=="dev" ? 1 : 0}"
  name = "${var.prefix}-codecommit"
  path = "/"
  description = "Otorga privilegios sobre repositorios codecommit de la aplicacion"
  policy = "${data.aws_iam_policy_document.codecommitDataPolicy.json}"
}


data "aws_iam_policy_document" "lambdaDataPolicy" {
  statement {
    sid = "lambdaAccessFuntion"
    actions = [
      "lambda:InvokeFunction",
      "lambda:ListVersionsByFunction",
      "lambda:Get*",
      "lambda:ListAliases",
      "lambda:UpdateFunctionConfiguration",
      "lambda:InvokeAsync",
      "lambda:UpdateAlias",
      "lambda:UpdateFunctionCode",
      "lambda:ListTags",
      "lambda:PublishVersion",
      "lambda:CreateAlias"
    ]
    resources = [
      "arn:aws:lambda:*:*:function:*${var.appName}*"
    ]
  }
  statement {
    sid = "lambdaAccessList"
    actions = [
      "lambda:List*",
      "lambda:Get*"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "lambdaPolicy" {
  count = "${var.env=="dev" ? 1 : 0}"
  name = "${var.prefix}-developper-lambda"
  path = "/"
  description = "Otorga privilegios a las funciones lambda de la aplicacion"
  policy = "${data.aws_iam_policy_document.lambdaDataPolicy.json}"
}


data "aws_iam_policy_document" "apiGatewayDataPolicy" {
  statement {
    sid = "apiGatewayAccess"
    actions = [
      "apigateway:PUT",
      "apigateway:PATCH",
      "apigateway:POST",
      "apigateway:GET"
    ]
    resources = [
      "arn:aws:apigateway:*::/restapis/${var.apiGatewayID}/*"
    ]
  }
}

resource "aws_iam_policy" "apiGatewayPolicy" {
  count = "${var.env=="dev" ? 1 : 0}"
  name = "${var.prefix}-apigateway"
  path = "/"
  description = "Otorga privilegios a la api de la aplicacion"
  policy = "${data.aws_iam_policy_document.apiGatewayDataPolicy.json}"
}

output "outArnCodecommitPolicy" {
  //value = "${aws_iam_policy.codecommitPolicy.arn}"
  value = "${element(concat(aws_iam_policy.codecommitPolicy.*.arn, list("")), 0)}"
}

output "outArnLambdaPolicy" {
  //value = "${aws_iam_policy.lambdaPolicy.arn}"
  value = "${element(concat(aws_iam_policy.lambdaPolicy.*.arn, list("")), 0)}"
}

output "outArnApiGatewayPolicy" {
  //value = "${aws_iam_policy.apiGatewayPolicy.arn}"
  value = "${element(concat(aws_iam_policy.apiGatewayPolicy.*.arn, list("")), 0)}"
}

