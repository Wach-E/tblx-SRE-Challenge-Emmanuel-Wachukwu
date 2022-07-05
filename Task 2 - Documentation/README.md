# SRE Challenge - Task 2

### Objective
The objective of this task is to build the following infrastructure:
- Kubernetes cluster with two (2) worker nodes
- must expand worker pool automatically up to four (4) nodes
- custom network for pods, where pods can be accessed by VMs and/or services
- enable and setup the ingress service
- deploy the app from task 1 or, if it was not built, any webapp
- make sure the app is accessible through its ingress.

### Solution Decisions
**Kubernetes**: For this task I will be using a managed Kubernetes service on AWS, **Elastic Kubernetes Service**. My choice of a managed service is factored by: reduced overhead with control plane management, scalability of cloud environments, fast deployments and automatic user configuration among many others. I wrote an article on the introduction to Kubernetes [here](https://medium.com/ambassador-api-gateway/an-introduction-to-kubernetes-tutorial-370789e09505).

**Infrastructure as Code(IaC)**: Terraform is the infrastructure as code tool of choice. Terraform integrates with arious public cloud providers native infrastructure constructs and with higher flexibility compared to AWS native IaC too, CloudFormation.

**Monitoring**: Prometheus and Grafana duo will be used for Kubernetes infrastructure monitoring. Prometheus is great for scraping metrics from targets configured as jobs, aggregating those metrics, and storing them but for monitoring systems resources, Prometheus and Grafana are a great duo. 

**Infrastructure workflow**: The workflow for the development and deployment of this infrastructure (and application) are as follows:
- Setup infrastructure development environment.
- Infrastructure development.
- Development of application manifest files.
- Infrastucture monitoring

**Documentation**: This task was documented according to the workflow. The documentation files can be found in [Task 2 - Documentation]9https://github.com/Wach-E/tblx-SRE-Challenge-Emmanuel-Wachukwu/tree/develop/Task%202%20-%20Documentation).

**Git workflow**: The `github feature (task-*) workflow develop*` was implemented for this task. This task (task-2) was created from the **task-1** branch.

## Extra points implemented
- Task 2 depends on Task 1
- Remote Backend
- Infrastucture monitoring

