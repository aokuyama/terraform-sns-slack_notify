resource "aws_codebuild_project" "app" {
  name         = var.project_name
  service_role = aws_iam_role.codebuild.arn
  source {
    git_clone_depth     = 1
    insecure_ssl        = false
    location            = var.uri_repository
    report_build_status = true
    type                = "GITHUB"
    git_submodules_config {
      fetch_submodules = false
    }
    buildspec = data.template_file.buildspec.rendered
  }
  source_version = var.branch-name_deploy
  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:3.0"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true
    type                        = "LINUX_CONTAINER"
  }
  artifacts {
    encryption_disabled    = false
    override_artifact_name = false
    type                   = "NO_ARTIFACTS"
  }
  logs_config {
    cloudwatch_logs {
      group_name  = "/aws/codebuild"
      stream_name = var.project_name
    }
    s3_logs {
      encryption_disabled = false
      status              = "DISABLED"
    }
  }
}
resource "aws_iam_role" "codebuild" {
  path = "/service-role/"
  assume_role_policy = jsonencode(
    {
      Statement = [
        {
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Principal = {
            Service = "codebuild.amazonaws.com"
          }
        },
      ]
      Version = "2012-10-17"
    }
  )
  managed_policy_arns = [
    aws_iam_policy.push_ecr.arn,
    aws_iam_policy.codebuild-log.arn,
    aws_iam_policy.get-codebuild_ssh_key.arn,
    aws_iam_policy.pull_ecr.arn,
  ]
}
resource "aws_iam_policy" "push_ecr" {
  path = "/service-role/"
  policy = jsonencode(
    {
      Statement = [
        {
          Action = [
            "ecr:BatchCheckLayerAvailability",
            "ecr:CompleteLayerUpload",
            "ecr:GetAuthorizationToken",
            "ecr:InitiateLayerUpload",
            "ecr:PutImage",
            "ecr:UploadLayerPart",
          ]
          Effect   = "Allow"
          Resource = "*"
        },
      ]
      Version = "2012-10-17"
    }
  )
}
resource "aws_iam_policy" "codebuild-log" {
  path = "/service-role/"
  policy = jsonencode(
    {
      Statement = [
        {
          Action = [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents",
          ]
          Effect = "Allow"
          Resource = [
            "arn:aws:logs:${var.region}:${data.aws_caller_identity.self.account_id}:log-group:/aws/codebuild/${var.project_name}",
            "arn:aws:logs:${var.region}:${data.aws_caller_identity.self.account_id}:log-group:/aws/codebuild/${var.project_name}:*",
            "arn:aws:logs:${var.region}:${data.aws_caller_identity.self.account_id}:log-group:/aws/codebuild:log-stream:*",
            "arn:aws:logs:${var.region}:${data.aws_caller_identity.self.account_id}:log-group:/aws/codebuild:log-stream:${var.project_name}/*",
          ]
        },
        {
          Action = [
            "codebuild:CreateReportGroup",
            "codebuild:CreateReport",
            "codebuild:UpdateReport",
            "codebuild:BatchPutTestCases",
            "codebuild:BatchPutCodeCoverages",
          ]
          Effect = "Allow"
          Resource = [
            "arn:aws:codebuild:${var.region}:${data.aws_caller_identity.self.account_id}:report-group/${var.project_name}-*",
          ]
        },
      ]
      Version = "2012-10-17"
    }
  )
}
resource "aws_iam_policy" "get-codebuild_ssh_key" {
  path = "/service-role/"
  policy = jsonencode(
    {
      Statement = [
        {
          "Action" : [
            "ssm:GetParameters"
          ],
          "Resource" : "arn:aws:ssm:${var.region}:${data.aws_caller_identity.self.account_id}:parameter/codebuild_ssh_key",
          "Effect" : "Allow"
        }
      ]
      Version = "2012-10-17"
    }
  )
}
resource "aws_iam_policy" "pull_ecr" {
  path = "/service-role/"
  policy = jsonencode(
    {
      Statement = [
        {
          Action = [
            "ecr:BatchCheckLayerAvailability",
            "ecr:BatchGetImage",
            "ecr:GetDownloadUrlForLayer",
          ]
          Effect   = "Allow"
          Resource = "*"
        },
      ]
      Version = "2012-10-17"
    }
  )
}
