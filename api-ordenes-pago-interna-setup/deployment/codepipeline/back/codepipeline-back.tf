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
variable "apiVersion" {
  type = "string"
}
variable "roleArn" {
  type = "string"
}

variable "repository" {
  type = "string"
}

variable "cBuildRole" {
  type = "string"
}

variable "cPipelineRole" {
  type = "string"
}

variable "cPipelineBucket" {
  type = "string"
}

variable "apiGatewayID" {
  type = "string"
}

variable "apiGatewayRootID" {
  type = "string"
}

variable "kmsKey" {
  type = "string"
}

variable "roleArnGetCodecommit" {
  type = "string"
}

variable "branch" {
  type = "map"
  default = {
    "prod2" = "master"
    "prod" = "master"
    "dev" = "develop"
    "qa" = "release"
    "env" = "ytarkowski"
    "env123" = "yerko"
    "qfpe" = "qaservel"
    "mock" = "qamock"
  }
}

variable "cognitoPoolArn" {
  type = "string"
}


resource "aws_codebuild_project" "codebuildBack" {
  name = "${var.prefix}-back"
  build_timeout = "15"
  service_role = "${var.cBuildRole}"
  encryption_key = "${var.kmsKey}"

  cache {
    type = "NO_CACHE"
  }

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image = "aws/codebuild/nodejs:8.11.0"
    type = "LINUX_CONTAINER"

    environment_variable {
      name = "BUILD_ENV"
      value = "${var.env}"
    }
    environment_variable {
      name = "BUILD_STAGES"
      value = "${var.apiVersion}"
    }
    environment_variable {
      name = "BUILD_LAMBDA_ROLE_ARN"
      value = "${var.roleArn}"
    }
    environment_variable {
      name = "BUILD_API_ID"
      value = "${var.apiGatewayID}"
    }
    environment_variable {
      name = "BUILD_API_ROOT_ID"
      value = "${var.apiGatewayRootID}"
    }
    environment_variable {
      name = "BUILD_COGNITO_POOL_ARN"
      value = "${var.cognitoPoolArn}"
    }
    environment_variable {
      name = "BUILD_VALIDACION_RTA_SII"
      value = "1"
    }
  }

  source {
    type = "CODEPIPELINE"
  }

  tags = {
    Application = "${var.appName}"
    Env = "${var.env}"
  }
}

resource "aws_codebuild_project" "codebuildSonarQube" {
  name = "${var.prefix}-sonarQube"
  build_timeout = "15"
  service_role = "${var.cBuildRole}"
  encryption_key = "${var.kmsKey}"
  cache {
    type = "NO_CACHE"
  }

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image = "aws/codebuild/nodejs:8.11.0"
    type = "LINUX_CONTAINER"

    environment_variable =
    [
      {
        name = "BUILD_ENV"
        value = "${var.env}"
      },
      {
        name = "BUILD_APP_NAME"
        value = "${var.appName}"
      },
      {
        name = "BUILD_SONARQUBE_HOST"
        value = "/tgr/sonarqube/host"
        type = "PARAMETER_STORE"
      },
      {
        name = "BUILD_SONARQUBE_LOGIN"
        value = "/tgr/sonarqube/login"
        type = "PARAMETER_STORE"
      },
      {
        name = "BUILD_SONARQUBE_URL_DESCARGA"
        value = "/tgr/sonarqube/url-descarga"
        type = "PARAMETER_STORE"
      },
      {
        name = "BUILD_SONARQUBE_NOMBRE_ARCHIVO"
        value = "/tgr/sonarqube/nombre-archivo"
        type = "PARAMETER_STORE"
      },
      {
        name = "BUILD_SONARQUBE_NOMBRE_CARPETA"
        value = "/tgr/sonarqube/nombre-carpeta"
        type = "PARAMETER_STORE"
      }

    ]

  }
  source {
    type = "CODEPIPELINE"
    buildspec = "${file("${path.module}/buildspec-sonarqube.yml")}"
  }

  tags = {
    Application = "${var.appName}"
    Env = "${var.env}"
  }

}


