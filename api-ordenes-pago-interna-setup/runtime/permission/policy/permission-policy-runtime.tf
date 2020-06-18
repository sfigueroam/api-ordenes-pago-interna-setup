variable "account" {
  type = "string"
}

variable "env" {
  type = "string"
}

variable "appPrefix" {
  type = "string"
}

variable "inputBucketID" {
  type = "string"
}




data "aws_iam_policy_document" "cloudwatchDataPolicy" {
  statement {
    sid = "putLogsEventsCloudWatch"
    actions = [
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:*:*:log-group:/aws/lambda/*:*:*"]
  }
  statement {
    sid = "CreateLogsCloudWatch"
    actions = [
      "logs:CreateLogStream"
    ]
    resources = [
      "arn:aws:logs:*:*:log-group:/aws/lambda/*:*"]
  }
}

resource "aws_iam_policy" "cloudwatchPolicy" {
  name = "${var.appPrefix}-cloudwatch-logs"
  path = "/"
  description = "Otorga privilegios para la creacion de logs CloudWatch"
  policy = "${data.aws_iam_policy_document.cloudwatchDataPolicy.json}"
}



resource "aws_iam_policy" "bucketPolicy" {
  name = "${var.appPrefix}-s3"
  path = "/"
  description = "Otorga privilegios sobre los bucket del proyecto"
  policy = "${data.aws_iam_policy_document.bucketDataPolicy.json}"
}

data "aws_iam_policy_document" "bucketDataPolicy" {
  statement {
    sid = "accessObjetsS3Bucket"
    actions = [
      "s3:GetObject*",
      "s3:PutObject*",
      "s3:DeleteObject*",
      "s3:*"
    ]
    resources = [
      "arn:aws:s3:::${var.inputBucketID}/*",
      "arn:aws:s3:::${var.inputBucketID}"]
  },
  statement {
    sid = "listObjetsS3Bucket"
    actions = [
      "s3:ListBucket"
    ]
    resources = [
      "*"
    ]
  }
}

data "aws_iam_policy_document" "lambdaDataPolicy" {
  statement {
    sid = "lambda"
    actions = [
      "lambda:InvokeFunction",
      "lambda:ListTags",
      "lambda:TagResource",
      "lambda:UntagResource"
    ]
    resources = [
      "arn:aws:lambda:us-east-1:${var.account}:function:${var.appPrefix}*",
      "arn:aws:lambda:us-east-1:${var.account}:function:tgr-${var.env}-log-analytics-cloudwatch-to-elasticsearch"
    ]
  }

  statement {
    sid = "stm2"
    actions = [
      "athena:StartQueryExecution",
      "athena:StopQueryExecution",
      "athena:GetQueryResults",
      "athena:GetQueryExecution"
    ]
    resources = [
      "arn:aws:athena:us-east-1:${var.account}:workgroup/primary"
    ]
  }

  statement {
    sid = "stm3"
    actions = [
      "glue:GetTable",
      "glue:GetPartitions",
      "glue:Get*"
    ]
    resources = [
      "arn:aws:glue:us-east-1:${var.account}:catalog",
      "arn:aws:glue:us-east-1:${var.account}:database/*",
      "arn:aws:glue:us-east-1:${var.account}:table/*/*"
    ]
  }

  statement {
    sid = "stm4"
    actions = [
      "s3:GetObject*"
    ]
    resources = [
      "arn:aws:s3:::tgr-prod2-api-pago-prov-input*"
    ]
  }

  statement {
    sid = "stm5"
    actions = [
      "dynamodb:*"
    ]
    resources = [
      "arn:aws:dynamodb:us-east-1:*:table/tgr-${var.env}-core-ordenes-pago-*",
      "arn:aws:dynamodb:us-east-1:*:table/tgr-${var.env}-core-ordenes-pago-*/index/*"
    ]
  }
  
  statement {
    sid = "stm6"
    actions = [
      "s3:GetObject*"
    ]
    resources = [
      "arn:aws:s3:::tgr-${var.env}-core-ordenes-pago-data"
    ]
  }
  
  statement {
    sid= "stm7"
    actions = [
      "states:*"
    ]
    resources = [
      "arn:aws:states:us-east-1:${var.account}:stateMachine:tgr-${var.env}-core-ordenes-pag*"
    ]
  }

  
}

resource "aws_iam_policy" "lambdaPolicy" {
  name = "${var.appPrefix}-invoke-lambda"
  path = "/"
  description = "Otorga privilegios de ejecución de lambdas"
  policy = "${data.aws_iam_policy_document.lambdaDataPolicy.json}"
}

output "outArnCloudwatchPolicy" {
  value = "${aws_iam_policy.cloudwatchPolicy.arn}"
}

output "s3PolicyArn" {
  value = "${aws_iam_policy.bucketPolicy.arn}"
}

output "lambdaPolicyArn" {
  value = "${aws_iam_policy.lambdaPolicy.arn}"
}