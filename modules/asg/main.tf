data "aws_ami" "default" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
  owners = ["amazon"]
}
resource "aws_launch_template" "this" {
  name_prefix   = "${var.name_prefix}-lt-"
  image_id      = data.aws_ami.default.id
  instance_type = var.instance_type
  
  # Only include key_name if it's provided and not null
  key_name = var.key_name != null && var.key_name != "" ? var.key_name : null

  iam_instance_profile {
    name = var.iam_instance_profile_name
  }

  network_interfaces {
    associate_public_ip_address = var.assign_public_ip
    security_groups             = [var.security_group_id]
    delete_on_termination       = true
  }

  user_data = base64encode(templatefile("${path.module}/user_data.sh.tpl", { name_prefix = var.name_prefix }))
  
  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${var.name_prefix}-instance"
    }
  }
}

resource "aws_autoscaling_group" "this" {
  name_prefix          = "${var.name_prefix}-asg-"
  max_size             = var.max_size
  min_size             = var.min_size
  desired_capacity     = var.desired_capacity
  vpc_zone_identifier  = var.subnet_ids
  
  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }
  
  target_group_arns = [var.target_group_arn]

  tag {
    key                 = "Name"
    value               = "${var.name_prefix}-asg-instance"
    propagate_at_launch = true
  }

  # Don't wait for ELB capacity - let instances start and register gradually
  min_elb_capacity = 0

  health_check_type         = "ELB"
  health_check_grace_period = 900  # 15 minutes for user data to complete
  
  # Add timeouts for instance replacement
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }
  
  # Increase wait timeout
  wait_for_capacity_timeout = "20m"

  # Optional scaling policies can be added here if desired
}