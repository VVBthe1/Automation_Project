#!/bin/bash
set -e

name="Vivek"
#S3 bucket name
s3_bucket='upgrad-vivekbharos'

# Updating package details
echo "Updating package cache"
sudo apt update -y

# Checking apache2 installation
echo "Checking for apache2 installation"
if dpkg-query -l apache2
then
    # Already installed
    echo "apache2 is already installed"
else
    # installing apache2
    echo "Installing apache2"
    sudo apt install -y apache2
fi 

# Chcking if apache2 is running
if systemctl is-active --quiet apache2
then
    echo "apache2 process is already running."
else
    echo "Process is dead. Starting apache2"
    sudo service apache2 start
fi

# Chcking if apache2 service is enabled
if systemctl is-enabled --quiet apache2.service
then
    echo "apache2 service is enabled."
else
    echo "Service disabled. Enabling apache2 service"
    sudo systemctl enable apache2.service
fi

# compressing log files
timestamp=$(date '+%d%m%Y-%H%M%S')
tar_name="$name-httpd-logs-$timestamp.tar.gz"

echo "Creating log backup"
sudo tar -czvf "/tmp/$tar_name" /var/log/apache2/*.log

# install aws cli
echo "Installing awscli"
sudo apt install -y awscli

echo "Uploading to S3"
aws s3 cp "/tmp/$tar_name" "s3://$s3_bucket/$tar_name"

# Updating inventory file
echo "Checking inventory file"
inventory_file="/var/www/html/inventory.html"
spaces="&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"
if [ -e $inventory_file ]
then
    echo "Inventory file exists. Updating"
else
    echo "Creating inventory file"
    echo "<b>Log Type $spaces Time Created $spaces $spaces Type $spaces Size</b><br />" > $inventory_file
fi

echo "httpd-logs $spaces $timestamp $spaces tar.gz $spaces $(du -sh /tmp/$tar_name | awk '{print $1}')<br />" >> $inventory_file

# Creating cron entry
# Updating inventory file
echo "Making/Replacing CRON entry"
echo "0 0 * * * root /root/Automation_Project/automation.sh" > /etc/cron.d/automation

echo "Finished execution. Terminating."