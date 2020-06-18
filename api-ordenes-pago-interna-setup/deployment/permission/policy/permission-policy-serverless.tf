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

variable "apiGatewayID" {
  type = "string"
}

data "aws_iam_policy_document" "serverlessDataPolicy" {
  statement {
    actions = [
      "cloudformation:CreateUploadBucket",
      "cloudformation:Describe*",
      "cloudformation:Get*",
      "cloudformation:List*",
      "cloudformation:ValidateTemplate",
      "lambda:CreateFunction",
      "lambda:ListFunctions",
      "lambda:ListVersionsByFunction",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:DeleteLogGroup",
      "logs:DeleteLogStream",
      "logs:PutLogEvents",
      "s3:CreateBucket",
      "s3:ListBucket",
      "s3:GetObject*",
      "s3:GetEncryptionConfiguration",
      "s3:PutEncryptionConfiguration",
      "kms:Decrypt",
      "kms:Encrypt"
    ]
    resources = [
      "*"
    ]
  }
  statement {
    actions = [
      "cloudformation:DeleteStack",
      "cloudformation:DescribeStackResource",
      "cloudformation:DescribeStackEvents",
      "cloudformation:DescribeStackResources",
      "cloudformation:CancelUpdateStack",
      "cloudformation:ContinueUpdateRollback",
      "cloudformation:CreateStack",
      "cloudformation:GetStackPolicy",
      "cloudformation:GetTemplate",
      "cloudformation:UpdateStack",
      "cloudformation:UpdateTerminationProtection",
      "cloudformation:SignalResource",
      "iam:CreateRole",
      "iam:DeleteRole",
      "iam:DeleteRolePolicy",
      "iam:GetRole",
      "iam:PassRole",
      "iam:PutRolePolicy",
      "lambda:UpdateFunctionCode",
      "lambda:UpdateFunctionConfiguration",
      "s3:PutObject",

    ]
    resources = [
      "arn:aws:cloudformation:*:*:stack/${substr(var.prefix, 0, min(length(var.prefix), 24))}*/*",
      "arn:aws:iam::*:role/${var.prefix}*",
      "arn:aws:s3:::${substr(var.prefix, 0, min(length(var.prefix), 24))}*/*",
      "arn:aws:lambda:us-east-1:${var.account}:function:${var.prefix}*"
    ]
  }

  statement {
    actions = [
      "apigateway:PATCH",
      "apigateway:DELETE",
      "apigateway:HEAD",
      "apigateway:GET",
      "apigateway:OPTIONS",
      "apigateway:POST",
      "apigateway:PUT"
    ]
    resources = [
      "arn:aws:apigateway:*::/restapis/${var.apiGatewayID}/*",
      "arn:aws:apigateway:*::/tags/*"
    ]
  }
  statement {
    actions = [
      "lambda:GetFunctionConfiguration",
      "s3:GetObject"
    ]
    resources = [
      "arn:aws:s3:::${var.prefix}*/*",
      "arn:aws:lambda:*:${var.account}:function:${var.prefix}*"
    ]
  }
  statement {
    actions = [
      "lambda:RemovePermission"
    ]
    resources = [
      "arn:aws:lambda:*:${var.account}:function:${var.prefix}*",
      "arn:aws:lambda:us-east-1:${var.account}:function:${var.prefix}*"

    ]
  }
  statement {
    actions = [
      "lambda:DeleteFunction"
    ]
    resources = [
      "arn:aws:lambda:*:${var.account}:function:${var.prefix}*",
      "arn:aws:lambda:us-east-1:${var.account}:function:${var.prefix}*"

    ]
  }
  statement {
    actions = [
      "lambda:GetFunction"
    ]
    resources = [
      "arn:aws:lambda:*:${var.account}:function:${var.prefix}*",
      "arn:aws:lambda:us-east-1:${var.account}:function:${var.prefix}*"

    ]
  }
  statement {
    actions = [
      "lambda:AddPermission"
    ]
    resources = [
      "arn:aws:lambda:*:${var.account}:function:${var.prefix}*"
    ]
  }
  statement {
    actions = [
      "lambda:AddPermission"
    ]
    resources = [
      "arn:aws:lambda:us-east-1:${var.account}:function:tgr-${var.env}-log-analytics-cloudwatch-to-elasticsearch"
    ]
  }
  statement {
    actions = [
      "lambda:CreateEventSourceMapping"
    ]
    resources = [
      "*"
    ]
  }
  statement {
    actions = [
      "lambda:GetEventSourceMapping",
      "lambda:DeleteEventSourceMapping",
      "lambda:ListTags",
      "lambda:TagResource",
      "lambda:UntagResource"
    ]
    resources = [
      "*"
    ]
  }
  statement {
    actions = [
      "lambda:PublishVersion"
    ]
    resources = [
      "arn:aws:lambda:*:${var.account}:function:${var.prefix}*"
    ]
  }
  statement {
    actions = [
      "ssm:GetParameters"
    ]
    resources = [
      "arn:aws:ssm:*:*:parameter/tgr/${var.env}/${var.appName}/*",
      "arn:aws:ssm:*:*:parameter/tgr/sonarqube/*"
    ]
  }
  
  statement {
    actions = [
      "cloudwatch:PutMetricAlarm",
      "cloudwatch:DeleteAlarms"
    ]
    resources = [
      "arn:aws:cloudwatch:us-east-1:${var.account}:alarm:${var.prefix}*"
    ]
  }
  
  statement {
    actions = [
      "SNS:ListTopics"
    ]
    resources = [
      "arn:aws:sns:us-east-1:${var.account}:*"
    ]
  }
  
  statement {
    actions = [
      "SNS:*"
    ]
    resources = [
      "arn:aws:sns:us-east-1:${var.account}:${var.prefix}*"
    ]
  }
  
  statement {
    actions = [
      "events:*"
    ]
    resources = [
      "arn:aws:events:us-east-1:${var.account}:rule/${var.prefix}*"
    ]
  }

  statement {
    actions = [
      "logs:*"
    ]
    resources = [
      "arn:aws:logs:us-east-1:${var.account}:log-group:/aws/lambda/${var.prefix}*:log-stream:"
    ]
  }
}

resource "aws_iam_policy" "serverlessPolicy" {
  name = "${var.prefix}-serverless-deploy"
  path = "/"
  description = "Otorga privilegios para realizar deploy serverless"
  policy = "${data.aws_iam_policy_document.serverlessDataPolicy.json}"
}

output "outArnServerlessPolicy" {
  value = "${aws_iam_policy.serverlessPolicy.arn}"
}


