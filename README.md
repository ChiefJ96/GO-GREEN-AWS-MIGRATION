Web Tier: ALB fronting EC2 Auto Scaling Group in public subnets behind NAT Gateways
Application Tier: Another ALB + ASG of EC2 instances in private subnets
Database Tier: RDS master + read replica each in private isolated subnets
S3 bucket as central storage
CloudWatch for monitoring
WAF protecting the ALB
Plus security groups for each tier and autoscaling groups
How to make this infrastructure complete but still beginner-friendly for Terraform
Key design decisions to keep it clear and functional:
Use 2 AZs for high availability with public/private subnets per AZ
Create NAT Gateways in each public subnet for private subnet outbound internet access
Use separate ALBs for web and app tier for clear separation
Use security groups per tier allowing necessary traffic between tiers securely
Keep things modular: separate vpc, security_groups, alb, asg, rds, s3, waf, cloudwatch modules
Use minimal but sufficient IAM roles for EC2 to access S3
Auto Scaling Groups for Web and App tier
Setup CloudWatch alarms on ALBs (e.g., HTTP 5xx errors) sending alerts via SNS
Terraform Architectural Overview
 copy
javascript

root/
|-- main.tf       # ties all modules and passes variables
|-- variables.tf
|-- outputs.tf
|-- modules/
    |-- vpc/
    |-- alb/
    |-- asg/
    |-- security_groups/
    |-- rds/
    |-- s3/
    |-- waf/
    |-- cloudwatch/
Summary for each module:
1. VPC Module
Create VPC 10.0.0.0/16
Public subnets: 10.0.0.0/24, 10.0.16.0/24
Private subnets: 10.32.0.0/24, 10.48.0.0/24 (App Tier)
Database subnets: 10.64.0.0/24, 10.80.0.0/24 (DB Tier)
Internet Gateway attached
NAT Gateways in each public subnet for private subnet access to internet
Public and private route tables with routes accordingly
Simple Network ACLs allowing HTTP/HTTPS/SSH where appropriate or left open for simplicity
2. Security Groups Module
Web Tier SG: Allows inbound HTTP/HTTPS from anywhere, outbound to App Tier SG on app ports
App Tier SG: Allows inbound from Web Tier SG, outbound to DB SG and to S3 endpoints
DB Tier SG: Allows inbound only from App Tier SG on DB port 5432
Allow outbound internet as needed
3. IAM Module
EC2 IAM Role with policy to allow read/write access to the designated S3 bucket
Attach to launch templates for Web and App EC2 ASGs
4. ALB Module (Web Tier and App Tier separately)
Application Load Balancers in public subnets
Listeners on HTTP/HTTPS for Web Tier ALB
Listeners on HTTP for App Tier ALB
Target groups pointing to respective ASGs
5. ASG Module
Two ASGs
Web Tier ASG with EC2 instances in public subnets behind NAT Gateway (or in private subnets with public IPs? Here, public subnets per diagram)
App Tier ASG with EC2 instances in private subnets
Minimum 1, Desired 2, Max 3 instances (configurable)
Use user_data to install a simple web server returning "Hello from <tier>"
6. RDS Module
Primary RDS PostgreSQL in private subnet (10.64.0.0/24)
Read replica in private subnet (10.80.0.0/24)
RDS subnet group covering database subnets
DB security group allowing inbound from App Tier SG only
7. S3 Module
Single bucket
Server-side encryption with KMS key created in S3 module
Attach bucket policy allowing EC2 role access
8. CloudWatch Module
Create SNS Topic for alerts
CloudWatch Metric alarm on ALB 5xx errors
Subscribe email or Slack webhook URL to SNS (can be configured externally)
9. WAF Module
Web ACL associated with the Web Tier ALB
Basic rules (e.g., AWS managed core rule set)