variable "prefix" {
  type = "string"
}

variable "appName" {
  type = "string"
}

variable "env" {
  type = "string"
}

variable "arnServerlessPolicy" {
  type = "string"
}

data "aws_iam_policy_document" "servelessDataRole" {
  statement {
    actions = [
      "sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = [
        "codebuild.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "serverlessRole" {
  name = "${var.prefix}-codebuild-back-deployment"
  description = "Otorga privilegios para realizar deploy serverless en codebuild"
  assume_role_policy = "${data.aws_iam_policy_document.servelessDataRole.json}"
  tags = {
    Application = "${var.appName}"
    Env = "${var.env}"
  }
}

resource "aws_iam_role_policy_attachment" "serverlessRoleAttach" {
  role = "${aws_iam_role.serverlessRole.name}"
  policy_arn = "${var.arnServerlessPolicy}"
  depends_on = [
    "aws_iam_role.serverlessRole"]
}


output "outArnServerlessRole" {
  value = "${aws_iam_role.serverlessRole.arn}"
}