resource "aws_codepipeline" "codepipelineBack" {
  name = "${var.prefix}-back"
  role_arn = "${var.cPipelineRole}"

  stage {
    name = "Source"

    action {
      name = "Source"
      category = "Source"
      owner = "AWS"
      provider = "CodeCommit"
      version = "1"
      role_arn = "${var.roleArnGetCodecommit}"
      output_artifacts = [
        "SourceArtifact"]

      configuration {
        RepositoryName = "${var.repository}"
        BranchName = "${var.branch[var.env]}"
        PollForSourceChanges = "false"
      }
    }
  }
  stage {
    name = "Build"

    action {
      name = "Build"
      category = "Build"
      owner = "AWS"
      provider = "CodeBuild"
      version = "1"
      input_artifacts = [
        "SourceArtifact"]

      configuration {
        ProjectName = "${aws_codebuild_project.codebuildBack.name}"
      }
    }
  }

  stage {
    name = "SonarQube"

    action {
      name = "SonarQube-Publish"
      category = "Build"
      owner = "AWS"
      provider = "CodeBuild"
      version = "1"
      input_artifacts = ["SourceArtifact"]

      configuration {
        ProjectName = "${aws_codebuild_project.codebuildSonarQube.name}"
      }
    }
  }


  artifact_store {
    location = "${var.cPipelineBucket}"
    type = "S3"
    encryption_key = {
      id = "${var.kmsKey}"
      type = "KMS"
    }
  }
}

data "aws_iam_policy_document" "codepipelineRunnerDataRole" {
  statement {
    actions = [
      "sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = [
        "events.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "codepipelineRunnerRole" {
  name = "${var.prefix}-codepipeline-runner-role"
  description = "Otorga privilegios para correr un codepipeline"
  assume_role_policy = "${data.aws_iam_policy_document.codepipelineRunnerDataRole.json}"
  tags = {
    Application = "${var.appName}"
    Env = "${var.env}"
  }
}

data "aws_iam_policy_document" "codepipelineRunnerDataPolicy" {
  statement {
    actions = [
      "codepipeline:StartPipelineExecution"
    ]
    resources = [
      "arn:aws:codepipeline:us-east-1:${var.account}:${var.prefix}*"
    ]
  }
}

resource "aws_iam_policy" "codepipelineRunnerPolicy" {
  name = "${var.prefix}-codepipeline-runner-policy"
  path = "/"
  description = ""
  policy = "${data.aws_iam_policy_document.codepipelineRunnerDataPolicy.json}"
}

resource "aws_iam_role_policy_attachment" "codepipelineRunnerRoleAttach" {
  role = "${aws_iam_role.codepipelineRunnerRole.name}"
  policy_arn = "${aws_iam_policy.codepipelineRunnerPolicy.arn}"
  depends_on = [
    "aws_iam_role.codepipelineRunnerRole"]
}


data "template_file" "sourceEventTemplate" {
  template = "${file("deployment/codepipeline/back/source-code-event.json")}"

  vars {
    //TODO: la cuenta donde esta codecommit esta en duro
    repositoryArn = "arn:aws:codecommit:us-east-1:080540609156:${var.repository}"
    branchName = "${var.branch[var.env]}"
  }
}

resource "aws_cloudwatch_event_rule" "sourceEvent" {
  name = "${var.prefix}-impl-source-change"

  event_pattern = "${data.template_file.sourceEventTemplate.rendered}"
}

resource "aws_cloudwatch_event_target" "stepsSourceEventTarget" {
  rule = "${aws_cloudwatch_event_rule.sourceEvent.name}"
  target_id = "StartCodepipeline"
  role_arn = "${aws_iam_role.codepipelineRunnerRole.arn}"
  arn = "${aws_codepipeline.codepipelineBack.arn}"
}
