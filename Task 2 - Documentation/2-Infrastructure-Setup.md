# Task 2 - Infrastructure development

The infrastructure developed majorly with AWS VPC and EKS terraform modules. The only custom module used, **null-resources** was for execution of commands within terraform. To develop and deploy this infrastructure, the following workflow was adopted:
1. Navigate to **infrastructure** directory.
2. Setup of remote backend: The remote backend is used tp staore the state of terraformm infrastructure. To setup the remote backend, the following was done:
    - Create a new directory, **backend-config** to hold the resources for creating the remote backend. Its best practise to separate the backend configuration file deployment from the main infrastructure deployment to avoid accidentally deleting the remote backend state file before the destroying the infrastructure.
    The contents of the **backend-config/** are **main.tf**, **providers.tf** and **outputs.tf**.
    - On complete development of the remote backend configuration:
        - Download required terraform modules: `terraform init`
        - Check for desired deployment: `terraform plan`
        - Deploy remote backend resources: `terraform apply`
            Confirm application with `yes`.
3. Navigate back to the **infrastructure** directory. Create a directory called **terraform-kubernetes(EKS)**. This directory will hold all the files needed for EKS deployment. Naviagte into **terraform-kubernetes(EKS)**:
    - Setup all **.tf** files and modules required for EKS deployment:
        - There are 3 variables files, **variables.tf**, **variables-vpc.tf** and **variables-eks.tf** which are used for the provider, VPC and EKS respectively.
        - **outputs.tf**: the output of the eks cluster on successful deployment.
        - **main.tf**: contains modular configuration for VPC, EKS and Nginx-Ingress deployment deployments.
        - **local.tf**: local configurations used in **main.tf**.
        - **data.tf**: configuration to query eks cluster and availability zones.
        - **providers.tf**: configuration for terraform providers with integration of remote backend.
    - Create the modules directory **modules/null_resources**
        - Add the required configuration, for null_resource setup: **main.tf** and **variables.tf**
    - Now the EKS infrastucture has been developed, its ready for deployment:
        - Download required terraform modules: `terraform init`
        - Check for desired deployment: `terraform plan`
        - Deploy EKS cluster resources: `terraform apply`
            Confirm application with `yes`
4. To access the EKS cluster from the terminal:
`aws eks update-kubeconfig --name tblx-challenge-sre --region us-west-1`
The cluster kubeconfig file will be updated in `~/.kube/config`. This will grant `kubectl` permissions to communicate which the `EKS API server`
5. Confirm worker nodes:
`kubectl get nodes`