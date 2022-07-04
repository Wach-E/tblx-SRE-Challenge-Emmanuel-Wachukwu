#!/bin/bash

# Download the installation file
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"

# Install unzip package
sudo apt update
sudo apt install unzip

# Unzip the installer
unzip awscliv2.zip

# Run the install program
sudo ./aws/install

# Confirm sucessful installation of aws cli
aws --version