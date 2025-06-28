// CloudWatch Log Group for EC2 logs
resource "aws_cloudwatch_log_group" "ec2_app_log" {
  name              = "/gogreen/ec2/app"
  retention_in_days = 7

  tags = {
    Name = "GoGreenEC2AppLog"
  }
}

// CloudWatch Log Group for RDS (optional if enhanced monitoring is enabled)
resource "aws_cloudwatch_log_group" "rds_log" {
  name              = "/aws/rds/gogreen-db"
  retention_in_days = 7

  tags = {
    Name = "GoGreenRDSLog"
  }
}

// Example: Alarm for high CPU on EC2 Auto Scaling Group
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "HighCPU-GogreenASG"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "This alarm triggers if CPU > 80% for 2 minutes"
  treat_missing_data  = "notBreaching"

  dimensions = {
    AutoScalingGroupName = var.asg_name
  }
}
