# SRE Challenge - Task 1

### Objective
Build an application with an API endpoint that receives a path from Wikipedia, [fetches](https://en.wikipedia.org/wiki/Special:ApiSandbox#action=parse&format=json&page=Word_list&prop=wikitext) its content and returns its [word list](https://en.wikipedia.org/wiki/Word_list). 

The app:
- may use any technology stack but must run on Linux
- must be containerized

### Solution Decisions
**Wikimedia/Wikipedia**: Wikimedia has 6 major apis used for data content collection as described [here](https://www.mediawiki.org/wiki/API:Main_page). The Wikipedia Mediawiki API would have been great for this task except for the fact that it returns data is in an unstrutured form when using either `parse` or `query` **actions** and the data type of `xml` and `json` limits the data collected as it lacks identifiers for direct data collection. Considering the scope of this application would need to consume only **one** Wikipedia webpage, **Daimler Truck**, I thought it be a better approach to directly request the webpage url and transform it into the wordlist.

**Programming Language**: From my previous experience with the Wikimedia Foundation, **Python** works best for most of her projects. Although, the final solution of this application has no direct dependence on Wikimedia but, at the early stage of developing this application where I used the MediaWiki API, python seemed to integrate best with most of Wikidata projects and hence, my choice of programming language.

**Framework**: To keep this appliction simple, I built the api endpoint using Flask. [Flask](https://flask.palletsprojects.com/en/2.1.x/) is a lightweight python framework used for the development of web applications.

**Container Technology**: Docker was used as the container technology for this task.

**Testing**: Pytest was used for running unit tests of the application api.

**Monitoring**: Application logging was used as a monitoring solution for this task. The Python logging module was used to write logs to a specific file. This decision was made with the consideration of the indirect approach to application logging (logging agent -> backend server -> visualization tool). 
The application logs could be retrieved by a **logging agent** such as Filebeat (by Elastic), Promtail (by Grafana) fluentd, Fluent Bit etc., transferred  to **storage backends** such as Elasticsearch (by Elastic), Logstash (by Elastic; processing only, no storage), Loki (by Grafana) and visualized in a **UI** such as Kibana (the UI for Elasticsearch), Grafana (supports different backends) etc.

**Application development workflow**: The workflow for the development of this application are as follows:
- Setup of development environment.
- Setup of virtual environment.
- Application development

**Documentation**: This task was documented according to the workflow. The documentation files can be found in [Task 1 - Documentation](https://github.com/Wach-E/tblx-SRE-Challenge-Emmanuel-Wachukwu/tree/task-1/Task%201%20-%20Documentation).

**Git workflow**: The `github feature (task-*) workflow develop*` was implemented for this task. This task (task-1) was created from the **development** branch.

## Extra points implemented
- Application logging
- Unit test


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

**Documentation**: This task was documented according to the workflow. The documentation files can be found in [Task 2 - Documentation](https://github.com/Wach-E/tblx-SRE-Challenge-Emmanuel-Wachukwu/tree/task-2/Task%202%20-%20Documentation).

**Git workflow**: The `github feature (task-*) workflow develop*` was implemented for this task. This task (task-2) was created from the **task-1** branch.

## Extra points implemented
- Task 2 depends on Task 1
- Remote Backend
- Infrastucture monitoring

# SRE Challenge - Task 3

### Objective
The objective of this task is to build a CI/CD pipeline with:
- CI that tests the app from task 1, if it was built, or any other app
- CI that tests the code from task 2 if it was built, or any other IaC
- CD that deploys the IaC from the CI stage
- CD that deploys the webapp from task 1  if it was built, or any other code
- pipeline that runs when there are code changes


### Solution Decisions
**CI/CD**: My CI/CD tool of choice is Github Actions. Github Actions is a Cloud agnostic continuous integration / continuous delivery tool that solves the problem of on-prem server overhead and public cloud vendor lock-in by offering integration with any type of cloud provider while abstracting server provisioning. Github Action pipelines are called workflows.

**Role based access (RBA)**: The deployment of EKS infrastructure to AWS using terraform requires user/role based authetication. In this task, I used OpenID Connect (ODIC) to authorize Github Actions to deploy infrastructure to AWS as well as to act as an assumed user to deploy the application manifests to the EKS cluster.

**CI/CD workflow**: The workflow for the continuous integration and continuous deployment pipeline for the web application and EKS infrastructure are as follows:
- Test application code.
- Build and deploy application artifact to Dockerhub.
- Deploy EKS infrastructure.
- Deploy application manifest to EKS cluster.

**Documentation**: This task was documented according to the workflow. The documentation files can be found in [Task 3 - Documentation](https://github.com/Wach-E/tblx-SRE-Challenge-Emmanuel-Wachukwu/tree/task-3/Task%203%20-%20Documentation).

**Git workflow**: The `github feature (task-*) workflow develop*` was implemented for this task. This task (task-3) was created from the **task-2** branch.

## Extra points implemented
- All tasks are built and dependent on each other
- Role based access control implemented (RBAC)
