variable "env" {
  type = "string"
}

variable "appPrefix" {
  type = "string"
}

variable "apiKnownName" {
  type = "string"
}

variable "apiVersion" {
  type = "string"
}


variable "apiDomainName" {
  type = "string"
}

resource "aws_api_gateway_rest_api" "apiGatewayBack" {
  name = "${var.appPrefix}-back"

  endpoint_configuration {
    types = [
      "REGIONAL"]
  }
}

locals {
  base_path_devqa = "${var.apiKnownName}"
}

resource "aws_api_gateway_base_path_mapping" "path-mapping-api-tgr" {
  api_id = "${aws_api_gateway_rest_api.apiGatewayBack.id}"
  //stage_name  = "${replace(var.apiVersion, ".", "-")}"
  base_path = "${var.env == "prod"? var.apiKnownName : local.base_path_devqa}"
  domain_name = "${var.apiDomainName}"
}


output "outApigatewayID" {
  value = "${aws_api_gateway_rest_api.apiGatewayBack.id}"
}

output "outApigatewayRootID" {
  value = "${aws_api_gateway_rest_api.apiGatewayBack.root_resource_id}"
}
