# Security Groups Module

This module defines security groups (firewall rules) for various tiers such as web, application, and database servers.

**Why:**  
Security groups control inbound and outbound traffic to AWS resources, enforcing network security boundaries.

**What it does:**  
- Creates security groups for web servers (allow HTTP/HTTPS)  
- Creates security groups for app servers (allow traffic from web/to app on specific ports)  
- Creates security groups for databases (restrict incoming traffic from app tier only)  

**Inputs:**  
- `vpc_id`

**Outputs:**  
- Security Group IDs for use by EC2 instances and other resources