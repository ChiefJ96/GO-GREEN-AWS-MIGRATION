# ALB Module

This module creates an Application Load Balancer (ALB), target group, and listener.

**Why:**  
Distribute incoming application traffic across multiple EC2 instances to increase availability and fault tolerance.

**What it does:**  
- Creates an internet-facing ALB across public subnets  
- Defines a target group for backend instances on port 80 HTTP  
- Creates an HTTP listener forwarding traffic to the target group  

**Inputs:**  
- `vpc_id`, `public_subnet_ids`, `security_group_id`, `name_prefix`

**Outputs:**  
- ALB ARN, DNS name, and target group ARN