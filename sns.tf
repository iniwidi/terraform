# SNS Topic
resource "aws_sns_topic" "cpu_alerts" {
  name = "ec2-cpu-alerts"
}

# SNS Email Subscription
resource "aws_sns_topic_subscription" "email_alert" {
  topic_arn = aws_sns_topic.cpu_alerts.arn
  protocol  = "email"
  endpoint  = "info@widianto.org"
}
