# SNS Topic for alerts
resource "aws_sns_topic" "alerts" {
  name = "${var.name_prefix}-alerts"
}

# SNS Email Subscription
resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.sns_email
}

# CloudWatch Alarms for AutoScaling Group

resource "aws_cloudwatch_metric_alarm" "asg_high_cpu" {
  alarm_name          = "${var.name_prefix}-asg-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Alarm when ASG instances CPU > 80%"
  dimensions          = {
    AutoScalingGroupName = var.asg_name
  }
  alarm_actions = [aws_sns_topic.alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "asg_low_cpu" {
  alarm_name          = "${var.name_prefix}-asg-low-cpu"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 10
  alarm_description   = "Alarm when ASG instances CPU < 10%"
  dimensions          = {
    AutoScalingGroupName = var.asg_name
  }
  alarm_actions = [aws_sns_topic.alerts.arn]
}

# CPU Alarm for RDS Primary Instance

resource "aws_cloudwatch_metric_alarm" "rds_cpu_high" {
  alarm_name          = "${var.name_prefix}-rds-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Alarm when RDS CPU > 80%"
  dimensions          = {
    DBInstanceIdentifier = var.db_identifier
  }
  alarm_actions = [aws_sns_topic.alerts.arn]
}

# Free Storage Space Alarm for RDS (warning threshold 10% of storage)

resource "aws_cloudwatch_metric_alarm" "rds_free_storage" {
  alarm_name          = "${var.name_prefix}-rds-low-storage"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 10737418240 # 10 GB (adjust as needed)
  alarm_description   = "Alarm when RDS free storage space < 10 GB"
  dimensions          = {
    DBInstanceIdentifier = var.db_identifier
  }
  alarm_actions = [aws_sns_topic.alerts.arn]
}

output "sns_topic_arn" {
  value = aws_sns_topic.alerts.arn
}