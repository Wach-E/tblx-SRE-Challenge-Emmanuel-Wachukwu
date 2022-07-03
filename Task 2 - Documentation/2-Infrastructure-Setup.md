The infrastructure setup was created using majorly AWS VPC and EKS terraform modules as well as custom modules. To have this infrastructure setup, the following workflow was adopted:
- Create a new directory for infrastructure, `infrastructure` to hold all the infrastructure files.
- Setup remote backend using the configuration in `backend-config/` directory.
- Deploy remote backend resources isolated from the EKS deployment.
- Create the directory, `terraform-kubernetes(EKS)` to hold the IaC files for EKS deployment.
- Setup VPC infrastructure for Worker nodes using AWS VPC module. For the purpose of EKS deployment, it is required that certain configurations must be set in the VPC as shown in the `main.tf` of the `terraform-kubernetes(EKS)` directory.
- Setup EKS control plane using AWS EKS module configured for autoscaling worker nodes.
- Configure local execution to update cluster kubeconfig and install nginx ingress controller (with kubectl) from the null resource.
- Configure variables based on its usage (general, VPC, EKS, etc) as well as locals.

On successful development of the infrastructure as code:
- Install the required modules:
 `terraform init`
 - Check for expected deployments:
 `terraform plan`
 - Deploy the infrastructure using 
 `terraform apply --auto-approve`

To access the kubernetes cluster from the terminal:
`aws eks update-kubeconfig --name tblx-challenge-sre --region us-west-1`
The cluster kubeconfig file will be updated in ~/.kube/config which will give access to communication between `kubectl` and `EKS API server`
Confirm nodes setup properly:
`kubectl get nodes`
