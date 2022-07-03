#!/bin/bash

# Install docker
sudo apt install docker.io -y

# Add ubuntu user to the docker group
sudo usermod -aG docker $USER

#  Allow access to docker by other applications 
sudo chmod 666 /var/run/docker.sock