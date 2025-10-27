resource "aws_sqs_queue" "application-queue-paiva2-java-app" {
  name                        = "application-queue-paiva2-java-app.fifo"
  fifo_queue                  = true
  content_based_deduplication = true
  max_message_size            = 2048

  tags = {
    Environment = "staging"
  }
}

data "aws_iam_policy_document" "sqs_queue_policy" {
  statement {
    sid    = "sns_sqs_target"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["sns.amazonaws.com"]
    }

    actions   = ["SQS:SendMessage"]
    resources = [aws_sqs_queue.application-queue-paiva2-java-app.arn]

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [var.subscribed_topic_arn]
    }
  }
}

resource "aws_sqs_queue_policy" "tf-sns_sqs_policy" {
  queue_url = aws_sqs_queue.application-queue-paiva2-java-app.id
  policy    = data.aws_iam_policy_document.sqs_queue_policy.json
}

resource "aws_sns_topic_subscription" "sqs_to_sns_subscription" {
  topic_arn = var.subscribed_topic_arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.application-queue-paiva2-java-app.arn
}