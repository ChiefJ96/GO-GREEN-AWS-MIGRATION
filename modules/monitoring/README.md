# Monitoring Module

This module configures CloudWatch Alarms and SNS for email notifications on key metrics.

**Why:**  
Proactively monitor application and database health, getting alerted on CPU spikes, low usage, or storage issues.

**What it does:**  
- Creates an SNS topic and email subscription  
- Sets CloudWatch alarms for ASG CPU High/Low thresholds  
- Sets CloudWatch alarms for RDS CPU usage and free storage space  
- Sends alerts to configured email via SNS  

**Inputs:**  
- Email address, ASG name, RDS DB identifier, name prefix

**Outputs:**  
- SNS topic ARN