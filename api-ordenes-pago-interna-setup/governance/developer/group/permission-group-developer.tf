variable "appName" {
  type = "string"
}

variable "env" {
  type = "string"
}

variable "arnCodecommitPolicy" {
  type = "string"
}

variable "arnLambdaPolicy" {
  type = "string"
}

variable "arnApiGatewayPolicy" {
  type = "string"
}

variable "arnS3Policy" {
  type = "string"
}

resource "aws_iam_group" "developGroup" {
  count = "${var.env=="dev" ? 1 : 0}"
  name = "team-${var.env}-${var.appName}"
  path = "/"
}

resource "aws_iam_group_policy_attachment" "codecommitPolicyAttach" {
  count      = "${var.env=="dev" ? 1 : 0}"
  group      = "${aws_iam_group.developGroup.name}"
  policy_arn = "${var.arnCodecommitPolicy}"
  depends_on = ["aws_iam_group.developGroup"]
}

resource "aws_iam_group_policy_attachment" "lambdaPolicyAttach" {
  count      = "${var.env=="dev" ? 1 : 0}"
  group      = "${aws_iam_group.developGroup.name}"
  policy_arn = "${var.arnLambdaPolicy}"
  depends_on = ["aws_iam_group.developGroup"]
}

resource "aws_iam_group_policy_attachment" "apiGatewayPolicyAttach" {
  count      = "${var.env=="dev" ? 1 : 0}"
  group      = "${aws_iam_group.developGroup.name}"
  policy_arn = "${var.arnApiGatewayPolicy}"
  depends_on = ["aws_iam_group.developGroup"]
}

resource "aws_iam_group_policy_attachment" "s3PolicyAttach" {
  count      = "${var.env=="dev" ? 1 : 0}"
  group      = "${aws_iam_group.developGroup.name}"
  policy_arn = "${var.arnS3Policy}"
  depends_on = ["aws_iam_group.developGroup"]
}