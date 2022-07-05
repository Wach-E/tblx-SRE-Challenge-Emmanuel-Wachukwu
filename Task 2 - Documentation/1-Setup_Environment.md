# Task 2 - Setup Environment

For the purpose of this task, the following tools were additionally selected:
- Helm: Helm is the `npm` for kubernetes and will be used to deploy microservices to the Kubernetes cluster.
- Kubectl: Kubernetes client (cli) tool used to administer changes to the Kubernetes cluster. 
- AWS cli: aws (client) for terminal cloud enginneering.
- Terraform: IaC tool used for provisioning, modifyig and destroying cloud infrastructure.

To setup the linux environment for EKS deployment, the above needs to be installed:
1. Create a directory for setup files:
`mkdir -p infrastructure/setup_environment`
2. Navigate to the setup_environment directory:
`cd infrastructure/setup_environment`
3. Create the setup script for awscli `nano awscli-setup.sh`
```
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
```
Change the permission mode for `awscli-setup.sh` file:
`chmod 700 awscli-setup.sh`
ker-setup.sh` file:
4. Create the setup script for kubectl `nano kubectl-setup.sh`
```
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
```
Change the permission mode for `kubectl-setup.sh` file:
`chmod 700 kubectl-setup.sh`
5. Create the setup script for terraform `nano terraform-setup.sh`
```
#!/bin/bash

# Ensure that your system is up to date, and install the gnupg, software-properties-common, and curl packages . 
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common curl
# You will use these packages to verify HashiCorp's GPG signature, and install HashiCorp's Debian package repository.

# Add the HashiCorp GPG key
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -

# Add the official HashiCorp Linux repository
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"

# Update to add the repository, and install the Terraform CLI
sudo apt-get update && sudo apt-get install terraform

# Confirm the installation worked
terraform -version
```
Change the permission mode for `terraform-setup.sh` file:
`chmod 700 terraform-setup.sh`
6. Create the setup script for helm `nano helm-setup.sh`:
```
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
```
Change the permission mode for `helm-setup.sh` file:
`chmod 700 helm-setup.sh`
7. Run the shell script to setup the 5 core tools:
```
./awscl-setup.sh
./helm-setup.sh
./kubectl-setup.sh
./terraform-setup.sh
```
8. To use AWS locally, an IAM user was created in AWS Management console with admin priviledges and configured in Linux environment. This configuration can be done in two ways:
- Creating an IAM role, attaching it to a user and adding it as an instance profile. This is best practise when working with a shared server. This will be observed when we get to task 3.
- Running `aws configure` with the iam user `access-id` and `secret-access-key`. This is best used when working solely on an EC2 server. Since this take is an individual kind, I will use this method here.

