# VPC Module

This module creates a Virtual Private Cloud (VPC) with subnets, internet gateway, NAT gateways, and associated routing.

**Why:**  
A VPC provides an isolated network environment for your AWS resources, enabling secure and controlled communication within the cloud.

**What it does:**  
- Creates a new VPC  
- Creates public, private, and database subnets across multiple Availability Zones  
- Configures an Internet Gateway for public internet access  
- Creates NAT Gateways allowing private subnets to access the internet securely  
- Sets up route tables associating subnets with appropriate gateways  

**Inputs:**  
- `cidr_block`, `azs`, subnet CIDR blocks, etc.

**Outputs:**  
- IDs for the VPC, subnets, route tables, and gateways