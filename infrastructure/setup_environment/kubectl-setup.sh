#!/bin/bash

# Download Kubectl binary release
curl -LO https://dl.k8s.io/release/v1.21.0/bin/linux/amd64/kubectl

# Download Kubectl checksum
curl -LO https://dl.k8s.io/v1.21.0/bin/linux/amd64/kubectl.sha256

# Run checksum again kubectl
echo "$(<kubectl.sha256) kubectl" | sha256sum --check

# Install kubectl
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Display kubectl client version
kubectl version --client