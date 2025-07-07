# IAM Module

This module creates an IAM Role and Instance Profile for EC2 instances.

**Why:**  
Grant EC2 instances least-privilege permissions needed to interact with AWS services such as S3 and CloudWatch for logging and metrics.

**What it does:**  
- Creates an IAM Role that EC2 can assume  
- Attaches policy granting S3 read/write and CloudWatch access  
- Creates instance profile to attach the role to EC2 instances

**Inputs:**  
- `name_prefix` - prefix for resource names

**Outputs:**  
- IAM role and instance profile names/ARNs