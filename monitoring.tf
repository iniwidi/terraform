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
widianto@ID-LPT-073:~/terraform$ cat monitoring.tf
# CloudWatch Alarm for EC2 CPU > 75%
resource "aws_cloudwatch_metric_alarm" "high_cpu_alarm" {
  alarm_name          = "high-cpu-ec2"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 75

  alarm_description   = "This alarm triggers when EC2 CPU > 75% for 2 minutes"
  alarm_actions       = [aws_sns_topic.cpu_alerts.arn]

  dimensions = {
    InstanceId = aws_instance.web.id
  }
}