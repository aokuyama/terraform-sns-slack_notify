resource "aws_lambda_function" "app" {
  function_name = var.function_name
  memory_size   = 128
  timeout       = 3
  image_uri     = "${aws_ecr_repository.app.repository_url}:${var.tag_deploy}"
  package_type  = "Image"
  role          = aws_iam_role.iam_for_lambda.arn
  environment {
    variables = {
      SLACK_APP_TOKEN       = var.slack_app_token
      SLACK_DEFAULT_CHANNEL = var.slack_default_channel
    }
  }
}
resource "aws_iam_role" "iam_for_lambda" {
  path = "/service-role/"
  assume_role_policy = jsonencode(
    {
      Statement = [
        {
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Principal = {
            Service = "lambda.amazonaws.com"
          }
        },
      ]
      Version = "2012-10-17"
    }
  )
  managed_policy_arns = [
    aws_iam_policy.policy_for_lambda.arn,
  ]
}
resource "aws_iam_policy" "policy_for_lambda" {
  path = "/service-role/"
  policy = jsonencode(
    {
      Statement = [
        {
          Action   = "logs:CreateLogGroup"
          Effect   = "Allow"
          Resource = "arn:aws:logs:${var.region}:${data.aws_caller_identity.self.account_id}:*"
        },
        {
          Action = [
            "logs:CreateLogStream",
            "logs:PutLogEvents",
          ]
          Effect = "Allow"
          Resource = [
            "arn:aws:logs:${var.region}:${data.aws_caller_identity.self.account_id}:log-group:/aws/lambda/${var.function_name}:*",
          ]
        },
      ]
      Version = "2012-10-17"
    }
  )
}
