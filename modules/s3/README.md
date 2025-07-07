# S3 Module

This module creates an encrypted Amazon S3 bucket with a customer-managed KMS key.

**Why:**  
Securely store objects with encryption and controlled access from your EC2 instances.

**What it does:**  
- Creates a KMS key for bucket encryption  
- Creates an S3 bucket with server-side encryption using the KMS key  
- Blocks public access to the bucket  
- Attaches a bucket policy (modifiable) to grant access to EC2 instances or other principals  

**Inputs:**  
- `bucket_name`, `name_prefix`

**Outputs:**  
- Bucket name, ARN, and KMS Key ARN