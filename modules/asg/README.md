# ASG Module

This module creates an Auto Scaling Group (ASG) with Launch Template to run EC2 instances behind an ALB.

**Why:**  
Automatically scale compute capacity based on demand to maintain application availability.

**What it does:**  
- Creates a launch template with AMI, instance type, user-data (e.g., installs httpd), and IAM profile  
- Creates an ASG spanning selected subnets with desired scaling parameters  
- Registers instances with the provided ALB Target Group for load balancing  

**Inputs:**  
- Subnet IDs, security group ID, ALB target group ARN, IAM instance profile, AMI ID, instance type, key pair, scaling parameters, name prefix  

**Outputs:**  
- ASG name and metadata