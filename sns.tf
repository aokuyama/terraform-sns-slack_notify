resource "aws_sns_topic" "app" {
  name = var.function_name
}

resource "aws_sns_topic_subscription" "app" {
  topic_arn = aws_sns_topic.app.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.app.arn
}

resource "aws_sns_topic_policy" "default" {
  arn    = aws_sns_topic.app.arn
  policy = data.aws_iam_policy_document.sns_topic_policy.json
}

data "aws_iam_policy_document" "sns_topic_policy" {
  statement {
    actions = [
      "SNS:Subscribe",
      "SNS:SetTopicAttributes",
      "SNS:RemovePermission",
      "SNS:Receive",
      "SNS:Publish",
      "SNS:ListSubscriptionsByTopic",
      "SNS:GetTopicAttributes",
      "SNS:DeleteTopic",
      "SNS:AddPermission",
    ]
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"

      values = [
        data.aws_caller_identity.self.account_id,
      ]
    }
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    resources = [
      aws_sns_topic.app.arn,
    ]
  }
}

resource "aws_lambda_permission" "app" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.app.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.app.arn
}
