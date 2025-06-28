#!/bin/bash
yum update -y
yum install -y httpd
systemctl enable httpd
systemctl start httpd
echo "Welcome to GoGreen Web App on EC2 $(hostname -f)" > /var/www/html/index.htm