#!/bin/bash
# Log all output
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

echo "Starting user data script..."

# Update the system
sudo yum update -y

# Install and start Apache
echo "Installing Apache..."
sudo yum install -y httpd

echo "Starting Apache service..."
sudo systemctl start httpd
sudo systemctl enable httpd

# Create a simple test page
echo "Creating test page..."
echo "<html><body><h1>Hello from ${name_prefix} ASG instance</h1><p>Instance is healthy and ready to serve traffic!</p><p>Timestamp: $(date)</p></body></html>" | sudo tee /var/www/html/index.html

# Create a health check endpoint
echo "OK" | sudo tee /var/www/html/health

# Ensure proper permissions
sudo chown -R apache:apache /var/www/html/
sudo chmod -R 644 /var/www/html/

# Test that Apache is serving content
sleep 15
curl -f http://localhost/ || echo "Warning: Apache not responding yet"
curl -f http://localhost/health || echo "Warning: Health check not responding yet"

# Ensure Apache is running
sudo systemctl status httpd

echo "User data script completed successfully!"