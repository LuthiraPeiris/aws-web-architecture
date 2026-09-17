resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "${var.project_name}-ec2-high-cpu"
  alarm_description   = "Alarm when EC2 CPU utilization exceeds 80%"
  comparison_operator = "GreaterThanThreshold"

  evaluation_periods = 1
  period             = 300
  metric_name        = "CPUUtilization"
  namespace          = "AWS/EC2"
  statistic          = "Average"

  threshold = 80

  dimensions = {
    InstanceId = aws_instance.app.id
  }

  treat_missing_data = "notBreaching"

  tags = {
    Name = "${var.project_name}-ec2-high-cpu"
  }
}