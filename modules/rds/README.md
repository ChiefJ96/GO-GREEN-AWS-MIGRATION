# RDS Module

This module provisions a PostgreSQL RDS primary instance with a read replica in private subnets.

**Why:**  
Deploy a scalable and highly available database for your applications in a secure, private network.

**What it does:**  
- Creates DB subnet group for proper multi-AZ deployment  
- Creates RDS primary DB instance with specified config (version, storage, engine)  
- Creates a read replica for read scalability  
- Associates security group to control access  

**Inputs:**  
- Private subnet IDs, security group ID, DB name, username, password, instance class, engine version, etc.

**Outputs:**  
- Primary and read replica endpoints