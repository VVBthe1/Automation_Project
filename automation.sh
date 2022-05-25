#!/bin/bash
set -e

#S3 bucket name
S3_BUCKET='upgrad-vivekbharos'

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
