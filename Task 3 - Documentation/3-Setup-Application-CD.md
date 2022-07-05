# Task 3 - Application Continuous Deployment

In this part of the task, the focus is on deploying the kubernetes manifest file using a pipeline job.

1. Kubectl requires a user to be able to make calls to the API server. For this, the `tblx-github-role` needs to be updated with the user. The user has to be there to provide short-lived tokens using AWS STS, so GitHub actions can assume that role. To satisfy this, the Trusted entity policy of the role must be edited to account for the user with `sts:TagSession` and `sts:AssumeRole` permissions. 
On the AWS Management console:
    - In the Trusted relationship of the role, edit the Trusted entity policy by adding the following statement:
    
    ```
            {
                "Sid": "",
                "Effect": "Allow",
                "Principal": {
                    "AWS": "arn:aws:iam::</account-id>:user/terraform_username"
                },
                "Action": [
                    "sts:AssumeRole",
                    "sts:TagSession"
                ]
            }
    ```

    - In the authentication user, add an inline IAM Policy as the JSON format:
    
    ```
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Sid": "",
                "Effect": "Allow",
                "Action": [
                    "sts:AssumeRole",
                    "sts:TagSession"
                ],
                "Resource": [
                    "arn:aws:iam::</account-id>:role/tblx-github-role"
                ]
            }
        ]
    }
    ```

N/B: The configuration done in the CI/CD task allowed `tblx-github-role` assume the role of the kubernetes creator user. Just in case the normal authentication technique does not work in the server, use: `aws eks update-kubeconfig --name tblx-challenge-sre --region us-west-1 --role-arn arn:aws:iam::</your-account-id>:role/tblx-github-role` as suggested [here](https://aws.amazon.com/premiumsupport/knowledge-center/eks-api-server-unauthorized-error/)

2. Add a the step to apply the manifest files to the kubernetes cluster:

```
      - name: Apply new deployment manifest
        run: |
          cd infrastructure/"terraform-kubernetes(EKS)"/manifests
          kubectl apply -f .
          sleep 60
          kubectl get ing -n daimler-truck
```

Now, the complete pipeline should look like this:

```
# CI/CD Pipeline for Task 3

name: Daimler-Truck WebApp CI/CD

# Controls when the workflow will run.
on:
  # Triggers the workflow on push and pull_request events for the develop branch.
  push:
    branches: [develop]
  pull_request:
    branches: [develop]

permissions:
  # Allow the OIDC JWT ID token to be requested
  id-token: write
  # Allow OIDC use the “checkout” action
  contents: read

env:
  AWS_REGION: us-west-1
  ASSUME_ROLE_ARN: ${{ secrets.AWS_ROLE_ARN }}
  EKS_CLUSTER_NAME: ${{ secrets.EKS_CLUSTER_NAME }}

jobs:
  test:
    runs-on: ubuntu-20.04
    steps:
      - uses: actions/checkout@v2
      - name: Set up Python
        uses: actions/setup-python@v2
        with:
          python-version: 3.8
      - name: Install dependencies
        run: |
          cd app
          python -m pip install --upgrade pip
          pip install -r requirements.txt
      - name: Test python application with pytest
        run: |
          pytest

  build_deploy:
    needs: [test]
    runs-on: ubuntu-20.04
    steps:
      - name: checkout
        uses: actions/checkout@v2
      - name: Build and push
        id: docker-build
        env:
          USER: ${{ secrets.DOCKERHUB_USERNAME }}
        run: |
          cd app
          export IMAGE_TAG=$(git rev-parse --short HEAD)
          echo ${{ secrets.DOCKERHUB_PASSWORD }} | docker login -u ${USER} --password-stdin

          docker build --platform linux/amd64 -t sre-tblx .
          docker tag sre-tblx ${USER}/sre-tblx:${IMAGE_TAG}
          docker push ${USER}/sre-tblx:${IMAGE_TAG}

  deploy_eks_infrastructure:
    needs: [build_deploy]
    runs-on: ubuntu-20.04
    steps:
      - name: Check Out
        uses: actions/checkout@v2
      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v1
        with:
          role-to-assume: ${{ env.ASSUME_ROLE_ARN }}
          aws-region: ${{ env.AWS_REGION }}
      - name: Deploy EKS Cluster
        id: deploy-eks
        run: |
          # Install kubectl
          cd infrastructure/setup_environment
          ./kubectl-setup.sh

          # Deploy EKS cluster with IaC
          cd ../"terraform-kubernetes(EKS)"
          terraform init -input=false
          terraform apply --auto-approve

          # Obtain kube config from cluster
          aws eks update-kubeconfig --name ${{ env.EKS_CLUSTER_NAME }} --region ${{ env.AWS_REGION }}
      - name: Apply new deployment manifest
        run: |
          cd infrastructure/"terraform-kubernetes(EKS)"/manifests
          kubectl apply -f .
          sleep 60
          kubectl get ing -n daimler-truck

```

Now, the application is ready for deployment. Adding to stage, commiting changes and pushing to git will trigger the pipeline and deploy the specifications within the manifests files to the kubernetes cluster.
**Ingress enpoint**: `http://a3f22e1a582ec4c2b874e93012765739-1216251317.us-west-1.elb.amazonaws.com`
**route path**: `/api/v1/daimler_truck`

**Complete url**: `http://a3f22e1a582ec4c2b874e93012765739-1216251317.us-west-1.elb.amazonaws.com/api/v1/daimler_truck`

The latest version of the application goes to dockerhub and can be rolled out separated by modifying the manifest files. Here are my thoughts on my selected approaches:
- Best practise for kubernetes CD suggest that the latest tag should not be used in production which is why I purposely added a tag as opposed to leaving the tag empty for latest image pulling. The reason for this is because latest doesn't give easy visibilty for root cause analysis of issues.
- Specialized tools such as agrocd are best used for CD to kubernetes clusters and could be implemented with helm charts.