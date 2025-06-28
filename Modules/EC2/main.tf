// modules/ec2/main.tf

resource "aws_launch_template" "gogreen_lt" {
  name_prefix   = "gogreen-lt-"
  image_id      = var.ami_id
  instance_type = var.instance_type

  iam_instance_profile {
    name = var.instance_profile
  }

  key_name = var.key_name

  user_data = base64encode(templatefile("${path.module}/cloud-init.tpl", {}))

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [var.ec2_sg]
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "GoGreenApp"
      Environment = "Production"
    }
  }
}

resource "aws_autoscaling_group" "asg" {
  name                      = "gogreen-asg"
  desired_capacity          = 2
  max_size                  = 4
  min_size                  = 2
  vpc_zone_identifier       = [var.private_subnet_a, var.private_subnet_b]
  launch_template {
    id      = aws_launch_template.gogreen_lt.id
    version = "$Latest"
  }

  target_group_arns = [var.target_group_arn]

  health_check_type         = "EC2"
  health_check_grace_period = 60

  tag {
    key                 = "Name"
    value               = "GoGreenAppInstance"
    propagate_at_launch = true
  }
}
