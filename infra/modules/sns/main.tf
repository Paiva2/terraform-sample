resource "aws_sns_topic" "tf-sns" {
  name                        = "tf-sns.fifo"
  fifo_topic                  = true
  content_based_deduplication = true
}