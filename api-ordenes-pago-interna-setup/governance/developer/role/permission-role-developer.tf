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
        "ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "serverlessRole" {
  count = "${var.env=="dev" ? 1 : 0}"
  name = "${var.prefix}-serverless-deploy-ec2"
  description = "Otorga privilegios para realizar deploy serverless en una instancia EC2"
  assume_role_policy = "${data.aws_iam_policy_document.servelessDataRole.json}"
  tags = {
    Application = "${var.appName}"
    Env = "${var.env}"
  }
}

resource "aws_iam_instance_profile" "serverlessRoleProfile" {
  count = "${var.env=="dev" ? 1 : 0}"
  name = "${aws_iam_role.serverlessRole.name}"
  role = "${aws_iam_role.serverlessRole.name}"
}

