﻿# SRE Challenge - Task 3

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

**Documentation**: This task was documented according to the workflow. The documentation files can be found in [Task 3 - Documentation](https://github.com/Wach-E/tblx-SRE-Challenge-Emmanuel-Wachukwu/tree/develop/Task%203%20-%20Documentation).

**Git workflow**: The `github feature (task-*) workflow develop*` was implemented for this task. This task (task-3) was created from the **task-2** branch.

## Extra points implemented
- All tasks are built and dependent on each other
- Role based access control implemented (RBAC)
