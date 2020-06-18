variable "appFullName" {
  type = "string"
}

variable "appName" {
  type = "string"
}

variable "apiKnownName" {
  type = "string"
}

variable "env" {
  type = "string"
}

variable "cognitoPoolID" {
  type = "string"
}

resource "aws_cognito_resource_server" "resource" {
  identifier = "op3"
  name = "${var.appFullName}"
  user_pool_id = "${var.cognitoPoolID}"

  scope = [
    {
      scope_name = "certificado-pago"
      scope_description = "Tiene permisos para consultar todos los resumenes de pago y sus detalles"
    }
  ]
}

resource "aws_cognito_user_pool_client" "certificado-pago" {
  name = "${var.appFullName}-certificado-pago"
  
  user_pool_id = "${var.cognitoPoolID}"

  generate_secret = true
  # explicit_auth_flows = ["ADMIN_NO_SRP_AUTH"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows = [
    "client_credentials"]
  depends_on = [
    "aws_cognito_resource_server.resource"
  ]

  allowed_oauth_scopes = [
    "${aws_cognito_resource_server.resource.identifier}/certificado-pago"
  ]
  supported_identity_providers = [
    "COGNITO"]  
}

